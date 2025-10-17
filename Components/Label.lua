-- Components/Label.lua
-- Simple label/paragraph display
local Label = {}
Label.__index = Label

function Label.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, Label)
    self.Title = opts.Title or ""
    self.Description = opts.Description or ""
    self.Section = Section
    self.Library = Library

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "LabelContainer"
    container.Size = UDim2.new(1, 0, 0, 24)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local text = Instance.new("TextLabel", container)
    text.Name = "Paragraph"
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.Gotham
    text.TextSize = 13
    text.TextColor3 = Color3.fromRGB(210,210,210)
    text.Text = self.Description or self.Title
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left

    self._container = container
    self._text = text

    return self
end

function Label:SaveState()
    return { Type = "Label", Title = self.Title, Text = self._text and self._text.Text or self.Description }
end

function Label:LoadState(state)
    if state and state.Text and self._text then
        self._text.Text = state.Text
    end
end

return {
    new = function(opts, Section, Library) return Label.new(opts, Section, Library) end
}
