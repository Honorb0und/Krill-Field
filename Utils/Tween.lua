-- Utils/Tween.lua
-- Lightweight Tween helper wrapper with helpful defaults and safe pcall usage.
-- Exports: Tween(service, instance, props, options)
local TweenService = game:GetService("TweenService")

local Tween = {}

-- Default tween info
Tween.DefaultInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

-- Create and play tween; returns tween object and completedConn for promise-like usage
function Tween.Play(instance, props, info)
    if not instance or type(props) ~= "table" then
        warn("[KrillField.Tween] invalid arguments to Play")
        return nil
    end
    
    if not instance.Parent then
        warn("[KrillField.Tween] Tried to tween object without parent:", instance.Name or instance.ClassName)
        return nil
    end

    info = info or Tween.DefaultInfo
    local ok, tw = pcall(function()
        return TweenService:Create(instance, info, props)
    end)
    if not ok or not tw then
        warn("[KrillField.Tween] failed to create tween; fallback to instant set")
        for k, v in pairs(props) do
            pcall(function() instance[k] = v end)
        end
        return nil
    end

    local played = pcall(function() tw:Play() end)
    if not played then
        warn("[KrillField.Tween] failed to Play tween")
    end
    return tw
end

-- Tween to goal with callback on complete (safe)
function Tween.To(instance, props, info, onComplete)
    local tw = Tween.Play(instance, props, info)
    if tw and type(onComplete) == "function" then
        local conn
        conn = tw.Completed:Connect(function()
            pcall(onComplete)
            if conn then conn:Disconnect() end
        end)
    end
    return tw
end

-- Promise-style wait for tween
function Tween.WaitForComplete(tween)
    if not tween or not tween.Completed then
        return
    end
    local yield = Instance.new("BindableEvent")
    local conn
    conn = tween.Completed:Connect(function()
        pcall(function() yield:Fire() end)
        conn:Disconnect()
    end)
    yield.Event:Wait()
    yield:Destroy()
end

return {
    Play = Tween.Play,
    To = Tween.To,
    Wait = Tween.WaitForComplete,
    DefaultInfo = Tween.DefaultInfo
}

