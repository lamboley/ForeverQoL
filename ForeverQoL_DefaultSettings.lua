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
    RestoreChatMessages = true,

    -- Social - Invites
    BlockDuelRequests = true,
    BlockPartyInvites = false,
    BlockFriendRequests = false,
    BlockDuelSpam = true,
    ShowInviterInfo = true,

    -- Gameplay - Automation
    AutoAcceptResurrect = true,
    AutoAcceptSummon = true,
    ThankOnSummon = true,
    ThankOnSummonMessage = "Thanks for the summon!",
    AutoConfirmRoleCheck = true,
    AutoReleaseInPvP = true,

    -- Gameplay - General
    FasterAutoLoot = true,
    AutoGroupChat = true,

    -- Inventory - Merchant
    RepairGearAutomatically = true,
    UseGuildBankForRepair = false,
    SellJunkAutomatically = true,
    KeepGreyGear = true,
    SellListedItemsAutomatically = true,
    AutoSellItemList = {
        [252032] = true, -- Red Delicious Stormapple
        [252030] = true, -- Pungent Skycheddar
        [252028] = true, -- Fresh Gustberry Bread
        [252022] = true, -- Galestrider Jerky
        [4604] = true, -- Forest Mushroom Cap
        [2070] = true, -- Darnassian Bleu
        [4536] = true, -- Shiny Red Apple
        [2287] = true, -- Haunch of Meat
        [2681] = true, -- Roasted Boar Meat
        [414] = true, -- Dalaran Sharp
        [4537] = true, -- Tel'Abim Banana
        [4605] = true, -- Red-speckled Mushroom
    },
    ShowRepairSummary = true,
    ShowSellSummary = true,
    BuyListedItemsAutomatically = true,
    AutoBuyItemList = {
        [4471] = 1, -- Flint and Tinder
        [2901] = 1, -- Mining Pick
        [5956] = 1, -- Blacksmith Hammer
    },
    TintKnownAtMerchant = true,

    -- Inventory - Bank
    DepositExcessGoldToBank = true,
    KeepGoldAmount = "1",
    DepositListedItemsToBank = true,
    AutoDepositItemList = {},

    -- Inventory - Bags
    TintUnusableInBags = true,
    EasyItemDestroy = true,
    DesaturateJunkInBags = true,

    -- Interface - Action Bars
    HideKeybindText = false,
    HideMacroText = true,

    -- Interface - Quests
    UntrackCompletedQuests = true,

    -- Interface - Tooltip
    ShowTargetInTooltip = true,

    -- Interface - Visibility
    HideBossBanner = true,
    HideErrorMessages = false,
    HideZoneText = false,
    HideEventToasts = true,
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
            -- The item lists are copied, so editing one in game never writes into the defaults.
            local saved = default
            if type(default) == "table" then
                saved = {}
                for index, value in pairs(default) do
                    saved[index] = value
                end
            end
            ForeverQoLData.Configs[key] = saved
        end
    end
end
