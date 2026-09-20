local ForeverQoL = select(2, ...)

local Merchant = CreateFrame("Frame", "ForeverQoL_Merchant")

-- The buyback list only ever holds 12 items, anything sold past that cannot be bought back.
local CONST_BUYBACK_LIMIT = 12

-- The sell list and the deposit list share one implementation
Merchant.Items = ForeverQoL.CreateItemList("AutoSellItemList", "auto sell list")

---Anything with an equip slot counts as gear, whatever its quality.
---The equip location comes straight from the item database, so it answers on an uncached item.
local function IsGear(itemID)
    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemID)

    -- Every wearable slot is one of the INVTYPE_ constants, and what cannot be worn comes back
    -- as INVTYPE_NON_EQUIP or INVTYPE_NON_EQUIP_IGNORE depending on the client, never as "".
    -- Matching by prefix rather than "not empty" means an unexpected value here degrades to
    -- selling the item, instead of calling the whole bag gear and selling nothing.
    return type(equipLoc) == "string"
        and equipLoc:find("INVTYPE_", 1, true) == 1
        and equipLoc:find("INVTYPE_NON_EQUIP", 1, true) ~= 1
end

function Merchant:UpdateGameplayMerchant()
    if ForeverQoLData.Configs["RepairGearAutomatically"] and CanMerchantRepair() then
        if ForeverQoLData.Configs["UseGuildBankForRepair"] and select(1, GetGuildInfo('player')) then
            RepairAllItems(true)
        end
        RepairAllItems()
    end

    local sellJunk = ForeverQoLData.Configs["SellJunkAutomatically"]
    local sellListed = ForeverQoLData.Configs["SellListedItemsAutomatically"]
    local keepGear = ForeverQoLData.Configs["KeepGreyGear"]
    if not sellJunk and not sellListed then
        return
    end

    local limit = ForeverQoLData.Configs["LimitSellToTwelveItems"] and CONST_BUYBACK_LIMIT or nil
    local sold = 0

    for bagID = 0, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots then
            for slot = 1, numSlots do
                if limit and sold >= limit then
                    ForeverQoL.Print(string.format("Sold %d items, the buyback limit. Reopen the merchant to sell more.", sold))
                    return
                end

                local itemID = C_Container.GetContainerItemID(bagID, slot)
                if itemID then
                    local containerInfo = C_Container.GetContainerItemInfo(bagID, slot)
                    -- hasNoValue means the merchant refuses it, and UseContainerItem would then use the item instead of selling it.
                    if containerInfo and not containerInfo.isLocked and not containerInfo.hasNoValue and containerInfo.iconFileID then
                        -- Only a grey item can ever be spared, so nothing else pays for the lookup.
                        -- The sell list below ignores this and sells what is on it either way.
                        local isGear = keepGear and containerInfo.quality == 0 and IsGear(itemID)
                        local isJunk = containerInfo.quality == 0 and not isGear

                        if (sellJunk and isJunk) or (sellListed and self.Items:Contains(itemID)) then
                            C_Container.UseContainerItem(bagID, slot)
                            sold = sold + 1
                        end
                    end
                end
            end
        end
    end
end

function Merchant:Init()
    self:RegisterEvent("MERCHANT_SHOW")

    self:SetScript("OnEvent", self.UpdateGameplayMerchant)
end

ForeverQoL.Gameplay.Merchant = Merchant
