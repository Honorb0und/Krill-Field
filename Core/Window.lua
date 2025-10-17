-- Core/Window.lua
-- Main Window class for Krill Field
-- Exports: Window.new(opts, Library) -> returns Window instance with methods: AddTab, Destroy, Minimize, Maximize, SaveConfig, LoadConfig, etc.
-- Depends on UIHelpers, Tween, Parallax, Notification utilities passed via Library in loader

local Window = {}
Window.__index = Window

-- Constructor: opts, Library (injected by loader)
function Window.new(opts, Library)
    opts = opts or {}
    Library = Library or {}
    local self = setmetatable({}, Window)
    -- default options
    self.Title = opts.Title or "Krill Field"
    self.Size = opts.Size or UDim2.new(0, 700, 0, 480)
    self.Position = opts.Position or UDim2.new(0.5, -(self.Size.X.Offset/2), 0.5, -(self.Size.Y.Offset/2))
    self.Acrylic = (opts.Acrylic == nil) and true or opts.Acrylic
    self.Theme = opts.Theme or "Dark"
    self.MinimizeKey = opts.MinimizeKey or Enum.KeyCode.RightControl
    self.Library = Library

    -- State
    self.Tabs = {}
    self.Open = true
    self._connections = {}
    self._createdGui = nil

    -- Create UI
    local ok, err = pcall(function() self:_CreateGui() end)
    if not ok then
        error("[KrillField.Window] failed to create GUI: " .. tostring(err))
    end

    -- Theme application
    self:ApplyTheme(self.Theme)

    -- Bind MinimizeKey
    if self.MinimizeKey then
        local UserInputService = game:GetService("UserInputService")
        table.insert(self._connections, UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == self.MinimizeKey then
                self:ToggleMinimize()
            end
        end))
    end

    return self
end

