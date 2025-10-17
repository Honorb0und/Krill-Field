-- Components/Button.lua
-- Simple button with callback, icon, tooltip, click ripple animation
local Button = {}
Button.__index = Button

function Button.new(opts, Section, Library)
    opts = opts or {}
    local self = setmetatable({}, Button)
    self.Title = opts.Title or "Button"
    self.Description = opts.Description or ""
    self.Icon = opts.Icon or ""
    self.Callback = opts.Callback or function() end
    self.Section = Section
    self.Library = Library

    local parent = Section._content

    local container = Instance.new("Frame")
    container.Name = "ButtonContainer_" .. self.Title
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.LayoutOrder = #parent:GetChildren()
    container.Parent = parent

    local btn = Instance.new("TextButton", container)
    btn.Name = "Button"
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 0.6
    btn.Text = self.Title
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(240,240,240)
    btn.AutoButtonColor = true
    btn.BorderSizePixel = 0

    -- Styles
    local UIHelpers = Library.Utils.UIHelpers
    UIHelpers.CreateCorner(btn, 6)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Transparency = 0.75
    stroke.Thickness = 1

    -- Tooltip (hover)
    if self.Description and self.Description ~= "" then
        local tip = Instance.new("TextLabel")
        tip.Name = "Tooltip"
        tip.Text = self.Description
        tip.Size = UDim2.new(0, 200, 0, 32)
        tip.AnchorPoint = Vector2.new(0,1)
        tip.BackgroundTransparency = 0.6
        tip.TextColor3 = Color3.fromRGB(220,220,220)
        tip.Font = Enum.Font.Gotham
        tip.TextSize = 12
        tip.Visible = false
        tip.Parent = container
        -- position update on hover
        btn.MouseEnter:Connect(function()
            tip.Position = UDim2.new(0, 0, 0, -8)
            tip.Visible = true
        end)
        btn.MouseLeave:Connect(function()
            tip.Visible = false
        end)
    end

    -- Ripple animation on click
    btn.MouseButton1Click:Connect(function()
        -- micro ripple: create circle frame, expand and fade
        local rip = Instance.new("Frame", btn)
        rip.Size = UDim2.new(0, 8, 0, 8)
        rip.BackgroundTransparency = 0
        rip.BackgroundColor3 = Color3.fromRGB(255,255,255)
        rip.AnchorPoint = Vector2.new(0.5,0.5)
        rip.Position = UDim2.new(0.5, 0, 0.5, 0)
        rip.ZIndex = btn.ZIndex + 2
        local rc = Instance.new("UICorner", rip); rc.CornerRadius = UDim.new(1,0)
        game:GetService("TweenService"):Create(rip, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {Size = UDim2.new(1.8,0,1.8,0), BackgroundTransparency = 1}):Play()
        delay(0.28, function() pcall(function() rip:Destroy() end) end)
        -- callback
        pcall(function() self.Callback() end)
    end)

    self._container = container
    self._button = btn

    return self
end

function Button:SaveState()
    return {
        Type = "Button",
        Title = self.Title
    }
end

function Button:LoadState(state)
    -- Buttons typically have no persistent state
end

return {
    new = function(opts, Section, Library) return Button.new(opts, Section, Library) end
}
