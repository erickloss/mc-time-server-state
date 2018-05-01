local llm = require("llm")
local remoteApp = llm:require("remote-app")
local serialization = require("serialization")

return function(oreberryProxyNetworkCardAddress, modem, oreberryProxyPort)
    return remoteApp.createModemRemote("oreberryTowerClient",
        oreberryProxyNetworkCardAddress,
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
        modem,
        oreberryProxyPort
    )
end