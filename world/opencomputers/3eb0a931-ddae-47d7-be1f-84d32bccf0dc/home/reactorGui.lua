local computer = require("computer")
local gpu = require("component").gpu
local guiApi = require("gui")

-- reactor control GUI module
local reactorGuiApi = {}

function reactorGuiApi.create(reactorStateModel, autoOnModel, autoOffModel)
    local publicApi = {}
    -- error fallback
    publicApi.update = function(_) os.exit() end
    _createGui(publicApi, reactorStateModel, autoOnModel, autoOffModel)
    return publicApi
end

function _createGui(publicApi, reactorStateModel, autoOnModel, autoOffModel)
    local startTime = computer.uptime()
    print(string.format("Starting reactor GUI... (%i seconds since machine boot)", startTime))
    local w, h = gpu.getResolution()
    local gui = guiApi.newGui(1, 1, w - 1, h - 1, true)

    local titleLabel = guiApi.newLabel(gui, 2, 3, "Reactor Control")
    local statusLabel = guiApi.newLabel(gui, 3, 5, "Status: Starting ...")
    local uptimeLabel = guiApi.newLabel(gui, 3, 6, "Uptime: Starting ...")

    local hline1 = guiApi.newHLine(gui, 1, 7, w - 1)

    -- auto on checkbox
    local autoOnCheckbox
    local autoOnCheckboxCallback = function()
        local checked = guiApi.getCheckboxStatus(gui, autoOnCheckbox)
        print(string.format("Auto On: %s", checked and "Enabled" or "Disabled"))
        autoOnModel.set(checked)
    end
    autoOnCheckbox = _newLabeledCheckbox(gui, 3, 8, "Auto On (< 10%)", autoOnModel.get(), autoOnCheckboxCallback)
    -- auto off checkbox
    local autoOffCheckbox
    local autoOffCheckboxCallback = function()
        local checked = guiApi.getCheckboxStatus(gui, autoOffCheckbox)
        print(string.format("Auto Off: %s", checked and "Enabled" or "Disabled"))
        autoOffModel.set(checked)
    end
    autoOffCheckbox = _newLabeledCheckbox(gui, 3, 9, "Auto Off (> 90%)", autoOffModel.get(), autoOffCheckboxCallback)

    -- shutdown button
    local shutdownButtonCallback = function()
        computer.shutdown()
    end
    local shutdownButton = guiApi.newButton(gui, w - 12, h - 1, "Shutdown", shutdownButtonCallback)
    -- exit to OS button
    local exitButtonCallback = function()
        os.exit()
    end
    local exitButton = guiApi.newButton(gui, w - 20, h - 1, "Exit", exitButtonCallback)

    -- gui update function
    publicApi.update = function()
        local reactorState = reactorStateModel.get()
        --print "update"
        guiApi.runGui(gui)
        guiApi.setText(gui, statusLabel, string.format("Status: %s", reactorState.active and "Active" or "Not Active"), false)
        guiApi.setText(gui, uptimeLabel, string.format("Uptime: %i", computer.uptime() - startTime), false)
        guiApi.setCheckbox(gui, autoOnCheckbox, autoOnModel.get())
        guiApi.setCheckbox(gui, autoOffCheckbox, autoOffModel.get())
        guiApi.displayGui(gui)
    end
    print(string.format("Started reactor GUI after %i seconds", computer.uptime() - startTime))
    guiApi.clearScreen()
end

function _newLabeledCheckbox(gui, x, y, label, state, func)
    guiApi.newLabel(gui, x + 3, y, label)
    return guiApi.newCheckbox(gui, x, y, state, func)
end

return reactorGuiApi