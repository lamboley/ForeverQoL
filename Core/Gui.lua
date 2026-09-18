---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local tonumber = tonumber

---@type detailsframework
local DF = _G["DetailsFramework"]

local WIDTH, HEIGHT = 1100, 670

local textTemplate = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local dropdownTemplate = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local switchTemplate = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local sliderTemplate = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local buttonTemplate = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local orangeTextTemplate = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")

local ForeverQoLGui = DF:CreateSimplePanel(UIParent, WIDTH, HEIGHT, "Forever QoL", "ForeverQoLGui", {UseScaleBar = true})
ForeverQoLGui.Title:SetAlpha(.75)
ForeverQoLGui:SetFrameStrata("DIALOG")
ForeverQoLGui:SetToplevel(true)
DF:ApplyStandardBackdrop(ForeverQoLGui)
-- ForeverQoLGui:SetPoint("CENTER")

local versionText = DF:CreateLabel (ForeverQoLGui, "0.0.1", 11, "white")
versionText:SetPoint ("topright", ForeverQoLGui, "topright", -25, -7)
versionText:SetAlpha(0.75)

function ForeverQoLGui:Init()
    local tabsContainer = DF:CreateTabContainer(ForeverQoLGui, "Forever QoL", "ForeverQoLGuiTabsContainers",
        {
            {
                name = "General",
                text = "General"
            },
            {
                name = "System",
                text = "System"
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
            width = WIDTH,
            height = HEIGHT - 10,
            backdrop_color = { 0, 0, 0, 0 },
            -- y_offset = 0,
            button_width = 108,
            -- button_height = 23,
            -- button_x = 220,
            -- button_y = 1,
            -- button_text_size = 9,
            close_text_alpha = 0.4,
            container_width_offset = 30,
            backdrop_border_color = { 0.1, 0.1, 0.1, 0.4 }
        }
    )
    tabsContainer:SetPoint("CENTER", ForeverQoLGui, "CENTER", 0, 0)

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

        local gradientAbove = DF:CreateTexture(frame,
            {
                gradient = "vertical",
                fromColor = DF.IsDragonflight() and {0, 0, 0, 0.3} or {0, 0, 0, 0.4},
                toColor = "transparent"
            }, 1, 80, "artwork", {0, 1, 0, 1}, "gradientAbove")
		gradientAbove:SetPoint("bottom-top", frameBackgroundTextureTopLine)

		local gradientBelow = DF:CreateTexture(frame,
            {
                gradient = "vertical",
                fromColor = "transparent",
                toColor = DF.IsDragonflight() and {0, 0, 0, 0.15} or {0, 0, 0, 0.25}
            }, 1, 100, "artwork", {0, 1, 0, 1}, "gradientBelow")
		gradientBelow:SetPoint("top-bottom", frameBackgroundTextureTopLine)
	end

    -- General
    DF:BuildMenu(tabsContainer:GetTabFrameByName("General"),
        {
            { -- General
                type = "label",
                get = function() return "General" end,
                text_template = orangeTextTemplate
            },
            { -- Enable Debug
                type = "toggle",
                boxfirst = true,
                name = "Enable Debug",
                get = function() return ForeverQoLData.Configs["Debug"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["Debug"] = value
                end,
            },
        },
        10, -100, HEIGHT - 10, false,
        textTemplate,  dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

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
                    OnEditFocusLost = function(self)
                        self:SetText(ForeverQoLData.Configs["UseCustomHeight"])
                    end,
                    OnEnterPressed = function(self) return end
                },
            },
            -- { -- UI Scale
            --     type = "range",
            --     name = "UI Scale",
            --     get = function() return ForeverQoLData.Configs["UIParentScale"] end,
            --     set = function(_, _, value)
            --         ForeverQoLData.Configs["UIParentScale"] = value
            --     end,
            --     min = 0.0000001,
            --     max = 2,
            --     step = 0.0000001,
            --     usedecimals = true,
            -- },
            -- {
            --     type = "breakline"
            -- },
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
        10, -100, HEIGHT - 10, false,
        textTemplate,  dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
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
            { -- Disable Right Click Targeting
                type = "toggle",
                boxfirst = true,
                name = "Disable Right Click Targeting",
                desc = "Requires /reload to take effect",
                get = function() return ForeverQoLData.Configs["DisableRightClickTargeting"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["DisableRightClickTargeting"] = value
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
                type = "blank"
            },
            { -- Scale
                type = "label",
                get = function() return "Roleplay" end,
                text_template = orangeTextTemplate
            },
            { -- Add Voice Line When Dead
                type = "toggle",
                boxfirst = true,
                name = "Add Voice Line When Dead",
                desc = "Voice line are from Ilgynoth, Yshaarj, Xalatath and Yoggsaron",
                get = function() return ForeverQoLData.Configs["AddVoiceLineWhenDead"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["AddVoiceLineWhenDead"] = value
                    if value then
                        ForeverQoL.Gameplay.Voice:Enable()
                    else
                        ForeverQoL.Gameplay.Voice:Disable()
                    end
                end,
            },
            { -- Print Quote From Thich Nhat Hanh
                type = "toggle",
                boxfirst = true,
                name = "Print Quote From Thich Nhat Hanh",
                get = function() return ForeverQoLData.Configs["PrintQuoteFromThichNhatHanh"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["PrintQuoteFromThichNhatHanh"] = value
                    if value then
                        ForeverQoL.Gameplay.ThichNhatHanh:Enable()
                    else
                        ForeverQoL.Gameplay.ThichNhatHanh:Disable()
                    end
                end,
            },
            {
                type = "blank"
            },
            { -- Scale
                type = "label",
                get = function() return "Battle Pet" end,
                text_template = orangeTextTemplate
            },
            { -- Keep A Battle Pet Summoned
                type = "toggle",
                boxfirst = true,
                name = "Keep A Battle Pet Summoned",
                get = function() return ForeverQoLData.Configs["KeepABattlePetSummoned"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["KeepABattlePetSummoned"] = value
                    if value then
                        ForeverQoL.Gameplay.BattlePet:Enable()
                    else
                        ForeverQoL.Gameplay.BattlePet:Disable()
                    end
                end,
            },
            { -- Battle Pet Name To Summon
                type = "textentry",
                name = "Pet Name",
                desc = "The name of the battle pet to be summoned",
                width = 130,
                get = function() return ForeverQoLData.Configs["BattlePetNameToSummon"] or "" end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["BattlePetNameToSummon"] = value
                end,
                hooks = {
                    OnEditFocusLost = function(self)
                        self:SetText(ForeverQoLData.Configs["BattlePetNameToSummon"])
                    end,
                    OnEnterPressed = function(self) return end
                },
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
                desc = "Sell every grey item except weapons and armour, those go on the list below if you want them gone",
                get = function() return ForeverQoLData.Configs["SellJunkAutomatically"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["SellJunkAutomatically"] = value
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
            { -- Limit Sell To Twelve Items
                type = "toggle",
                boxfirst = true,
                name = "Never Sell More Than 12 Items",
                desc = "The buyback list only holds 12 items. Past that, anything sold earlier is gone for good",
                get = function() return ForeverQoLData.Configs["LimitSellToTwelveItems"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["LimitSellToTwelveItems"] = value
                end,
            },
            { -- Add Item To The Sell List
                type = "textentry",
                id = "AutoSellAddItem",
                name = "Add Item",
                desc = "Drag an item from your bags onto this box, or type an item ID, or shift-click an item into it",
                width = 160,
                get = function() return "" end,
                set = function(_, _, value)
                    if value == "" then return end
                    ForeverQoL.Gameplay.Vendor.Items.Add(value)
                end,
                hooks = {
                    OnEditFocusLost = function(self)
                        self:SetText("")
                    end,
                    OnEnterPressed = function(self)
                        self:SetText("")
                    end
                },
            },
            { -- Remove Item From The Sell List
                type = "select",
                name = "Remove Item",
                desc = "Pick an item to take it back off the sell list",
                get = function() return 0 end,
                values = function() return ForeverQoL.Gameplay.Vendor.Items.GetOptions() end,
            },
            {
                type = "blank"
            },
            { -- Bank
                type = "label",
                get = function() return "Bank" end,
                text_template = orangeTextTemplate
            },
            { -- Deposit Excess Gold To Warbank
                type = "toggle",
                boxfirst = true,
                name = "Deposit Excess Gold To Warbank",
                desc = "When a bank with warband access is opened, move everything above the amount below",
                get = function() return ForeverQoLData.Configs["DepositExcessGoldToWarbank"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["DepositExcessGoldToWarbank"] = value
                end,
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
            { -- Add Item To The Deposit List
                type = "textentry",
                id = "AutoDepositAddItem",
                name = "Add Item",
                desc = "Drag an item from your bags onto this box, or type an item ID, or shift-click an item into it",
                width = 160,
                get = function() return "" end,
                set = function(_, _, value)
                    if value == "" then return end
                    ForeverQoL.Gameplay.Bank.Items.Add(value)
                end,
                hooks = {
                    OnEditFocusLost = function(self)
                        self:SetText("")
                    end,
                    OnEnterPressed = function(self)
                        self:SetText("")
                    end
                },
            },
            { -- Remove Item From The Deposit List
                type = "select",
                name = "Remove Item",
                desc = "Pick an item to take it back off the deposit list",
                get = function() return 0 end,
                values = function() return ForeverQoL.Gameplay.Bank.Items.GetOptions() end,
            },

        },
        10, -100, HEIGHT - 10, false,
        textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )

    ForeverQoL.Gameplay.Vendor.Items.EnableDrop(gameplayFrame:GetWidgetById("AutoSellAddItem"))
    ForeverQoL.Gameplay.Bank.Items.EnableDrop(gameplayFrame:GetWidgetById("AutoDepositAddItem"))

    -- Interface
    DF:BuildMenu(tabsContainer:GetTabFrameByName("Interface"),
        {
            { -- General
                type = "label",
                get = function() return "General" end,
                text_template = orangeTextTemplate
            },
            { -- Disable Damage Text
                type = "select",
                name = "Floating Combat Text",
                desc = "Covers damage, healing, periodic ticks and pet damage",
                get = function() return ForeverQoLData.Configs["FloatingCombatTextVisibility"] end,
                values = function() return ForeverQoL.Interface.GetCombatTextOptions() end,
            },
            { -- Show Recipe Icons
                type = "toggle",
                boxfirst = true,
                name = "Show Recipe Icons",
                desc = "Put the item icon back on each row of the profession recipe list",
                get = function() return ForeverQoLData.Configs["ShowRecipeIcons"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["ShowRecipeIcons"] = value
                end,
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
        },
        10, -100, HEIGHT - 10, false,
        textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )
end

function ForeverQoLGui:ToggleOptions()
    if ForeverQoLGui:IsShown() then
        ForeverQoLGui:Hide()
    else
        ForeverQoLGui:Show()
    end
end

ForeverQoL.ForeverQoLGui = ForeverQoLGui
