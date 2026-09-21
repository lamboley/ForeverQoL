local ForeverQoL = select(2, ...)

local Chat = CreateFrame("Frame", "ForeverQoL_Chat")

function Chat:UpdateChat()
    DEFAULT_CHATFRAME_ALPHA = 0
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)

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

function Chat:Init()
    self:UpdateChat()
end

ForeverQoL.Social.Chat = Chat
