local remoteAppApi = require("remote-app")
local serialization = require("serialization")

local reactorServerApi = {}
reactorServerApi.createServer = function(reactorProxyAddress, tunnel, reactorStateModel, autoOnModel, autoOffModel)
    local function _sendState(sender)
        sender("reactorState", serialization.serialize({
            reactor = reactorStateModel.get(),
            app = {
                autoOnActive = autoOnModel.get(),
                autoOffActive = autoOffModel.get()
            }
        }))
    end
    local serverRemote = remoteAppApi.createTunnelRemote("reactorServer",
        reactorProxyAddress,
        {
            reactorState = _sendState
        },
        {
            getState = _sendState,
            setAutoOn = function(_, enabled)
                autoOnModel.set(enabled == "true" or enabled == "1" or enabled == "on")
            end,
            setAutoOff = function(_, enabled)
                autoOffModel.set(enabled == "true" or enabled == "1" or enabled == "on")
            end
        },
        tunnel
    )
    return serverRemote
end
return reactorServerApi