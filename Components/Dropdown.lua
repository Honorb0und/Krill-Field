-- Components/Dropdown.lua
-- Dropdown supporting multi-select with checkboxes
local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, Dropdown)
    self.Title = opts.Title or "Dropdown"
    self.Description = opts.Description or ""
    self.Options = opts.Options or {}
    self.Default = opts.Default or (self.Options[1] and self.Options[1]) or nil
    self.MultiSelect = opts.MultiSelect or false
    self.Callback = opts.Callback or function(value) end
    self.Section = Section
    self.Library = Library
    self._selected = {}
    if self.Default then
        if self.MultiSelect and type(self.Default) == "table" then
            for _, v in ipairs(self.Default) do self._selected[v] = true end
        else
            self._selected[self.Default] = true
        end
    end

    local parent = Section._content
    local container = Instance.new("Frame")
    container.Name = "DropdownContainer_" .. self.Title
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local label = Instance.new("TextLabel", container)
    label.Name = "Label"
    label.Size = UDim2.new(1, -36, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.Text = self.Title
    label.TextXAlignment = Enum.TextXAlignment.Left

    local dropdownBtn = Instance.new("TextButton", container)
    dropdownBtn.Name = "DropdownBtn"
    dropdownBtn.AnchorPoint = Vector2.new(1, 0.5)
    dropdownBtn.Position = UDim2.new(1, -8, 0.5, 0)
    dropdownBtn.Size = UDim2.new(0, 140, 0, 28)
    dropdownBtn.BackgroundTransparency = 0.6
    dropdownBtn.Text = self:_getDisplayText()
    dropdownBtn.Font = Enum.Font.Gotham
    dropdownBtn.TextSize = 12
    dropdownBtn.BorderSizePixel = 0
    dropdownBtn.AutoButtonColor = true
    local corner = Instance.new("UICorner", dropdownBtn)

    local expanded = Instance.new("Frame")
    expanded.Name = "Expanded"
    expanded.Size = UDim2.new(0, 160, 0, 0)
    expanded.Position = UDim2.new(1, -148, 0, 38)
    expanded.BackgroundTransparency = 0.8
    expanded.Visible = false
    expanded.Parent = container
    local border = Instance.new("UIStroke", expanded); border.Thickness = 1; border.Transparency = 0.8

    -- create option entries in expanded
    local layout = Instance.new("UIListLayout", expanded)
    layout.Padding = UDim.new(0, 2)

    local function toggleOption(opt)
        if self.MultiSelect then
            self._selected[opt] = not self._selected[opt]
        else
            self._selected = {}
            self._selected[opt] = true
            expanded.Visible = false
        end
        dropdownBtn.Text = self:_getDisplayText()
        pcall(function() self.Callback(self:GetValue()) end)
    end

    for _, opt in ipairs(self.Options) do
        local optBtn = Instance.new("TextButton", expanded)
        optBtn.Size = UDim2.new(1, -8, 0, 26)
        optBtn.Position = UDim2.new(0, 4, 0, 0)
        optBtn.BackgroundTransparency = 0.6
        optBtn.Text = tostring(opt)
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 12
        optBtn.AutoButtonColor = true
        optBtn.BorderSizePixel = 0
        optBtn.MouseButton1Click:Connect(function()
            toggleOption(opt)
        end)
    end

    dropdownBtn.MouseButton1Click:Connect(function()
        expanded.Visible = not expanded.Visible
        if expanded.Visible then
            -- size to fit
            local count = #self.Options
            expanded.Size = UDim2.new(0, 160, 0, math.clamp(count * 28 + 6, 28, 220))
        else
            expanded.Size = UDim2.new(0, 160, 0, 0)
        end
    end)

    self._container = container
    self._dropdownBtn = dropdownBtn
    self._expanded = expanded

    return self
end

function Dropdown:_getDisplayText()
    local arr = {}
    for _, opt in ipairs(self.Options) do
        if self._selected[opt] then table.insert(arr, tostring(opt)) end
    end
    if #arr == 0 then
        return tostring(self.Default or "Select")
    end
    if self.MultiSelect then
        return table.concat(arr, ", ")
    else
        return arr[1]
    end
end

function Dropdown:GetValue()
    local arr = {}
    for k,v in pairs(self._selected) do if v then table.insert(arr, k) end end
    if self.MultiSelect then return arr else return arr[1] end
end

function Dropdown:SaveState()
    return { Type = "Dropdown", Title = self.Title, Selected = self:GetValue() }
end

function Dropdown:LoadState(state)
    if not state then return end
    self._selected = {}
    if type(state.Selected) == "table" then
        for _, v in ipairs(state.Selected) do self._selected[v] = true end
    elseif state.Selected then
        self._selected[state.Selected] = true
    end
    if self._dropdownBtn then self._dropdownBtn.Text = self:_getDisplayText() end
end

return {
    new = function(opts, Section, Library) return Dropdown.new(opts, Section, Library) end
}
