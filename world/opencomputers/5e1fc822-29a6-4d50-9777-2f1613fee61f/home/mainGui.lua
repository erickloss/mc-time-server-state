local llm = require("llm")
local guiApi = llm:require("oc-gui-api")
local component = require("component")
local gpu = component.gpu

local HIDDEN_LAYER = 20
local BG_COLOR = 0x000000
local PRIM_COLOR = 0x00A508
local SEC_COLOR = 0xFF8C49


local SCREEN_DASHBOARD = "dashboard"
local SCREEN_REACTOR_OVERVIEW = "reactor_overview"


local function readAll(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()
    return content
end


local MainGui = {}
local MainGui_MT = {__index = MainGui }

function MainGui:new(initialActiveScreen, screenFactories)
    local new = {
        screens = {},
        screenFactories = screenFactories,
        activeScreen = nil,
        initialActiveScreen = initialActiveScreen
    }

    guiApi.initialize()

    local w, h = gpu.getResolution()
    new.screenBg = guiApi.rect_full(1, 1, w - 1, h - 1, HIDDEN_LAYER, BG_COLOR, BG_COLOR)
    return setmetatable(new, MainGui_MT)
end

function MainGui:start()
    for screenName, factory in pairs(self.screenFactories) do
        local screen = factory(self, HIDDEN_LAYER)
        screen:hide()
        self.screens[screenName] = screen
    end
    self:setActiveScreen(self.initialActiveScreen)
    guiApi.show()
end

function MainGui:update()
    self.screens[self.activeScreen]:update()
end

function MainGui:setActiveScreen(screenName)
    if screenName == nil or screenName == self.activeScreen then
        return
    end

    if self.activeScreen ~= nil then
        self.screens[self.activeScreen]:hide()
    end
    self.activeScreen = screenName
    self.screens[screenName]:show()
    self.screenBg.update()
    guiApi.update()
end

local Screen = {}
local Screen_MT = {__index = Screen }

function Screen:new(updateCallback)
    local new = {
        widgets = {},
        update = updateCallback
    }
    return setmetatable(new, Screen_MT)
end

function Screen:hide()
    for widgetName, w in pairs(self.widgets) do
        w.widget.changeLayer(HIDDEN_LAYER - 10)
    end
end

function Screen:show()
    for widgetName, w in pairs(self.widgets) do
        local layer = HIDDEN_LAYER + 12 + w.layerOffset
        w.widget.changeLayer(layer)
    end
end

function Screen:addWidget(name, widget, layerOffset)
    layerOffset = layerOffset or 0
    self.widgets[name] = {
        widget = widget,
        layerOffset = layerOffset
    }
end

------------------------------------------------------------

local function _createDefaultScreen(layer, updateFunction)
    local screen = Screen:new(updateFunction)
    local w, h = gpu.getResolution()
    local headerBg = guiApi.rect_full(1, 1, w - 1, 10, layer, SEC_COLOR, SEC_COLOR)
    screen:addWidget("headerBg", headerBg, 1)
    return screen
end

local function _updateDashboard()
end

local function _createDashboard(mainGui, layer)
    local w, h = guiApi.getResolution()
    local screen = _createDefaultScreen(layer, _updateDashboard, 0x0000ff)

    local function onTitleClick()
        mainGui:setActiveScreen(SCREEN_REACTOR_OVERVIEW)
    end
    local title = guiApi.labelbox(20, 2, 100, 8, layer, PRIM_COLOR, nil, onTitleClick, nil, readAll("/home/title.txt"))
    screen:addWidget("title", title, 2)
    return screen
end

local function _updateReactorOverview()
end

local function _createReactorOverview(mainGui, layer)
    local screen = _createDefaultScreen(layer, _updateReactorOverview, 0xff0000)
    local function onTitleClick()
        mainGui:setActiveScreen(SCREEN_DASHBOARD)
    end
    local title = guiApi.labelbox(100, 7, 20, 3, layer, PRIM_COLOR, nil, onTitleClick, nil, "REACTOR OVERVIEW")
    screen:addWidget("title", title, 2)
    return screen
end

local function mainGuiFactory()
    local screenFactories = {}
    screenFactories[SCREEN_DASHBOARD] = _createDashboard
    screenFactories[SCREEN_REACTOR_OVERVIEW] = _createReactorOverview
    return MainGui:new(SCREEN_DASHBOARD, screenFactories)
end

return mainGuiFactory