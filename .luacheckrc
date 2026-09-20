std = "lua51"
max_line_length = false
exclude_files = {
	"Libs/",
	".luacheckrc"
}
ignore = {
	"11./SLASH_.*", -- Setting an undefined (Slash handler) global variable
	"11./BINDING_.*", -- Setting an undefined (Keybinding header) global variable
	"113/LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"113/NUM_LE_.*", -- Accessing an undefined (Lua ENUM type) global variable
	"211", -- Unused local variable
	"211/L", -- Unused local variable "L"
	"211/CL", -- Unused local variable "CL"
	"212", -- Unused argument
	"213", -- Unused loop variable
	"214", -- unused hint
	-- "231", -- Set but never accessed
	"311", -- Value assigned to a local variable is unused
	"314", -- Value of a field in a table literal is unused
	"42.", -- Shadowing a local variable, an argument, a loop variable.
	"43.", -- Shadowing an upvalue, an upvalue argument, an upvalue loop variable.
	"542", -- An empty if branch
	"581", --  error-prone operator orders
	"582", --  error-prone operator orders
}
globals = {
	-- ForeverQoL
	"ForeverQoLData",

	-- Third Party
	"LibStub",

	-- WoW Namespaces
	"BagsBar",
	"MainStatusTrackingBarContainer",
	"MicroMenuContainer",
	"CHAT_FRAMES",
	"ChatFrame1",
	"QuickJoinToastButton",
	"CHAT_FRAME_BUTTON_FRAME_MIN_ALPHA",
	"DEFAULT_CHATFRAME_ALPHA",
	"C_Bank",
	"C_HousingCatalog",
	"C_Container",
	"C_Item",
	"C_TooltipInfo",
	"C_TradeSkillUI",
	"C_TransmogCollection",
	"C_QuestLog",
	"ContainerFrameMixin",
	"DFPixelUtil",
	"PixelUtil",
	"C_Timer",
	"Enum",
	"Item",

	-- WoW Frames
	"DEFAULT_CHAT_FRAME",
	"GameTooltip",
	"LootFrame",
	"MerchantFrame",
	"ProfessionsFrame",
	"ProfessionsRecipeListRecipeMixin",
	"UIParent",

	-- WoW Constants
	"ITEM_COSMETIC",
	"ITEM_QUALITY_COLORS",
	"ITEM_PET_KNOWN",
	"ITEM_SPELL_KNOWN",
	"MERCHANT_ITEMS_PER_PAGE",
	"NUM_BAG_SLOTS",
	"TOY",

	-- WoW Functions
	"CanMerchantRepair",
	"ClearCursor",
	"CreateFrame",
	"GetCursorInfo",
	"GetCVar",
	"GetGuildInfo",
	"GetLocale",
	"GetMoney",
	"GetRealmName",
	"GetMerchantItemLink",
	"GetNumLootItems",
	"GetPhysicalScreenSize",
	"GetSpecialization",
	"GetSpecializationRole",
	"LootSlot",
	"MerchantFrame_UpdateMerchantInfo",
	"MouselookStart",
	"MouselookStop",
	"MuteSoundFile",
	"PlaySoundFile",
	"RegisterStateDriver",
	"ReloadUI",
	"RepairAllItems",
	"SetCVar",
	"SetItemButtonNameFrameVertexColor",
	"SetItemButtonNormalTextureVertexColor",
	"SetItemButtonSlotVertexColor",
	"SetItemButtonTextureVertexColor",
	"SlashCmdList",
	"UnitAffectingCombat",
	"UnitClass",
	"UnitName",
	"hooksecurefunc",
	"time",
	"wipe",
}
