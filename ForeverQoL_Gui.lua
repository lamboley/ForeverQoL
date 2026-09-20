local ForeverQoL = select(2, ...)

local DF = _G["DetailsFramework"]

local CONST_WIDTH, CONST_HEIGHT = 1100, 670

local textTemplate = DF:GetTemplate("font", "OPTIONS_FONT_TEMPLATE")
local dropdownTemplate = DF:GetTemplate("dropdown", "OPTIONS_DROPDOWN_TEMPLATE")
local switchTemplate = DF:GetTemplate("switch", "OPTIONS_CHECKBOX_TEMPLATE")
local sliderTemplate = DF:GetTemplate("slider", "OPTIONS_SLIDER_TEMPLATE")
local buttonTemplate = DF:GetTemplate("button", "OPTIONS_BUTTON_TEMPLATE")
local orangeTextTemplate = DF:GetTemplate("font", "ORANGE_FONT_TEMPLATE")

local ForeverQoLGui = DF:CreateSimplePanel(UIParent, CONST_WIDTH, CONST_HEIGHT, "Forever QoL", "ForeverQoLGui", {UseScaleBar = true})
ForeverQoLGui.Title:SetAlpha(.75)
ForeverQoLGui:SetFrameStrata("DIALOG")
ForeverQoLGui:SetToplevel(true)
DF:ApplyStandardBackdrop(ForeverQoLGui)

local versionText = DF:CreateLabel (ForeverQoLGui, "0.0.1", 11, "white")
versionText:SetPoint ("topright", ForeverQoLGui, "topright", -25, -7)
versionText:SetAlpha(0.75)

local CONST_ICON_SIZE, CONST_ICON_PAD = 38, 4
local CONST_ICONS_PER_ROW = 7

local CONST_CELL = CONST_ICON_SIZE + CONST_ICON_PAD
local CONST_COLUMN_WIDTH = CONST_ICONS_PER_ROW * CONST_CELL + 10
local CONST_LIST_WIDTH = CONST_COLUMN_WIDTH * 2 + 70
local CONST_LIST_HEIGHT = CONST_HEIGHT
local CONST_GRID_ROWS = math.floor((CONST_LIST_HEIGHT - 110) / CONST_CELL)

local itemListWindows = {}

---Every distinct item the bags hold, sorted by name.
local function ScanBags()
	local seen, items = {}, {}

	for bagID = 0, NUM_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
			local info = C_Container.GetContainerItemInfo(bagID, slot)
			local itemID = info and info.itemID
			if itemID and not seen[itemID] then
				seen[itemID] = true
				items[#items + 1] = {
					id = itemID,
					icon = info.iconFileID,
					quality = info.quality,
					name = (C_Item.GetItemInfo(itemID)) or string.format("Item #%d", itemID),
				}
			end
		end
	end

	table.sort(items, function(a, b) return a.name < b.name end)

	return items
end

