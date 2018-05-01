local function getOrInitDefaultEnv(key, default)
    if os.getenv(key) == nil then
        os.setenv(key, default)
    end
    return os.getenv(key)
end
local llmVersion = getOrInitDefaultEnv("LLM.VERSION", "master")
local baseUrl = "https://raw.githubusercontent.com/erickloss/oc-llm/" .. llmVersion

-- libraries
os.execute("wget -f " .. baseUrl .. "/llm.lua /lib/llm.lua")
os.execute("wget -f " .. baseUrl .. "/lib/json.lua /lib/json.lua")

-- binaries
os.execute("wget -f " .. baseUrl .. "/bin/llm-cli.lua /bin/llm.lua")

print("Lua Library Manager downloaded successfully")