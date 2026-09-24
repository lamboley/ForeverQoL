local ForeverQoL = select(2, ...)

local DF = _G["DetailsFramework"]
local ForeverQoLOptions = ForeverQoL.ForeverQoLOptions

local CONST_ICON_SIZE = 38
local CONST_ICON_PAD = 4
local CONST_ICONS_PER_ROW = 7
local CONST_HEARTHSTONE_ID = 6948

local CONST_CELL = CONST_ICON_SIZE + CONST_ICON_PAD
local CONST_COLUMN_WIDTH = CONST_ICONS_PER_ROW * CONST_CELL + 10
local CONST_LIST_WIDTH = CONST_COLUMN_WIDTH * 2 + 70
local CONST_LIST_HEIGHT = 670
local CONST_GRID_ROWS = math.floor((CONST_LIST_HEIGHT - 110) / CONST_CELL)

function ForeverQoLOptions:ToggleAutoSellList()
    if self.AutoSellListWindow then
        self.AutoSellListWindow:Toggle()
        return
    end
    local frameName = "ForeverQoLSellListWindow"
    local window = DF:CreateSimplePanel(UIParent, CONST_LIST_WIDTH, CONST_LIST_HEIGHT, "Auto Sell List", frameName)
    window:SetFrameStrata("FULLSCREEN_DIALOG")
    window:SetToplevel(true)
    DF:ApplyStandardBackdrop(window)

    window:ClearAllPoints()
    window:SetPoint("topleft", ForeverQoLOptions, "topright", 8, 0)
    window:Hide()
    local bagScroll, listScroll
    local searchText = ""

    local function AddItem(itemID)
        local refusal = itemID == CONST_HEARTHSTONE_ID and "The Hearthstone cannot be added to the auto sell list."
            or ForeverQoL.IsQuestItem(itemID) and "Quest items cannot be added to the auto sell list."
        if refusal then
            ForeverQoL.Print(refusal)
            return
        end

        local entries = ForeverQoLData.Configs.AutoSellItemList
        if entries[itemID] then
            return
        end
        entries[itemID] = true
        ForeverQoL.Print(string.format("Added %s (%d) to the auto sell list.",
            (C_Item.GetItemInfo(itemID)) or string.format("Item #%d", itemID), itemID))
        window:Reload()
    end

    local function EnableDrop(frame)
        local function AddFromCursor()
            local cursorType, itemID = GetCursorInfo()
            if cursorType ~= "item" or not itemID then
                return
            end
            ClearCursor()
            AddItem(itemID)
        end

        frame:EnableMouse(true)
        frame:SetScript("OnReceiveDrag", AddFromCursor)
        frame:HookScript("OnMouseDown", function()
            frame.addedFromCursor = GetCursorInfo() == "item"
            AddFromCursor()
        end)
    end

    local function GridLine(onClick, acceptsDrop)
        return function(self, index)
            local row = CreateFrame("frame", nil, self)
            row:SetPoint("topleft", self, "topleft", 1, -((index - 1) * CONST_CELL) - 2)
            row:SetSize(CONST_COLUMN_WIDTH - 12, CONST_ICON_SIZE)
            row.slots = {}
            for column = 1, CONST_ICONS_PER_ROW do
                local slot = ForeverQoL.CreateSlot(row, column, onClick)
                if acceptsDrop then
                    EnableDrop(slot)
                end
                row.slots[column] = slot
            end
            return row
        end
    end

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
        for itemID in pairs(ForeverQoLData.Configs.AutoSellItemList) do
            local name, _, quality = C_Item.GetItemInfo(itemID)
            if not name then
                Item:CreateFromItemID(itemID):ContinueOnItemLoad(function()
                    if C_Item.GetItemInfo(itemID) then
                        window:Reload()
                    end
                end)
                name = string.format("Item #%d", itemID)
            end
            if itemID ~= CONST_HEARTHSTONE_ID and not ForeverQoL.IsQuestItem(itemID) and (name:lower():find(searchText, 1, true)
                or tostring(itemID):find(searchText, 1, true)) then
                selected[#selected + 1] = { id = itemID, name = name, quality = quality }
            end
        end
        table.sort(selected, function(a, b) return a.name < b.name end)
        for _, entry in ipairs(ForeverQoL.ScanBags()) do
            if not ForeverQoLData.Configs.AutoSellItemList[entry.id] and (entry.name:lower():find(searchText, 1, true)
                or tostring(entry.id):find(searchText, 1, true)) then
                available[#available + 1] = entry
            end
        end

        bagScroll:SetData(ForeverQoL.ToGridRows(available))
        listScroll:SetData(ForeverQoL.ToGridRows(selected))
        if ForeverQoLOptions.AutoDepositListWindow and ForeverQoLOptions.AutoDepositListWindow:IsShown() then
            ForeverQoLOptions.AutoDepositListWindow:Reload()
        end
        if resetScroll then
            bagScroll:OnVerticalScroll(0)
            listScroll:OnVerticalScroll(0)
        else
            bagScroll:Refresh()
            listScroll:Refresh()
        end
    end

    DF:CreateLabel(window, "In your bags, click to add", 12, "orange"):SetPoint("topleft", window, "topleft", 20, -68)
    bagScroll = DF:CreateScrollBox(window, frameName .. "Bags", ForeverQoL.RefreshGrid, {},
        CONST_COLUMN_WIDTH, CONST_GRID_ROWS * CONST_CELL, CONST_GRID_ROWS, CONST_CELL)
    bagScroll:SetPoint("topleft", window, "topleft", 20, -88)
    bagScroll:CreateLines(GridLine(function(slot)
        if slot.entry then
            AddItem(slot.entry.id)
        end
    end), CONST_GRID_ROWS)
    DF:ReskinSlider(bagScroll)

    DF:CreateLabel(window, "On the list, drag here to add, click to remove", 12, "orange"):SetPoint("topleft", window, "topleft", CONST_COLUMN_WIDTH + 50, -68)
    listScroll = DF:CreateScrollBox(window, frameName .. "List", ForeverQoL.RefreshGrid, {},
        CONST_COLUMN_WIDTH, CONST_GRID_ROWS * CONST_CELL, CONST_GRID_ROWS, CONST_CELL)
    listScroll:SetPoint("topleft", window, "topleft", CONST_COLUMN_WIDTH + 50, -88)
    listScroll:CreateLines(GridLine(function(slot)
        if slot.addedFromCursor or not slot.entry then
            return
        end
        ForeverQoLData.Configs.AutoSellItemList[slot.entry.id] = nil
        ForeverQoL.Print(string.format("Removed %s (%d) from the auto sell list.", slot.entry.name, slot.entry.id))
        window:Reload()
    end, true), CONST_GRID_ROWS)
    DF:ReskinSlider(listScroll)

    EnableDrop(listScroll)

    DF:CreateLabel(window, "Search name or item ID", 12, "orange"):SetPoint("topleft", window, "topleft", 20, -36)
    local searchBox = DF:CreateSearchBox(window, function(self)
        searchText = self:GetText():match("^%s*(.-)%s*$"):lower()
        window:Reload(true)
    end)
    searchBox:SetPoint("topleft", window, "topleft", 185, -27)
    searchBox:SetWidth(CONST_LIST_WIDTH - 210)

    self.AutoSellListWindow = window
    window:Toggle()
end
