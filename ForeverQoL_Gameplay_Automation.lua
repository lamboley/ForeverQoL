local ForeverQoL = select(2, ...)

local Automation = CreateFrame("Frame", "ForeverQoL_Automation")

function Automation:OnEvent(event)
    if event == "RESURRECT_REQUEST" and ForeverQoLData.Configs["AutoAcceptResurrect"] then
        AcceptResurrect()
    elseif event == "CONFIRM_SUMMON" and ForeverQoLData.Configs["AutoAcceptSummon"] then
        local summoner = C_SummonInfo.GetSummonConfirmSummoner()
        C_SummonInfo.ConfirmSummon()
        StaticPopup_Hide("CONFIRM_SUMMON")
        if summoner and ForeverQoLData.Configs["ThankOnSummon"] then
            SendChatMessage(ForeverQoLData.Configs["ThankOnSummonMessage"], "WHISPER", nil, summoner)
        end
    elseif event == "LFG_ROLE_CHECK_SHOW" and ForeverQoLData.Configs["AutoConfirmRoleCheck"] then
        CompleteLFGRoleCheck(true)
    elseif event == "PLAYER_DEAD" and ForeverQoLData.Configs["AutoReleaseInPvP"] then
        local _, instanceType = IsInInstance()
        if instanceType == "pvp" or instanceType == "arena" then
            RepopMe()
        end
    end
end

function Automation:Init()
    self:RegisterEvent("RESURRECT_REQUEST")
    self:RegisterEvent("CONFIRM_SUMMON")
    self:RegisterEvent("LFG_ROLE_CHECK_SHOW")
    self:RegisterEvent("PLAYER_DEAD")
    self:SetScript("OnEvent", self.OnEvent)
end

ForeverQoL.Gameplay.Automation = Automation
