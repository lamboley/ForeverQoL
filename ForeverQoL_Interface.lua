local ForeverQoL = select(2, ...)

local Interface = CreateFrame("Frame", "ForeverQoL_Interface")

local CONST_KNOWN_COLOR = { r = 0, g = 1, b = 0 }
local CONST_ICON_DIM = 0.9

local CONST_PET_KNOWN_PREFIX = string.match(ITEM_PET_KNOWN, "[^%(]+")

local function IsKnown(itemLink)
    local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
    if not tooltipData then
        return false
    end

    for i, line in ipairs(tooltipData.lines) do
        local text = line.leftText
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
        if not merchantButton then
            return
        end

        local itemButton = _G["MerchantItem" .. index .. "ItemButton"]
        if not itemButton then
            return
        end

        local page = MerchantFrame.page or 1
        local itemLink = GetMerchantItemLink(((page - 1) * MERCHANT_ITEMS_PER_PAGE) + index)

        if itemLink and IsKnown(itemLink) then
            local r = CONST_KNOWN_COLOR.r
            local g = CONST_KNOWN_COLOR.g
            local b = CONST_KNOWN_COLOR.b

            SetItemButtonNameFrameVertexColor(merchantButton, r, g, b)
            SetItemButtonSlotVertexColor(merchantButton, r, g, b)
            SetItemButtonTextureVertexColor(itemButton, CONST_ICON_DIM * r, CONST_ICON_DIM * g, CONST_ICON_DIM * b)
            SetItemButtonNormalTextureVertexColor(itemButton, CONST_ICON_DIM * r, CONST_ICON_DIM * g, CONST_ICON_DIM * b)
        end
    end
end

function Interface:Init()
    if ForeverQoLData.Configs["TintKnownAtMerchant"] then
        hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateKnowMerchant)
    end

    self.Quests:Init()
    self.Visibility:Init()
    self.OtherAddons:Init()
end

ForeverQoL.Interface = Interface
