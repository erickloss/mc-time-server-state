local component = require("component")
local sides = require("sides")
local event = require("event")
local serialization = require("serialization")

local namedArgs = require("named-args")({...})

local sideExport = sides.south
local sideGatherers = sides.east

local function _doOnParamPresent(paramName, action)
  local argValue = namedArgs[paramName]
  if argValue then
    action(argValue)
  end
end

_activateRedstone = function(side, description)
	if (component.redstone.getOutput(side) < 255) then
		component.redstone.setOutput(side, 255)
		print(description .. " activated")
		return true
	else 
		print(description .. " is already activated")
		return false
	end
end

_deactivateRedstone = function(side, description)
	if (component.redstone.getOutput(side) > 0) then
		component.redstone.setOutput(side, 0)
		print(description .. " deactivated")
		return true
	else 
		print(description .. " is already deactivated")
		return false
	end
end

local function _setRestoneByParam(side, paramName, description)
  _doOnParamPresent(paramName, function(paramValue)
	if paramValue == "true" or paramValue == "1" or paramValue == "on" then
		_activateRedstone(side, description)
	else
		_deactivateRedstone(side, description)
	end
  end)
end

local getOreberryTowerState = function()
	return {
		exportActive = component.redstone.getOutput(sideExport) > 0,
		gatherersActive = component.redstone.getOutput(sideGatherers) > 0
	}
end

local remoteAccessCallback = function(event, a, b, c, d, command, payload)
	if command == "get_state" then
		print("remote: get state")
		component.tunnel.send("oreberry_tower_state", serialization.serialize(getOreberryTowerState()))
	end
	if command == "set_export" then
		print("remote: set export '" .. payload .. "'")
		if payload == "true" or payload == "1" or payload == "on" then
			_activateRedstone(sideExport, "Dimensional Transceiver")
		else
			_deactivateRedstone(sideExport, "Dimensional Transceiver")
		end
	end
	if command == "set_gatherers" then
		print("remote: set gatherers '" .. payload .. "'")
		if payload == "true" or payload == "1" or payload == "on" then
			_activateRedstone(sideGatherers, "Oreberry Bush Gatherers")
		else
			_deactivateRedstone(sideGatherers, "Oreberry Bush Gatherers")
		end
	end
end

local function _startRemoteAccess()
	if os.getenv("oreberryTower_remoteAccessCallbackID") == nil then
		local tunnel = component.tunnel
		os.setenv("oreberryTower_remoteAccessCallbackID", event.listen("modem_message", remoteAccessCallback))
		print("Remote access started")
	else
		print("Remote access already running")
	end
end

local function _stopRemoteAccess()
	if os.getenv("oreberryTower_remoteAccessCallbackID") == nil then
		print("Remote access not running")
	else
		event.cancel(tonumber(os.getenv("oreberryTower_remoteAccessCallbackID")))
		os.setenv("oreberryTower_remoteAccessCallbackID", nil)
		print("Remote access stopped")
	end
end

local function main()
  _setRestoneByParam(sideExport, "export", "Dimensional Transceiver")
  _setRestoneByParam(sideGatherers, "gatherers", "Oreberry Bush Gatherers")
  _doOnParamPresent("remote", function(remoteArgValue)
	if remoteArgValue == "true" or remoteArgValue == "1" or remoteArgValue == "on" then
		_startRemoteAccess()
	else
		_stopRemoteAccess()
	end
  end)
end

main()