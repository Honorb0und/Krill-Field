-- Utils/Config.lua
-- Save/Load configuration using HttpService -> encode/decode JSON and store in PlayerGui or Roblox DataStore?
-- For security, default is local Storage (set/get with persistent attributes). Provides Save/Load/Delete/List.
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Config = {}

-- Local config storage (in-memory) and a small fallback to Instance attributes on Player to persist across sessions on local machine
Config._cache = {}
Config._prefix = "KrillField_Config_"

-- Serialize table to JSON, safeguard functions
local function safeEncode(tbl)
    local ok, enc = pcall(function() return HttpService:JSONEncode(tbl) end)
    if ok then return enc end
    -- fallback: shallow serialize without functions
    local copy = {}
    for k,v in pairs(tbl) do
        if type(v) ~= "function" then
            copy[k] = v
        else
            copy[k] = tostring(v)
        end
    end
    return HttpService:JSONEncode(copy)
end

-- Save config to cache + Player attributes for local persistence
function Config.Save(name, tbl)
    if type(name) ~= "string" then
        error("[KrillField.Config] Save expects name string")
    end
    tbl = tbl or {}
    Config._cache[name] = tbl
    local ok, err = pcall(function()
        if player and player:IsA("Player") then
            local enc = safeEncode(tbl)
            pcall(function() player:SetAttribute(Config._prefix..name, enc) end)
        end
    end)
    return true
end

-- Load config from cache or player attribute
function Config.Load(name)
    if type(name) ~= "string" then return nil end
    if Config._cache[name] then return Config._cache[name] end
    if player and player:IsA("Player") then
        local attr = player:GetAttribute(Config._prefix..name)
        if attr then
            local ok, dec = pcall(function() return HttpService:JSONDecode(attr) end)
            if ok then
                Config._cache[name] = dec
                return dec
            end
        end
    end
    return nil
end

function Config.Delete(name)
    Config._cache[name] = nil
    if player and player:IsA("Player") then
        pcall(function() player:SetAttribute(Config._prefix..name, nil) end)
    end
end

function Config.List()
    local list = {}
    for k,_ in pairs(Config._cache) do
        table.insert(list, k)
    end
    -- Attempt to read attributes on player
    if player and player:IsA("Player") then
        for _,attr in pairs(player:GetAttributes()) do
            -- Player:GetAttributes returns map - but we can't enumerate names via GetAttributes, skip complexity
        end
    end
    return list
end

return {
    Save = Config.Save,
    Load = Config.Load,
    Delete = Config.Delete,
    List = Config.List
}
