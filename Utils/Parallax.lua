-- Utils/Parallax.lua
-- Small parallax manager for noise ImageLabels / backgrounds
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Parallax = {}
Parallax._tracked = {}
Parallax._rate = 0.08 -- effect intensity

function Parallax.Track(guiObject, opts)
    opts = opts or {}
    if not guiObject or not guiObject:IsA("GuiObject") then return end
    table.insert(Parallax._tracked, {Gui = guiObject, Opts = opts})
end

-- Simple update loop
local conn
conn = RunService.RenderStepped:Connect(function(dt)
    local mouse = player and player:GetMouse()
    if not mouse then return end
    local hx = (mouse.X - (workspace.CurrentCamera.ViewportSize.X/2)) / (workspace.CurrentCamera.ViewportSize.X/2)
    local hy = (mouse.Y - (workspace.CurrentCamera.ViewportSize.Y/2)) / (workspace.CurrentCamera.ViewportSize.Y/2)
    for _, rec in ipairs(Parallax._tracked) do
        if rec and rec.Gui and rec.Gui:IsA("GuiObject") then
            local offsetX = -(hx * (rec.Opts.X or Parallax._rate) * (rec.Gui.Size.X.Offset or 64))
            local offsetY = -(hy * (rec.Opts.Y or Parallax._rate) * (rec.Gui.Size.Y.Offset or 64))
            pcall(function()
                rec.Gui.Position = UDim2.new(0, offsetX, 0, offsetY)
            end)
        end
    end
end)

function Parallax.Untrack(guiObject)
    for i, rec in ipairs(Parallax._tracked) do
        if rec.Gui == guiObject then
            table.remove(Parallax._tracked, i)
            return true
        end
    end
    return false
end

function Parallax.Stop()
    if conn then
        conn:Disconnect()
        conn = nil
    end
    Parallax._tracked = {}
end

return {
    Track = Parallax.Track,
    Untrack = Parallax.Untrack,
    Stop = Parallax.Stop
}
