local inet = require("internet")

local req = inet.request("https://api.github.com")
local serverJson = ""
for line in req do
  serverJson = serverJson .. line .. "\n"
end

print(serverJson)