local ForeverQoL = select(2, ...)

local Chat = CreateFrame("Frame", "ForeverQoL_Chat")

local CONST_HISTORY_LINES = 128
-- Anything slower than this was a logout, not a reload, and the player has moved on.
local CONST_HISTORY_MAX_AGE = 20

function Chat:UpdateChat()
    DEFAULT_CHATFRAME_ALPHA = 0
    for _, frameName in ipairs(CHAT_FRAMES) do
        local chatFrame = _G[frameName]
        if chatFrame then
            chatFrame:SetClampedToScreen(not ForeverQoLData.Configs["DisableChatClamping"])
            chatFrame:SetClampRectInsets(0, 0, 0, 0)
            local editBox = _G[frameName .. "EditBox"]
            if editBox then
                local scrollBar = chatFrame.ScrollBar
                editBox:ClearAllPoints()
                editBox:SetPoint("BOTTOMLEFT", chatFrame, "TOPLEFT", 0, 3)
                editBox:SetPoint("BOTTOMRIGHT", chatFrame, "TOPRIGHT", scrollBar and scrollBar:GetWidth() or 0, 3)
            end
        end
    end
end

function Chat:SaveHistory()
    local history = { player = UnitName("player"), time = time(), frames = {} }
    for _, frameName in ipairs(CHAT_FRAMES) do
        local chatFrame = _G[frameName]
        local total = chatFrame and chatFrame:GetNumMessages() or 0
        -- The combat log is rebuilt by the game, so replaying it would only add stale lines.
        if total > 0 and frameName ~= "ChatFrame2" then
            local lines = {}
            for index = math.max(1, total - CONST_HISTORY_LINES + 1), total do
                local message, r, g, b = chatFrame:GetMessageInfo(index)
                if message then
                    -- The colour lives outside the text, so it has to be baked in to survive.
                    lines[#lines + 1] = string.format("|cff%02x%02x%02x%s|r",
                        math.floor((r or 1) * 255), math.floor((g or 1) * 255), math.floor((b or 1) * 255), message)
                end
            end
            history.frames[frameName] = lines
        end
    end
    ForeverQoLData.ChatHistory = history
end

---Replayed only after a reload: an older snapshot is from a session the player has left behind,
---and another character's chat is not theirs to read.
function Chat:RestoreHistory()
    local history = ForeverQoLData.ChatHistory
    ForeverQoLData.ChatHistory = nil
    if not history or history.player ~= UnitName("player") or time() - history.time > CONST_HISTORY_MAX_AGE then
        return
    end
    for frameName, lines in pairs(history.frames) do
        local chatFrame = _G[frameName]
        if chatFrame then
            for _, line in ipairs(lines) do
                chatFrame:AddMessage(line)
            end
        end
    end
end

function Chat:Init()
    self:UpdateChat()

    if ForeverQoLData.Configs["RestoreChatMessages"] then
        self:RestoreHistory()
        self:RegisterEvent("PLAYER_LOGOUT")
        self:SetScript("OnEvent", self.SaveHistory)
    end
end

ForeverQoL.Social.Chat = Chat
