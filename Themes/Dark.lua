-- Themes/Dark.lua
local Theme = {}

function Theme.Apply(Window, Library)
    local p = Window._panel
    if not p then return end
    p.BackgroundColor3 = Color3.fromRGB(8,12,18)
    p.BackgroundTransparency = 0.32
    local grad = p:FindFirstChild("Krill_Gradient")
    if grad then
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(8,12,18)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(18,26,38)),
        }
    end
    if Window._titleLabel then
        Window._titleLabel.TextColor3 = Color3.fromRGB(230,230,230)
    end
end

return Theme
