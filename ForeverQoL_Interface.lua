local ForeverQoL = select(2, ...)

local Interface = CreateFrame("Frame", "ForeverQoL_Interface")

-- TEMPORARY: how many calls to record before going quiet
local traced = 0

-- Blizzard has never numbered more than this, and a missing one is simply skipped
local CONST_CONTAINER_FRAMES = 13
local CONST_UNUSABLE_COLOR = { r = 1, g = 0.3, b = 0.3 }
local CONST_KNOWN_COLOR = { r = 0, g = 1, b = 0 }
local CONST_ICON_DIM = 0.9
local containerHookRegistered = false
local merchantHookRegistered = false

-- ITEM_PET_KNOWN reads "Already collected (%d/%d)", the count has to be trimmed off.
local CONST_PET_KNOWN_PREFIX = string.match(ITEM_PET_KNOWN, "[^%(]+")

local function TintButton(button, frameBagID)
    local icon = button.icon

    -- A combined bag frame holds slots from every bag, so its own id means nothing.
    -- The button knows which bag it belongs to, ask it first.
    local bagID = button:GetBagID() or frameBagID
    local slotIndex = button:GetID()
    local itemID = (bagID and slotIndex) and C_Container.GetContainerItemID(bagID, slotIndex)

    -- TEMPORARY: parked on disk because this client writes saved variables faithfully and
    -- its chat cannot be copied out of. Remove once the tint works.
    if traced < 6 then
        traced = traced + 1
        local diag = ForeverQoLData.Diag or {}
        ForeverQoLData.Diag = diag
        diag.Bags = diag.Bags or {}
        diag.Bags[#diag.Bags + 1] = string.format("icon=%s bag=%s slot=%s item=%s unusable=%s option=%s",
            tostring(icon ~= nil), tostring(bagID), tostring(slotIndex), tostring(itemID),
            tostring(itemID and ForeverQoL.IsUnusable(itemID)),
            tostring(ForeverQoLData.Configs["TintUnusableRed"]))
    end

    if not icon or not itemID then return end

    if ForeverQoLData.Configs["TintUnusableRed"] and ForeverQoL.IsUnusable(itemID) then
        icon:SetVertexColor(CONST_UNUSABLE_COLOR.r, CONST_UNUSABLE_COLOR.g, CONST_UNUSABLE_COLOR.b)
    else
        icon:SetVertexColor(1, 1, 1)
    end
end

local function UpdateContainer(frame)
    local frameBagID = frame:GetID()
    for _, button in frame:EnumerateValidItems() do
        TintButton(button, frameBagID)
    end
end

---Containers already on screen when the addon loads have had their redraw, so they need one pass.
function Interface:UpdateBags()
    for index = 1, CONST_CONTAINER_FRAMES do
        local frame = _G["ContainerFrame" .. index]
        if frame and frame:IsShown() then
            UpdateContainer(frame)
        end
    end
end

local function IsKnown(itemLink)
    local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
    if not tooltipData then return false end

    for i, line in ipairs(tooltipData.lines) do
        local text = line.leftText
        if not text then
            -- keep scanning, a blank line is not an answer
        elseif text == ITEM_SPELL_KNOWN or (CONST_PET_KNOWN_PREFIX and string.match(text, CONST_PET_KNOWN_PREFIX)) then
            return true
        elseif text == TOY then
            -- A toy carries its known line two rows below the Toy tag, not on it
            local following = tooltipData.lines[i + 2]
            if following and following.leftText == ITEM_SPELL_KNOWN then return true end
        elseif text == ITEM_COSMETIC and C_TransmogCollection.PlayerHasTransmogByItemInfo(itemLink) then
            -- Cosmetics often omit the known line entirely, so ask the collection directly
            return true
        end
    end

    return false
end

local function TintSlot(index)
    local merchantButton = _G["MerchantItem" .. index]
    local itemButton = _G["MerchantItem" .. index .. "ItemButton"]
    if not merchantButton or not itemButton then return end

    local page = MerchantFrame.page or 1
    local itemLink = GetMerchantItemLink(((page - 1) * MERCHANT_ITEMS_PER_PAGE) + index)
    if not itemLink then return end

    -- Unusable wins over known: what the character can never wear matters more than owning it
    local color
    if ForeverQoLData.Configs["TintUnusableRed"] and ForeverQoL.IsUnusable(itemLink) then
        color = CONST_UNUSABLE_COLOR
    elseif ForeverQoLData.Configs["TintKnownAtMerchant"] and IsKnown(itemLink) then
        color = CONST_KNOWN_COLOR
    else
        return
    end

    local r, g, b = color.r, color.g, color.b
    SetItemButtonNameFrameVertexColor(merchantButton, r, g, b)
    SetItemButtonSlotVertexColor(merchantButton, r, g, b)
    SetItemButtonTextureVertexColor(itemButton, CONST_ICON_DIM * r, CONST_ICON_DIM * g, CONST_ICON_DIM * b)
    SetItemButtonNormalTextureVertexColor(itemButton, CONST_ICON_DIM * r, CONST_ICON_DIM * g, CONST_ICON_DIM * b)
end

local function UpdateMerchant()
    if not ForeverQoLData.Configs["TintKnownAtMerchant"] and not ForeverQoLData.Configs["TintUnusableRed"] then
        return
    end

    for index = 1, MERCHANT_ITEMS_PER_PAGE do
        TintSlot(index)
    end
end

function Interface:Init()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:SetScript("OnEvent", self.UpdateBags)

    if not containerHookRegistered then
        hooksecurefunc(ContainerFrameMixin, "UpdateItems", UpdateContainer)
        containerHookRegistered = true
    end

    if not merchantHookRegistered then
        hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateMerchant)
        merchantHookRegistered = true
    end

    self.Quests:Init()
    self.Visibility:Init()
    self.OtherAddons:Init()
end

ForeverQoL.Interface = Interface
