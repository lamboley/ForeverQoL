local ForeverQoL = select(2, ...)

local Interface = CreateFrame("Frame", "ForeverQoL_Interface")

-- Known items go green; the icon itself is dimmed so the item art still reads through it.
local CONST_ICON_DIM = 0.9
local CONST_JUNK_SHADE = 0.4
local CONST_PET_KNOWN_PREFIX = string.match(ITEM_PET_KNOWN, "[^%(]+")
local CONST_CONTAINER_FRAMES = 13

local CONST_RED_CHANNEL_MAX = 0.2

local function IsKnown(itemLink)
    local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
    if not tooltipData then
        return false
    end
    for _, line in ipairs(tooltipData.lines) do
        local text = line.leftText or ""
        if text == ITEM_SPELL_KNOWN or (CONST_PET_KNOWN_PREFIX and string.match(text, CONST_PET_KNOWN_PREFIX)) then
            return true
        elseif text == ITEM_COSMETIC and C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink) then
            return true
        end
    end
    return false
end

local function UpdateKnowMerchant()
    for index = 1, MERCHANT_ITEMS_PER_PAGE do
        local merchantButton = _G["MerchantItem" .. index]
        local itemButton = _G["MerchantItem" .. index .. "ItemButton"]
        if not merchantButton or not itemButton then
            return
        end
        local page = MerchantFrame.page or 1
        local itemLink = GetMerchantItemLink(((page - 1) * MERCHANT_ITEMS_PER_PAGE) + index)
        if itemLink and IsKnown(itemLink) then
            SetItemButtonNameFrameVertexColor(merchantButton, 0, 1, 0)
            SetItemButtonSlotVertexColor(merchantButton, 0, 1, 0)
            SetItemButtonTextureVertexColor(itemButton, 0, CONST_ICON_DIM, 0)
            SetItemButtonNormalTextureVertexColor(itemButton, 0, CONST_ICON_DIM, 0)
        end
    end
end

local function IsRestrictionRed(color)
    return color ~= nil and color.r == 1 and color.g < CONST_RED_CHANNEL_MAX and color.b < CONST_RED_CHANNEL_MAX
end

local function IsUnusable(bagID, slotID)
    local tooltipData = C_TooltipInfo.GetBagItem(bagID, slotID)
    if not tooltipData then
        return false
    end
    for _, line in ipairs(tooltipData.lines) do
        if IsRestrictionRed(line.rightColor) then
            return true
        end
        if IsRestrictionRed(line.leftColor)
            and line.leftText ~= ITEM_SCRAPABLE_NOT
            and line.leftText ~= CANNOT_UNEQUIP_COMBAT
            and line.leftText ~= ITEM_DISENCHANT_NOT_DISENCHANTABLE then
            return true
        end
    end
    return false
end

local function TintRed(icon)
    icon:SetVertexColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b)
end

local function MarkItem(itemButton, unusable, dim)
    local icon = itemButton.icon
    if not icon then
        return
    end
    itemButton.foreverQoLUnusable = unusable
    if not icon.foreverQoLHooked then
        icon.foreverQoLHooked = true
        local restoring = false
        hooksecurefunc(icon, "SetVertexColor", function()
            if restoring or not itemButton.foreverQoLUnusable then
                return
            end
            restoring = true
            TintRed(icon)
            restoring = false
        end)
    end

    icon:SetDesaturated(dim)
    if unusable then
        TintRed(icon)
    else
        local shade = dim and CONST_JUNK_SHADE or 1
        icon:SetVertexColor(shade, shade, shade)
    end
end

local function MarkContainer(containerFrame)
    if not containerFrame or not containerFrame:IsVisible() or not containerFrame.Items then
        return
    end
    for _, itemButton in ipairs(containerFrame.Items) do
        if itemButton.GetSlotAndBagID then
            local slotID, bagID = itemButton:GetSlotAndBagID()
            -- Switching the combined bags on or off rebuilds these frames, and a button that
            -- has not been handed its slot back yet answers -1, which the container API rejects.
            local info = slotID > 0 and C_Container.GetContainerItemInfo(bagID, slotID)
            MarkItem(itemButton,
                info and ForeverQoLData.Configs["TintUnusableInBags"] and IsUnusable(bagID, slotID),
                info and ForeverQoLData.Configs["DesaturateJunkInBags"]
                    and (info.quality == 0 or ForeverQoLData.Configs.AutoSellItemList[info.itemID] == true))
        end
    end
end

local function UpdateBagMarks()
    local container = _G["ContainerFrameContainer"]
    if container and container.ContainerFrames then
        for _, containerFrame in ipairs(container.ContainerFrames) do
            MarkContainer(containerFrame)
        end
    end

    MarkContainer(_G["ContainerFrameCombinedBags"])
end

function Interface:Init()
    if ForeverQoLData.Configs["TintKnownAtMerchant"] then
        hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateKnowMerchant)
    end

    if ForeverQoLData.Configs["TintUnusableInBags"] or ForeverQoLData.Configs["DesaturateJunkInBags"] then
        for frameIndex = 1, CONST_CONTAINER_FRAMES do
            local containerFrame = _G["ContainerFrame" .. frameIndex]
            if containerFrame then
                containerFrame:HookScript("OnShow", UpdateBagMarks)
            end
        end
        local combinedFrame = _G["ContainerFrameCombinedBags"]
        if combinedFrame then
            combinedFrame:HookScript("OnShow", UpdateBagMarks)
        end
        self:RegisterEvent("BAG_UPDATE_DELAYED")
        self:RegisterEvent("PLAYER_LEVEL_UP")
        self:SetScript("OnEvent", UpdateBagMarks)
        UpdateBagMarks()
    end

    if ForeverQoLData.Configs["EasyItemDestroy"] then
        -- Quest items keep the typing, which is the one case where the friction earns its keep.
        hooksecurefunc("StaticPopup_Show", function(which)
            local popup = which == "DELETE_GOOD_ITEM" and StaticPopup_FindVisible(which)
            if popup then
                popup.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
            end
        end)
    end

    self.ActionBars:Init()
    self.Tooltip:Init()
    self.Quests:Init()
    self.Visibility:Init()
    self.OtherAddons:Init()
end

ForeverQoL.Interface = Interface
