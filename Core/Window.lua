local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Window = {}
Window.__index = Window

function Window.new(title)
    local self = setmetatable({}, Window)
    self.Title = title or "Window"
    self.Minimized = false
    self.RestoreSize = nil
    self:CreateUI()
    return self
end

-- // Create the full GUI layout
function Window:CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KrillFieldWindow"
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui")

    -- Main frame
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 500, 0, 350)
    frame.Position = UDim2.new(0.5, -250, 0.5, -175)
    frame.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = false
    frame.Parent = screenGui
    self.Frame = frame

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, 36)
    topbar.BackgroundColor3 = Color3.fromRGB(45, 55, 80)
    topbar.BorderSizePixel = 0
    topbar.Parent = frame

    local barCorner = Instance.new("UICorner", topbar)
    barCorner.CornerRadius = UDim.new(0, 10)

    -- Title label
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = self.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topbar

    -- Buttons
    local buttonContainer = Instance.new("Frame")
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.AnchorPoint = Vector2.new(1, 0)
    buttonContainer.Position = UDim2.new(1, -6, 0, 4)
    buttonContainer.Size = UDim2.new(0, 80, 1, -8)
    buttonContainer.Parent = topbar

    local function createButton(name, text)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(60, 70, 95)
        btn.Size = UDim2.new(0, 24, 1, 0)
        btn.AutoButtonColor = false
        local c = Instance.new("UICorner", btn)
        c.CornerRadius = UDim.new(0, 6)
        btn.Parent = buttonContainer
        return btn
    end

    local minimizeButton = createButton("Minimize", "–")
    minimizeButton.Position = UDim2.new(0, 0, 0, 0)
    local closeButton = createButton("Close", "×")
    closeButton.Position = UDim2.new(0, 28, 0, 0)

    -- Content area
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -36)
    content.Position = UDim2.new(0, 0, 0, 36)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Parent = frame
    self.Content = content

    -- Resize corner
    local resizeCorner = Instance.new("Frame")
    resizeCorner.Size = UDim2.new(0, 14, 0, 14)
    resizeCorner.AnchorPoint = Vector2.new(1, 1)
    resizeCorner.Position = UDim2.new(1, 0, 1, 0)
    resizeCorner.BackgroundColor3 = Color3.fromRGB(80, 90, 120)
    resizeCorner.BorderSizePixel = 0
    resizeCorner.Active = true
    resizeCorner.Draggable = false
    resizeCorner.ZIndex = 5
    local rcCorner = Instance.new("UICorner", resizeCorner)
    rcCorner.CornerRadius = UDim.new(0, 3)
    resizeCorner.Parent = frame

    ----------------------------------------------------------------
    -- 🧭 DRAGGING
    ----------------------------------------------------------------
    do
        local dragging = false
        local dragStart, startPos
        topbar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    ----------------------------------------------------------------
    -- 📏 RESIZING
    ----------------------------------------------------------------
    do
        local resizing = false
        local startPos, startSize
        resizeCorner.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                startPos = input.Position
                startSize = frame.Size
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - startPos
                frame.Size = UDim2.new(
                    0,
                    math.clamp(startSize.X.Offset + delta.X, 300, workspace.CurrentCamera.ViewportSize.X - 40),
                    0,
                    math.clamp(startSize.Y.Offset + delta.Y, 200, workspace.CurrentCamera.ViewportSize.Y - 40)
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end

    ----------------------------------------------------------------
    -- 🔽 MINIMIZE / CLOSE
    ----------------------------------------------------------------
    minimizeButton.MouseButton1Click:Connect(function()
        self:ToggleMinimize()
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

function Window:ToggleMinimize()
    if not self.Frame then return end
    local content = self.Content

    if self.Minimized then
        content.Visible = true
        TweenService:Create(
            self.Frame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = self.RestoreSize or self.Frame.Size}
        ):Play()
        self.Minimized = false
    else
        self.RestoreSize = self.Frame.Size
        content.Visible = false
        TweenService:Create(
            self.Frame,
            TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Size = UDim2.new(self.Frame.Size.X.Scale, self.Frame.Size.X.Offset, 0, 44)}
        ):Play()
        self.Minimized = true
    end
end

return Window
