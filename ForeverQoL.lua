local ForeverQoL = select(2, ...)

function ForeverQoL.Print(...)
	print("|cff00D9FFFQL:|r", ...)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= "ForeverQoL" then return end

        ForeverQoL:CreateDefaultSettings()
        ForeverQoL:CreateDataTables()
    elseif event == "PLAYER_LOGIN" then
        ForeverQoL.ForeverQoLGui:Init()

        ForeverQoL.System:Init()
        ForeverQoL.Social:Init()
        ForeverQoL.Gameplay:Init()
        ForeverQoL.Interface:Init()
    end
end)
