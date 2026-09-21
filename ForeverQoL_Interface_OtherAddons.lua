local ForeverQoL = select(2, ...)

local OtherAddons = CreateFrame("Frame", "ForeverQoL_OtherAddons")

function OtherAddons:UpdateGrid2()
    local Grid2Layout = _G.Grid2Layout
    if Grid2Layout and Grid2Layout.frame and Grid2Layout.db then
        Grid2Layout:RestorePositions()
    end
end

function OtherAddons:Init()
    if not ForeverQoLData.Configs["RestoreGrid2Positions"] then
        return
    end

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UI_SCALE_CHANGED")
    self:RegisterEvent("DISPLAY_SIZE_CHANGED")

    self:SetScript("OnEvent", self.UpdateGrid2)
end

ForeverQoL.Interface.OtherAddons = OtherAddons
