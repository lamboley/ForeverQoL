local ForeverQoL = select(2, ...)

local Graphics = CreateFrame("Frame", "ForeverQoL_Graphics")

local CONST_MINIMUM_SCALE = 0.4
local CONST_MAXIMUM_SCALE = 1.15

function Graphics:SetPerfectPixelScale()
    local screenHeight = tonumber(ForeverQoLData.Configs["UseCustomHeight"]) or select(2, GetPhysicalScreenSize())
    local scale = math.max(CONST_MINIMUM_SCALE, math.min(CONST_MAXIMUM_SCALE, 768 / screenHeight))
    UIParent:SetScale(scale)
end

function Graphics:Init()
    if ForeverQoLData.Configs["UsePerfectPixel"] then
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("DISPLAY_SIZE_CHANGED")

        self:SetScript("OnEvent", self.SetPerfectPixelScale)
    end
end

ForeverQoL.System.Graphics = Graphics
