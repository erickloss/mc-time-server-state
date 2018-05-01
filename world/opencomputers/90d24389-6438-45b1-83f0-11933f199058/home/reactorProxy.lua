local component = require("component")
local serialization = require("serialization")
local remoteAppApi = require("remote-app")

local proxyPort = 22
-- reactor server tunnel card
local remoteAddress = "54e208d7-764f-4e6a-8e12-1851d14042eb"
-- main control network card
local clientAddress = "0b01ffe8-daa0-4006-b5b7-7666fb3af599"

local remote = remoteAppApi.createTunnelRemote("reactorProxy",
    remoteAddress,
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
    component.tunnel
)
local executor = remoteAppApi.createGenericExecutor(remote)
local proxy = remoteAppApi.createModemProxy(remote, clientAddress, component.modem, proxyPort)


local function main(...)
    remote.start()
    proxy.start()
    executor(...)
end

main(...)