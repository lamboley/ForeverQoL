local ForeverQoL = select(2, ...)

local DF = _G["DetailsFramework"]
local ForeverQoLOptions = ForeverQoL.ForeverQoLOptions

local CONST_ICON_SIZE = 26
local CONST_ROW_HEIGHT = 32
local CONST_DEFAULT_AMOUNT = 20

local CONST_LIST_WIDTH = 460
local CONST_LIST_HEIGHT = 670
local CONST_LIST_ROWS = math.floor((CONST_LIST_HEIGHT - 110) / CONST_ROW_HEIGHT)

function ForeverQoLOptions:ToggleAutoBuyList()
    if self.AutoBuyListWindow then
        self.AutoBuyListWindow:Toggle()
        return
    end
    local frameName = "ForeverQoLBuyListWindow"
    local window = DF:CreateSimplePanel(UIParent, CONST_LIST_WIDTH, CONST_LIST_HEIGHT, "Auto Buy List", frameName)
    window:SetFrameStrata("FULLSCREEN_DIALOG")
    window:SetToplevel(true)
    DF:ApplyStandardBackdrop(window)

    -- Beside the options panel rather than on top of it. Only at creation, so dragging it
    -- somewhere else afterwards sticks.
    window:ClearAllPoints()
    window:SetPoint("topleft", ForeverQoLOptions, "topright", 8, 0)
    window:Hide()
    local listScroll
    local searchText = ""

    local function AddItem(itemID)
        local refusal = ForeverQoLData.Configs.AutoSellItemList[itemID] and "Remove this item from the auto sell list before adding it to the auto buy list."
            or ForeverQoL.IsQuestItem(itemID) and "Quest items cannot be added to the auto buy list."
        if refusal then
            ForeverQoL.Print(refusal)
            return
        end

        local entries = ForeverQoLData.Configs.AutoBuyItemList
        if entries[itemID] then
            return
        end
        entries[itemID] = CONST_DEFAULT_AMOUNT
        ForeverQoL.Print(string.format("Added %s (%d) to the auto buy list, keeping %d in the bags.",
            (C_Item.GetItemInfo(itemID)) or string.format("Item #%d", itemID), itemID, CONST_DEFAULT_AMOUNT))
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
            -- Dropping onto a row must not also remove that row on mouse release.
            frame.addedFromCursor = GetCursorInfo() == "item"
            AddFromCursor()
        end)
    end

    local function ListLine(self, index)
        local row = CreateFrame("frame", nil, self)
        row:SetPoint("topleft", self, "topleft", 1, -((index - 1) * CONST_ROW_HEIGHT) - 2)
        row:SetSize(CONST_LIST_WIDTH - 44, CONST_ROW_HEIGHT - 4)
        row.iconButton = CreateFrame("button", nil, row)
        row.iconButton:SetPoint("left", row, "left", 2, 0)
        row.iconButton:SetSize(CONST_ICON_SIZE, CONST_ICON_SIZE)
        row.iconButton:SetScript("OnClick", function(iconButton)
            if iconButton.addedFromCursor or not row.itemID then
                return
            end
            ForeverQoLData.Configs.AutoBuyItemList[row.itemID] = nil
            ForeverQoL.Print(string.format("Removed %s (%d) from the auto buy list.", row.itemName, row.itemID))
            window:Reload()
        end)
        EnableDrop(row.iconButton)
        row.icon = row.iconButton:CreateTexture(nil, "artwork")
        row.icon:SetAllPoints()
        -- The default coordinates include the icon's own border
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.label = DF:CreateLabel(row, "", 11)
        row.label:SetPoint("left", row.iconButton, "right", 8, 0)
        row.amount = DF:CreateTextEntry(row, function(_, _, text)
            local amount = math.floor(tonumber(text) or 0)
            if row.itemID and amount >= 1 then
                ForeverQoLData.Configs.AutoBuyItemList[row.itemID] = amount
            else
                ForeverQoL.Print("Amount to keep must be a whole number of 1 or more")
            end
            window:Reload()
        end, 48, 20)
        row.amount:SetPoint("right", row, "right", -4, 0)
        return row
    end

    local function RefreshList(self, data, offset, totalLines)
        for i = 1, totalLines do
            local entry = data[i + offset]
            local row = self:GetLine(i)
            row.itemID = entry and entry.id
            if entry then
                row.itemName = entry.name
                row.icon:SetTexture(C_Item.GetItemIconByID(entry.id))
                row.label:SetText(entry.name)
                row.amount:SetText(tostring(entry.amount))
                row:Show()
            else
                row:Hide()
            end
        end
    end

    ---Opening always reloads, since an item may have joined the sell list since last time.
    function window:Toggle()
        if self:IsShown() then
            self:Hide()
            return
        end
        self:Reload()
        self:Show()
    end

    function window:Reload(resetScroll)
        local entries = {}
        for itemID, amount in pairs(ForeverQoLData.Configs.AutoBuyItemList) do
            local name = (C_Item.GetItemInfo(itemID)) or string.format("Item #%d", itemID)
            if name:lower():find(searchText, 1, true) or tostring(itemID):find(searchText, 1, true) then
                entries[#entries + 1] = { id = itemID, name = name, amount = amount }
            end
        end
        table.sort(entries, function(a, b) return a.name < b.name end)

        listScroll:SetData(entries)
        if resetScroll then
            -- A search must start at its first result, even when the unfiltered list was scrolled down.
            listScroll:OnVerticalScroll(0)
        else
            listScroll:Refresh()
        end
    end

    DF:CreateLabel(window, "Drag an item here to add it, click its icon to remove", 12, "orange"):SetPoint("topleft", window, "topleft", 20, -68)
    listScroll = DF:CreateScrollBox(window, frameName .. "List", RefreshList, {},
        CONST_LIST_WIDTH - 40, CONST_LIST_ROWS * CONST_ROW_HEIGHT, CONST_LIST_ROWS, CONST_ROW_HEIGHT)
    listScroll:SetPoint("topleft", window, "topleft", 20, -88)
    listScroll:CreateLines(ListLine, CONST_LIST_ROWS)
    DF:ReskinSlider(listScroll)

    -- The scrollbox catches whatever lands between or below the rows
    EnableDrop(listScroll)

    DF:CreateLabel(window, "Search name or item ID", 12, "orange"):SetPoint("topleft", window, "topleft", 20, -36)
    local searchBox = DF:CreateSearchBox(window, function(self)
        searchText = self:GetText():match("^%s*(.-)%s*$"):lower()
        window:Reload(true)
    end)
    searchBox:SetPoint("topleft", window, "topleft", 185, -27)
    searchBox:SetWidth(CONST_LIST_WIDTH - 210)

    self.AutoBuyListWindow = window
    window:Toggle()
end
