local ForeverQoL = select(2, ...)

local Gameplay = CreateFrame("Frame", "ForeverQoL_Gameplay")

local lootFrameAlpha

function Gameplay:UpdateAutoLoot()
    if ForeverQoLData.Configs["FasterAutoLoot"] then
        if lootFrameAlpha == nil then
            lootFrameAlpha = LootFrame:GetAlpha()
        end
        LootFrame:SetAlpha(0)
        for i = 1, GetNumLootItems() do
            LootSlot(i)
        end
    elseif lootFrameAlpha ~= nil then
        LootFrame:SetAlpha(lootFrameAlpha)
        lootFrameAlpha = nil
    end
end

function Gameplay:UpdateGroupChat()
    if not ForeverQoLData.Configs.AutoGroupChat then
        self.groupChatType = nil
        return
    end

    local chatType
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        chatType = "INSTANCE_CHAT"
    elseif IsInRaid() then
        chatType = "RAID"
    elseif IsInGroup() then
        chatType = "PARTY"
    end

    -- Roster changes within the same group must not override a manually chosen channel.
    if chatType == self.groupChatType then
        return
    end
    local previousType = self.groupChatType
    self.groupChatType = chatType

    for _, frameName in ipairs(CHAT_FRAMES) do
        local editBox = _G[frameName .. "EditBox"]
        if editBox then
            local targetType = chatType or "SAY"
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
    self:SetScript("OnEvent", function(self, event)
        if event == "LOOT_READY" then
            self:UpdateAutoLoot()
        else
            self:UpdateGroupChat()
        end
    end)
    self:UpdateGroupChat()

    self.Merchant:Init()
    self.Bank:Init()
end

ForeverQoL.Gameplay = Gameplay
