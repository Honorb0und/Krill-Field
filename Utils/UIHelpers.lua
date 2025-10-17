-- Utils/UIHelpers.lua
-- Helper utilities for creating stylized UI elements: acrylic panels, strokes, corners, noise etc.
local UIHelpers = {}

local RunService = game:GetService("RunService")
local Tween = require(script:FindFirstChild("Tween") or script) -- fallback; real loader uses separate module

-- Utility: create UICorner with specified radius
function UIHelpers.CreateCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Name = "Krill_UICorner"
    corner.Parent = parent
    return corner
end

-- Utility: create a noise ImageLabel (acrylic texture)
function UIHelpers.CreateNoise(parent, imageId, tile)
    local img = Instance.new("ImageLabel")
    img.Name = "Krill_Noise"
    img.Image = imageId or "rbxassetid://1665395372"
    img.Size = UDim2.new(1.5, 0, 1.5, 0) -- slightly larger for parallax
    img.Position = UDim2.new(-0.25, 0, -0.25, 0)
    img.BackgroundTransparency = 1
    img.ImageTransparency = 0.9
    img.ScaleType = Enum.ScaleType.Tile
    img.TileSize = Vector2.new(64, 64)
    img.ZIndex = parent.ZIndex - 1
    img.Parent = parent
    return img
end

-- Utility: apply glass base (background + gradient + strokes)
function UIHelpers.ApplyGlass(frame, opts)
    opts = opts or {}
    frame.BackgroundTransparency = opts.BackgroundTransparency or 0.35
    frame.BackgroundColor3 = opts.BackgroundColor3 or Color3.fromRGB(15, 25, 40)
    frame.BorderSizePixel = 0

    -- Gradient overlay
    local grad = Instance.new("UIGradient")
    grad.Name = "Krill_Gradient"
    grad.Rotation = opts.GradientRotation or 90
    grad.Color = ColorSequence.new(opts.Gradient or {
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 25, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(26, 42, 64))
    })
    grad.Parent = frame

    -- Outer stroke (glow)
    local stroke = Instance.new("UIStroke")
    stroke.Name = "Krill_StrokeOuter"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Transparency = opts.OuterStrokeTransparency or 0.7
    stroke.Thickness = opts.OuterStrokeThickness or 1
    stroke.Parent = frame

    -- Inner subtle stroke for neumorphism
    local innerStroke = Instance.new("UIStroke")
    innerStroke.Name = "Krill_StrokeInner"
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Inner
    innerStroke.LineJoinMode = Enum.LineJoinMode.Round
    innerStroke.Transparency = opts.InnerStrokeTransparency or 0.85
    innerStroke.Thickness = opts.InnerStrokeThickness or 1
    innerStroke.Parent = frame

    -- Corner
    UIHelpers.CreateCorner(frame, opts.CornerRadius or 10)
end

-- Safe text creation utility
function UIHelpers.CreateText(parent, props)
    local lbl = Instance.new("TextLabel")
    lbl.Name = props.Name or "Krill_Text"
    lbl.Text = props.Text or ""
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = props.TextColor3 or Color3.fromRGB(230, 230, 230)
    lbl.TextSize = props.TextSize or 14
    lbl.Font = props.Font or Enum.Font.Gotham
    lbl.TextWrapped = props.TextWrapped or false
    lbl.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    lbl.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    lbl.Size = props.Size or UDim2.new(1, 0, 0, 18)
    lbl.Position = props.Position or UDim2.new(0, 0, 0, 0)
    lbl.Parent = parent
    return lbl
end

-- Hover animation helper: scales and adds stroke glow
function UIHelpers.HoverEffect(inst, enterProps, leaveProps)
    enterProps = enterProps or {}
    leaveProps = leaveProps or {}
    local hover = false
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    -- fallback: use InputBegan if hover not feasible (mobile)
    local inputConn
    local function onEnter()
        if hover then return end
        hover = true
        pcall(function()
            require(script:FindFirstChild("Tween") or script).To(inst, enterProps.TweenProps or {Size = inst.Size}, enterProps.TweenInfo or nil)
        end)
    end
    local function onLeave()
        if not hover then return end
        hover = false
        pcall(function()
            require(script:FindFirstChild("Tween") or script).To(inst, leaveProps.TweenProps or {Size = inst.Size}, leaveProps.TweenInfo or nil)
        end)
    end
    -- Connect mouse enter/leave if it's a GuiObject (has MouseEnter/MouseLeave)
    if inst and inst:IsA("GuiObject") then
        if inst.MouseEnter then inst.MouseEnter:Connect(onEnter) end
        if inst.MouseLeave then inst.MouseLeave:Connect(onLeave) end
    end
    return {
        Disconnect = function()
            if inputConn then
                inputConn:Disconnect()
            end
        end
    }
end

return UIHelpers
