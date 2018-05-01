local llm = require("llm")
local remoteApp = llm:require("remote-app")
local component = require("component")
local serialization = require("serialization")

-- local tunnel address: 07e4a8b1-b838-400d-ad56-1f94176cb900
local proxyTunnelCardAddress = "1de8ef40-b92b-4054-bfc4-52751f84d8ec"
local gathererEnergyAddress = "5053fdb4-300b-4e16-9b5a-b16962d76f0b"
local gathererInventoryAddress = "dfb5c100-ded0-4927-a14c-fae1cc7c2052"
local sowerEnergyAddress = "d3e13023-cc57-4ef2-93ed-8ce864e29390"
local sowerInventoryAddress = "42a3376a-272e-4888-9266-9f76ea6a1840"
local dimensionalTransceiverEnergyAddress = "b5eb2dd7-bd99-4771-a163-b2c8ba6d0f07"
local dimensionalTransceiverInventoryAddress = "5ada7c92-f25a-466c-b30a-1715ef5e3166"
local saplingStorageAddress = "86e42a41-6072-483d-83a3-a0fece899f93"

local function calculateEnergyStoredInPercent(energyDevice)
    return (energyDevice.getEnergyStored() / energyDevice.getMaxEnergyStored()) * 100
end

local gathererEnergyAdapter = component.proxy(gathererEnergyAddress)
local sowerEnergyAdapter = component.proxy(sowerEnergyAddress)

local function getTreeFarmState()
    return {
        gatherer = {
            energyStoredInPercent = calculateEnergyStoredInPercent(gathererEnergyAdapter)
        },
        sower = {
            energyStoredInPercent = calculateEnergyStoredInPercent(sowerEnergyAdapter)
        }
    }
end

local function _sendState(sender)
    sender("treeFarmState", serialization.serialize(getTreeFarmState()))
end

local remote = remoteApp.createTunnelRemote(
    "treeFarmControl",
    proxyTunnelCardAddress,
    {
        treeFarmState = _sendState
    }, {
    getState = _sendState
},
    component.tunnel
)

local executor = remoteApp.createGenericExecutor(remote)
executor(...)
