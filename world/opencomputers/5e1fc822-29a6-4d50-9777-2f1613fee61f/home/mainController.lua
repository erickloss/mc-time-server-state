local component = require("component")
local llm = require("llm")
local remoteApp = llm:require("remote-app")

local oreberryTowerClientFactory = require("oreberryTowerClient")
local reactorClientFactory = require("reactorClient")
local treeFarmClientFactory = require("treeFarmClient")

local mainGuiFactory = require("mainGui")

-- local devices
local modem = component.modem

-- clients
local oreberryProxyNetworkCardAddress = "6dd6031c-6701-4992-bd08-c66193069aee"
local oreberryProxyPort = 22
local oreberryTowerClient = oreberryTowerClientFactory(oreberryProxyNetworkCardAddress, modem, oreberryProxyPort)

local reactorProxyPort = 22
local reactorProxyNetworkCardAddress = "69741a99-fc55-43b0-83cc-44ae713896fa"
local reactorClient = reactorClientFactory(reactorProxyNetworkCardAddress, modem, reactorProxyPort)

local treeFarmProxyPort = 22
local treeFarmProxyNetworkCardAddress = "d588505f-fec9-4137-8f6a-5ec153d70957"
local treeFarmClient = treeFarmClientFactory(treeFarmProxyNetworkCardAddress, modem, treeFarmProxyPort)

local function _startClients()
    oreberryTowerClient.start()
    reactorClient.start()
    treeFarmClient.start()
end

local function cliMode(...)
    local executors = {
        oreberryTower = remoteApp.createGenericExecutor(oreberryTowerClient),
        reactor = remoteApp.createGenericExecutor(reactorClient),
        treeFarm = remoteApp.createGenericExecutor(treeFarmClient),
    }

    local args = { ... }
    local context = args[1]
    if context ~= nil then
        print("[local]: context '" .. context .. "'")
        table.remove(args, 1)
        local executor = executors[context]
        if executor == nil then
            print("Invalid context " .. context)
        else
            executor(table.unpack(args))
        end
    end
end

local function guiMode()
    local gui = mainGuiFactory()
    gui:start()
    while true do
        gui:update()
        os.sleep(0.5)
    end
end

_startClients()
if os.getenv("CLI_MODE") ~= nil then
    cliMode(...)
else
    guiMode()
end