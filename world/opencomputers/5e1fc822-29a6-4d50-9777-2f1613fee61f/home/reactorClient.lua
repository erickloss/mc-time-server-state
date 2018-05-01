local llm = require("llm")
local remoteApp = llm:require("remote-app")
local serialization = require("serialization")

return function(reactorProxyNetworkCardAddress, modem, reactorProxyPort)
    return remoteApp.createModemRemote("reactorClient",
        reactorProxyNetworkCardAddress,
        {
            getState = "getState",
            setAutoOn = "setAutoOn",
            setAutoOff = "setAutoOff",
            setAutoFuelInput = "setAutoFuelInput"
        },
        {
            reactorState = function(_, reactorState)
                local state = serialization.unserialize(reactorState)
                local appState = state.app
                local reactorState = state.reactor
                print("=== Reactor State ===")
                print("= Application:")
                print(string.format("= - Auto on active: %s", appState.autoOnActive and "Yes" or "No"))
                print(string.format("= - Auto off active: %s", appState.autoOffActive and "Yes" or "No"))
                print(string.format("= - Auto fuel input active: %s", appState.autoFuelInputActive and "Yes" or "No"))
                print("= Reactor:")
                print(string.format("= - Reactor active: %s", reactorState.active and "Yes" or "No"))
                print(string.format("= - Fuel amount: %d", reactorState.fuelAmount))
                print(string.format("= - Fuel reactivity: %.2f", reactorState.fuelReactivity))
                print(string.format("= - Fuel temperature: %.2f", reactorState.fuelTemperature))
                print(string.format("= - Fuel consumed last tick: %.5f", reactorState.fuelConsumedLastTick))
                print(string.format("= - Energy produced last tick: %d", reactorState.energyProducedLastTick))
                print(string.format("= - Energy stored (total): %.2f", reactorState.energyStoredTotal))
                print(string.format("= - Energy stored (percent): %.2f%%", reactorState.energyStoredPercent))
                print("=====================")
            end
        },
        modem,
        reactorProxyPort
    )
end