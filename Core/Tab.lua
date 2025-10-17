-- Core/Tab.lua
-- Tab class: creates a tab entry in the left list and creates a page frame
local Tab = {}
Tab.__index = Tab

function Tab.new(opts, Window, Library)
    opts = opts or {}
    local self = setmetatable({}, Tab)
    self.Title = opts.Title or "Tab"
    self.Icon = opts.Icon or ""
    self.Window = Window
    self.Library = Library
    self.Sections = {}
    self._selected = false

    -- Create UI elements under window._tabsList and window._pages
    local tabsList = Window._tabsList
    local pages = Window._pages

    local entry = Instance.new("TextButton")
    entry.Name = "TabEntry_" .. self.Title
    entry.Text = "  " .. self.Title
    entry.TextSize = 14
    entry.Font = Enum.Font.Gotham
    entry.TextColor3 = Color3.fromRGB(215,215,215)
    entry.BackgroundTransparency = 1
    entry.Size = UDim2.new(1, 0, 0, 44)
    entry.Parent = tabsList
    entry.AutoButtonColor = false

    local page = Instance.new("Frame")
    page.Name = "TabPage_" .. self.Title
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Parent = pages
    page.Visible = false

    -- store references
    self._entry = entry
    self._page = page

    -- click selects tab
    entry.MouseButton1Click:Connect(function()
        self:Select()
    end)

    return self
end

-- Select this tab (deselect others)
function Tab:Select()
    -- deselect siblings
    for _, t in ipairs(self.Window.Tabs) do
        if t ~= self then
            t:_SetSelected(false)
        end
    end
    self:_SetSelected(true)
end

function Tab:_SetSelected(v)
    self._selected = v
    self._page.Visible = v
    if v then
        self._entry.TextColor3 = Color3.fromRGB(255,255,255)
        -- small fade animation on page
        pcall(function()
            local Tween = self.Library.Utils.Tween
            Tween.To(self._page, { BackgroundTransparency = 1 }, Tween.DefaultInfo)
        end)
    else
        self._entry.TextColor3 = Color3.fromRGB(200,200,200)
    end
end

-- Add a section to this tab
function Tab:AddSection(title)
    local SectionClass = self.Library.Core.Section
    local section = SectionClass.new(title, self, self.Library)
    table.insert(self.Sections, section)
    return section
end

-- Save tab state (names + child components)
function Tab:SaveState()
    local out = { Title = self.Title, Sections = {} }
    for _, s in ipairs(self.Sections) do
        if s and s.SaveState then
            table.insert(out.Sections, s:SaveState())
        end
    end
    return out
end

function Tab:LoadState(state)
    if not state then return end
    for i, sdata in ipairs(state.Sections or {}) do
        local s = self.Sections[i]
        if s and s.LoadState then
            pcall(function() s:LoadState(sdata) end)
        end
    end
end

return {
    new = function(opts, Window, Library) return Tab.new(opts, Window, Library) end
}
