---@class ForeverQoL
local ForeverQoL = select(2, ...)

--Lua API
local select = select
local type = type
local format = string.format

-- WoW API
-- Namespaces absent from a client are read here rather than indexed, so this file still loads
local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots
local GetContainerItemID = C_Container and C_Container.GetContainerItemID
local UseContainerItem = C_Container and C_Container.UseContainerItem
local GetItemInfoInstant = C_Item and C_Item.GetItemInfoInstant
local CanMerchantRepair = CanMerchantRepair
local RepairAllItems = RepairAllItems
local GetGuildInfo = GetGuildInfo

-- Selling walks the bags, repairing does not, so the two halves are gated separately
local canScanBags = (GetContainerItemInfo and GetContainerNumSlots and GetContainerItemID and UseContainerItem) ~= nil

local Vendor = ForeverQoL.CreateModule("Vendor", "MERCHANT_SHOW")

-- The buyback list only ever holds 12 items, anything sold past that cannot be bought back.
local BUYBACK_LIMIT = 12

-- The sell list and the deposit list share one implementation
Vendor.Items = ForeverQoL.CreateItemList("AutoSellItemList", "auto sell list")

---Anything with an equip slot counts as gear, whatever its quality.
---The equip location comes straight from the item database, so it answers on an uncached item.
---@param itemID number
---@return boolean
local function IsGear(itemID)
    if not GetItemInfoInstant then
        return false
    end

    local _, _, _, equipLoc = GetItemInfoInstant(itemID)

    -- Every wearable slot is one of the INVTYPE_ constants, and what cannot be worn comes back
    -- as INVTYPE_NON_EQUIP or INVTYPE_NON_EQUIP_IGNORE depending on the client, never as "".
    -- Matching by prefix rather than "not empty" means an unexpected value here degrades to
    -- selling the item, instead of calling the whole bag gear and selling nothing.
    return type(equipLoc) == "string"
        and equipLoc:find("INVTYPE_", 1, true) == 1
        and equipLoc:find("INVTYPE_NON_EQUIP", 1, true) ~= 1
end

---Selling leans on APIs that are not on every client, and doing nothing at a merchant
---looks exactly like an empty bag, so the gaps are reported once at login instead.
function Vendor:PreEnable()
    if not canScanBags then
        ForeverQoL.Print("This client has no C_Container API, automatic selling is off. Repairing still works.")
    elseif not GetItemInfoInstant then
        ForeverQoL.Print("This client cannot tell an item's equip slot, grey weapons and armour are sold with the other junk.")
    end
end

function Vendor:OnEvent(_, ...)
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

    if not canScanBags then
        ForeverQoL.Info("Vendor: this client has no container API, nothing can be sold")
        return
    end

    local limit = ForeverQoLData.Configs["LimitSellToTwelveItems"] and BUYBACK_LIMIT or nil
    local sold = 0

    for bagID = 0, NUM_BAG_SLOTS do
        local numSlots = GetContainerNumSlots(bagID)
        if numSlots then
            for slot = 1, numSlots do
                if limit and sold >= limit then
                    ForeverQoL.Print(format("Sold %d items, the buyback limit. Reopen the merchant to sell more.", sold))
                    return
                end

                local itemID = GetContainerItemID(bagID, slot)
                if itemID then
                    local containerInfo = GetContainerItemInfo(bagID, slot)
                    -- hasNoValue means the merchant refuses it, and UseContainerItem would then use the item instead of selling it.
                    if containerInfo and not containerInfo.isLocked and not containerInfo.hasNoValue and containerInfo.iconFileID then
                        -- Only a grey item can ever be spared, so nothing else pays for the lookup.
                        -- The sell list below ignores this and sells what is on it either way.
                        local isGear = keepGear and containerInfo.quality == 0 and IsGear(itemID)
                        local isJunk = containerInfo.quality == 0 and not isGear

                        if (sellJunk and isJunk) or (sellListed and Vendor.Items.Contains(itemID)) then
                            UseContainerItem(bagID, slot)
                            sold = sold + 1
                        end
                    end
                end
            end
        end
    end
end

ForeverQoL.Gameplay.Vendor = Vendor
