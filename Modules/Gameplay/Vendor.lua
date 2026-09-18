---@class ForeverQoL
local ForeverQoL = select(2, ...)

--Lua API
local select = select
local format = string.format

-- WoW API
-- Namespaces absent from a client are read here rather than indexed, so this file still loads
local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots
local GetContainerItemID = C_Container and C_Container.GetContainerItemID
local UseContainerItem = C_Container and C_Container.UseContainerItem
local CanMerchantRepair = CanMerchantRepair
local IsEquippableItem = IsEquippableItem
local RepairAllItems = RepairAllItems
local GetGuildInfo = GetGuildInfo

local Vendor = ForeverQoL.CreateModule("Vendor", "MERCHANT_SHOW")

-- The buyback list only ever holds 12 items, anything sold past that cannot be bought back.
local BUYBACK_LIMIT = 12

-- The sell list and the deposit list share one implementation
Vendor.Items = ForeverQoL.CreateItemList("AutoSellItemList", "auto sell list")

function Vendor:OnEvent(_, ...)
    if ForeverQoLData.Configs["RepairGearAutomatically"] and CanMerchantRepair() then
        if ForeverQoLData.Configs["UseGuildBankForRepair"] and select(1, GetGuildInfo('player')) then
            RepairAllItems(true)
        end
        RepairAllItems()
    end

    local sellJunk = ForeverQoLData.Configs["SellJunkAutomatically"]
    local sellListed = ForeverQoLData.Configs["SellListedItemsAutomatically"]
    if not sellJunk and not sellListed then
        return
    end

    -- Repairing above needs no bag access, so only the selling half is gated on it
    if not GetContainerNumSlots or not GetContainerItemID or not GetContainerItemInfo or not UseContainerItem then
        ForeverQoL.Debug("Vendor: this client has no container API, nothing can be sold")
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
                        -- Grey gear is still gear, and on a fresh character it is often the best
                        -- thing in the bag, so junk selling leaves anything equippable alone.
                        -- Putting it on the sell list below still sells it.
                        local isJunk = containerInfo.quality == 0 and not IsEquippableItem(itemID)

                        if (sellJunk and isJunk) or (sellListed and Vendor.Items.Contains(itemID)) then
                            UseContainerItem(bagID, slot)
                            sold = sold + 1
                        end
                    end
                end
            end
        end
    end

    ForeverQoL.Debug("Sold", sold, "items")
end

ForeverQoL.Gameplay.Vendor = Vendor
