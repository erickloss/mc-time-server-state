local component = require("component")
local reactorGuiApi = require("reactorGui")
local reactor = component.br_reactor
local reactorServerApi = require("reactorServer")
-- reactor proxy tunnel card
local reactorProxyAddress = "2c8108f3-a8be-4a11-a333-fd7f2a153adc"

-- state for the reactor controller application
local state = {
    autoOnEnabled = true,
    autoOffEnabled = true
}

local autoOnModel = {
    get = function() return state.autoOnEnabled end,
    set = function(value)
        print(value)
        print(state.autoOnEnabled)
        if not (state.autoOnEnabled == value) then
            state.autoOnEnabled = value
            reactorRemote.reactorState()
        end
    end
}

local autoOffModel = {
    get = function() return state.autoOffEnabled end,
    set = function(value)
        if not (state.autoOffEnabled == value) then
            state.autoOffEnabled = value
            reactorRemote.reactorState()
        end
    end
}

local function _calculateEnergyStoredInPercent(reactor)
    local stored = reactor.getEnergyStored()
    if stored > 0 then
        return reactor.getEnergyCapacity() / stored
    else
        return 0
    end
end

-- read only
local reactorStateModel = {
    get = function() return {
        active = reactor.getActive(),
        fuelAmount = reactor.getFuelAmount(),
        fuelReactivity = reactor.getFuelReactivity(),
        fuelTemperature = reactor.getFuelTemperature(),
        fuelConsumedLastTick = reactor.getFuelConsumedLastTick(),
        energyProducedLastTick = reactor.getEnergyProducedLastTick(),
        energyStoredTotal = reactor.getEnergyStored(),
        energyStoredPercent = _calculateEnergyStoredInPercent(reactor)
    } end
}

reactorRemote = reactorServerApi.createServer(
    reactorProxyAddress,
    component.tunnel,
    reactorStateModel,
    autoOnModel,
    autoOffModel
)

function autoOff()
    if (reactor.getActive() and reactor.getEnergyStored() > 2000000) then
        reactor.setActive(false)
        print("Internal energy buffer max. threshold reached; reactor deactivated")
    end
end

function autoOn()
    if (not reactor.getActive() and reactor.getEnergyStored() < 50000) then
        reactor.setActive(true)
        print("Internal energy buffer min. threshold reached; reactor activated")
    end
end

function runReactorControl()
    component.gpu.setResolution(64, 22)
    local gui = reactorGuiApi.create(reactorStateModel, autoOnModel, autoOffModel)
    reactorRemote.start()
    while true do
        if state.autoOffEnabled then autoOff() end
        if state.autoOnEnabled then autoOn() end
        gui.update()
    end
end

runReactorControl()