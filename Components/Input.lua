-- Components/Input.lua
-- Simple text input / textbox with callback
local Input = {}
Input.__index = Input

function Input.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, Input)
    self.Title = opts.Title or "Input"
    self.Description = opts.Description or ""
    self.Default = opts.Default or ""
    self.Callback = opts.Callback or function(text) end
    self.Section = Section
    self.Library = Library

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "InputContainer_" .. self.Title
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = self.Title
    label.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", container)
    box.Name = "Box"
    box.AnchorPoint = Vector2.new(1, 0.5)
    box.Position = UDim2.new(1, -8, 0.5, 0)
    box.Size = UDim2.new(0.48, 0, 0.6, 0)
    box.BackgroundTransparency = 0.6
    box.Text = self.Default
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.TextColor3 = Color3.fromRGB(230,230,230)
    box.ClearTextOnFocus = false
    box.BorderSizePixel = 0

    box.FocusLost:Connect(function(enter)
        if enter then
            pcall(function() self.Callback(box.Text) end)
        end
    end)

    self._container = container
    self._box = box

    return self
end

function Input:SaveState()
    return { Type = "Input", Title = self.Title, Text = self._box and self._box.Text or self.Default }
end

function Input:LoadState(state)
    if state and state.Text and self._box then
        self._box.Text = state.Text
    end
end

return {
    new = function(opts, Section, Library) return Input.new(opts, Section, Library) end
}
