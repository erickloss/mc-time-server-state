local llm = require("llm")
local remoteApp = llm:require("remote-app")
local component = require("component")

local mainControlNetworkCardAddress = "0b01ffe8-daa0-4006-b5b7-7666fb3af599"
local treeFarmTunnelCardAddress = "07e4a8b1-b838-400d-ad56-1f94176cb900"
local proxyPort = 22

local proxy = remoteApp.createSimpleTunnelToModemProxy(
    "treeFarmProxy",
    treeFarmTunnelCardAddress,
    component.tunnel,
    mainControlNetworkCardAddress,
    component.modem,
    proxyPort
)


local executor = remoteApp.createGenericExecutor(proxy)
-- available commands: start, stop
executor(...)