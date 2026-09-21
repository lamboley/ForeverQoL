local ForeverQoL = select(2, ...)

local Bank = CreateFrame("Frame", "ForeverQoL_Bank")

local CONST_COPPER_PER_GOLD = 10000
local CONST_CHARACTER_BANK = Enum.BankType.Character

local function DepositListedItems()
    local deposited = 0

    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
            local itemID = C_Container.GetContainerItemID(bagID, slot)
            if itemID and ForeverQoLData.Configs.AutoDepositItemList[itemID]
                and not ForeverQoLData.Configs.AutoSellItemList[itemID] then
                local containerInfo = C_Container.GetContainerItemInfo(bagID, slot)
                if containerInfo and not containerInfo.isLocked then
                    C_Container.UseContainerItem(bagID, slot)
                    deposited = deposited + 1
                end
            end
        end
    end

    if deposited > 0 then
        ForeverQoL.Print(string.format("Deposited %d stacks into the open bank tab.", deposited))
    end
end

local function DepositExcessGold()
    local keep = math.max(0, math.floor(tonumber(ForeverQoLData.Configs["KeepGoldAmount"]) or 0))
    local excess = math.max(0, math.floor(GetMoney() / CONST_COPPER_PER_GOLD) - keep)
    if excess == 0 then
        return
    end

    C_Bank.DepositMoney(CONST_CHARACTER_BANK, excess * CONST_COPPER_PER_GOLD)
    ForeverQoL.Print(string.format("Deposited %d gold into the bank.", excess))
end

function Bank:UpdateGameplayBank()
    if ForeverQoLData.Configs["DepositListedItemsToBank"] then
        DepositListedItems()
    end

    if ForeverQoLData.Configs["DepositExcessGoldToBank"] and C_Bank.CanUseBank(CONST_CHARACTER_BANK) then
        DepositExcessGold()
    end
end

function Bank:Init()
    self:RegisterEvent("BANKFRAME_OPENED")

    self:SetScript("OnEvent", self.UpdateGameplayBank)
end

ForeverQoL.Gameplay.Bank = Bank
