local ForeverQoL = select(2, ...)

ForeverQoL.DefaultSettings = {
    -- System - General
    MaxOutCameraDistance = true,

    -- System - Graphics
    UsePerfectPixel = true,
    UseCustomHeight = "1440",

    -- System - Audio
    MuteAnnoyingSound = true,

    -- Social - Chat
    DisableChatClamping = true,

    -- Gameplay - General
    DisableRightClickTargeting = true,
    FasterAutoLoot = true,

    -- Gameplay - Merchant
    RepairGearAutomatically = true,
    UseGuildBankForRepair = false,
    SellJunkAutomatically = true,
    KeepGreyGear = true,
    SellListedItemsAutomatically = true,
    AutoSellItemList = {
        252032, -- Red Delicious Stormapple
        252030, -- Pungent Skycheddar
        252028, -- Fresh Gustberry Bread
        267464, -- Galeswept Forestshroom
        252022, -- Galestrider Jerky
    },
    LimitSellToTwelveItems = true,

    -- Gameplay - Bank
    DepositExcessGoldToBank = true,
    KeepGoldAmount = "1",
    DepositListedItemsToBank = true,
    AutoDepositItemList = {},

    -- Interface - General
    TintKnownAtMerchant = true,
    TintUnusableRed = true,

    -- Interface - Quests
    UntrackCompletedQuests = true,

    -- Interface - Visibility
    FloatingCombatTextVisibility = "always",
    HideTooltipWhileInCombat = false,
    BagBarVisibility = "always",
    MicroMenuVisibility = "always",
    StatusBarVisibility = "always",

    -- Interface - Other Addons
    RestoreGrid2Positions = true,
}

function ForeverQoL:CreateDefaultSettings()
    ForeverQoLData = ForeverQoLData or {}
    ForeverQoLData.Configs = ForeverQoLData.Configs or {}

    for key, default in pairs(self.DefaultSettings) do
        if ForeverQoLData.Configs[key] == nil then
            ForeverQoLData.Configs[key] = default
        end
    end
end
