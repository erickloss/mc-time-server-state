local function parseNamedArgs(args)
  local result = {}
  for index, arg in pairs(args) do
	local name, value = arg:gmatch("-(%w+)=(%w*)")()
	if name then result[name] = value end
  end
  return result
end

return parseNamedArgs