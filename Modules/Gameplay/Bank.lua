---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local tonumber = tonumber
local format = string.format
local floor = math.floor
local max = math.max

-- WoW API
-- Namespaces absent from a client are read here rather than indexed, so this file still loads
local CanUseBank = C_Bank and C_Bank.CanUseBank
local DepositMoney = C_Bank and C_Bank.DepositMoney
local GetContainerItemInfo = C_Container and C_Container.GetContainerItemInfo
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots
local GetContainerItemID = C_Container and C_Container.GetContainerItemID
local UseContainerItem = C_Container and C_Container.UseContainerItem
local GetMoney = GetMoney

local Bank = ForeverQoL.CreateModule("Bank", "BANKFRAME_OPENED")

local COPPER_PER_GOLD = 10000
-- Enum.BankType only exists on a client that has the warband bank
local WARBAND_BANK = Enum and Enum.BankType and Enum.BankType.Account

Bank.Items = ForeverQoL.CreateItemList("AutoDepositItemList", "auto deposit list")

---Using a bag item while a bank is open deposits it into whichever tab is being viewed.
local function DepositListedItems()
    if not ForeverQoLData.Configs["DepositListedItemsToBank"] then
        return
    end

    if not GetContainerNumSlots or not GetContainerItemID or not GetContainerItemInfo or not UseContainerItem then
        ForeverQoL.Info("Bank: this client has no container API, nothing can be deposited")
        return
    end

    local deposited = 0
    for bagID = 0, NUM_BAG_SLOTS do
        local numSlots = GetContainerNumSlots(bagID)
        if numSlots then
            for slot = 1, numSlots do
                local itemID = GetContainerItemID(bagID, slot)
                if itemID and Bank.Items.Contains(itemID) then
                    local containerInfo = GetContainerItemInfo(bagID, slot)
                    if containerInfo and not containerInfo.isLocked then
                        UseContainerItem(bagID, slot)
                        deposited = deposited + 1
                    end
                end
            end
        end
    end

    if deposited > 0 then
        ForeverQoL.Print(format("Deposited %d stacks into the open bank tab.", deposited))
    end
end

---@return number copper to move, zero when there is nothing to do
local function GetExcessCopper()
    local keep = max(0, floor(tonumber(ForeverQoLData.Configs["KeepGoldAmount"]) or 0))
    local excess = GetMoney() - (keep * COPPER_PER_GOLD)
    if excess <= 0 then
        return 0
    end

    -- Deposit whole gold only, leaving the silver and copper on the character
    return floor(excess / COPPER_PER_GOLD) * COPPER_PER_GOLD
end

function Bank:OnEvent(event, ...)
    DepositListedItems()

    if not ForeverQoLData.Configs["DepositExcessGoldToWarbank"] then
        return
    end

    if not CanUseBank or not DepositMoney or not WARBAND_BANK then
        ForeverQoL.Info("Bank: this client has no warband bank")
        return
    end

    -- The warband bank is not reachable from every banker, and not at all before it is unlocked
    if not CanUseBank(WARBAND_BANK) then
        ForeverQoL.Info("Bank: the warband bank cannot be used here")
        return
    end

    local excess = GetExcessCopper()
    if excess == 0 then
        return
    end

    DepositMoney(WARBAND_BANK, excess)
    ForeverQoL.Print(format("Deposited %d gold to the warband bank.", excess / COPPER_PER_GOLD))
end

ForeverQoL.Gameplay.Bank = Bank
