-- Utils/UIHelpers.lua (Simplified & Optimized)
-- Clean, visible, no acrylic, smooth look.

local UIHelpers = {}

-- Create rounded corners
function UIHelpers.CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Name = "Krill_UICorner"
	corner.Parent = parent
	return corner
end

-- Apply simple dark background with outline
function UIHelpers.ApplyGlass(frame, opts)
	opts = opts or {}
	frame.BackgroundTransparency = opts.BackgroundTransparency or 0.1
	frame.BackgroundColor3 = opts.BackgroundColor3 or Color3.fromRGB(25, 30, 45)
	frame.BorderSizePixel = 0

	-- Clean white outline
	local stroke = Instance.new("UIStroke")
	stroke.Name = "Krill_Stroke"
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.LineJoinMode = Enum.LineJoinMode.Round
	stroke.Thickness = 1
	stroke.Transparency = 0.2
	stroke.Color = Color3.fromRGB(200, 200, 200)
	stroke.Parent = frame

	UIHelpers.CreateCorner(frame, opts.CornerRadius or 8)
end

-- Clean text label creator
function UIHelpers.CreateText(parent, props)
	local lbl = Instance.new("TextLabel")
	lbl.Name = props.Name or "Krill_Text"
	lbl.Text = props.Text or ""
	lbl.BackgroundTransparency = 1
	lbl.TextColor3 = props.TextColor3 or Color3.fromRGB(240, 240, 240)
	lbl.TextSize = props.TextSize or 15
	lbl.Font = props.Font or Enum.Font.GothamSemibold
	lbl.TextWrapped = props.TextWrapped or false
	lbl.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	lbl.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
	lbl.Size = props.Size or UDim2.new(1, 0, 0, 18)
	lbl.Position = props.Position or UDim2.new(0, 0, 0, 0)
	lbl.Parent = parent
	return lbl
end

return UIHelpers
