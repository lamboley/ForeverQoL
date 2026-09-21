local ForeverQoL = select(2, ...)

local Interface = CreateFrame("Frame", "ForeverQoL_Interface")

local CONST_KNOWN_COLOR = { r = 0, g = 1, b = 0 }
local CONST_ICON_DIM = 0.9

local CONST_PET_KNOWN_PREFIX = string.match(ITEM_PET_KNOWN, "[^%(]+")

local CONST_CONTAINER_FRAMES = 13

-- Restriction text is drawn at full red; anything darker is a different kind of message.
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
            local r, g, b = CONST_KNOWN_COLOR.r, CONST_KNOWN_COLOR.g, CONST_KNOWN_COLOR.b

            SetItemButtonNameFrameVertexColor(merchantButton, r, g, b)
            SetItemButtonSlotVertexColor(merchantButton, r, g, b)
            SetItemButtonTextureVertexColor(itemButton, r * CONST_ICON_DIM, g * CONST_ICON_DIM, b * CONST_ICON_DIM)
            SetItemButtonNormalTextureVertexColor(itemButton, r * CONST_ICON_DIM, g * CONST_ICON_DIM, b * CONST_ICON_DIM)
        end
    end
end

local function IsRestrictionRed(color)
    return color ~= nil
        and color.r == 1
        and color.g < CONST_RED_CHANNEL_MAX
        and color.b < CONST_RED_CHANNEL_MAX
end

---Every restriction the game applies -- class, race, level, reputation, profession --
---reaches the tooltip as red text, so matching the colour covers all of them at once and
---in every locale. The three excluded lines are red without meaning the item is unusable.
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

local function MarkUnusable(itemButton, unusable)
    local icon = itemButton.icon
    if not icon then
        return
    end

    itemButton.foreverQoLUnusable = unusable

    if not icon.foreverQoLHooked then
        icon.foreverQoLHooked = true

        -- Blizzard resets the icon to white whenever it redraws a slot, on paths no addon
        -- is told about, so the tint is restored from inside SetVertexColor rather than by
        -- chasing every update function the client happens to have.
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

    if unusable then
        TintRed(icon)
    else
        icon:SetVertexColor(1, 1, 1)
    end
end

---This client builds bag buttons dynamically and gives them no global name, so they are
---reachable only through the container's own lists, and each button knows its own bag.
local function MarkContainer(containerFrame)
    if not containerFrame or not containerFrame:IsVisible() or not containerFrame.Items then
        return
    end

    for _, itemButton in ipairs(containerFrame.Items) do
        if itemButton.GetSlotAndBagID then
            local slotID, bagID = itemButton:GetSlotAndBagID()
            local hasItem = C_Container.GetContainerItemID(bagID, slotID) ~= nil
            MarkUnusable(itemButton, hasItem and IsUnusable(bagID, slotID))
        end
    end
end

local function UpdateUnusableBags()
    local container = _G["ContainerFrameContainer"]
    if container and container.ContainerFrames then
        for _, containerFrame in ipairs(container.ContainerFrames) do
            MarkContainer(containerFrame)
        end
    end

    -- Combined bags replace the numbered frames and are not in that list.
    MarkContainer(_G["ContainerFrameCombinedBags"])
end

function Interface:Init()
    if ForeverQoLData.Configs["TintKnownAtMerchant"] then
        hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateKnowMerchant)
    end

    if ForeverQoLData.Configs["TintUnusableInBags"] then
        -- A container frame is handed a different bag as bags open and close, so the marks
        -- need recomputing on show and not only when the contents change.
        for frameIndex = 1, CONST_CONTAINER_FRAMES do
            local containerFrame = _G["ContainerFrame" .. frameIndex]
            if containerFrame then
                containerFrame:HookScript("OnShow", UpdateUnusableBags)
            end
        end

        local combinedFrame = _G["ContainerFrameCombinedBags"]
        if combinedFrame then
            combinedFrame:HookScript("OnShow", UpdateUnusableBags)
        end

        self:RegisterEvent("BAG_UPDATE_DELAYED")
        self:RegisterEvent("PLAYER_LEVEL_UP")
        self:SetScript("OnEvent", UpdateUnusableBags)

        UpdateUnusableBags()
    end

    self.Quests:Init()
    self.Visibility:Init()
    self.OtherAddons:Init()
end

ForeverQoL.Interface = Interface
