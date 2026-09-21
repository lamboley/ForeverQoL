local ForeverQoL = select(2, ...)

local CONST_ICON_SIZE = 38
local CONST_ICON_PAD = 4
local CONST_ICONS_PER_ROW = 7
local CONST_HEARTHSTONE_ID = 6948

local CONST_CELL = CONST_ICON_SIZE + CONST_ICON_PAD

function ForeverQoL.IsQuestItem(itemID)
    if select(6, C_Item.GetItemInfoInstant(itemID)) == Enum.ItemClass.Questitem then
        return true
    end
    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
            if C_Container.GetContainerItemID(bagID, slot) == itemID then
                local questInfo = C_Container.GetContainerItemQuestInfo(bagID, slot)
                if questInfo and (questInfo.isQuestItem or questInfo.questID) then
                    return true
                end
            end
        end
    end
    return false
end

function ForeverQoL.ScanBags()
    local seen, items = {}, {}
    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
            local info = C_Container.GetContainerItemInfo(bagID, slot)
            local itemID = info and info.itemID
            if itemID and itemID ~= CONST_HEARTHSTONE_ID and not seen[itemID] and not ForeverQoL.IsQuestItem(itemID) then
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
function ForeverQoL.ToGridRows(items)
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

function ForeverQoL.CreateSlot(row, column, onClick)
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
    slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return slot
end

function ForeverQoL.RefreshGrid(self, data, offset, totalLines)
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
                    slot.icon:SetVertexColor(1, 1, 1)

                    -- The slot border carries the rarity, the way a bag slot does
                    local color = entry.quality and ITEM_QUALITY_COLORS[entry.quality]
                    if color then
                        slot:SetBackdropBorderColor(color.r, color.g, color.b, 1)
                    else
                        slot:SetBackdropBorderColor(0, 0, 0, 0.5)
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
