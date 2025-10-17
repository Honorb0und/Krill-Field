-- Utils/Notification.lua
-- Small notification system: slide-in to top-right, with types, duration, tweening, stacking.
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Notification = {}
Notification._container = nil
Notification._connections = {}
Notification._active = {}
Notification._spacing = 8
Notification._zIndex = 9999

-- Ensure ScreenGui and container exist
local function ensureContainer()
    if Notification._container and Notification._container.Parent then return Notification._container end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KrillField_Notifications"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(1, 0)
    container.Position = UDim2.new(1, -16, 0, 16)
    container.Size = UDim2.new(0, 320, 0, 0)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.ZIndex = Notification._zIndex
    container.Parent = screenGui
    Notification._container = container
    return container
end

-- Create a notification element
local function createNotificationFrame(opts)
    opts = opts or {}
    local frame = Instance.new("Frame")
    frame.Name = "KrillNotif"
    frame.Size = UDim2.new(0, 320, 0, 64)
    frame.Position = UDim2.new(1, 0, 0, 0)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(10, 16, 25)
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    -- Apply acrylic style
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 1
    stroke.Transparency = 0.8

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -88, 0, 24)
    title.Position = UDim2.new(0, 16, 0, 8)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = Color3.fromRGB(230,230,230)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = opts.Title or "Notification"

    local desc = Instance.new("TextLabel", frame)
    desc.Size = UDim2.new(1, -88, 0, 24)
    desc.Position = UDim2.new(0, 16, 0, 32)
    desc.BackgroundTransparency = 1
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 12
    desc.TextColor3 = Color3.fromRGB(200,200,200)
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Text = opts.Description or ""

    -- Icon placeholder
    local icon = Instance.new("ImageLabel", frame)
    icon.Size = UDim2.new(0, 48, 0, 48)
    icon.Position = UDim2.new(1, -64, 0, 8)
    icon.BackgroundTransparency = 1
    icon.Image = opts.Icon or ""
    icon.ScaleType = Enum.ScaleType.Fit

    return frame, title, desc, icon
end

-- Slide in and out, stacking
function Notification.Notify(opts)
    opts = opts or {}
    local container = ensureContainer()
    local frame = createNotificationFrame(opts)
    frame.Parent = container
    frame.ZIndex = Notification._zIndex

    -- Reposition stack
    table.insert(Notification._active, 1, frame)
    for i, f in ipairs(Notification._active) do
        local y = (i-1) * (frame.Size.Y.Offset + Notification._spacing)
        local goal = UDim2.new(0, 0, 0, y)
        -- animate via TweenService
        pcall(function()
            TweenService:Create(f, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -16, 0, y)}):Play()
        end)
    end

    -- Slide in from right
    pcall(function()
        frame.Position = UDim2.new(1, 400, 0, 0)
        TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -16, 0, 0)}):Play()
    end)

    -- Auto remove after duration
    local duration = tonumber(opts.Duration) or 4
    delay(duration, function()
        pcall(function()
            -- Slide out then remove and re-stack
            TweenService:Create(frame, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 400, 0, frame.Position.Y.Offset)}):Play()
            wait(0.24)
            -- remove from active
            for i,f in ipairs(Notification._active) do
                if f == frame then
                    table.remove(Notification._active, i)
                    break
                end
            end
            frame:Destroy()
            -- restack remaining
            for i,f in ipairs(Notification._active) do
                local y = (i-1) * (64 + Notification._spacing)
                pcall(function()
                    TweenService:Create(f, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -16, 0, y)}):Play()
                end)
            end
        end)
    end)

    return frame
end

return {
    Notify = Notification.Notify
}
