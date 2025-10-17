-- Components/Toggle.lua
-- Toggle with state, callback, icon, description
local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, Toggle)
    self.Title = opts.Title or "Toggle"
    self.Description = opts.Description or ""
    self.Default = (opts.Default == nil) and false or opts.Default
    self.Callback = opts.Callback or function() end
    self.Section = Section
    self.Library = Library

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "ToggleContainer_" .. self.Title
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = self.Title
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggle = Instance.new("TextButton", container)
    toggle.Name = "Toggle"
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Position = UDim2.new(1, -8, 0.5, 0)
    toggle.Size = UDim2.new(0, 46, 0, 24)
    toggle.BackgroundTransparency = 0.6
    toggle.Text = ""
    toggle.AutoButtonColor = true
    toggle.BorderSizePixel = 0
    toggle.Font = Enum.Font.SourceSans

    local uic = Instance.new("UICorner", toggle); uic.CornerRadius = UDim.new(0,8)
    local knob = Instance.new("Frame", toggle)
    knob.Name = "Knob"
    knob.Size = UDim2.new(0.44, -2, 0.78, 0)
    knob.Position = UDim2.new(0.02, 0, 0.11, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.AnchorPoint = Vector2.new(0,0)
    knob.BorderSizePixel = 0
    local cornerK = Instance.new("UICorner", knob); cornerK.CornerRadius = UDim.new(0, 8)

    self._state = self.Default

    local function updateVisual(state)
        if state then
            toggle.BackgroundColor3 = Color3.fromRGB(86, 160, 255)
            knob:TweenPosition(UDim2.new(0.96 - knob.Size.X.Scale, -2, knob.Position.Y.Scale, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.16, true)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            knob:TweenPosition(UDim2.new(0.02, 0, knob.Position.Y.Scale, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.16, true)
        end
    end

    toggle.MouseButton1Click:Connect(function()
        self._state = not self._state
        updateVisual(self._state)
        pcall(function() self.Callback(self._state) end)
    end)

    -- initialize visual
    updateVisual(self._state)

    self._container = container
    self._toggle = toggle
    self._knob = knob

    return self
end

function Toggle:SaveState()
    return { Type = "Toggle", Title = self.Title, State = self._state }
end

function Toggle:LoadState(state)
    if state and state.State ~= nil then
        self._state = state.State
        -- reflect visually
        if self._toggle and self._knob then
            local knob = self._knob -- local reference
            if self._state then
                self._toggle.BackgroundColor3 = Color3.fromRGB(86, 160, 255)
                knob.Position = UDim2.new(0.96 - knob.Size.X.Scale, -2, knob.Position.Y.Scale, 0)
            else
                self._toggle.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
                knob.Position = UDim2.new(0.02, 0, knob.Position.Y.Scale, 0)
            end
        end
    end
end

return {
    new = function(opts, Section, Library) return Toggle.new(opts, Section, Library) end
}
