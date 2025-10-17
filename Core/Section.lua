-- Core/Section.lua
-- Section class: holds components inside a tab page
local Section = {}
Section.__index = Section

function Section.new(title, Tab, Library)
    local self = setmetatable({}, Section)
    self.Title = title or "Section"
    self.Tab = Tab
    self.Library = Library
    self.Components = {}

    -- Layout: a Frame inside the tab page
    local page = Tab._page

    local container = Instance.new("Frame")
    container.Name = "Section_" .. tostring(self.Title)
    container.Size = UDim2.new(1, -32, 0, 120)
    container.Position = UDim2.new(0, 16, 0, (#page:GetChildren() * 4)) -- naive stacking; better use UIListLayout
    container.BackgroundTransparency = 1
    container.Parent = page

    local label = Instance.new("TextLabel", container)
    label.Name = "SectionLabel"
    label.Size = UDim2.new(1, 0, 0, 22)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Text = self.Title
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.TextXAlignment = Enum.TextXAlignment.Left

    local content = Instance.new("Frame", container)
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 1, -28)
    content.Position = UDim2.new(0, 0, 0, 28)
    content.BackgroundTransparency = 1

    -- Give content a UIListLayout for components
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    self._container = container
    self._content = content

    return self
end

-- Generic Add component helpers: delegates to component modules in Library.Components
function Section:AddButton(opts)
    opts = opts or {}
    local comp = self.Library.Components.Button
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add button: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddToggle(opts)
    opts = opts or {}
    local comp = self.Library.Components.Toggle
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add toggle: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddSlider(opts)
    opts = opts or {}
    local comp = self.Library.Components.Slider
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add slider: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddKeybind(opts)
    local comp = self.Library.Components.Keybind
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add keybind: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddDropdown(opts)
    local comp = self.Library.Components.Dropdown
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add dropdown: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddColorPicker(opts)
    local comp = self.Library.Components.ColorPicker
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add colorpicker: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddInput(opts)
    local comp = self.Library.Components.Input
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add input: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddLabel(opts)
    local comp = self.Library.Components.Label
    local ok, c = pcall(function() return comp.new(opts, self, self.Library) end)
    if not ok then warn("Failed to add label: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

function Section:AddSeparator()
    local comp = self.Library.Components.Separator
    local ok, c = pcall(function() return comp.new(nil, self, self.Library) end)
    if not ok then warn("Failed to add separator: "..tostring(c)) end
    table.insert(self.Components, c)
    return c
end

-- Save state of section (delegates to components)
function Section:SaveState()
    local out = { Title = self.Title, Components = {} }
    for _, c in ipairs(self.Components) do
        if c.SaveState then
            pcall(function()
                table.insert(out.Components, c:SaveState())
            end)
        end
    end
    return out
end

function Section:LoadState(state)
    if not state then return end
    for i, sdata in ipairs(state.Components or {}) do
        local c = self.Components[i]
        if c and c.LoadState then
            pcall(function() c:LoadState(sdata) end)
        end
    end
end

return {
    new = function(title, Tab, Library) return Section.new(title, Tab, Library) end
}
