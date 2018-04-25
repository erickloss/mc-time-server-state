local component = require("component")
local event = require("event")
local serialization = require("serialization")

local args = {...}

local remoteActionCallback = function(_,_,_,_,_, command, payload)
  print("remote: " .. command)
  print(payload)
  for name, value in pairs(serialization.deserialize(payload)) do print(key .. ": " .. value) end
end

local function main()
	if os.getenv("oreberryTowerRemote_remoteActionCallbackID") == nil then
		os.setenv("oreberryTowerRemote_remoteActionCallbackID", event.listen("modem_message", remoteActionCallback))
	end
	
	print("[local]: executing command '" .. args[1] .. "")
	
	if args[1] == "get_state" then
		component.tunnel.send("get_state")
	elseif args[1] == "set_export" then
		component.tunnel.send("set_export", args[2])
	elseif args[1] == "set_gatherers" then
		component.tunnel.send("set_gatherers", args[2])
	elseif args[1] == "close" then
		event.close(os.getenv("oreberryTowerRemote_remoteActionCallbackID"))
		os.setenv("oreberryTowerRemote_remoteActionCallbackID", nil)
	end
end

main()