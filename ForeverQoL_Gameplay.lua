local ForeverQoL = select(2, ...)

local Gameplay = CreateFrame("Frame", "ForeverQoL_Gameplay")

local lootFrameAlpha

function Gameplay:UpdateAutoLoot()
    if ForeverQoLData.Configs["FasterAutoLoot"] then
        lootFrameAlpha = lootFrameAlpha or LootFrame:GetAlpha()
        LootFrame:SetAlpha(0)
        for i = 1, GetNumLootItems() do
            LootSlot(i)
        end
    elseif lootFrameAlpha then
        LootFrame:SetAlpha(lootFrameAlpha)
        lootFrameAlpha = nil
    end
end

function Gameplay:UpdateGroupChat()
    if not ForeverQoLData.Configs.AutoGroupChat then
        self.groupChatType = nil
        return
    end

    local chatType = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT"
        or IsInRaid() and "RAID"
        or IsInGroup() and "PARTY"
        or nil

    -- Roster changes within the same group must not override a manually chosen channel.
    if chatType == self.groupChatType then
        return
    end
    local previousType = self.groupChatType
    local targetType = chatType or "SAY"
    self.groupChatType = chatType

    for _, frameName in ipairs(CHAT_FRAMES) do
        local editBox = _G[frameName .. "EditBox"]
        if editBox then
            if chatType or editBox:GetAttribute("stickyType") == previousType then
                editBox:SetAttribute("stickyType", targetType)
            end
            -- Keep the recipient of an unfinished message intact.
            if editBox:GetText() == "" and (chatType or editBox:GetAttribute("chatType") == previousType) then
                editBox:SetAttribute("chatType", targetType)
                editBox:UpdateHeader()
            end
        end
    end
end

function Gameplay:Init()
    self:RegisterEvent("LOOT_READY")
    self:RegisterEvent("GROUP_ROSTER_UPDATE")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", function(frame, event)
        if event == "LOOT_READY" then
            frame:UpdateAutoLoot()
        else
            frame:UpdateGroupChat()
        end
    end)
    self:UpdateGroupChat()
    self.Merchant:Init()
    self.Bank:Init()
end

ForeverQoL.Gameplay = Gameplay
