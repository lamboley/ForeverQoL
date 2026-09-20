local ForeverQoL = select(2, ...)

local Bank = CreateFrame("Frame", "ForeverQoL_Bank")

-- TODO: Probably hide item in auto sell list if they are present in bag

local CONST_COPPER_PER_GOLD = 10000
-- The character's own bank. This client has no warband bank, so Enum.BankType.Account is out.
local CONST_CHARACTER_BANK = Enum.BankType.Character

Bank.Items = ForeverQoL.CreateItemList("AutoDepositItemList", "auto deposit list")

---Using a bag item while a bank is open deposits it into whichever tab is being viewed.
function Bank:DepositListedItems()
    if not ForeverQoLData.Configs["DepositListedItemsToBank"] then
        return
    end

    local deposited = 0
    for bagID = 0, NUM_BAG_SLOTS do
        local numSlots = C_Container.GetContainerNumSlots(bagID)
        if numSlots then
            for slot = 1, numSlots do
                local itemID = C_Container.GetContainerItemID(bagID, slot)
                if itemID and self.Items:Contains(itemID) then
                    local containerInfo = C_Container.GetContainerItemInfo(bagID, slot)
                    if containerInfo and not containerInfo.isLocked then
                        C_Container.UseContainerItem(bagID, slot)
                        deposited = deposited + 1
                    end
                end
            end
        end
    end

    if deposited > 0 then
        ForeverQoL.Print(string.format("Deposited %d stacks into the open bank tab.", deposited))
    end
end

local function GetExcessCopper()
    local keep = math.max(0, math.floor(tonumber(ForeverQoLData.Configs["KeepGoldAmount"]) or 0))
    local excess = GetMoney() - (keep * CONST_COPPER_PER_GOLD)
    if excess <= 0 then
        return 0
    end

    -- Deposit whole gold only, leaving the silver and copper on the character
    return math.floor(excess / CONST_COPPER_PER_GOLD) * CONST_COPPER_PER_GOLD
end

function Bank:UpdateGameplayBank()
    self:DepositListedItems()

    if not ForeverQoLData.Configs["DepositExcessGoldToBank"] then
        return
    end

    if not C_Bank.CanUseBank(CONST_CHARACTER_BANK) then
        return
    end

    local excess = GetExcessCopper()
    if excess == 0 then
        return
    end

    C_Bank.DepositMoney(CONST_CHARACTER_BANK, excess)
    ForeverQoL.Print(string.format("Deposited %d gold into the bank.", excess / CONST_COPPER_PER_GOLD))
end

function Bank:Init()
    self:RegisterEvent("BANKFRAME_OPENED")

    self:SetScript("OnEvent", self.UpdateGameplayBank)
end

ForeverQoL.Gameplay.Bank = Bank
