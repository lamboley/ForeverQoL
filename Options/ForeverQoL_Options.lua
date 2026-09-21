local ForeverQoL = select(2, ...)

local DF = _G["DetailsFramework"]

local CONST_OPTIONSPANEL_WIDTH = 1100
local CONST_OPTIONSPANEL_HEIGHT = 670

local textTemplate = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local dropdownTemplate = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local switchTemplate = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local sliderTemplate = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local buttonTemplate = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local orangeTextTemplate = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")

local ForeverQoLOptions = DF:CreateSimplePanel(UIParent, CONST_OPTIONSPANEL_WIDTH, CONST_OPTIONSPANEL_HEIGHT, "Forever QoL", "ForeverQoLOptions")
ForeverQoLOptions.Title:SetAlpha(.75)
ForeverQoLOptions:SetFrameStrata("DIALOG")
ForeverQoLOptions:SetToplevel(true)
DF:ApplyStandardBackdrop(ForeverQoLOptions)

function ForeverQoLOptions:Init()
    local tabsContainer = DF:CreateTabContainer(self, "Forever QoL", "ForeverQoLOptionsTabsContainers",
        {
            {
                name = "System",
                text = "System"
            },
            {
                name = "Social",
                text = "Social"
            },
            {
                name = "Gameplay",
                text = "Gameplay"
            },
            {
                name = "Interface",
                text = "Interface"
            },
        },
        {
            width = CONST_OPTIONSPANEL_WIDTH,
            height = CONST_OPTIONSPANEL_HEIGHT - 10,
            backdrop_color = { 0, 0, 0, 0 },
            button_width = 108,
            close_text_alpha = 0.4,
            container_width_offset = 30,
            backdrop_border_color = { 0.1, 0.1, 0.1, 0.4 }
        }
    )
    tabsContainer:SetPoint("CENTER", self, "CENTER", 0, 0)

    for _, frame in ipairs(tabsContainer.AllFrames) do
		local frameBackgroundTexture = frame:CreateTexture(nil, "artwork")
		frameBackgroundTexture:SetPoint("topleft", frame, "topleft", 1, -85)
		frameBackgroundTexture:SetPoint("bottomright", frame, "bottomright", -1, 20)
		frameBackgroundTexture:SetColorTexture (0.2317647, 0.2317647, 0.2317647)
		frameBackgroundTexture:SetVertexColor (0.27, 0.27, 0.27)
		frameBackgroundTexture:SetAlpha (0.3)

		local frameBackgroundTextureTopLine = frame:CreateTexture(nil, "artwork")
		frameBackgroundTextureTopLine:SetPoint("bottomleft", frameBackgroundTexture, "topleft", 0, 0)
		frameBackgroundTextureTopLine:SetPoint("bottomright", frame, "topright", -1, 0)
		frameBackgroundTextureTopLine:SetHeight(1)
		frameBackgroundTextureTopLine:SetColorTexture(0.1215, 0.1176, 0.1294)
		frameBackgroundTextureTopLine:SetAlpha(1)
	end

    -- System
    DF:BuildMenu(tabsContainer:GetTabFrameByName("System"),
        {
            { -- General
                type = "label",
                get = function() return "General" end,
                text_template = orangeTextTemplate
            },
            { -- Max Out Camera Distance
                type = "toggle",
                boxfirst = true,
                name = "Max Out Camera Distance",
                desc = ForeverQoL.L["A /reload may be required to take effect."],
                get = function() return ForeverQoLData.Configs["MaxOutCameraDistance"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["MaxOutCameraDistance"] = value
                end,
            },
            {
                type = "breakline"
            },
            { -- Graphics
                type = "label",
                get = function() return "Graphics" end,
                text_template = orangeTextTemplate
            },
            { -- Use Perfect Pixel
                type = "toggle",
                boxfirst = true,
                name = "Use Perfect Pixel",
                desc = "Set the UI Scale based on the vertical resolution (UIScale = 768 / verticalResolution). Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["UsePerfectPixel"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["UsePerfectPixel"] = value
                end,
            },
            { -- Use Custom Height
                type = "textentry",
                name = "Use Custom Height",
                desc = "If the UI is too small when using the option above, you can set a custom vertical resolution here. Requires /reload to take effect",
                CONST_OPTIONSPANEL_WIDTH = 50,
                get = function() return ForeverQoLData.Configs["UseCustomHeight"] or "" end,
                set = function(_, _, value)
                    local height = tonumber(value)
                    if height and height >= 480 and height <= 4320 then
                        ForeverQoLData.Configs["UseCustomHeight"] = value
                    else
                        ForeverQoL.Print("Custom height must be between 480-4320")
                    end
                end,
                hooks = {
                    OnEditFocusLost = function(self)
                        self:SetText(ForeverQoLData.Configs["UseCustomHeight"])
                    end,
                    OnEnterPressed = function(self) return end
                },
            },
            {
                type = "breakline",
                spacement = true,
            },
            { -- Audio
                type = "label",
                get = function() return "Audio" end,
                text_template = orangeTextTemplate
            },
            { -- Mute Annoying Sound
                type = "toggle",
                boxfirst = true,
                name = "Mute Annoying Sound",
                desc = "Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["MuteAnnoyingSound"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["MuteAnnoyingSound"] = value
                end,
            },
        },
        10, -100, CONST_OPTIONSPANEL_HEIGHT - 10, false,
        textTemplate,  dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    -- Social
    DF:BuildMenu(tabsContainer:GetTabFrameByName("Social"),
        {
            { -- Chat
                type = "label",
                get = function() return "Chat" end,
                text_template = orangeTextTemplate
            },
            { -- Disable Chat Clamping
                type = "toggle",
                boxfirst = true,
                name = "Disable Chat Clamping",
                desc = "Let the chat windows be dragged past the edge of the screen",
                get = function() return ForeverQoLData.Configs["DisableChatClamping"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["DisableChatClamping"] = value
                    ForeverQoL.Social.Chat:UpdateChat()
                end,
            },
        },
        10, -100, CONST_OPTIONSPANEL_HEIGHT - 10, false,
        textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    -- Gameplay
    local gameplayFrame = tabsContainer:GetTabFrameByName("Gameplay")
    DF:BuildMenu(gameplayFrame,
        {
            { -- General
                type = "label",
                get = function() return "General" end,
                text_template = orangeTextTemplate
            },
            { -- Auto Group Chat
                type = "toggle",
                boxfirst = true,
                name = "Auto Group Chat",
                desc = "Switch default chat to party, raid, or instance chat when joining a group",
                get = function() return ForeverQoLData.Configs.AutoGroupChat end,
                set = function(_, _, value)
                    ForeverQoLData.Configs.AutoGroupChat = value
                    ForeverQoL.Gameplay:UpdateGroupChat()
                end,
            },
            { -- Faster Auto Loot
                type = "toggle",
                boxfirst = true,
                name = "Faster Auto Loot",
                get = function() return ForeverQoLData.Configs["FasterAutoLoot"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["FasterAutoLoot"] = value
                end,
            },
            {
                type = "breakline"
            },
            { -- Merchant
                type = "label",
                get = function() return "Merchant" end,
                text_template = orangeTextTemplate
            },
            { -- Repair Gear Automatically
                type = "toggle",
                boxfirst = true,
                name = "Repair Gear Automatically",
                get = function() return ForeverQoLData.Configs["RepairGearAutomatically"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["RepairGearAutomatically"] = value
                end,
            },
            { -- Use Guild Bank For Repair
                type = "toggle",
                boxfirst = true,
                name = "Use Guild Bank For Repair",
                get = function() return ForeverQoLData.Configs["UseGuildBankForRepair"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["UseGuildBankForRepair"] = value
                end,
            },
            { -- Sell Junk Automatically
                type = "toggle",
                boxfirst = true,
                name = "Sell Junk Automatically",
                desc = "Sell every grey item in the bags",
                get = function() return ForeverQoLData.Configs["SellJunkAutomatically"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["SellJunkAutomatically"] = value
                end,
            },
            { -- Keep Grey Gear
                type = "toggle",
                boxfirst = true,
                name = "Keep Grey Gear",
                desc = "Spare grey weapons and armour, sell the rest. Put one on the list below to sell it anyway",
                get = function() return ForeverQoLData.Configs["KeepGreyGear"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["KeepGreyGear"] = value
                end,
            },
            { -- Sell Listed Items Automatically
                type = "toggle",
                boxfirst = true,
                name = "Sell Listed Items Automatically",
                desc = "Also sell every item on the list below, whatever its quality",
                get = function() return ForeverQoLData.Configs["SellListedItemsAutomatically"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["SellListedItemsAutomatically"] = value
                end,
            },
            { -- Manage The Sell List
                type = "execute",
                name = "Manage My Sell List",
                desc = "Open the list of items sold on sight, to add to it or take from it",
                func = function()
                    self:ToggleAutoSellList()
                end,
            },
            {
                type = "blank"
            },
            { -- Bank
                type = "label",
                get = function() return "Bank" end,
                text_template = orangeTextTemplate
            },
            { -- Deposit Excess Gold To Bank
                type = "toggle",
                boxfirst = true,
                name = "Deposit Excess Gold To Bank",
                desc = "When the bank is opened, move everything above the amount below",
                get = function() return ForeverQoLData.Configs["DepositExcessGoldToBank"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["DepositExcessGoldToBank"] = value
                end,
            },
            { -- Keep Gold Amount
                type = "textentry",
                name = "Gold To Keep",
                desc = "How much gold stays on the character, silver and copper are never moved",
                CONST_OPTIONSPANEL_WIDTH = 90,
                get = function() return ForeverQoLData.Configs["KeepGoldAmount"] or "" end,
                set = function(_, _, value)
                    local amount = tonumber(value)
                    if amount and amount >= 0 then
                        ForeverQoLData.Configs["KeepGoldAmount"] = tostring(math.floor(amount))
                    else
                        ForeverQoL.Print("Gold to keep must be a positive number")
                    end
                end,
                hooks = {
                    OnEditFocusLost = function(self)
                        self:SetText(ForeverQoLData.Configs["KeepGoldAmount"])
                    end,
                    OnEnterPressed = function(self) return end
                },
            },
            { -- Deposit Listed Items To Bank
                type = "toggle",
                boxfirst = true,
                name = "Deposit Listed Items",
                desc = "Move every item on the list below into whichever bank tab is open",
                get = function() return ForeverQoLData.Configs["DepositListedItemsToBank"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["DepositListedItemsToBank"] = value
                end,
            },
            { -- Manage The Deposit List
                type = "execute",
                name = "Manage My Deposit List",
                desc = "Open the list of items sent to the bank on sight, to add to it or take from it",
                func = function()
                    self:ToggleAutoDepositList()
                end,
            },

        },
        10, -100, CONST_OPTIONSPANEL_HEIGHT - 10, false,
        textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    -- Interface
    DF:BuildMenu(tabsContainer:GetTabFrameByName("Interface"),
        {
            { -- General
                type = "label",
                get = function() return "General" end,
                text_template = orangeTextTemplate
            },
            { -- Tint Known At Merchant
                type = "toggle",
                boxfirst = true,
                name = "Tint Known Items At Merchants",
                desc = "Colour already collected items green. Turn off AlreadyKnown if you use it, or both will tint",
                get = function() return ForeverQoLData.Configs["TintKnownAtMerchant"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["TintKnownAtMerchant"] = value
                end,
            },
            { -- Tint Unusable In Bags
                type = "toggle",
                boxfirst = true,
                name = "Mark Unusable Items In Red",
                desc = "Colour items your character cannot use red in the default bags. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["TintUnusableInBags"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["TintUnusableInBags"] = value
                end,
            },
            {
                type = "blank"
            },
            { -- Quests
                type = "label",
                get = function() return "Quests" end,
                text_template = orangeTextTemplate
            },
            { -- Untrack Completed Quests
                type = "toggle",
                boxfirst = true,
                name = "Untrack Completed Quests",
                desc = "Drop a quest from the tracker as soon as it is ready for turn-in",
                get = function() return ForeverQoLData.Configs["UntrackCompletedQuests"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["UntrackCompletedQuests"] = value
                    ForeverQoL.Interface.Quests:UntrackCompleted()
                end,
            },
            {
                type = "blank"
            },
            { -- Visibility
                type = "label",
                get = function() return "Visibility" end,
                text_template = orangeTextTemplate
            },
            { -- Disable Damage Text
                type = "select",
                name = "Floating Combat Text",
                desc = "Covers damage, healing, periodic ticks and pet damage",
                get = function() return ForeverQoLData.Configs["FloatingCombatTextVisibility"] end,
                values = function() return ForeverQoL.Interface.Visibility:GetCombatTextOptions() end,
            },
            { -- Hide Tooltip While In Combat
                type = "toggle",
                boxfirst = true,
                name = "Hide Tooltip While In Combat",
                desc = "Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["HideTooltipWhileInCombat"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["HideTooltipWhileInCombat"] = value
                end,
            },
            { -- Bag Bar Visibility
                type = "select",
                name = "Bag Bar Visibility",
                desc = "The bag slots bar next to the micro menu",
                get = function() return ForeverQoLData.Configs["BagBarVisibility"] end,
                values = function() return ForeverQoL.Interface.Visibility:GetVisibilityOptions("BagBarVisibility") end,
            },
            { -- Micro Menu Visibility
                type = "select",
                name = "Micro Menu Visibility",
                desc = "The row of menu buttons, character sheet through game menu",
                get = function() return ForeverQoLData.Configs["MicroMenuVisibility"] end,
                values = function() return ForeverQoL.Interface.Visibility:GetVisibilityOptions("MicroMenuVisibility") end,
            },
            { -- Status Bar Visibility
                type = "select",
                name = "Status Bar Visibility",
                desc = "The experience and reputation bar",
                get = function() return ForeverQoLData.Configs["StatusBarVisibility"] end,
                values = function() return ForeverQoL.Interface.Visibility:GetVisibilityOptions("StatusBarVisibility") end,
            },
            {
                type = "blank"
            },
            { -- Other Addons
                type = "label",
                get = function() return "Other Addons" end,
                text_template = orangeTextTemplate
            },
            { -- Grid2
                type = "toggle",
                boxfirst = true,
                name = "Restore Grid2 Positions",
                desc = "Restore Grid2's saved positions when entering the world or changing UI scale or display size. Requires Grid2.",
                get = function() return ForeverQoLData.Configs["RestoreGrid2Positions"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["RestoreGrid2Positions"] = value
                    ForeverQoL.Interface.OtherAddons:UpdateGrid2()
                end,
            },
        },
        10, -100, CONST_OPTIONSPANEL_HEIGHT - 10, false,
        textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )
end

function ForeverQoLOptions:ToggleOptions()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

ForeverQoL.ForeverQoLOptions = ForeverQoLOptions
