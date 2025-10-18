--[[
	Glassmorphism UI Window Library for Roblox
	Created: 2025
	Version: 2.0
	Author: Expert UI Engineer
	
	A complete, self-contained glassmorphism window system with modern 2025 design trends,
	featuring frosted glass effects, smooth animations, and comprehensive interaction handling.
--]]

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Main window creation function
local function CreateWindow(config)
	-- Configuration validation and defaults
	config = config or {}
	local title = config.Title or "Window"
	local size = config.Size or UDim2.new(0, 500, 0, 400)
	local position = config.Position or UDim2.new(0.5, -250, 0.5, -200)
	local theme = config.Theme or "Dark"
	local acrylic = config.Acrylic ~= false
	local minimizeKey = config.MinimizeKey or Enum.KeyCode.RightControl
	
	-- Color palette (Modern Jewel Tones 2025)
	local COLORS = {
		Primary = {
			DeepTwilight = Color3.fromHex("#0F1928"),
			TwilightMid = Color3.fromHex("#142232"),
			TwilightLight = Color3.fromHex("#1A2A40")
		},
		Secondary = Color3.fromHex("#283246"),
		Accent = Color3.fromHex("#0096C8"),
		Highlight = Color3.fromHex("#00B478"),
		Text = {
			Primary = Color3.fromHex("#E6E6EB"),
			Secondary = Color3.fromHex("#96A0AA")
		},
		Traffic = {
			Red = Color3.fromHex("#FF5F57"),
			Yellow = Color3.fromHex("#FFBD2E"),
			Green = Color3.fromHex("#28C840")
		},
		Neutral = Color3.fromHex("#000000")
	}
	
	-- Animation timing and easing
	local TWEEN_INFO = {
		Default = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		Spring = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, false, 0.1),
		Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	}
	
	-- Window state management
	local windowState = {
		IsMinimized = false,
		IsMaximized = false,
		IsDragging = false,
		IsResizing = false,
		OriginalSize = size,
		OriginalPosition = position,
		MinSize = UDim2.new(0, 300, 0, 200),
		MaxSize = UDim2.new(1, 0, 1, 0),
		LastMousePosition = nil
	}
	
	-- Create main screen GUI container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "GlassWindow_" .. title:gsub("%s+", "")
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	screenGui.Parent = PlayerGui
	
	-- Main window container with glassmorphism foundation
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = size
	mainFrame.Position = position
	mainFrame.BackgroundColor3 = COLORS.Primary.DeepTwilight
	mainFrame.BackgroundTransparency = 0.3
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui
	
	-- Rounded corners for modern aesthetic
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = mainFrame
	
	-- Dual stroke system for neumorphic depth
	local outerStroke = Instance.new("UIStroke")
	outerStroke.Color = Color3.new(1, 1, 1)
	outerStroke.Transparency = 0.9
	outerStroke.Thickness = 2
	outerStroke.Parent = mainFrame
	
	local innerStroke = Instance.new("UIStroke")
	innerStroke.Color = Color3.new(0, 0, 0)
	innerStroke.Transparency = 0.8
	innerStroke.Thickness = 1.5
	innerStroke.Parent = mainFrame
	
	-- Glass blur effect using noise texture
	local glassNoise = Instance.new("ImageLabel")
	glassNoise.Name = "GlassNoise"
	glassNoise.Size = UDim2.new(1, 0, 1, 0)
	glassNoise.BackgroundTransparency = 1
	glassNoise.Image = "rbxassetid://1665395372"
	glassNoise.ImageTransparency = 0.9
	glassNoise.ScaleType = Enum.ScaleType.Tile
	glassNoise.TileSize = UDim2.new(0, 256, 0, 256)
	glassNoise.ZIndex = 1
	glassNoise.Parent = mainFrame
	
	-- Depth gradient overlay
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLORS.Primary.DeepTwilight),
		ColorSequenceKeypoint.new(1, COLORS.Primary.TwilightLight)
	})
	gradient.Rotation = 45
	gradient.Parent = mainFrame
	
	-- Parallax background container
	local parallaxContainer = Instance.new("Frame")
	parallaxContainer.Name = "ParallaxContainer"
	parallaxContainer.Size = UDim2.new(1.1, 0, 1.1, 0)
	parallaxContainer.Position = UDim2.new(-0.05, 0, -0.05, 0)
	parallaxContainer.BackgroundTransparency = 1
	parallaxContainer.Parent = mainFrame
	
	-- Top bar for window controls and dragging
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.BackgroundColor3 = COLORS.Secondary
	topBar.BackgroundTransparency = 0.3
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 10
	topBar.Parent = parallaxContainer
	
	local topBarCorner = Instance.new("UICorner")
	topBarCorner.CornerRadius = UDim.new(0, 8)
	topBarCorner.Parent = topBar
	
	-- Traffic lights container (window controls)
	local trafficLights = Instance.new("Frame")
	trafficLights.Name = "TrafficLights"
	trafficLights.Size = UDim2.new(0, 72, 0, 16)
	trafficLights.Position = UDim2.new(0, 15, 0.5, -8)
	trafficLights.BackgroundTransparency = 1
	trafficLights.ZIndex = 11
	trafficLights.Parent = topBar
	
	-- Close button (red)
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 16, 0, 16)
	closeButton.Position = UDim2.new(0, 0, 0, 0)
	closeButton.BackgroundColor3 = COLORS.Traffic.Red
	closeButton.Text = ""
	closeButton.ZIndex = 12
	closeButton.Parent = trafficLights
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeButton
	
	-- Minimize button (yellow)
	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Name = "MinimizeButton"
	minimizeButton.Size = UDim2.new(0, 16, 0, 16)
	minimizeButton.Position = UDim2.new(0, 28, 0, 0)
	minimizeButton.BackgroundColor3 = COLORS.Traffic.Yellow
	minimizeButton.Text = ""
	minimizeButton.ZIndex = 12
	minimizeButton.Parent = trafficLights
	
	local minimizeCorner = Instance.new("UICorner")
	minimizeCorner.CornerRadius = UDim.new(1, 0)
	minimizeCorner.Parent = minimizeButton
	
	-- Maximize button (green)
	local maximizeButton = Instance.new("TextButton")
	maximizeButton.Name = "MaximizeButton"
	maximizeButton.Size = UDim2.new(0, 16, 0, 16)
	maximizeButton.Position = UDim2.new(0, 56, 0, 0)
	maximizeButton.BackgroundColor3 = COLORS.Traffic.Green
	maximizeButton.Text = ""
	maximizeButton.ZIndex = 12
	maximizeButton.Parent = trafficLights
	
	local maximizeCorner = Instance.new("UICorner")
	maximizeCorner.CornerRadius = UDim.new(1, 0)
	maximizeCorner.Parent = maximizeButton
	
	-- Window title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -100, 1, 0)
	titleLabel.Position = UDim2.new(0, 100, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = COLORS.Text.Primary
	titleLabel.TextSize = 16
	titleLabel.Font = Enum.Font.GothamSemibold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 11
	titleLabel.Parent = topBar
	
	-- Content area for user elements
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, -20, 1, -60)
	contentArea.Position = UDim2.new(0, 10, 0, 50)
	contentArea.BackgroundTransparency = 1
	contentArea.Parent = parallaxContainer
	
	-- Resize grip at bottom-right corner
	local resizeGrip = Instance.new("TextButton")
	resizeGrip.Name = "ResizeGrip"
	resizeGrip.Size = UDim2.new(0, 20, 0, 20)
	resizeGrip.Position = UDim2.new(1, -20, 1, -20)
	resizeGrip.BackgroundColor3 = COLORS.Accent
	resizeGrip.BackgroundTransparency = 0.8
	resizeGrip.Text = ""
	resizeGrip.ZIndex = 15
	resizeGrip.Parent = mainFrame
	
	local resizeCorner = Instance.new("UICorner")
	resizeCorner.CornerRadius = UDim.new(0, 4)
	resizeCorner.Parent = resizeGrip
	
	local resizeIcon = Instance.new("ImageLabel")
	resizeIcon.Name = "ResizeIcon"
	resizeIcon.Size = UDim2.new(0, 12, 0, 12)
	resizeIcon.Position = UDim2.new(0.5, -6, 0.5, -6)
	resizeIcon.BackgroundTransparency = 1
	resizeIcon.Image = "rbxassetid://11677211851" -- Diagonal resize icon
	resizeIcon.ImageColor3 = COLORS.Text.Primary
	resizeIcon.ZIndex = 16
	resizeIcon.Parent = resizeGrip
	
	-- Ripple effect for button interactions
	local function createRippleEffect(button)
		local ripple = Instance.new("Frame")
		ripple.Name = "Ripple"
		ripple.Size = UDim2.new(0, 0, 0, 0)
		ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
		ripple.BackgroundColor3 = Color3.new(1, 1, 1)
		ripple.BackgroundTransparency = 0.7
		ripple.ZIndex = 20
		
		local rippleCorner = Instance.new("UICorner")
		rippleCorner.CornerRadius = UDim.new(1, 0)
		rippleCorner.Parent = ripple
		
		ripple.Parent = button
		
		-- Animate ripple
		local tweenIn = TweenService:Create(ripple, TWEEN_INFO.Default, {
			Size = UDim2.new(2, 0, 2, 0),
			Position = UDim2.new(-0.5, 0, -0.5, 0),
			BackgroundTransparency = 1
		})
		
		tweenIn:Play()
		tweenIn.Completed:Connect(function()
			ripple:Destroy()
		end)
	end
	
	-- Button hover animations
	local function setupButtonHover(button, accentColor)
		local originalSize = button.Size
		local originalTransparency = button.BackgroundTransparency
		
		local hoverTween = TweenService:Create(button, TWEEN_INFO.Default, {
			Size = originalSize * 1.05,
			BackgroundTransparency = originalTransparency - 0.1
		})
		
		local leaveTween = TweenService:Create(button, TWEEN_INFO.Default, {
			Size = originalSize,
			BackgroundTransparency = originalTransparency
		})
		
		local glowTween = TweenService:Create(button, TWEEN_INFO.Quick, {
			BackgroundColor3 = accentColor
		})
		
		local unglowTween = TweenService:Create(button, TWEEN_INFO.Quick, {
			BackgroundColor3 = button.BackgroundColor3
		})
		
		button.MouseEnter:Connect(function()
			hoverTween:Play()
			glowTween:Play()
		end)
		
		button.MouseLeave:Connect(function()
			leaveTween:Play()
			unglowTween:Play()
		end)
		
		button.MouseButton1Down:Connect(function()
			createRippleEffect(button)
		end)
	end
	
	-- Apply hover effects to control buttons
	setupButtonHover(closeButton, COLORS.Traffic.Red)
	setupButtonHover(minimizeButton, COLORS.Traffic.Yellow)
	setupButtonHover(maximizeButton, COLORS.Traffic.Green)
	setupButtonHover(resizeGrip, COLORS.Accent)
	
	-- Window dragging implementation
	local function initializeDragging()
		local dragStart = nil
		local startPosition = nil
		
		local function updateDrag(input)
			if not dragStart or not startPosition then return end
			
			local delta = input.Position - dragStart
			local newPosition = UDim2.new(
				startPosition.X.Scale, 
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale, 
				startPosition.Y.Offset + delta.Y
			)
			
			-- Clamp to screen bounds
			local absPos = mainFrame.AbsolutePosition
			local absSize = mainFrame.AbsoluteSize
			local screenSize = workspace.CurrentCamera.ViewportSize
			
			if absPos.X + delta.X < 0 then
				newPosition = UDim2.new(0, 0, newPosition.Y.Scale, newPosition.Y.Offset)
			elseif absPos.X + absSize.X + delta.X > screenSize.X then
				newPosition = UDim2.new(1, -absSize.X, newPosition.Y.Scale, newPosition.Y.Offset)
			end
			
			if absPos.Y + delta.Y < 0 then
				newPosition = UDim2.new(newPosition.X.Scale, newPosition.X.Offset, 0, 0)
			elseif absPos.Y + absSize.Y + delta.Y > screenSize.Y then
				newPosition = UDim2.new(newPosition.X.Scale, newPosition.X.Offset, 1, -absSize.Y)
			end
			
			mainFrame.Position = newPosition
		end
		
		topBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				windowState.IsDragging = true
				dragStart = input.Position
				startPosition = mainFrame.Position
				
				-- Bring to front
				local highestZ = 1
				for _, gui in ipairs(PlayerGui:GetChildren()) do
					if gui:IsA("ScreenGui") and gui ~= screenGui then
						highestZ = math.max(highestZ, gui.ZIndexBehavior == Enum.ZIndexBehavior.Global and (gui:GetFullName():match("%d+") or 1) or 1)
					end
				end
				screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
			end
		end)
		
		topBar.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				windowState.IsDragging = false
				dragStart = nil
				startPosition = nil
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if windowState.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateDrag(input)
			end
		end)
	end
	
	-- Window resizing implementation
	local function initializeResizing()
		local resizeStart = nil
		local startSize = nil
		local startPosition = nil
		
		local function updateResize(input)
			if not resizeStart or not startSize then return end
			
			local delta = input.Position - resizeStart
			local newSize = UDim2.new(
				startSize.X.Scale,
				math.max(windowState.MinSize.X.Offset, startSize.X.Offset + delta.X),
				startSize.Y.Scale,
				math.max(windowState.MinSize.Y.Offset, startSize.Y.Offset + delta.Y)
			)
			
			-- Clamp to maximum size
			local screenSize = workspace.CurrentCamera.ViewportSize
			if newSize.X.Offset > screenSize.X then
				newSize = UDim2.new(0, screenSize.X, newSize.Y.Scale, newSize.Y.Offset)
			end
			if newSize.Y.Offset > screenSize.Y then
				newSize = UDim2.new(newSize.X.Scale, newSize.X.Offset, 0, screenSize.Y)
			end
			
			mainFrame.Size = newSize
		end
		
		resizeGrip.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				windowState.IsResizing = true
				resizeStart = input.Position
				startSize = mainFrame.Size
				startPosition = mainFrame.Position
			end
		end)
		
		resizeGrip.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				windowState.IsResizing = false
				resizeStart = nil
				startSize = nil
				startPosition = nil
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if windowState.IsResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateResize(input)
			end
		end)
	end
	
	-- Window state management (minimize/maximize)
	local function toggleMinimize()
		if windowState.IsMaximized then return end -- Can't minimize when maximized
		
		windowState.IsMinimized = not windowState.IsMinimized
		
		if windowState.IsMinimized then
			-- Save current size before minimizing
			windowState.OriginalSize = mainFrame.Size
			
			-- Tween to minimized state (topbar only)
			local minimizeTween = TweenService:Create(mainFrame, TWEEN_INFO.Spring, {
				Size = UDim2.new(windowState.OriginalSize.X.Scale, windowState.OriginalSize.X.Offset, 0, 40)
			})
			
			local contentFade = TweenService:Create(contentArea, TWEEN_INFO.Default, {
				BackgroundTransparency = 1
			})
			
			minimizeTween:Play()
			contentFade:Play()
			
			-- Hide resize grip
			resizeGrip.Visible = false
		else
			-- Restore to original size
			local restoreTween = TweenService:Create(mainFrame, TWEEN_INFO.Spring, {
				Size = windowState.OriginalSize
			})
			
			local contentFade = TweenService:Create(contentArea, TWEEN_INFO.Default, {
				BackgroundTransparency = 0
			})
			
			restoreTween:Play()
			contentFade:Play()
			
			-- Show resize grip
			resizeGrip.Visible = true
		end
	end
	
	local function toggleMaximize()
		if windowState.IsMinimized then return end -- Can't maximize when minimized
		
		windowState.IsMaximized = not windowState.IsMaximized
		
		if windowState.IsMaximized then
			-- Save current size and position before maximizing
			windowState.OriginalSize = mainFrame.Size
			windowState.OriginalPosition = mainFrame.Position
			
			-- Tween to fullscreen
			local maximizeTween = TweenService:Create(mainFrame, TWEEN_INFO.Spring, {
				Size = windowState.MaxSize,
				Position = UDim2.new(0, 0, 0, 0)
			})
			
			maximizeTween:Play()
			
			-- Hide resize grip in maximized state
			resizeGrip.Visible = false
		else
			-- Restore to original size and position
			local restoreTween = TweenService:Create(mainFrame, TWEEN_INFO.Spring, {
				Size = windowState.OriginalSize,
				Position = windowState.OriginalPosition
			})
			
			restoreTween:Play()
			
			-- Show resize grip
			resizeGrip.Visible = true
		end
	end
	
	-- Button click handlers
	closeButton.MouseButton1Click:Connect(function()
		createRippleEffect(closeButton)
		
		-- Animate close with fade out
		local closeTween = TweenService:Create(mainFrame, TWEEN_INFO.Default, {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		})
		
		closeTween:Play()
		closeTween.Completed:Connect(function()
			screenGui:Destroy()
		end)
	end)
	
	minimizeButton.MouseButton1Click:Connect(function()
		createRippleEffect(minimizeButton)
		toggleMinimize()
	end)
	
	maximizeButton.MouseButton1Click:Connect(function()
		createRippleEffect(maximizeButton)
		toggleMaximize()
	end)
	
	-- Keyboard shortcut for minimize
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == minimizeKey then
			toggleMinimize()
		end
	end)
	
	-- Parallax effect on mouse move
	local function initializeParallax()
		local connection
		local function updateParallax()
			if not windowState.IsDragging and not windowState.IsResizing then
				local mousePos = UserInputService:GetMouseLocation()
				local screenSize = workspace.CurrentCamera.ViewportSize
				local center = screenSize / 2
				
				local offset = (mousePos - center) / center * 5 -- Reduced intensity for subtlety
				
				parallaxContainer.Position = UDim2.new(
					-0.05 + offset.X * 0.01,
					0,
					-0.05 + offset.Y * 0.01,
					0
				)
			end
		end
		
		-- Only enable parallax on desktop for performance
		if not UserInputService.TouchEnabled then
			connection = RunService.RenderStepped:Connect(updateParallax)
		end
		
		-- Cleanup connection when window is destroyed
		mainFrame.AncestryChanged:Connect(function()
			if not mainFrame:IsDescendantOf(game) and connection then
				connection:Disconnect()
			end
		end)
	end
	
	-- Initialize all window functionalities
	initializeDragging()
	initializeResizing()
	initializeParallax()
	
	-- Public API methods
	local windowAPI = {}
	
	function windowAPI:Minimize()
		if not windowState.IsMinimized then
			toggleMinimize()
		end
	end
	
	function windowAPI:Maximize()
		if not windowState.IsMaximized then
			toggleMaximize()
		end
	end
	
	function windowAPI:Restore()
		if windowState.IsMinimized then
			toggleMinimize()
		elseif windowState.IsMaximized then
			toggleMaximize()
		end
	end
	
	function windowAPI:Close()
		screenGui:Destroy()
	end
	
	function windowAPI:SetTitle(newTitle)
		titleLabel.Text = newTitle
	end
	
	function windowAPI:GetContentArea()
		return contentArea
	end
	
	function windowAPI:IsMinimized()
		return windowState.IsMinimized
	end
	
	function windowAPI:IsMaximized()
		return windowState.IsMaximized
	end
	
	function windowAPI:SetSize(newSize)
		-- Validate size constraints
		local minSize = windowState.MinSize
		local maxSize = windowState.MaxSize
		
		local validatedSize = UDim2.new(
			newSize.X.Scale,
			math.max(minSize.X.Offset, math.min(maxSize.X.Offset, newSize.X.Offset)),
			newSize.Y.Scale,
			math.max(minSize.Y.Offset, math.min(maxSize.Y.Offset, newSize.Y.Offset))
		)
		
		mainFrame.Size = validatedSize
		windowState.OriginalSize = validatedSize
	end
	
	function windowAPI:SetPosition(newPosition)
		mainFrame.Position = newPosition
		windowState.OriginalPosition = newPosition
	end
	
	-- Return the public API
	return windowAPI
