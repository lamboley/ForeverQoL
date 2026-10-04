std = "lua51"
max_line_length = false
exclude_files = { "Libs/" }
ignore = {
	"11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
	"11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
	"113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"212", -- Unused argument
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable
}
globals = {
	-- ForeverQoL
	"ForeverQoLData", "ForeverQoL_FocusNextQuest", "ForeverQoL_FocusPreviousQuest",

	-- Third Party
	"LibStub",

	-- WoW Namespaces
	"C_Bank", "C_BattleNet", "C_Container", "C_CurrencyInfo", "C_FriendList", "C_Item",
	"C_QuestLog", "C_SummonInfo", "C_SuperTrack", "C_TooltipInfo", "C_TransmogCollection",
	"Enum", "Item", "PixelUtil",

	-- WoW Frames
	"ActionBarButtonEventsFrame", "BagsBar", "BossBanner", "EventToastManagerFrame",
	"GameTooltip", "LootFrame", "MainStatusTrackingBarContainer", "MerchantFrame",
	"MicroMenuContainer", "SubZoneTextFrame", "TooltipDataProcessor", "UIErrorsFrame",
	"UIParent", "ZoneTextFrame",

	-- WoW Constants
	"CANNOT_UNEQUIP_COMBAT", "CHAT_FRAMES", "DEFAULT_CHATFRAME_ALPHA", "DELETE_ITEM_CONFIRM_STRING",
	"DUEL_WINNER_KNOCKOUT", "DUEL_WINNER_RETREAT", "ITEM_COSMETIC",
	"ITEM_DISENCHANT_NOT_DISENCHANTABLE", "ITEM_PET_KNOWN", "ITEM_QUALITY_COLORS",
	"ITEM_SCRAPABLE_NOT", "ITEM_SPELL_KNOWN", "MERCHANT_ITEMS_PER_PAGE", "NUM_BAG_SLOTS",
	"RED_FONT_COLOR", "TARGET",

	-- WoW Functions
	"AcceptResurrect", "BNDeclineFriendInvite", "BNGetNumFriendInvites", "BuyMerchantItem",
	"CanMerchantRepair", "CancelDuel", "ChatFrame_AddMessageEventFilter", "ClearCursor",
	"CompleteLFGRoleCheck", "CreateFrame", "DeclineGroup", "GetCursorInfo", "GetGuildInfo",
	"GetLocale", "GetMerchantItemLink", "GetMerchantNumItems", "GetMoney", "GetNumLootItems",
	"GetPhysicalScreenSize", "GetPlayerInfoByGUID", "GetRepairAllCost", "GetSpecialization",
	"GetSpecializationRole", "IsInGroup", "IsInInstance", "IsInRaid", "LootSlot",
	"MerchantFrame_UpdateMerchantInfo", "MuteSoundFile", "ReloadUI", "RepairAllItems", "RepopMe",
	"SendChatMessage", "SetCVar", "SetItemButtonNameFrameVertexColor",
	"SetItemButtonNormalTextureVertexColor", "SetItemButtonSlotVertexColor",
	"SetItemButtonTextureVertexColor", "SlashCmdList", "StaticPopup_FindVisible",
	"StaticPopup_Hide", "StaticPopup_Show", "UnitAffectingCombat", "UnitName", "hooksecurefunc",
	"strsplit", "time", "wipe",
}
