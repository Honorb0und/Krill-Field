-- Components/Slider.lua
-- Slider with numeric value, callback, Increment, Min, Max
local Slider = {}
Slider.__index = Slider

function Slider.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, Slider)
    self.Title = opts.Title or "Slider"
    self.Description = opts.Description or ""
    self.Min = tonumber(opts.Min) or 0
    self.Max = tonumber(opts.Max) or 100
    self.Default = tonumber(opts.Default) or self.Min
    self.Increment = tonumber(opts.Increment) or 1
    self.Callback = opts.Callback or function(value) end
    self.Section = Section
    self.Library = Library

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "SliderContainer_" .. self.Title
    container.Size = UDim2.new(1, 0, 0, 56)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(1, -84, 0, 18)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = self.Title
    label.TextXAlignment = Enum.TextXAlignment.Left

    local valueText = Instance.new("TextLabel", container)
    valueText.Name = "Value"
    valueText.Size = UDim2.new(0, 72, 0, 18)
    valueText.Position = UDim2.new(1, -72, 0, 0)
    valueText.BackgroundTransparency = 1
    valueText.Font = Enum.Font.Gotham
    valueText.TextSize = 14
    valueText.TextColor3 = Color3.fromRGB(210,210,210)
    valueText.Text = tostring(self.Default)
    valueText.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", container)
    track.Name = "Track"
    track.Size = UDim2.new(1, -12, 0, 8)
    track.Position = UDim2.new(0, 6, 0, 26)
    track.BackgroundTransparency = 0.6
    track.BorderSizePixel = 0
    local trackCorner = Instance.new("UICorner", track); trackCorner.CornerRadius = UDim.new(0, 8)

    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new( (self.Default - self.Min) / math.max(1, (self.Max - self.Min)), 0, 1, 0)
    fill.AnchorPoint = Vector2.new(0,0)
    fill.Position = UDim2.new(0,0,0,0)
    fill.BackgroundTransparency = 0
    fill.BorderSizePixel = 0
    local fillCorner = Instance.new("UICorner", fill); fillCorner.CornerRadius = UDim.new(0,8)

    local knob = Instance.new("Frame", track)
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel = 0
    local knobCorner = Instance.new("UICorner", knob); knobCorner.CornerRadius = UDim.new(0, 16)

    local dragging = false
    local UIS = game:GetService("UserInputService")
    local function updateFromPos(x)
        local absolute = track.AbsoluteSize.X
        local relativeX = math.clamp((x - track.AbsolutePosition.X) / absolute, 0, 1)
        local rawVal = self.Min + (relativeX * (self.Max - self.Min))
        -- snap to increment
        if self.Increment > 0 then
            rawVal = math.floor((rawVal / self.Increment) + 0.5) * self.Increment
        end
        rawVal = math.clamp(rawVal, self.Min, self.Max)
        -- update visuals
        local pct = (rawVal - self.Min) / math.max(1, (self.Max - self.Min))
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valueText.Text = tostring(math.floor(rawVal*100)/100)
        pcall(function() self.Callback(rawVal) end)
        self._value = rawVal
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateFromPos(input.Position.X)
        end
    end)
    track.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromPos(input.Position.X)
        end
    end)

    -- initialize
    self._value = self.Default
    updateFromPos(track.AbsolutePosition.X + (fill.Size.X.Offset or 0))

    self._container = container
    self._track = track
    self._fill = fill
    self._knob = knob

    return self
end

function Slider:SaveState()
    return { Type = "Slider", Title = self.Title, Value = self._value }
end

function Slider:LoadState(state)
    if state and state.Value then
        self._value = state.Value
        if self._fill and self._knob then
            local pct = (state.Value - self.Min) / math.max(1, (self.Max - self.Min))
            self._fill.Size = UDim2.new(pct, 0, 1, 0)
            self._knob.Position = UDim2.new(pct, 0, 0.5, 0)
        end
        pcall(function() self.Callback(self._value) end)
    end
end

return {
    new = function(opts, Section, Library) return Slider.new(opts, Section, Library) end
}