---Cuts a flat list into rows, because a scrollbox line is a row of icons here.
local function ToGridRows(items)
	local rows = {}

	for i = 1, #items, CONST_ICONS_PER_ROW do
		local row = {}
		for column = 0, CONST_ICONS_PER_ROW - 1 do
			row[column + 1] = items[i + column]
		end
		rows[#rows + 1] = row
	end

	return rows
end

---A window over one of the item lists, laid out like a bag: the bags on the left to pick from,
---the list itself on the right. The sell list and the deposit list differ only by their data,
---so they share the whole thing. Built the first time it is asked for, then reused.
local function GetItemListWindow(list, title, frameName)
	if itemListWindows[frameName] then
		return itemListWindows[frameName]
	end

	local window = DF:CreateSimplePanel(UIParent, CONST_LIST_WIDTH, CONST_LIST_HEIGHT, title, frameName)
	window:SetFrameStrata("FULLSCREEN_DIALOG")
	window:SetToplevel(true)
	DF:ApplyStandardBackdrop(window)

	-- Beside the options panel rather than on top of it. Only at creation, so dragging it
	-- somewhere else afterwards sticks.
	window:ClearAllPoints()
	window:SetPoint("topleft", ForeverQoLGui, "topright", 8, 0)
	window:Hide()

	local bagScroll, listScroll
	local searchText = ""

	local function CreateSlot(row, column, onClick)
		-- BackdropTemplate, otherwise the frame has no SetBackdrop on a modern client
		local slot = CreateFrame("button", nil, row, "BackdropTemplate")
		slot:SetPoint("left", row, "left", (column - 1) * CONST_CELL + 2, 0)
		slot:SetSize(CONST_ICON_SIZE, CONST_ICON_SIZE)

		-- One interface unit is not one screen pixel once UIParent is scaled, so a width of 1
		-- lands on one pixel or two depending where the slot falls. This asks for the unit
		-- size that rounds to exactly one pixel at the scale actually in force.
		local edge = PixelUtil.GetNearestPixelSize(1, slot:GetEffectiveScale(), 1)

		-- Its own backdrop rather than the standard one, so the rarity edge is a known width
		slot:SetBackdrop({
			bgFile = [[Interface\Buttons\WHITE8X8]],
			edgeFile = [[Interface\Buttons\WHITE8X8]],
			edgeSize = edge,
		})
		slot:SetBackdropColor(0, 0, 0, 0.6)

		slot.icon = slot:CreateTexture(nil, "artwork")
		-- Inset by the edge width, otherwise the icon covers the rarity it is meant to show
		slot.icon:SetPoint("topleft", slot, "topleft", edge, -edge)
		slot.icon:SetPoint("bottomright", slot, "bottomright", -edge, edge)
		-- The default coordinates include the icon's own border
		slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		slot:SetScript("OnClick", onClick)

		slot:SetScript("OnEnter", function(self)
			if not self.entry then
				return
			end

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink("item:" .. self.entry.id)
			GameTooltip:Show()
		end)

		slot:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		return slot
	end

	local function GridLine(onClick, acceptsDrop)
		return function(self, index)
			local row = CreateFrame("frame", nil, self)
			row:SetPoint("topleft", self, "topleft", 1, -((index - 1) * CONST_CELL) - 2)
			row:SetSize(CONST_COLUMN_WIDTH - 12, CONST_ICON_SIZE)

			row.slots = {}
			for column = 1, CONST_ICONS_PER_ROW do
				local slot = CreateSlot(row, column, onClick)
				if acceptsDrop then
					list:EnableDrop(slot)
				end

				row.slots[column] = slot
			end

			return row
		end
	end

	local function RefreshGrid(self, data, offset, totalLines)
		for i = 1, totalLines do
			local rowData = data[i + offset]
			if rowData then
				local row = self:GetLine(i)
				for column = 1, CONST_ICONS_PER_ROW do
					local slot = row.slots[column]
					local entry = rowData[column]

					slot.entry = entry
					if entry then
						slot.icon:SetTexture(entry.icon or (C_Item.GetItemIconByID(entry.id)))

						-- The slot border carries the rarity, the way a bag slot does
						local color = entry.quality and ITEM_QUALITY_COLORS[entry.quality]
						if color then
							slot:SetBackdropBorderColor(color.r, color.g, color.b, 1)
						else
							slot:SetBackdropBorderColor(0, 0, 0, 0.5)
						end

						if ForeverQoLData.Configs["TintUnusableRed"] and ForeverQoL.IsUnusable(entry.id) then
							slot.icon:SetVertexColor(1, 0.3, 0.3)
						else
							slot.icon:SetVertexColor(1, 1, 1)
						end

						slot:Show()
					else
						slot:Hide()
					end
				end

				row:Show()
			end
		end
	end

	---Opening always reloads, since the bags will have moved since last time.
	function window:Toggle()
		if self:IsShown() then
			self:Hide()
			return
		end

		self:Reload()
		self:Show()
	end

	function window:Reload(resetScroll)
		local available, selected = {}, {}
		for _, entry in ipairs(ScanBags()) do
			if not list:Contains(entry.id) and (entry.name:lower():find(searchText, 1, true)
				or tostring(entry.id):find(searchText, 1, true)) then
				available[#available + 1] = entry
			end
		end
		for _, entry in ipairs(list:GetSorted()) do
			if entry.name:lower():find(searchText, 1, true) or tostring(entry.id):find(searchText, 1, true) then
				selected[#selected + 1] = entry
			end
		end

		bagScroll:SetData(ToGridRows(available))
		listScroll:SetData(ToGridRows(selected))
		if resetScroll then
			-- A search must start at its first result, even when the unfiltered list was scrolled down.
			bagScroll:OnVerticalScroll(0)
			listScroll:OnVerticalScroll(0)
		else
			bagScroll:Refresh()
			listScroll:Refresh()
		end
	end

	local bagHeader = DF:CreateLabel(window, "In your bags, click to add", 12, "orange")
	bagHeader:SetPoint("topleft", window, "topleft", 20, -68)

	bagScroll = DF:CreateScrollBox(window, frameName .. "Bags", RefreshGrid, {},
		CONST_COLUMN_WIDTH, CONST_GRID_ROWS * CONST_CELL, CONST_GRID_ROWS, CONST_CELL)
	bagScroll:SetPoint("topleft", window, "topleft", 20, -88)
	bagScroll:CreateLines(GridLine(function(slot)
		if not list:Contains(slot.entry.id) then
			list:Add(slot.entry.id)
		end
	end), CONST_GRID_ROWS)
	DF:ReskinSlider(bagScroll)

	local listHeader = DF:CreateLabel(window, "On the list, drag here to add, click to remove", 12, "orange")
	listHeader:SetPoint("topleft", window, "topleft", CONST_COLUMN_WIDTH + 50, -68)

	listScroll = DF:CreateScrollBox(window, frameName .. "List", RefreshGrid, {},
		CONST_COLUMN_WIDTH, CONST_GRID_ROWS * CONST_CELL, CONST_GRID_ROWS, CONST_CELL)
	listScroll:SetPoint("topleft", window, "topleft", CONST_COLUMN_WIDTH + 50, -88)
	listScroll:CreateLines(GridLine(function(slot)
		list:Remove(slot.entry.id)
	end, true), CONST_GRID_ROWS)
	DF:ReskinSlider(listScroll)

	-- The scrollbox catches whatever lands between or below the slots
	list:EnableDrop(listScroll)

	local searchLabel = DF:CreateLabel(window, "Search name or item ID", 12, "orange")
	searchLabel:SetPoint("topleft", window, "topleft", 20, -36)
	local searchBox = DF:CreateSearchBox(window, function(self)
		searchText = self:GetText():match("^%s*(.-)%s*$"):lower()
		window:Reload(true)
	end)
	searchBox:SetPoint("topleft", window, "topleft", 185, -27)
	searchBox:SetWidth(CONST_LIST_WIDTH - 210)

	-- Adding resolves the item name asynchronously, so the list says when it actually changed
	list.OnChanged = function()
		window:Reload()
	end

	itemListWindows[frameName] = window

	return window
end

function ForeverQoLGui:Init()
    local tabsContainer = DF:CreateTabContainer(self, "Forever QoL", "ForeverQoLGuiTabsContainers",
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
            width = CONST_WIDTH,
            height = CONST_HEIGHT - 10,
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
                CONST_WIDTH = 50,
                get = function() return ForeverQoLData.Configs["UseCustomHeight"] or "" end,
                set = function(_, _, value)
                    local CONST_HEIGHT = tonumber(value)
                    if CONST_HEIGHT and CONST_HEIGHT >= 480 and CONST_HEIGHT <= 4320 then
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
        10, -100, CONST_HEIGHT - 10, false,
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
        10, -100, CONST_HEIGHT - 10, false,
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
            { -- Manage The Sell List
                type = "execute",
                name = "Manage My Sell List",
                desc = "Open the list of items sold on sight, to add to it or take from it",
                func = function()
                    GetItemListWindow(ForeverQoL.Gameplay.Merchant.Items, "Auto Sell List", "ForeverQoLSellListWindow"):Toggle()
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
                CONST_WIDTH = 90,
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
                    GetItemListWindow(ForeverQoL.Gameplay.Bank.Items, "Auto Deposit List", "ForeverQoLDepositListWindow"):Toggle()
                end,
            },

        },
        10, -100, CONST_HEIGHT - 10, false,
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
            { -- Tint Unusable Red
                type = "toggle",
                boxfirst = true,
                name = "Tint Unusable Items Red",
                desc = "Redden what this character can never wear, at merchants and in the item list windows. A level requirement does not count, it only says not yet",
                get = function() return ForeverQoLData.Configs["TintUnusableRed"] end,
                set = function(_, _, value)
                    ForeverQoLData.Configs["TintUnusableRed"] = value
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
        10, -100, CONST_HEIGHT - 10, false,
        textTemplate, dropdownTemplate, switchTemplate, true, sliderTemplate, buttonTemplate
    )
end

function ForeverQoLGui:ToggleOptions()
    if self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

ForeverQoL.ForeverQoLGui = ForeverQoLGui
