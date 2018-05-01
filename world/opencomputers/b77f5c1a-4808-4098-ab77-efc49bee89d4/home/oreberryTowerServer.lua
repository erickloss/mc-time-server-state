local llm = require("llm")
local remoteApp = llm:require("remote-app")
local component = require("component")
local sides = require("sides")
local serialization = require("serialization")

local oreberryProxyTunnelCardAddress = "6d28d35d-4b48-42ee-b653-8217a79e79ac"

local sideExport = sides.south
local sideGatherers = sides.east

local function getOreberryTowerState()
    return {
        exportActive = component.redstone.getOutput(sideExport) > 0,
        gatherersActive = component.redstone.getOutput(sideGatherers) > 0
    }
end

local _activateRedstone = function(side, description)
    if (component.redstone.getOutput(side) < 255) then
        component.redstone.setOutput(side, 255)
        print(description .. " activated")
        return true
    else
        print(description .. " is already activated")
        return false
    end
end

local _deactivateRedstone = function(side, description)
    if (component.redstone.getOutput(side) > 0) then
        component.redstone.setOutput(side, 0)
        print(description .. " deactivated")
        return true
    else
        print(description .. " is already deactivated")
        return false
    end
end

local function _sendState(sender)
    sender("oreberryTowerState", serialization.serialize(getOreberryTowerState()))
end

local function _setExport(sender, enabled)
    if enabled == "true" or enabled == "1" or enabled == "on" then
        if _activateRedstone(sideExport, "Dimensional Transceiver") then
            _sendState(sender)
        end
    else
        if _deactivateRedstone(sideExport, "Dimensional Transceiver") then
            _sendState(sender)
        end
    end
end

local function _setGatherers(sender, enabled)
    if enabled == "true" or enabled == "1" or enabled == "on" then
        if _activateRedstone(sideGatherers, "Oreberry Bush Gatherers") then
            _sendState(sender)
        end
    else
        if _deactivateRedstone(sideGatherers, "Oreberry Bush Gatherers") then
            _sendState(sender)
        end
    end
end

local remote = remoteApp.createTunnelRemote(
    "oreberryTower_server",
    oreberryProxyTunnelCardAddress,
    {
        oreberryTowerState = _sendState
    }, {
        getState = _sendState,
        setExport = _setExport,
        setGatherers = _setGatherers
    },
    component.tunnel
)

local executor = remoteApp.createGenericExecutor(remote)

local function main(...)
    remote.start()
    local args = {...}
    if args[1] == "setExport" then
        _setExport(remote.send, args[2])
    elseif args[1] == "setGatherers" then
        _setGatherers(remote.send, args[2])
    else
        executor(...)
    end
end

main(...)