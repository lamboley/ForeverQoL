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
    AutoGroupChat = true,

    -- Gameplay - Merchant
    RepairGearAutomatically = true,
    UseGuildBankForRepair = false,
    SellJunkAutomatically = true,
    KeepGreyGear = true,
    SellListedItemsAutomatically = true,
    AutoSellItemList = {
        [252032] = true, -- Red Delicious Stormapple
        [252030] = true, -- Pungent Skycheddar
        [252028] = true, -- Fresh Gustberry Bread
        [267464] = true, -- Galeswept Forestshroom
        [252022] = true, -- Galestrider Jerky
    },

    -- Gameplay - Bank
    DepositExcessGoldToBank = true,
    KeepGoldAmount = "1",
    DepositListedItemsToBank = true,
    AutoDepositItemList = {},

    -- Interface - General
    TintKnownAtMerchant = true,

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
            if type(default) == "table" then
                ForeverQoLData.Configs[key] = {}
                for index, value in pairs(default) do
                    ForeverQoLData.Configs[key][index] = value
                end
            else
                ForeverQoLData.Configs[key] = default
            end
        end
    end
end
