-- Components/Keybind.lua
-- Captures a key and provides callback when pressed (supports modifier capture)
local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, Keybind)
    self.Title = opts.Title or "Keybind"
    self.Description = opts.Description or ""
    self.Default = opts.Default or Enum.KeyCode.F
    self.Callback = opts.Callback or function(key) end
    self.Section = Section
    self.Library = Library
    self._boundKey = self.Default

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "KeybindContainer_" .. self.Title
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

    local keyBtn = Instance.new("TextButton", container)
    keyBtn.Name = "Key"
    keyBtn.AnchorPoint = Vector2.new(1, 0.5)
    keyBtn.Position = UDim2.new(1, -8, 0.5, 0)
    keyBtn.Size = UDim2.new(0, 90, 0, 24)
    keyBtn.BackgroundTransparency = 0.6
    keyBtn.Text = tostring(self._boundKey.Name)
    keyBtn.Font = Enum.Font.Gotham
    keyBtn.TextSize = 12
    keyBtn.BorderSizePixel = 0
    keyBtn.AutoButtonColor = true
    local listening = false
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "Press key..."
        local conn
        conn = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self._boundKey = input.KeyCode
                keyBtn.Text = tostring(self._boundKey.Name)
                listening = false
                conn:Disconnect()
            end
        end)
    end)

    -- Global listener for bound key
    game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == self._boundKey then
                pcall(function() self.Callback(self._boundKey) end)
            end
        end
    end)

    self._container = container
    self._keyBtn = keyBtn

    return self
end

function Keybind:SaveState()
    return { Type = "Keybind", Title = self.Title, Bound = tostring(self._boundKey) }
end

function Keybind:LoadState(state)
    if state and state.Bound then
        -- Attempt to parse Enum.KeyCode from string like "Enum.KeyCode.F"
        local kName = tostring(state.Bound):gsub("Enum.KeyCode.", "")
        for i = 0, 255 do
            local kk = Enum.KeyCode:GetEnumItems()[i]
            if kk and kk.Name == kName then
                self._boundKey = kk
                if self._keyBtn then self._keyBtn.Text = kk.Name end
                break
            end
        end
    end
end

return {
    new = function(opts, Section, Library) return Keybind.new(opts, Section, Library) end
}
