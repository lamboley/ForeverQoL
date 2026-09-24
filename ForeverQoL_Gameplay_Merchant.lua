local ForeverQoL = select(2, ...)

local Merchant = CreateFrame("Frame", "ForeverQoL_Merchant")

local function isGear(itemID)
    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemID)
    return type(equipLoc) == "string" and equipLoc:find("INVTYPE_", 1, true) == 1 and equipLoc:find("INVTYPE_NON_EQUIP", 1, true) ~= 1
end

local function sellItems()
    local sold, earned = 0, 0
    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
            local itemID = C_Container.GetContainerItemID(bagID, slot)
            local containerInfo = itemID and C_Container.GetContainerItemInfo(bagID, slot)
            if containerInfo and not containerInfo.isLocked and containerInfo.iconFileID then
                local isJunk = containerInfo.quality == 0 and not (ForeverQoLData.Configs["KeepGreyGear"] and isGear(itemID))
                if isJunk or ForeverQoLData.Configs.AutoSellItemList[itemID] then
                    C_Container.UseContainerItem(bagID, slot)
                    sold = sold + 1
                    earned = earned + (select(11, C_Item.GetItemInfo(itemID)) or 0) * (containerInfo.stackCount or 1)
                end
            end
        end
    end
    if sold > 0 and ForeverQoLData.Configs["ShowSellSummary"] then
        ForeverQoL.Print(string.format("Sold %d items for %s.", sold, GetCoinTextureString(earned)))
    end
end

local function buyItems()
    for index = 1, GetMerchantNumItems() do
        local link = GetMerchantItemLink(index)
        local itemID = link and C_Item.GetItemInfoInstant(link)
        local wanted = itemID and ForeverQoLData.Configs.AutoBuyItemList[itemID]
        local missing = wanted and wanted - C_Item.GetItemCount(itemID) or 0
        if missing > 0 then
            BuyMerchantItem(index, missing)
        end
    end
end

local function repairItems()
    local cost = GetRepairAllCost()
    if ForeverQoLData.Configs["UseGuildBankForRepair"] and GetGuildInfo("player") then
        RepairAllItems(true)
    end
    RepairAllItems()
    if cost > 0 and ForeverQoLData.Configs["ShowRepairSummary"] then
        ForeverQoL.Print(string.format("Repaired for %s.", GetCoinTextureString(cost)))
    end
end

function Merchant:UpdateGameplayMerchant()
    if ForeverQoLData.Configs["RepairGearAutomatically"] and CanMerchantRepair() then
        repairItems()
    end
    if ForeverQoLData.Configs["SellJunkAutomatically"] and ForeverQoLData.Configs["SellListedItemsAutomatically"] then
        sellItems()
    end

    if ForeverQoLData.Configs["BuyListedItemsAutomatically"] then
        buyItems()
    end
end

function Merchant:Init()
    self:RegisterEvent("MERCHANT_SHOW")
    self:SetScript("OnEvent", self.UpdateGameplayMerchant)
end

ForeverQoL.Gameplay.Merchant = Merchant
