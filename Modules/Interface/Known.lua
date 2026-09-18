---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local ipairs = ipairs
local strmatch = string.match

-- WoW API
-- Namespaces absent from a client are read here rather than indexed, so this file still loads
local PlayerHasTransmogByItemInfo = C_TransmogCollection and C_TransmogCollection.PlayerHasTransmogByItemInfo
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant
local GetHyperlink = C_TooltipInfo and C_TooltipInfo.GetHyperlink
local GetMerchantItemLink = GetMerchantItemLink
local hooksecurefunc = hooksecurefunc

local Known = ForeverQoL.CreateModule("Known", "PLAYER_ENTERING_WORLD")

local KNOWN_COLOR = { r = 0, g = 1, b = 0 }
local ICON_DIM = 0.9

-- ITEM_PET_KNOWN reads "Already collected (%d/%d)", the count has to be trimmed off.
-- The constant is absent on a client without a pet journal.
local PET_KNOWN_PREFIX = ITEM_PET_KNOWN and strmatch(ITEM_PET_KNOWN, "[^%(]+")

local merchantHookRegistered = false

---Housing decor carries no known line, the catalog has to be asked whether the entry is owned.
---@param itemLink string
---@return boolean
local function IsDecorOwned(itemLink)
	-- The catalog only exists from Midnight onwards
	if not C_HousingCatalog or not C_HousingCatalog.GetCatalogEntryInfoByItem then
		return false
	end

	local _, _, _, _, _, classId, subclassId = GetItemInfoInstant(itemLink)
	if classId ~= Enum.ItemClass.Housing or subclassId ~= Enum.ItemHousingSubclass.Decor then
		return false
	end

	local info = C_HousingCatalog.GetCatalogEntryInfoByItem(itemLink, true)
	if not info or not info.entryID then
		return false
	end

	local subtype = info.entryID.entrySubtype
	return subtype == Enum.HousingCatalogEntrySubtype.OwnedUnmodifiedStack
		or subtype == Enum.HousingCatalogEntrySubtype.OwnedModifiedStack
end

---@param itemLink string
---@return boolean
local function IsKnown(itemLink)
	if IsDecorOwned(itemLink) then
		return true
	end

	local tooltipData = GetHyperlink(itemLink)
	if not tooltipData then
		return false
	end

	for i, line in ipairs(tooltipData.lines) do
		local text = line.leftText
		if not text then
			-- keep scanning, a blank line is not an answer
		elseif text == ITEM_SPELL_KNOWN or (PET_KNOWN_PREFIX and strmatch(text, PET_KNOWN_PREFIX)) then
			return true
		elseif text == TOY then
			-- A toy carries its known line two rows below the Toy tag, not on it
			local following = tooltipData.lines[i + 2]
			if following and following.leftText == ITEM_SPELL_KNOWN then
				return true
			end
		elseif text == ITEM_COSMETIC and PlayerHasTransmogByItemInfo and PlayerHasTransmogByItemInfo(itemLink) then
			-- Cosmetics often omit the known line entirely, so ask the collection directly
			return true
		end
	end

	return false
end

---@param index number slot on the merchant frame
local function TintSlot(index)
	local merchantButton = _G["MerchantItem" .. index]
	local itemButton = _G["MerchantItem" .. index .. "ItemButton"]
	if not merchantButton or not itemButton then
		return
	end

	local page = MerchantFrame.page or 1
	local itemLink = GetMerchantItemLink(((page - 1) * MERCHANT_ITEMS_PER_PAGE) + index)
	if not itemLink or not IsKnown(itemLink) then
		return
	end

	local r, g, b = KNOWN_COLOR.r, KNOWN_COLOR.g, KNOWN_COLOR.b
	SetItemButtonNameFrameVertexColor(merchantButton, r, g, b)
	SetItemButtonSlotVertexColor(merchantButton, r, g, b)
	SetItemButtonTextureVertexColor(itemButton, ICON_DIM * r, ICON_DIM * g, ICON_DIM * b)
	SetItemButtonNormalTextureVertexColor(itemButton, ICON_DIM * r, ICON_DIM * g, ICON_DIM * b)
end

local function UpdateMerchant()
	if not ForeverQoLData.Configs["TintKnownAtMerchant"] then
		return
	end

	for index = 1, MERCHANT_ITEMS_PER_PAGE do
		TintSlot(index)
	end
end

---The tooltip scan is what tells a known item from an unknown one, there is no fallback for it.
---@return boolean
function Known:IsSupported()
	return GetHyperlink ~= nil and MerchantFrame_UpdateMerchantInfo ~= nil
end

function Known:PreEnable()
	-- The hook is permanent and cannot be removed, so it re-checks the config instead.
	-- Running after Blizzard's own update is what makes recolouring stick.
	if not merchantHookRegistered then
		hooksecurefunc("MerchantFrame_UpdateMerchantInfo", UpdateMerchant)
		merchantHookRegistered = true
	end
end

function Known:OnEvent(event, ...)
	return
end

ForeverQoL.Interface.Known = Known