end

-- Example usage and demonstration
return function()
	-- Example 1: Basic window
	local basicWindow = CreateWindow({
		Title = "Dashboard",
		Size = UDim2.new(0, 600, 0, 400),
		Position = UDim2.new(0.1, 0, 0.1, 0),
		Theme = "Dark",
		Acrylic = true,
		MinimizeKey = Enum.KeyCode.RightControl
	})
	
	-- Add some example content
	local content = basicWindow:GetContentArea()
	
	local sampleLabel = Instance.new("TextLabel")
	sampleLabel.Size = UDim2.new(1, 0, 0, 30)
	sampleLabel.Position = UDim2.new(0, 0, 0, 10)
	sampleLabel.BackgroundTransparency = 1
	sampleLabel.Text = "Welcome to Glassmorphism UI"
	sampleLabel.TextColor3 = Color3.fromHex("#E6E6EB")
	sampleLabel.TextSize = 18
	sampleLabel.Font = Enum.Font.Gotham
	sampleLabel.TextXAlignment = Enum.TextXAlignment.Center
	sampleLabel.Parent = content
	
	local sampleButton = Instance.new("TextButton")
	sampleButton.Size = UDim2.new(0, 120, 0, 36)
	sampleButton.Position = UDim2.new(0.5, -60, 0.5, -18)
	sampleButton.BackgroundColor3 = Color3.fromHex("#0096C8")
	sampleButton.BackgroundTransparency = 0.2
	sampleButton.Text = "Click Me"
	sampleButton.TextColor3 = Color3.fromHex("#E6E6EB")
	sampleButton.TextSize = 14
	sampleButton.Font = Enum.Font.GothamSemibold
	
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = sampleButton
	
	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromHex("#FFFFFF")
	buttonStroke.Transparency = 0.8
	buttonStroke.Thickness = 1
	buttonStroke.Parent = sampleButton
	
	sampleButton.Parent = content
	
	-- Example 2: Secondary window
	task.wait(1)
	local secondaryWindow = CreateWindow({
		Title = "Settings Panel",
		Size = UDim2.new(0, 450, 0, 300),
		Position = UDim2.new(0.6, 0, 0.2, 0),
		Theme = "Dark",
		Acrylic = true
	})
	
	return basicWindow
end
