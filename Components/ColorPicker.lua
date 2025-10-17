-- Components/ColorPicker.lua
-- Color picker with HSV wheel-esque UI (simplified), returns Color3
local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, ColorPicker)
    self.Title = opts.Title or "Color"
    self.Description = opts.Description or ""
    self.Default = opts.Default or Color3.new(1, 0, 0)
    self.Callback = opts.Callback or function(color) end
    self.Section = Section
    self.Library = Library

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "ColorPickerContainer_" .. self.Title
    container.Size = UDim2.new(1, 0, 0, 64)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(1, -96, 0, 18)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = self.Title
    label.TextXAlignment = Enum.TextXAlignment.Left

    local preview = Instance.new("Frame", container)
    preview.Name = "Preview"
    preview.AnchorPoint = Vector2.new(1, 0)
    preview.Position = UDim2.new(1, -8, 0, 2)
    preview.Size = UDim2.new(0, 64, 0, 48)
    preview.BackgroundColor3 = self.Default
    preview.BorderSizePixel = 0
    local pc = Instance.new("UICorner", preview)

    -- Simplified color selection: three sliders for R, G, B
    local sliders = {}
    local y = 22
    for i, channel in ipairs({"R","G","B"}) do
        local s = Instance.new("Frame", container)
        s.Name = "Slider_" .. channel
        s.Size = UDim2.new(1, -80, 0, 12)
        s.Position = UDim2.new(0, 8, 0, y)
        s.BackgroundTransparency = 0.6
        s.BorderSizePixel = 0
        local corner = Instance.new("UICorner", s)
        local fill = Instance.new("Frame", s)
        fill.Name = "Fill"
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BorderSizePixel = 0
        local knob = Instance.new("Frame", s)
        knob.Name = "Knob"
        knob.Size = UDim2.new(0, 10, 1, 0)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 6, 0.5, 0)
        local kc = Instance.new("UICorner", knob)
        y = y + 16
        table.insert(sliders, {Frame = s, Fill = fill, Knob = knob})
    end

    -- function to update preview and call callback
    local function updatePreviewFromRGB(rgb)
        preview.BackgroundColor3 = Color3.fromRGB(rgb[1], rgb[2], rgb[3])
        pcall(function() self.Callback(preview.BackgroundColor3) end)
    end

    -- Input handling for sliders
    for idx, sl in ipairs(sliders) do
        local dragging = false
        sl.Frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local x = input.Position.X
                local rel = math.clamp((x - sl.Frame.AbsolutePosition.X) / sl.Frame.AbsoluteSize.X, 0, 1)
                sl.Fill.Size = UDim2.new(rel, 0, 1, 0)
                sl.Knob.Position = UDim2.new(rel, 0, 0.5, 0)
                local rgb = {0,0,0}
                for i=1,3 do
                    local f = sliders[i]
                    rgb[i] = math.floor((f.Fill.Size.X.Scale * 255)+0.5)
                end
                updatePreviewFromRGB(rgb)
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local x = input.Position.X
                local rel = math.clamp((x - sl.Frame.AbsolutePosition.X) / sl.Frame.AbsoluteSize.X, 0, 1)
                sl.Fill.Size = UDim2.new(rel, 0, 1, 0)
                sl.Knob.Position = UDim2.new(rel, 0, 0.5, 0)
                local rgb = {0,0,0}
                for i=1,3 do
                    local f = sliders[i]
                    rgb[i] = math.floor((f.Fill.Size.X.Scale * 255)+0.5)
                end
                updatePreviewFromRGB(rgb)
            end
        end)
        sl.Frame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    -- initialize preview with default color
    local r,g,b = math.floor(self.Default.R*255), math.floor(self.Default.G*255), math.floor(self.Default.B*255)
    for i, v in ipairs({r,g,b}) do
        local pct = v/255
        sliders[i].Fill.Size = UDim2.new(pct, 0, 1, 0)
        sliders[i].Knob.Position = UDim2.new(pct, 0, 0.5, 0)
    end
    updatePreviewFromRGB({r,g,b})

    self._container = container
    self._preview = preview
    self._sliders = sliders

    return self
end

function ColorPicker:SaveState()
    local c = self._preview and self._preview.BackgroundColor3 or self.Default
    return { Type = "ColorPicker", Title = self.Title, Color = {c.r, c.g, c.b} }
end

function ColorPicker:LoadState(state)
    if not state or not state.Color then return end
    local r,g,b = unpack(state.Color)
    if self._preview then
        self._preview.BackgroundColor3 = Color3.new(r,g,b)
    end
end

return {
    new = function(opts, Section, Library) return ColorPicker.new(opts, Section, Library) end
}
