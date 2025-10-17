-- Components/Separator.lua
-- Visual separator line
local Separator = {}
Separator.__index = Separator

function Separator.new(_, Section, Library)
    local self = setmetatable({}, Separator)
    self.Section = Section
    self.Library = Library

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "Separator"
    container.Size = UDim2.new(1, 0, 0, 8)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local line = Instance.new("Frame", container)
    line.Size = UDim2.new(1, -12, 0, 1)
    line.Position = UDim2.new(0, 6, 0.5, -0.5)
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0

    self._container = container
    return self
end

function Separator:SaveState()
    return { Type = "Separator" }
end

function Separator:LoadState(_) end

return {
    new = function(opts, Section, Library) return Separator.new(opts, Section, Library) end
}
