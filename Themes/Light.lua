-- Themes/Light.lua
local Theme = {}

function Theme.Apply(Window, Library)
    local p = Window._panel
    if not p then return end
    p.BackgroundColor3 = Color3.fromRGB(240, 246, 250)
    p.BackgroundTransparency = 0.22
    local grad = p:FindFirstChild("Krill_Gradient")
    if grad then
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(245,248,250)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(232,238,244)),
        }
    end
    if Window._titleLabel then
        Window._titleLabel.TextColor3 = Color3.fromRGB(36,36,36)
    end
end

return Theme
