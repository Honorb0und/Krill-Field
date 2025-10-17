-- Themes/Default.lua
-- Soft blue/purple glass theme
local Theme = {}

function Theme.Apply(Window, Library)
    local p = Window._panel
    if not p then return end
    p.BackgroundColor3 = Color3.fromRGB(10, 18, 30)
    p.BackgroundTransparency = 0.28
    local grad = p:FindFirstChild("Krill_Gradient")
    if grad then
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10,18,30)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(24,40,64)),
        }
    end
    -- Topbar and text colors
    p:FindFirstChildWhichIsA("Frame", true)
    if Window._titleLabel then
        Window._titleLabel.TextColor3 = Color3.fromRGB(245,245,245)
    end
    -- subcomponents: style tab entries
    for _, t in ipairs(Window.Tabs or {}) do
        if t._entry then
            t._entry.TextColor3 = Color3.fromRGB(210,210,220)
        end
    end
end

return Theme
