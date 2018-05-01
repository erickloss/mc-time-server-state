local component = require("component")
local serialization = require("serialization")
local remoteAppApi = require("remote-app")

local proxyPort = 22
-- oreberry tower server tunnel card
local remoteAddress = "6210b9ae-a963-4541-a110-cd4359b47717"
-- main controller network card
local clientAddress = "0b01ffe8-daa0-4006-b5b7-7666fb3af599"

local remote = remoteAppApi.createTunnelRemote("oreberryTowerProxy",
    remoteAddress,
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