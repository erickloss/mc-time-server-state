local component = require("component")
local reactorGuiApi = require("reactorGui")
local sides = require("sides")
local reactor = component.br_reactor
local reactorServerApi = require("reactorServer")

local reactorProxyTunnelCardAddress = "2c8108f3-a8be-4a11-a333-fd7f2a153adc"
-- local components
local fuelControlRedstoneAddress = "d09e8441-343f-432b-8c1f-ed6a2d4a0ccf"

-- state for the reactor controller application
local state = {
    autoOnEnabled = true,
    autoOffEnabled = true
}

local autoOnModel = {
    get = function() return state.autoOnEnabled end,
    set = function(value)
        if state.autoOnEnabled ~= value then
            state.autoOnEnabled = value
            reactorRemote.reactorState()
        end
    end
}

local autoOffModel = {
    get = function() return state.autoOffEnabled end,
    set = function(value)
        if state.autoOffEnabled ~= value then
            state.autoOffEnabled = value
            reactorRemote.reactorState()
        end
    end
}

local fuelControlRedstone = component.proxy(component.get(fuelControlRedstoneAddress))
local autoFuelInputModel = {
    get = function() return fuelControlRedstone.getOutput(sides.bottom) > 0 end,
    set = function(value)
        local currentRedstoneValue = fuelControlRedstone.getOutput(sides.bottom) > 0 and 255 or 0
        local redstoneValueToSet = value and 255 or 0
        if currentRedstoneValue ~= redstoneValueToSet then
            fuelControlRedstone.setOutput(sides.bottom, redstoneValueToSet)
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
    reactorProxyTunnelCardAddress,
    component.tunnel,
    reactorStateModel,
    autoOnModel,
    autoOffModel,
    autoFuelInputModel
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
    local gui = reactorGuiApi.create(reactorStateModel, autoOnModel, autoOffModel, autoFuelInputModel)
    reactorRemote.start()
    while true do
        if state.autoOffEnabled then autoOff() end
        if state.autoOnEnabled then autoOn() end
        gui.update()
    end
end

runReactorControl()