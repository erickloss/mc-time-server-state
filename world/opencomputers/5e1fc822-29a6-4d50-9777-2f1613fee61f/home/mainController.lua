local component = require("component")
local serialization = require("serialization")
local remoteAppApi = require("remote-app")

local oreberryProxyPort = 22
-- oreberry tower proxy (network card)
local oreberryProxyAddress = "6dd6031c-6701-4992-bd08-c66193069aee"

local reactorProxyPort = 22
-- reactor proxy (network card)
local reactorProxyAddress = "69741a99-fc55-43b0-83cc-44ae713896fa"

-- clients

local oreberryTowerClient = remoteAppApi.createModemRemote("oreberryTowerClient",
    oreberryProxyAddress,
    {
        getState = "getState",
        setExport = "setExport",
        setGatherers = "setGatherers"
    },
    {
        oreberryTowerState = function(_, oreberryTowerState)
            local state = serialization.unserialize(oreberryTowerState)
            print("=== Oreberry Tower State ===")
            print(string.format("Export active: %s", state.exportActive and "Yes" or "No"))
            print(string.format("Gatherers active: %s", state.gatherersActive and "Yes" or "No"))
        end
    },
    component.modem,
    oreberryProxyPort
)

local reactorClient = remoteAppApi.createModemRemote("reactorClient",
    reactorProxyAddress,
    {
        getState = "getState",
        setAutoOn = "setAutoOn",
        setAutoOff = "setAutoOff"
    },
    {
        reactorState = function(_, reactorState)
            local state = serialization.unserialize(reactorState)
            local appState = state.app
            local reactorState = state.reactor
            print("=== Application State ===")
            print(string.format("Auto on active: %s", appState.autoOnActive and "Yes" or "No"))
            print(string.format("Auto off active: %s", appState.autoOffActive and "Yes" or "No"))
            print("=== Reactor State ===")
            print(string.format("Reactor active: %s", reactorState.active and "Yes" or "No"))
            print(string.format("Fuel amount: %d", reactorState.fuelAmount))
            print(string.format("Fuel reactivity: %.2f", reactorState.fuelReactivity))
            print(string.format("Fuel temperature: %.2f", reactorState.fuelTemperature))
            print(string.format("Fuel consumed last tick: %.5f", reactorState.fuelConsumedLastTick))
            print(string.format("Energy produced last tick: %d", reactorState.energyProducedLastTick))
            print(string.format("Energy stored (total): %.2f", reactorState.energyStoredTotal))
            print(string.format("Energy stored (percent): %.2f", reactorState.energyStoredPercent))
        end
    },
    component.modem,
    reactorProxyPort
)

local executors = {
    oreberryTower = remoteAppApi.createGenericExecutor(oreberryTowerClient),
    reactor = remoteAppApi.createGenericExecutor(reactorClient)
}

local function main(...)
    oreberryTowerClient.start()
    reactorClient.start()

    local args = { ... }
    local context = args[1]
    print("[local]: context '" .. context .. "'")
    table.remove(args, 1)
    local executor = executors[context]
    if executor == nil then
        print("Invalid context " .. context)
    else
        executor(table.unpack(args))
    end
end

main(...)