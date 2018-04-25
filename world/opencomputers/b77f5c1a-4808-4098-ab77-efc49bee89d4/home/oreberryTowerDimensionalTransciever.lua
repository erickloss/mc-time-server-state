local component = require("component")
local sides = require("sides")

local namedArgs = require("named-args")({...})

local function _setRestoneByParam(side, paramName, description)
  local activeArg = namedArgs[paramName]
  if activeArg then
	if activeArg == "true" or activeArg == "1" or activeArg == "on" then
		if (component.redstone.getOutput(side) < 255) then
			component.redstone.setOutput(side, 255)
			print(description .. " activated")
		else 
			print(description .. " is already activated")
		end
	else
		if (component.redstone.getOutput(side) > 0) then
			component.redstone.setOutput(side, 0)
			print(description .. " deactivated")
		else 
			print(description .. " is already deactivated")
		end
	end
  end
end

local function main()
  _setRestoneByParam(sides.east, "export", "Dimensional Transceiver")
  _setRestoneByParam(sides.south, "gatherers", "Oreberry Bush Gatherers")
end

main()