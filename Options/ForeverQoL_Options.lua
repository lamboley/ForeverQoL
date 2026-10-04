local ForeverQoL = select(2, ...)

local DF = _G["DetailsFramework"]

local CONST_OPTIONSPANEL_WIDTH = 1100
local CONST_OPTIONSPANEL_HEIGHT = 670

-- How far a column may run before BuildMenu wraps it into the next one, roughly one
-- widget per 20. Raise it per tab, the way Details does, when a section needs more room.
local CONST_MENU_HEIGHT = CONST_OPTIONSPANEL_HEIGHT - 10

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
            { name = "System", text = "System" },
            { name = "Social", text = "Social" },
            { name = "Gameplay", text = "Gameplay" },
            { name = "Inventory", text = "Inventory" },
            { name = "Interface", text = "Interface" },
        },
        {
            width = CONST_OPTIONSPANEL_WIDTH,
            height = CONST_MENU_HEIGHT,
            backdrop_color = { 0, 0, 0, 0 },
            button_width = 108,
            close_text_alpha = 0.4,
            container_width_offset = 30,
            backdrop_border_color = { 0.1, 0.1, 0.1, 0.4 }
        }
    )
    tabsContainer:SetPoint("CENTER", self, "CENTER", 0, 0)

    for _, frame in ipairs(tabsContainer.AllFrames) do
        -- One call for the panel colour: a 0.2317647 texture tinted to 0.27 renders as the
        -- product of the two, and the fourth argument carries what SetAlpha did.
        local frameBackgroundTexture = frame:CreateTexture(nil, "artwork")
        frameBackgroundTexture:SetPoint("topleft", frame, "topleft", 1, -85)
        frameBackgroundTexture:SetPoint("bottomright", frame, "bottomright", -1, 20)
        frameBackgroundTexture:SetColorTexture(0.0626, 0.0626, 0.0626, 0.3)
        local frameBackgroundTextureTopLine = frame:CreateTexture(nil, "artwork")
        frameBackgroundTextureTopLine:SetPoint("bottomleft", frameBackgroundTexture, "topleft", 0, 0)
        frameBackgroundTextureTopLine:SetPoint("bottomright", frame, "topright", -1, 0)
        frameBackgroundTextureTopLine:SetHeight(1)
        frameBackgroundTextureTopLine:SetColorTexture(0.1215, 0.1176, 0.1294)
    end

    -- System
    DF:BuildMenu(tabsContainer:GetTabFrameByName("System"),
        {
            { -- General
                type = "label",
                text = "General",
                text_template = orangeTextTemplate
            },
            { -- Max Out Camera Distance
                type = "toggle",
                boxfirst = true,
                name = "Max Out Camera Distance",
                desc = ForeverQoL.L["A /reload may be required to take effect."],
                get = function() return ForeverQoLData.Configs["MaxOutCameraDistance"] end,
                set = function(_, _, value) ForeverQoLData.Configs["MaxOutCameraDistance"] = value end,
            },
            {
                type = "breakline"
            },
            { -- Graphics
                type = "label",
                text = "Graphics",
                text_template = orangeTextTemplate
            },
            { -- Use Perfect Pixel
                type = "toggle",
                boxfirst = true,
                name = "Use Perfect Pixel",
                desc = "Set the UI Scale based on the vertical resolution (UIScale = 768 / verticalResolution). Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["UsePerfectPixel"] end,
                set = function(_, _, value) ForeverQoLData.Configs["UsePerfectPixel"] = value end,
            },
            { -- Use Custom Height
                type = "textentry",
                name = "Use Custom Height",
                desc = "If the UI is too small when using the option above, you can set a custom vertical resolution here. Requires /reload to take effect",
                width = 50,
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
                    OnEditFocusLost = function(self) self:SetText(ForeverQoLData.Configs["UseCustomHeight"]) end,
                },
            },
            {
                type = "breakline",
                spacement = true,
            },
            { -- Audio
                type = "label",
                text = "Audio",
                text_template = orangeTextTemplate
            },
            { -- Mute Annoying Sound
                type = "toggle",
                boxfirst = true,
                name = "Mute Annoying Sound",
                desc = "Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["MuteAnnoyingSound"] end,
                set = function(_, _, value) ForeverQoLData.Configs["MuteAnnoyingSound"] = value end,
            },
        },
        10, -100, CONST_MENU_HEIGHT, false, textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    -- Social
    DF:BuildMenu(tabsContainer:GetTabFrameByName("Social"),
        {
            { -- Chat
                type = "label",
                text = "Chat",
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
            { -- Restore Chat Messages
                type = "toggle",
                boxfirst = true,
                name = "Restore Chat Messages",
                desc = "Put the chat history back after a /reload. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["RestoreChatMessages"] end,
                set = function(_, _, value) ForeverQoLData.Configs["RestoreChatMessages"] = value end,
            },
            {
                type = "breakline"
            },
            { -- Invites
                type = "label",
                text = "Invites",
                text_template = orangeTextTemplate
            },
            { -- Block Duel Requests
                type = "toggle",
                boxfirst = true,
                name = "Block Duel Requests",
                desc = "Decline duels from anyone who is not on your friends list",
                get = function() return ForeverQoLData.Configs["BlockDuelRequests"] end,
                set = function(_, _, value) ForeverQoLData.Configs["BlockDuelRequests"] = value end,
            },
            { -- Block Duel Spam
                type = "toggle",
                boxfirst = true,
                name = "Block Duel Spam",
                desc = "Hide the system messages announcing duels you had no part in",
                get = function() return ForeverQoLData.Configs["BlockDuelSpam"] end,
                set = function(_, _, value) ForeverQoLData.Configs["BlockDuelSpam"] = value end,
            },
            { -- Block Party Invites
                type = "toggle",
                boxfirst = true,
                name = "Block Party Invites",
                desc = "Decline group invites from anyone who is not on your friends list",
                get = function() return ForeverQoLData.Configs["BlockPartyInvites"] end,
                set = function(_, _, value) ForeverQoLData.Configs["BlockPartyInvites"] = value end,
            },
            { -- Block Friend Requests
                type = "toggle",
                boxfirst = true,
                name = "Block Friend Requests",
                desc = "Decline incoming BattleTag and Real ID friend requests",
                get = function() return ForeverQoLData.Configs["BlockFriendRequests"] end,
                set = function(_, _, value) ForeverQoLData.Configs["BlockFriendRequests"] = value end,
            },
            { -- Show Inviter Info
                type = "toggle",
                boxfirst = true,
                name = "Announce Inviter",
                desc = "Print the race and class of whoever invites you to a group",
                get = function() return ForeverQoLData.Configs["ShowInviterInfo"] end,
                set = function(_, _, value) ForeverQoLData.Configs["ShowInviterInfo"] = value end,
            },
        },
        10, -100, CONST_MENU_HEIGHT, false, textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    -- Gameplay
    DF:BuildMenu(tabsContainer:GetTabFrameByName("Gameplay"),
        {
            { -- General
                type = "label",
                text = "General",
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
                set = function(_, _, value) ForeverQoLData.Configs["FasterAutoLoot"] = value end,
            },
            {
                type = "breakline"
            },
            { -- Automation
                type = "label",
                text = "Automation",
                text_template = orangeTextTemplate
            },
            { -- Auto Accept Resurrect
                type = "toggle",
                boxfirst = true,
                name = "Accept Resurrections",
                desc = "Take any resurrection offered, without the confirmation box",
                get = function() return ForeverQoLData.Configs["AutoAcceptResurrect"] end,
                set = function(_, _, value) ForeverQoLData.Configs["AutoAcceptResurrect"] = value end,
            },
            { -- Auto Accept Summon
                type = "toggle",
                boxfirst = true,
                name = "Accept Summons",
                desc = "Take any summon offered, without the confirmation box",
                get = function() return ForeverQoLData.Configs["AutoAcceptSummon"] end,
                set = function(_, _, value) ForeverQoLData.Configs["AutoAcceptSummon"] = value end,
            },
            { -- Thank On Summon
                type = "toggle",
                boxfirst = true,
                name = "Thank The Summoner",
                desc = "Whisper the summoner after taking a summon",
                get = function() return ForeverQoLData.Configs["ThankOnSummon"] end,
                set = function(_, _, value) ForeverQoLData.Configs["ThankOnSummon"] = value end,
            },
            { -- Thank On Summon Message
                type = "textentry",
                name = "Thank You Message",
                desc = "What to whisper the summoner",
                width = 200,
                get = function() return ForeverQoLData.Configs["ThankOnSummonMessage"] or "" end,
                set = function(_, _, value)
                    if value:match("%S") then
                        ForeverQoLData.Configs["ThankOnSummonMessage"] = value
                    else
                        ForeverQoL.Print("The thank you message cannot be empty")
                    end
                end,
                hooks = {
                    OnEditFocusLost = function(self) self:SetText(ForeverQoLData.Configs["ThankOnSummonMessage"]) end,
                },
            },
            { -- Auto Confirm Role Check
                type = "toggle",
                boxfirst = true,
                name = "Confirm Role Checks",
                desc = "Answer the group finder role check with the role already selected",
                get = function() return ForeverQoLData.Configs["AutoConfirmRoleCheck"] end,
                set = function(_, _, value) ForeverQoLData.Configs["AutoConfirmRoleCheck"] = value end,
            },
            { -- Auto Release In PvP
                type = "toggle",
                boxfirst = true,
                name = "Release In Battlegrounds",
                desc = "Release straight away on death in a battleground or arena, never elsewhere",
                get = function() return ForeverQoLData.Configs["AutoReleaseInPvP"] end,
                set = function(_, _, value) ForeverQoLData.Configs["AutoReleaseInPvP"] = value end,
            },
        },
        10, -100, CONST_MENU_HEIGHT, false, textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    -- Inventory
    DF:BuildMenu(tabsContainer:GetTabFrameByName("Inventory"),
        {
            { -- Merchant
                type = "label",
                text = "Merchant",
                text_template = orangeTextTemplate
            },
            { -- Repair Gear Automatically
                type = "toggle",
                boxfirst = true,
                name = "Repair Gear Automatically",
                get = function() return ForeverQoLData.Configs["RepairGearAutomatically"] end,
                set = function(_, _, value) ForeverQoLData.Configs["RepairGearAutomatically"] = value end,
            },
            { -- Use Guild Bank For Repair
                type = "toggle",
                boxfirst = true,
                name = "Use Guild Bank For Repair",
                get = function() return ForeverQoLData.Configs["UseGuildBankForRepair"] end,
                set = function(_, _, value) ForeverQoLData.Configs["UseGuildBankForRepair"] = value end,
            },
            { -- Show Repair Summary
                type = "toggle",
                boxfirst = true,
                name = "Announce Repair Cost",
                desc = "Print what the repair cost in chat",
                get = function() return ForeverQoLData.Configs["ShowRepairSummary"] end,
                set = function(_, _, value) ForeverQoLData.Configs["ShowRepairSummary"] = value end,
            },
            { -- Sell Junk Automatically
                type = "toggle",
                boxfirst = true,
                name = "Sell Junk Automatically",
                desc = "Sell every grey item in the bags",
                get = function() return ForeverQoLData.Configs["SellJunkAutomatically"] end,
                set = function(_, _, value) ForeverQoLData.Configs["SellJunkAutomatically"] = value end,
            },
            { -- Keep Grey Gear
                type = "toggle",
                boxfirst = true,
                name = "Keep Grey Gear",
                desc = "Spare grey weapons and armour, sell the rest. Put one on the list below to sell it anyway",
                get = function() return ForeverQoLData.Configs["KeepGreyGear"] end,
                set = function(_, _, value) ForeverQoLData.Configs["KeepGreyGear"] = value end,
            },
            { -- Sell Listed Items Automatically
                type = "toggle",
                boxfirst = true,
                name = "Sell Listed Items Automatically",
                desc = "Also sell every item on the list below, whatever its quality",
                get = function() return ForeverQoLData.Configs["SellListedItemsAutomatically"] end,
                set = function(_, _, value) ForeverQoLData.Configs["SellListedItemsAutomatically"] = value end,
            },
            { -- Show Sell Summary
                type = "toggle",
                boxfirst = true,
                name = "Announce Sale Total",
                desc = "Print how many items were sold and for how much",
                get = function() return ForeverQoLData.Configs["ShowSellSummary"] end,
                set = function(_, _, value) ForeverQoLData.Configs["ShowSellSummary"] = value end,
            },
            { -- Manage The Sell List
                type = "execute",
                name = "Manage My Sell List",
                desc = "Open the list of items sold on sight, to add to it or take from it",
                func = function() self:ToggleAutoSellList() end,
            },
            { -- Buy Listed Items Automatically
                type = "toggle",
                boxfirst = true,
                name = "Buy Listed Items Automatically",
                desc = "Top up the items on the list below whenever a merchant sells them",
                get = function() return ForeverQoLData.Configs["BuyListedItemsAutomatically"] end,
                set = function(_, _, value) ForeverQoLData.Configs["BuyListedItemsAutomatically"] = value end,
            },
            { -- Manage The Buy List
                type = "execute",
                name = "Manage My Buy List",
                desc = "Open the list of items kept stocked, with how many of each to keep",
                func = function() self:ToggleAutoBuyList() end,
            },
            { -- Tint Known At Merchant
                type = "toggle",
                boxfirst = true,
                name = "Tint Known Items At Merchants",
                desc = "Colour already collected items green. Turn off AlreadyKnown if you use it, or both will tint",
                get = function() return ForeverQoLData.Configs["TintKnownAtMerchant"] end,
                set = function(_, _, value) ForeverQoLData.Configs["TintKnownAtMerchant"] = value end,
            },
            {
                type = "breakline"
            },
            { -- Bank
                type = "label",
                text = "Bank",
                text_template = orangeTextTemplate
            },
            { -- Deposit Excess Gold To Bank
                type = "toggle",
                boxfirst = true,
                name = "Deposit Excess Gold To Bank",
                desc = "When the bank is opened, move everything above the amount below",
                get = function() return ForeverQoLData.Configs["DepositExcessGoldToBank"] end,
                set = function(_, _, value) ForeverQoLData.Configs["DepositExcessGoldToBank"] = value end,
            },
            { -- Keep Gold Amount
                type = "textentry",
                name = "Gold To Keep",
                desc = "How much gold stays on the character, silver and copper are never moved",
                width = 90,
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
                    OnEditFocusLost = function(self) self:SetText(ForeverQoLData.Configs["KeepGoldAmount"]) end,
                },
            },
            { -- Deposit Listed Items To Bank
                type = "toggle",
                boxfirst = true,
                name = "Deposit Listed Items",
                desc = "Move every item on the list below into whichever bank tab is open",
                get = function() return ForeverQoLData.Configs["DepositListedItemsToBank"] end,
                set = function(_, _, value) ForeverQoLData.Configs["DepositListedItemsToBank"] = value end,
            },
            { -- Manage The Deposit List
                type = "execute",
                name = "Manage My Deposit List",
                desc = "Open the list of items sent to the bank on sight, to add to it or take from it",
                func = function() self:ToggleAutoDepositList() end,
            },
            {
                type = "breakline"
            },
            { -- Bags
                type = "label",
                text = "Bags",
                text_template = orangeTextTemplate
            },
            { -- Tint Unusable In Bags
                type = "toggle",
                boxfirst = true,
                name = "Mark Unusable Items In Red",
                desc = "Colour items your character cannot use red in the default bags. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["TintUnusableInBags"] end,
                set = function(_, _, value) ForeverQoLData.Configs["TintUnusableInBags"] = value end,
            },
            { -- Desaturate Junk In Bags
                type = "toggle",
                boxfirst = true,
                name = "Grey Out Junk Items",
                desc = "Dim and drain the colour from grey quality items and auto sell list items in the default bags. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["DesaturateJunkInBags"] end,
                set = function(_, _, value) ForeverQoLData.Configs["DesaturateJunkInBags"] = value end,
            },
            { -- Easy Item Destroy
                type = "toggle",
                boxfirst = true,
                name = "Skip Typing DELETE",
                desc = "Fill in the delete confirmation for you. Items that start a quest still have to be typed out. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["EasyItemDestroy"] end,
                set = function(_, _, value) ForeverQoLData.Configs["EasyItemDestroy"] = value end,
            },
        },
        10, -100, CONST_MENU_HEIGHT, false, textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    -- Interface
    DF:BuildMenu(tabsContainer:GetTabFrameByName("Interface"),
        {
            { -- Quests
                type = "label",
                text = "Quests",
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
                type = "breakline"
            },
            { -- Visibility
                type = "label",
                text = "Visibility",
                text_template = orangeTextTemplate
            },
            { -- Floating Combat Text Visibility
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
                set = function(_, _, value) ForeverQoLData.Configs["HideTooltipWhileInCombat"] = value end,
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
            { -- Hide Boss Banner
                type = "toggle",
                boxfirst = true,
                name = "Hide Boss Loot Banner",
                desc = "The banner naming the boss and its loot after a kill. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["HideBossBanner"] end,
                set = function(_, _, value) ForeverQoLData.Configs["HideBossBanner"] = value end,
            },
            { -- Hide Event Toasts
                type = "toggle",
                boxfirst = true,
                name = "Hide Event Toasts",
                desc = "The banners that drop from the top of the screen on finishing an activity. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["HideEventToasts"] end,
                set = function(_, _, value) ForeverQoLData.Configs["HideEventToasts"] = value end,
            },
            { -- Hide Zone Text
                type = "toggle",
                boxfirst = true,
                name = "Hide Zone Text",
                desc = "The zone and subzone names that fade in over the screen on arrival. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["HideZoneText"] end,
                set = function(_, _, value) ForeverQoLData.Configs["HideZoneText"] = value end,
            },
            { -- Hide Error Messages
                type = "toggle",
                boxfirst = true,
                name = "Hide Error Messages",
                desc = "The red text above the player frame, such as Out of range. Hides all of them, including ones worth reading. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["HideErrorMessages"] end,
                set = function(_, _, value) ForeverQoLData.Configs["HideErrorMessages"] = value end,
            },
            {
                type = "breakline"
            },
            { -- Action Bars
                type = "label",
                text = "Action Bars",
                text_template = orangeTextTemplate
            },
            { -- Hide Keybind Text
                type = "toggle",
                boxfirst = true,
                name = "Hide Keybind Text",
                desc = "Hide the hotkey label in the corner of every action button. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["HideKeybindText"] end,
                set = function(_, _, value) ForeverQoLData.Configs["HideKeybindText"] = value end,
            },
            { -- Hide Macro Text
                type = "toggle",
                boxfirst = true,
                name = "Hide Macro Text",
                desc = "Hide the macro name along the bottom of every action button. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["HideMacroText"] end,
                set = function(_, _, value) ForeverQoLData.Configs["HideMacroText"] = value end,
            },
            {
                type = "breakline"
            },
            { -- Tooltip
                type = "label",
                text = "Tooltip",
                text_template = orangeTextTemplate
            },
            { -- Show Target In Tooltip
                type = "toggle",
                boxfirst = true,
                name = "Show Target In Tooltip",
                desc = "Add who a unit is currently attacking to its tooltip. Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["ShowTargetInTooltip"] end,
                set = function(_, _, value) ForeverQoLData.Configs["ShowTargetInTooltip"] = value end,
            },
            {
                type = "breakline"
            },
            { -- Other Addons
                type = "label",
                text = "Other Addons",
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
        10, -100, CONST_MENU_HEIGHT, false, textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )
end

function ForeverQoLOptions:ToggleOptions()
    self:SetShown(not self:IsShown())
end

ForeverQoL.ForeverQoLOptions = ForeverQoLOptions
