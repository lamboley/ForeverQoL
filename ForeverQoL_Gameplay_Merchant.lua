local ForeverQoL = select(2, ...)

local Merchant = CreateFrame("Frame", "ForeverQoL_Merchant")

Merchant.Items = ForeverQoL.CreateItemList("AutoSellItemList", "auto sell list")

local function isGear(itemID)
    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemID)
    return type(equipLoc) == "string" and equipLoc:find("INVTYPE_", 1, true) == 1 and equipLoc:find("INVTYPE_NON_EQUIP", 1, true) ~= 1
end


local function sellItems()
    for bagID = 0, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots then
            for slot = 1, numSlots do
                local itemID = C_Container.GetContainerItemID(bagID, slot)
                if itemID then
                    local containerInfo = C_Container.GetContainerItemInfo(bagID, slot)
                    if containerInfo and not containerInfo.isLocked and containerInfo.iconFileID then
                        local isGear = ForeverQoLData.Configs["KeepGreyGear"] and containerInfo.quality == 0 and isGear(itemID)
                        local isJunk = containerInfo.quality == 0 and not isGear

                        if isJunk or Merchant.Items:Contains(itemID) then
                            C_Container.UseContainerItem(bagID, slot)
                        end
                    end
                end
            end
        end
    end
end

local function repairItems()
    if ForeverQoLData.Configs["UseGuildBankForRepair"] and select(1, GetGuildInfo('player')) then
        RepairAllItems(true)
    end
    RepairAllItems()
end

function Merchant:UpdateGameplayMerchant()
    if ForeverQoLData.Configs["RepairGearAutomatically"] and CanMerchantRepair() then
        repairItems()
    end


    if ForeverQoLData.Configs["SellJunkAutomatically"] and ForeverQoLData.Configs["SellListedItemsAutomatically"] then
        sellItems()
    end

end

function Merchant:Init()
    self:RegisterEvent("MERCHANT_SHOW")

    self:SetScript("OnEvent", self.UpdateGameplayMerchant)
end

ForeverQoL.Gameplay.Merchant = Merchant
