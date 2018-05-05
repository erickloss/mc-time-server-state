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


local function readAsciiFont(file)
    local f = assert(io.open(file, "rb"))
    local content = f:read("*all")
    f:close()

    local width, height = 0, 0
    for line in content:gmatch("%\n") do
        width = string.len(line) > width and string.len(line) or width
        height = height + 1
    end

    return content, width, height
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
    local headerBg = guiApi.rect_full(1, 1, w - 1, 8, layer, SEC_COLOR, SEC_COLOR)
    screen:addWidget("headerBg", headerBg, 1)
    return screen
end

local function _updateDashboard()
end

local TILE_COLOR_INITIALIZING = { f = 0x000000, b = 0xffffff }
local TILE_COLOR_UP_AND_RUNNING = 0x000000
local TILE_COLOR_STOPPED = 0x000000
local TILE_COLOR_WARNING = 0x000000
local TILE_COLOR_ERROR = 0x000000
local function _dashboardTile(tileId, titleFile, targetScreen, xGrid, yGrid, layer, mainGui, screen, dashboardTitleH)
    local function onClick()
        mainGui:setActiveScreen(targetScreen)
    end
    local w, h = guiApi.getResolution()
    local tileW, tileH, spacingV, spacingH = math.floor(w / 5), math.floor((h - dashboardTitleH) / 4), 3, 1
    local tileX = (tileW + spacingV) * (xGrid - 1) + spacingV
    local tileY = (tileH + spacingH) * (yGrid - 1) + spacingH + dashboardTitleH
    local titleText, titleW, titleH = readAsciiFont(titleFile)
    -- box
    screen:addWidget(
        tileId .. "_tileBg",
        guiApi.rect_full(tileX, tileY, tileW, tileH, layer, TILE_COLOR_INITIALIZING.f, TILE_COLOR_INITIALIZING.b, onClick),
        1
    )
    -- label
    screen:addWidget(
        tileId .. "_label",
        guiApi.label(
            tileX + math.floor(tileW / 2) - math.ceil(titleW / 2),
            tileY + math.floor(tileH / 2) - math.ceil(titleH / 2),
            titleW,
            titleH,
            layer,
            TILE_COLOR_INITIALIZING.f,
            TILE_COLOR_INITIALIZING.b,
            onClick,
            nil,
            titleText
        ),
        2
    )

end

local function _createDashboard(mainGui, layer)
    local w, h = guiApi.getResolution()
    local screen = _createDefaultScreen(layer, _updateDashboard, 0x0000ff)

    -- main title ascii art
    local titleText, titleW, titleH = readAsciiFont("/home/title.txt")
    screen:addWidget("title", guiApi.labelbox(5, 2, 100, 6, layer, PRIM_COLOR, nil, nil, nil, titleText), 2)

    -- tiles
    _dashboardTile("reactorTile", "/home/reactorTileTitle.txt", SCREEN_REACTOR_OVERVIEW, 1, 1, layer, mainGui, screen, titleH)
    _dashboardTile("reactorTile2", "/home/reactorTileTitle.txt", SCREEN_REACTOR_OVERVIEW, 1, 2, layer, mainGui, screen, titleH)
    _dashboardTile("reactorTile3", "/home/reactorTileTitle.txt", SCREEN_REACTOR_OVERVIEW, 2, 1, layer, mainGui, screen, titleH)

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