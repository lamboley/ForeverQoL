local ForeverQoL = select(2, ...)

local Merchant = CreateFrame("Frame", "ForeverQoL_Merchant")

local function isGear(itemID)
    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemID)
    return type(equipLoc) == "string" and equipLoc:find("INVTYPE_", 1, true) == 1 and equipLoc:find("INVTYPE_NON_EQUIP", 1, true) ~= 1
end

local function sellItems()
    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
            local itemID = C_Container.GetContainerItemID(bagID, slot)
            local containerInfo = itemID and C_Container.GetContainerItemInfo(bagID, slot)
            if containerInfo and not containerInfo.isLocked and containerInfo.iconFileID then
                local isJunk = containerInfo.quality == 0 and not (ForeverQoLData.Configs["KeepGreyGear"] and isGear(itemID))
                if isJunk or ForeverQoLData.Configs.AutoSellItemList[itemID] then
                    C_Container.UseContainerItem(bagID, slot)
                end
            end
        end
    end
end

local function repairItems()
    if ForeverQoLData.Configs["UseGuildBankForRepair"] and GetGuildInfo("player") then
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
