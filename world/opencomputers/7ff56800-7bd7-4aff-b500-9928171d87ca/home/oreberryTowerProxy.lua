local component = require("component")
local llm = require("llm")
local remoteApp = llm:require("remote-app")

local proxyPort = 22
-- oreberry tower server tunnel card
local oreberryTowerTunnelCardAddress = "6210b9ae-a963-4541-a110-cd4359b47717"
-- main controller network card
local mainControlNetworkCardAddress = "0b01ffe8-daa0-4006-b5b7-7666fb3af599"

local proxy = remoteApp.createSimpleTunnelToModemProxy(
    "oreberryTowerProxy",
    oreberryTowerTunnelCardAddress,
    component.tunnel,
    mainControlNetworkCardAddress,
    component.modem,
    proxyPort
)

local executor = remoteApp.createGenericExecutor(proxy)
-- available commands: start, stop
executor(...)