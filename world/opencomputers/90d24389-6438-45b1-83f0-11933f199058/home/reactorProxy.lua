local component = require("component")
local llm = require("llm")
local remoteApp = llm:require("remote-app")

local proxyPort = 22
local reactorTunnelCardAddress = "54e208d7-764f-4e6a-8e12-1851d14042eb"
local mainControlNetworkCardAddress = "0b01ffe8-daa0-4006-b5b7-7666fb3af599"

local proxy = remoteApp.createSimpleTunnelToModemProxy(
    "reactorProxy",
    reactorTunnelCardAddress,
    component.tunnel,
    mainControlNetworkCardAddress,
    component.modem,
    proxyPort
)


local executor = remoteApp.createGenericExecutor(proxy)
-- available commands: start, stop
executor(...)