local ForeverQoL = select(2, ...)

local Quests = CreateFrame("Frame", "ForeverQoL_Quests")

function Quests:UntrackCompleted()
    for index = C_QuestLog.GetNumQuestWatches(), 1, -1 do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(index)
        if questID and C_QuestLog.ReadyForTurnIn(questID) then
            C_QuestLog.RemoveQuestWatch(questID)
        end
    end
end

function Quests:Init()
    if ForeverQoLData.Configs["UntrackCompletedQuests"] then
        self:RegisterEvent("QUEST_LOG_UPDATE")
        self:RegisterEvent("QUEST_WATCH_UPDATE")
        self:SetScript("OnEvent", self.UntrackCompleted)
    end
end

ForeverQoL.Interface.Quests = Quests
