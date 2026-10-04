local ForeverQoL = select(2, ...)

local Quests = CreateFrame("Frame", "ForeverQoL_Quests")

function Quests:UntrackCompleted()
    local focused = C_SuperTrack.GetSuperTrackedQuestID()
    for index = C_QuestLog.GetNumQuestWatches(), 1, -1 do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(index)
        if questID and questID ~= focused and C_QuestLog.ReadyForTurnIn(questID) then
            C_QuestLog.RemoveQuestWatch(questID)
        end
    end
end

---Moves the tracker's focus, which is what the on-screen arrow and the map pin follow. Wraps
---at both ends so one key walks the whole list.
function Quests:FocusByDelta(delta)
    local total = C_QuestLog.GetNumQuestWatches()
    if total == 0 then
        return
    end

    -- With nothing focused yet, stepping forward lands on the first quest and back on the last.
    local focused = C_SuperTrack.GetSuperTrackedQuestID()
    local current = delta > 0 and 0 or 1
    for index = 1, total do
        if C_QuestLog.GetQuestIDForQuestWatchIndex(index) == focused then
            current = index
            break
        end
    end
    C_SuperTrack.SetSuperTrackedQuestID(C_QuestLog.GetQuestIDForQuestWatchIndex((current + delta - 1) % total + 1))
end

function Quests:Init()
    if ForeverQoLData.Configs["UntrackCompletedQuests"] then
        self:RegisterEvent("QUEST_LOG_UPDATE")
        self:RegisterEvent("QUEST_WATCH_UPDATE")
        self:SetScript("OnEvent", self.UntrackCompleted)
    end
end

-- Bindings.xml reaches these by name, so they have to be globals.
BINDING_HEADER_FOREVERQOL = "ForeverQoL"
BINDING_NAME_FOREVERQOL_FOCUS_NEXT_QUEST = "Focus Next Quest"
BINDING_NAME_FOREVERQOL_FOCUS_PREVIOUS_QUEST = "Focus Previous Quest"

function ForeverQoL_FocusNextQuest()
    Quests:FocusByDelta(1)
end

function ForeverQoL_FocusPreviousQuest()
    Quests:FocusByDelta(-1)
end

ForeverQoL.Interface.Quests = Quests
