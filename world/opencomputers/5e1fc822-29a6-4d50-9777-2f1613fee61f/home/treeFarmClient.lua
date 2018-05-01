local llm = require("llm")
local remoteApp = llm:require("remote-app")
local serialization = require("serialization")

return function(treeFarmProxyNetworkCardAddress, modem, treeFarmProxyPort)
    return remoteApp.createModemRemote("treeFarmClient",
        treeFarmProxyNetworkCardAddress,
        {
            getState = "getState"
        },
        {
            treeFarmState = function(_, treeFarmState)
                local state = serialization.unserialize(treeFarmState)
                local gathererState = state.gatherer
                local sowerState = state.sower
                print("=== Tree Farm State ===")
                print("= gatherer:")
                print(string.format(" - Energy stored (percent): %.2f%%", gathererState.energyStoredInPercent))
                print("= sower:")
                print(string.format(" - Energy stored (percent): %.2f%%", sowerState.energyStoredInPercent))
            end
        },
        modem,
        treeFarmProxyPort
    )
end