-- Private helper: create ScreenGui and base elements
function Window:_CreateGui()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KrillField_Window_" .. tostring(math.random(1000,9999))
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 50
    screenGui.Parent = playerGui

    -- Main container
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "KrillField_Main"
    mainFrame.AnchorPoint = Vector2.new(0.5,0.5)
    mainFrame.Position = self.Position
    mainFrame.Size = self.Size
    mainFrame.BackgroundTransparency = 1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    mainFrame.ZIndex = 50

    -- Background panel (glass)
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.AnchorPoint = Vector2.new(0.5,0.5)
    panel.Size = UDim2.new(1, 0, 1, 0)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.BackgroundTransparency = 0
    panel.BorderSizePixel = 0
    panel.Parent = mainFrame
    panel.ZIndex = 51

    -- Apply glass look
    local UIHelpers = self.Library.Utils.UIHelpers
    UIHelpers.ApplyGlass(panel, {CornerRadius = 12, BackgroundTransparency = 0.32})

    -- Noise layer (image)
    local noise = UIHelpers.CreateNoise(panel, "rbxassetid://1665395372")
    noise.Name = "Panel_Noise"
    noise.ZIndex = 50
    noise.Parent = panel
    -- Track parallax
    pcall(function() self.Library.Utils.Parallax.Track(noise, {X = 0.08, Y = 0.06}) end)

    -- Topbar (title, drag)
    local topbar = Instance.new("Frame", panel)
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 44)
    topbar.Position = UDim2.new(0, 0, 0, 0)
    topbar.BackgroundTransparency = 1
    topbar.ZIndex = 60

    local title = Instance.new("TextLabel", topbar)
    title.Name = "Title"
    title.Text = self.Title
    title.TextSize = 16
    title.Font = Enum.Font.GothamSemibold
    title.TextColor3 = Color3.fromRGB(240,240,240)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0.5, -12, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left

    -- Right controls (minimize, close, theme)
    local controlsFrame = Instance.new("Frame", topbar)
    controlsFrame.Name = "Controls"
    controlsFrame.AnchorPoint = Vector2.new(1,0)
    controlsFrame.Position = UDim2.new(1, -12, 0, 8)
    controlsFrame.Size = UDim2.new(0, 120, 1, -16)
    controlsFrame.BackgroundTransparency = 1

    local buttonClose = Instance.new("TextButton", controlsFrame)
    buttonClose.Name = "Close"
    buttonClose.Size = UDim2.new(0, 36, 0, 28)
    buttonClose.Position = UDim2.new(1, -36, 0, 0)
    buttonClose.AnchorPoint = Vector2.new(1,0)
    buttonClose.Text = "✕"
    buttonClose.Font = Enum.Font.Gotham
    buttonClose.TextSize = 16
    buttonClose.BackgroundTransparency = 0.6
    buttonClose.AutoButtonColor = true
    buttonClose.BorderSizePixel = 0
    buttonClose.TextColor3 = Color3.fromRGB(240,240,240)
    buttonClose.ZIndex = 70
    local UICorner = Instance.new("UICorner", buttonClose); UICorner.CornerRadius = UDim.new(0,6)
    local closeStroke = Instance.new("UIStroke", buttonClose); closeStroke.Thickness = 1; closeStroke.Transparency = 0.7

    local buttonMin = buttonClose:Clone()
    buttonMin.Name = "Minimize"
    buttonMin.Text = "—"
    buttonMin.Parent = controlsFrame
    buttonMin.Position = UDim2.new(1, -76, 0, 0)

    local themeBtn = buttonClose:Clone()
    themeBtn.Name = "Theme"
    themeBtn.Text = "●"
    themeBtn.Parent = controlsFrame
    themeBtn.Position = UDim2.new(1, -116, 0, 0)
    themeBtn.TextSize = 12

    -- Content area (tabs + content panels)
    local content = Instance.new("Frame", panel)
    content.Name = "Content"
    content.Position = UDim2.new(0, 0, 0, 44)
    content.Size = UDim2.new(1, 0, 1, -44)
    content.BackgroundTransparency = 1

    -- Tabs list (left side)
    local tabsList = Instance.new("Frame", content)
    tabsList.Name = "TabsList"
    tabsList.Size = UDim2.new(0, 160, 1, 0)
    tabsList.Position = UDim2.new(0, 0, 0, 0)
    tabsList.BackgroundTransparency = 1

    -- Tab pages container
    local pages = Instance.new("Frame", content)
    pages.Name = "Pages"
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.new(0, 160, 0, 0)
    pages.Size = UDim2.new(1, -160, 1, 0)

    -- Resize handle bottom-right
    local resizeCorner = Instance.new("Frame", panel)
    resizeCorner.Name = "Resize"
    resizeCorner.Size = UDim2.new(0, 16, 0, 16)
    resizeCorner.AnchorPoint = Vector2.new(1,1)
    resizeCorner.Position = UDim2.new(1, -6, 1, -6)
    resizeCorner.BackgroundTransparency = 0.6
    resizeCorner.BorderSizePixel = 0
    resizeCorner.ZIndex = 80
    local rcCorner = Instance.new("UICorner", resizeCorner); rcCorner.CornerRadius = UDim.new(0,4)
    local dragDetector = Instance.new("ImageLabel", resizeCorner) -- UIDragDetector not always available; emulate with image and input
    dragDetector.Size = UDim2.new(1,0,1,0)
    dragDetector.BackgroundTransparency = 1
    dragDetector.ZIndex = 81
    dragDetector.Image = ""
    dragDetector.Name = "ResizeGrip"

    -- Save references
    self._screenGui = screenGui
    self._mainFrame = mainFrame
    self._panel = panel
    self._topbar = topbar
    self._titleLabel = title
    self._content = content
    self._tabsList = tabsList
    self._pages = pages
    self._resizeCorner = resizeCorner
    self._controlsFrame = controlsFrame
    self._buttonClose = buttonClose
    self._buttonMin = buttonMin
    self._themeBtn = themeBtn

    -- Interactivity: Drag window by topbar
    do
        local UserInputService = game:GetService("UserInputService")
        local dragging = false
        local dragStart = nil
        local startPos = nil
        local function onInputBegan(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = mainFrame.Position
            end
        end
        local function onInputChanged(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
        local function onInputEnded(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end
        topbar.InputBegan:Connect(onInputBegan)
        topbar.InputChanged:Connect(onInputChanged)
        topbar.InputEnded:Connect(onInputEnded)
    end

    -- Close & minimize handlers
    self._buttonClose.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    self._buttonMin.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)
    self._themeBtn.MouseButton1Click:Connect(function()
        -- cycle theme
        local nextTheme = "Default"
        if self.Theme == "Dark" then nextTheme = "Light"
        elseif self.Theme == "Light" then nextTheme = "Default"
        elseif self.Theme == "Default" then nextTheme = "Dark"
        end
        self:ApplyTheme(nextTheme)
    end)

    -- Resize handling (mouse drag)
    do
        local UserInputService = game:GetService("UserInputService")
        local dragging = false
        local startPos, startSize
        local function begin(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                startPos = input.Position
                startSize = mainFrame.Size
            end
        end
        local function move(input)
            if not dragging then return end
            local delta = input.Position - startPos
            local newX = math.clamp(startSize.X.Offset + delta.X, 300, workspace.CurrentCamera.ViewportSize.X - 40)
            local newY = math.clamp(startSize.Y.Offset + delta.Y, 200, workspace.CurrentCamera.ViewportSize.Y - 40)
            mainFrame.Size = UDim2.new(0, newX, 0, newY)
        end
        local function stop(input)
            dragging = false
        end
        resizeCorner.InputBegan:Connect(begin)
        resizeCorner.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                move(input)
            end
        end)
        UserInputService.InputEnded:Connect(stop)
    end

    -- Return screenGui to instance
    self._createdGui = screenGui
end

-- Apply theme by name (uses Library.Themes)
function Window:ApplyTheme(themeName)
    themeName = themeName or self.Theme or "Dark"
    local themeModule = self.Library.Themes[themeName] or self.Library.Themes.Default
    if type(themeModule) == "table" and themeModule.Apply then
        pcall(function()
            themeModule.Apply(self, self.Library)
            self.Theme = themeName
        end)
    else
        warn("[KrillField.Window] theme module missing Apply function; using default styling")
    end
end

-- Create and add a tab (returns Tab instance)
function Window:AddTab(opts)
    opts = opts or {}
    local TabClass = self.Library.Core.Tab
    local ok, tab = pcall(function()
        return TabClass.new(opts, self, self.Library)
    end)
    if not ok then
        error("[KrillField.Window] failed to create tab: " .. tostring(tab))
    end
    table.insert(self.Tabs, tab)
    return tab
end

-- Toggle minimize: shrink to topbar
function Window:ToggleMinimize()
    if not self._panel then return end
    if self._minimized then
        -- restore
        self._panel:TweenSize(self._restoreSize or self._panel.Size, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true)
        self._minimized = false
    else
        self._restoreSize = self._panel.Size
        self._panel:TweenSize(UDim2.new(self._panel.Size.X.Scale, self._panel.Size.X.Offset, 0, 44), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true)
        self._minimized = true
    end
end

-- Destroy the window and cleanup
function Window:Destroy()
    if self._createdGui and self._createdGui.Parent then
        self._createdGui:Destroy()
    end
    -- track cleanup functions (e.g., parallax)
    pcall(function() self.Library.Utils.Parallax.Stop() end)
    self._createdGui = nil
    -- disconnect stored connections
    for _,c in ipairs(self._connections) do
        pcall(function() c:Disconnect() end)
    end
    self._connections = {}
    self.Tabs = {}
    self.Open = false
end

-- Save & Load config helpers (delegates to Library.Utils.Config)
function Window:SaveConfig(name)
    local cfg = {
        Title = self.Title,
        Size = self._mainFrame and self._mainFrame.Size,
        Position = self._mainFrame and self._mainFrame.Position,
        Theme = self.Theme,
        -- gather tab/component state
        Tabs = {}
    }
    for _, tab in ipairs(self.Tabs) do
        if tab and tab.SaveState then
            table.insert(cfg.Tabs, tab:SaveState())
        end
    end
    self.Library.Utils.Config.Save(name, cfg)
end

function Window:LoadConfig(name)
    local cfg = self.Library.Utils.Config.Load(name)
    if not cfg then return end
    pcall(function()
        self.Title = cfg.Title or self.Title
        if cfg.Size and self._mainFrame then self._mainFrame.Size = cfg.Size end
        if cfg.Position and self._mainFrame then self._mainFrame.Position = cfg.Position end
        if cfg.Theme then self:ApplyTheme(cfg.Theme) end
        -- tabs
        for i, data in ipairs(cfg.Tabs or {}) do
            local tab = self.Tabs[i]
            if tab and tab.LoadState then
                pcall(function() tab:LoadState(data) end)
            end
        end
    end)
end

return {
    new = function(opts, Library) return Window.new(opts, Library) end
}
