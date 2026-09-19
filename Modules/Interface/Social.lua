---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- LUA API
local _G = _G

-- WoW API
local GetCVar = GetCVar
local SetCVar = SetCVar

local Social = ForeverQoL.CreateModule("Social", "PLAYER_ENTERING_WORLD")

local CHAT_SCALE = 1.1

function Social:UpdateChat()
	DEFAULT_CHATFRAME_ALPHA = 0
	CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA = 0.2

	-- The IM chat style leaves the edit box on screen at all times, and the reposition below
	-- would park it above the chat frame, in the middle of the screen, doing nothing
	if GetCVar("chatStyle") then
		SetCVar("chatStyle", "classic")
	end

	ChatFrame1:ClearAllPoints()
	ChatFrame1:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 0, 0)

	for i = 1, #CHAT_FRAMES do
		local frameName = "ChatFrame" .. i

		local chatFrame = _G[frameName]
		if chatFrame then
			chatFrame:SetClampedToScreen(not ForeverQoLData.Configs["DisableChatClamping"])
			chatFrame:SetClampRectInsets(0, 0, 0, 0)
			chatFrame:SetScale(CHAT_SCALE)

			local chatFrameXTab = _G[frameName .. 'Tab']
			if chatFrameXTab then
				chatFrameXTab:SetScale(CHAT_SCALE)
			end

			local editBox = _G[frameName .. 'EditBox']
			if editBox then
				-- Only the newer chat frame carries a scroll bar, without one there is no width to clear
				local scrollBar = chatFrame.ScrollBar

				editBox:ClearAllPoints()
				editBox:SetPoint('BOTTOMLEFT', chatFrame, 'TOPLEFT', 0, 3)
				editBox:SetPoint('BOTTOMRIGHT', chatFrame, 'TOPRIGHT', scrollBar and scrollBar:GetWidth() or 0, 3)
				editBox:SetScale(CHAT_SCALE)
			end
		end
	end

	if QuickJoinToastButton then
		QuickJoinToastButton:SetScale(CHAT_SCALE)
	end
end

function Social:OnEvent(event, ...)
	self:UpdateChat()
end

ForeverQoL.Interface.Social = Social
