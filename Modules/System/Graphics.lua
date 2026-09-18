---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local tonumber = tonumber
local select = select
local abs = math.abs
local max = math.max
local min = math.min

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
        ForeverQoL.Debug("Graphics: asking Grid2 to restore its positions")
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

    local scale = max(0.4, min(1.15, 768 / screenHeight))

    -- SetScale fires UI_SCALE_CHANGED, which lands back here, this early return stops the recursion
    if abs(UIParent:GetScale() - scale) <= 0.0001 then
        return
    end

    ForeverQoL.Debug("Graphics: UI scale", UIParent:GetScale(), "->", scale)
    UIParent:SetScale(scale)
    RepositionScaleConsumers()
end

function Graphics:OnEvent(event, ...)
    Graphics.ApplyScale()

    if event == "PLAYER_ENTERING_WORLD" and ForeverQoLData.Configs["MaxOutCameraDistance"] then
        SetCVar('cameraDistanceMaxZoomFactor', 2.6)
    end
end

ForeverQoL.System.Graphics = Graphics
