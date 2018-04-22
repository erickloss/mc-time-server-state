local component = require("component")
local colors = require("colors")
local sides = require("sides")
local redstone = component.redstone

local arguments = {...}
if (arguments[1]) then
  if (arguments[1] == "on") then
    redstone.setOutput(sides.bottom, 15)
    print("Fuel input enabled")
  else
    redstone.setOutput(sides.bottom, 0)
    print("Fuel input disabled")
  end
else
  print("use 'on' or 'off' parameter")
end