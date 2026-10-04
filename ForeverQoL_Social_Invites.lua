local ForeverQoL = select(2, ...)

local Invites = CreateFrame("Frame", "ForeverQoL_Invites")

-- Both announcements name the winner first and the loser second.
local CONST_DUEL_MESSAGES = {
    (DUEL_WINNER_KNOCKOUT:gsub("%%1$s", "(.+)"):gsub("%%2$s", "(.+)")),
    (DUEL_WINNER_RETREAT:gsub("%%1$s", "(.+)"):gsub("%%2$s", "(.+)")),
}

---Friends are never filtered, since blocking someone you know is never what was meant. Invites
---carry a realm on the name and the friends list does not, so both sides are trimmed.
local function IsFriend(name)
    if not name then
        return false
    end
    C_FriendList.ShowFriends()
    local shortName = strsplit("-", name)
    for index = 1, C_FriendList.GetNumFriends() do
        local friend = C_FriendList.GetFriendInfoByIndex(index)
        if friend and friend.name and strsplit("-", friend.name) == shortName then
            return true
        end
    end
    return false
end

---The system channel announces every duel on the realm, which is only worth reading when the
---player is in it.
local function FilterDuelSpam(_, _, message)
    if not ForeverQoLData.Configs["BlockDuelSpam"] then
        return false
    end
    local player = UnitName("player")
    for _, pattern in ipairs(CONST_DUEL_MESSAGES) do
        local winner, loser = string.match(message, pattern)
        if winner then
            return winner ~= player and loser ~= player
        end
    end
    return false
end

function Invites:OnEvent(event, name, _, _, _, _, _, inviterGUID)
    if event == "DUEL_REQUESTED" then
        if ForeverQoLData.Configs["BlockDuelRequests"] and not IsFriend(name) then
            CancelDuel()
            StaticPopup_Hide("DUEL_REQUESTED")
        end
    elseif event == "PARTY_INVITE_REQUEST" then
        -- Printed before any declining, so a blocked invite still says who it was from.
        if ForeverQoLData.Configs["ShowInviterInfo"] and inviterGUID then
            local class, _, race = GetPlayerInfoByGUID(inviterGUID)
            ForeverQoL.Print(string.format("Invite from %s, %s %s.", name, race or "", class or ""))
        end
        if ForeverQoLData.Configs["BlockPartyInvites"] and not IsFriend(name) then
            DeclineGroup()
            StaticPopup_Hide("PARTY_INVITE")
            StaticPopup_Hide("PARTY_INVITE_XREALM")
        end
    elseif event == "BN_FRIEND_INVITE_ADDED" and ForeverQoLData.Configs["BlockFriendRequests"] then
        for index = BNGetNumFriendInvites(), 1, -1 do
            local invite = C_BattleNet.GetFriendInviteInfo(index)
            if invite and invite.inviteID then
                BNDeclineFriendInvite(invite.inviteID)
                ForeverQoL.Print(string.format("Declined a friend request from %s.", invite.accountName or "?"))
            end
        end
    end
end

function Invites:Init()
    self:RegisterEvent("DUEL_REQUESTED")
    self:RegisterEvent("PARTY_INVITE_REQUEST")
    self:RegisterEvent("BN_FRIEND_INVITE_ADDED")
    self:SetScript("OnEvent", self.OnEvent)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", FilterDuelSpam)
end

ForeverQoL.Social.Invites = Invites
