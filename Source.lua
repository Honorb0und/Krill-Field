-- Source.lua
-- Top-level loader for "Krill Field" UI library
-- Usage:
-- local KrillField = loadstring(game:HttpGet("https://raw.githubusercontent.com/Honorb0und/Krill-Field/main/Source.lua"))()
-- local Window = KrillField:CreateWindow({ Title = "Krill Field", Size = UDim2.new(0,500,0,400) })

-- NOTE: Replace "yourrepo/main" with your repository path.
local Loader = {}
Loader.__index = Loader

-- Base URL where modules live (change to your repo)
local BASE = "https://raw.githubusercontent.com/Honorb0und/Krill-Field/main/"

local required = {
    -- Core
    "Core/Window.lua",
    "Core/Tab.lua",
    "Core/Section.lua",
    -- Components
    "Components/Button.lua",
    "Components/Toggle.lua",
    "Components/Slider.lua",
    "Components/Dropdown.lua",
    "Components/Keybind.lua",
    "Components/ColorPicker.lua",
    "Components/Input.lua",
    "Components/Label.lua",
    "Components/Separator.lua",
    -- Themes
    "Themes/Default.lua",
    "Themes/Dark.lua",
    "Themes/Light.lua",
    -- Utils
    "Utils/Tween.lua",
    "Utils/Config.lua",
    "Utils/Notification.lua",
    "Utils/Parallax.lua",
    "Utils/UIHelpers.lua",
}

-- We'll store loaded modules here
local modules = {}

-- Helper to HttpGet and load a module; returns the module's returned table
local function fetchModule(path)
    local url = BASE .. path
    local ok, res = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not ok then
        warn(("[KrillField] Failed to HttpGet %s (%s)"):format(path, tostring(res)))
        return nil, ("HttpGet failed for %s: %s"):format(path, tostring(res))
    end
    local chunk, err = loadstring(res)
    if not chunk then
        warn(("[KrillField] loadstring failed for %s: %s"):format(path, tostring(err)))
        return nil, ("loadstring failed for %s: %s"):format(path, tostring(err))
    end
    local ok2, ret = pcall(chunk)
    if not ok2 then
        warn(("[KrillField] executing chunk failed for %s: %s"):format(path, tostring(ret)))
        return nil, ("module execution failed for %s: %s"):format(path, tostring(ret))
    end
    return ret
end

-- Attempt to fetch each required module; collect errors but keep going
local errors = {}
for _, path in ipairs(required) do
    local mod, err = fetchModule(path)
    if not mod then
        table.insert(errors, err)
    else
        modules[path] = mod
    end
end

if #errors > 0 then
    -- If modules failed, provide a graceful fallback "stub" library that errors on use but won't crash
    warn("[KrillField] One or more modules failed to load. Library will expose a stub that informs the user.")
    local stub = {}
    function stub.CreateWindow()
        error("[KrillField] Cannot create window because one or more modules failed to load. Check HttpGet URLs and module availability.")
    end
    return stub
end

-- Assemble Library from modules
local Library = {}
Library.__index = Library

-- Expose utilities and theme constructor hooks
Library.Utils = {
    Tween = modules["Utils/Tween.lua"],
    Config = modules["Utils/Config.lua"],
    Notification = modules["Utils/Notification.lua"],
    Parallax = modules["Utils/Parallax.lua"],
    UIHelpers = modules["Utils/UIHelpers.lua"],
}

-- Expose Components as constructors
Library.Components = {
    Button = modules["Components/Button.lua"],
    Toggle = modules["Components/Toggle.lua"],
    Slider = modules["Components/Slider.lua"],
    Dropdown = modules["Components/Dropdown.lua"],
    Keybind = modules["Components/Keybind.lua"],
    ColorPicker = modules["Components/ColorPicker.lua"],
    Input = modules["Components/Input.lua"],
    Label = modules["Components/Label.lua"],
    Separator = modules["Components/Separator.lua"],
}

-- Expose Core classes
Library.Core = {
    Window = modules["Core/Window.lua"],
    Tab = modules["Core/Tab.lua"],
    Section = modules["Core/Section.lua"],
}

-- Expose themes
Library.Themes = {
    Default = modules["Themes/Default.lua"],
    Dark = modules["Themes/Dark.lua"],
    Light = modules["Themes/Light.lua"],
}

-- Convenience CreateWindow function that constructs a window using Core/Window
function Library:CreateWindow(opts)
    opts = opts or {}
    local WindowClass = Library.Core.Window
    local ok, winOrErr = pcall(function()
        return WindowClass.new(opts, Library)
    end)
    if not ok then
        error("[KrillField] Failed to create window: " .. tostring(winOrErr))
    end
    return winOrErr
end

-- Basic Notify wrapper (shortcut)
function Library:Notify(opts)
    opts = opts or {}
    local n = Library.Utils.Notification
    if type(n) == "table" and n.Notify then
        return n.Notify(opts)
    else
        warn("[KrillField] Notification utility missing or malformed.")
    end
end

-- Config helper
function Library:SaveConfig(name, tbl)
    return Library.Utils.Config.Save(name, tbl)
end
function Library:LoadConfig(name)
    return Library.Utils.Config.Load(name)
end

-- Expose a Destroy global to cleanup (closes all windows, disconnects parallax)
function Library:Destroy()
    LocalKrill_Cleanup = LocalKrill_Cleanup or {}
    for _, fn in pairs(LocalKrill_Cleanup) do
        pcall(fn)
    end
    -- More cleanup could be added here (e.g. remove created ScreenGuis)
end

-- Return the assembled library
return Library
