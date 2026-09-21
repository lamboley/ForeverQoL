local ForeverQoL = select(2, ...)

local Graphics = CreateFrame("Frame", "ForeverQoL_Graphics")

local CONST_MINIMUM_SCALE, CONST_MAXIMUM_SCALE = 0.4, 1.15

function Graphics:SetPerfectPixelScale()
    local screenHeight = tonumber(ForeverQoLData.Configs["UseCustomHeight"]) or select(2, GetPhysicalScreenSize())
    UIParent:SetScale(math.max(CONST_MINIMUM_SCALE, math.min(CONST_MAXIMUM_SCALE, 768 / screenHeight)))
end

function Graphics:Init()
    if ForeverQoLData.Configs["UsePerfectPixel"] then
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("DISPLAY_SIZE_CHANGED")
        self:SetScript("OnEvent", self.SetPerfectPixelScale)
    end
end

ForeverQoL.System.Graphics = Graphics
