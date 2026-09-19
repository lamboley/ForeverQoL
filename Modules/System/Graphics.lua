---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local tonumber = tonumber
local select = select
local abs = math.abs
local format = string.format
local max = math.max
local min = math.min

-- Sane bounds only. Whether the client accepts what is asked for is checked after the fact.
local MIN_SCALE = 0.4
local MAX_SCALE = 1.15

-- Guards the SetScale below against the UI_SCALE_CHANGED it fires itself
local applying = false

-- WoW API
local GetPhysicalScreenSize = GetPhysicalScreenSize
local SetCVar = SetCVar

local Graphics = ForeverQoL.CreateModule("Graphics", {
    "PLAYER_ENTERING_WORLD",
    "UI_SCALE_CHANGED",
    "DISPLAY_SIZE_CHANGED"
})

---Grid2 keeps its frame position in absolute screen pixels and registers no scale listener,
---so it never notices a scale change and has to be told to place its frames again.
local function RepositionScaleConsumers()
    local Grid2Layout = _G.Grid2Layout
    if Grid2Layout and Grid2Layout.frame and Grid2Layout.db and Grid2Layout.RestorePositions then
        Grid2Layout:RestorePositions()
    end
end

---Applies the pixel perfect UI scale.
---Idempotent, so it is safe to call from several events.
function Graphics.ApplyScale()
    if not ForeverQoLData.Configs["UsePerfectPixel"] then
        return
    end

    local screenHeight = tonumber(ForeverQoLData.Configs["UseCustomHeight"]) or select(2, GetPhysicalScreenSize())
    if not screenHeight or screenHeight <= 0 then
        return
    end

    local wanted = 768 / screenHeight
    local scale = max(MIN_SCALE, min(MAX_SCALE, wanted))

    -- Comparing against the scale actually in force, not against what was last asked for:
    -- the client resets UIParent while it finishes building its interface, and only this
    -- test notices the drift and puts the scale back on the next event.
    if abs(UIParent:GetScale() - scale) <= 0.0001 then
        return
    end

    -- SetScale fires UI_SCALE_CHANGED, which lands straight back here
    if applying then
        return
    end
    applying = true

    ForeverQoL.Info("Graphics: UI scale", UIParent:GetScale(), "->", scale)
    UIParent:SetScale(scale)
    applying = false

    -- The client silently keeps its own value when it considers the request out of range,
    -- which otherwise looks exactly like the option doing nothing at all
    local applied = UIParent:GetScale()
    if abs(applied - scale) > 0.0001 then
        ForeverQoL.Print(format("Asked for a UI scale of %.4f, the client kept %.4f.", scale, applied))
    end

    RepositionScaleConsumers()
end

function Graphics:OnEvent(event, ...)
    Graphics.ApplyScale()

    if event == "PLAYER_ENTERING_WORLD" and ForeverQoLData.Configs["MaxOutCameraDistance"] then
        SetCVar('cameraDistanceMaxZoomFactor', 2.6)
    end
end

ForeverQoL.System.Graphics = Graphics
