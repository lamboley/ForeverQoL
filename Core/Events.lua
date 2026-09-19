---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- WoW API
local CreateFrame = CreateFrame

local Events = CreateFrame("Frame")
Events:RegisterEvent("ADDON_LOADED")
Events:RegisterEvent("PLAYER_LOGIN")
Events:SetScript("OnEvent", function(_, event, ...)
	if (event == "ADDON_LOADED") then
        local name = ...
        if name == "ForeverQoL" then
            if not ForeverQoLData then
                ForeverQoLData = {}
            end

            if not ForeverQoLData.Configs then
                ForeverQoLData.Configs = {}
            end

            local function SetDefault(key, default)
                if ForeverQoLData.Configs[key] == nil then
                    ForeverQoLData.Configs[key] = default
                end
            end


            -- System
            SetDefault("MaxOutCameraDistance", true)
            SetDefault("UsePerfectPixel", true)
            SetDefault("UseCustomHeight", "1440")
            SetDefault("MuteAnnoyingSound", false)

            -- Social
            SetDefault("DisableChatClamping", true)

            -- Gameplay
            SetDefault("DisableRightClickTargeting", true)
            SetDefault("FasterAutoLoot", false)
            SetDefault("AddVoiceLineWhenDead", false)
            SetDefault("PrintQuoteFromThichNhatHanh", false)
            SetDefault("KeepABattlePetSummoned", false)
            SetDefault("BattlePetNameToSummon", "")
            SetDefault("RepairGearAutomatically", true)
            SetDefault("UseGuildBankForRepair", false)
            SetDefault("SellJunkAutomatically", true)
            SetDefault("KeepGreyGear", true)
            SetDefault("SellListedItemsAutomatically", false)
            SetDefault("AutoSellItemList", {})
            SetDefault("LimitSellToTwelveItems", true)
            SetDefault("DepositListedItemsToBank", false)
            SetDefault("AutoDepositItemList", {})
            SetDefault("DepositExcessGoldToWarbank", false)
            SetDefault("KeepGoldAmount", "10000")

            -- Interface
            SetDefault("FloatingCombatTextVisibility", "always")
            SetDefault("TintKnownAtMerchant", false)
            SetDefault("ShowRecipeIcons", true)
            -- Matched as a prefix on the category name, ids differ from one profession to the next
            SetDefault("CollapsedCategoryNames", { "Appendix" })
            SetDefault("HideTooltipWhileInCombat", false)
            SetDefault("BagBarVisibility", "never")
            SetDefault("MicroMenuVisibility", "mouseover")
            SetDefault("StatusBarVisibility", "never")

            -- Booleans that became dropdown states, carry the old setting over once
            -- and drop the retired key so this only runs on the first load after upgrading
            local function Migrate(oldKey, newKey, whenTrue)
                local previous = ForeverQoLData.Configs[oldKey]
                if previous == nil then
                    return
                end

                ForeverQoLData.Configs[newKey] = previous and whenTrue or "always"
                ForeverQoLData.Configs[oldKey] = nil
            end

            Migrate("DisableDamageText", "FloatingCombatTextVisibility", "never")
            Migrate("HideBagBar", "BagBarVisibility", "never")
            Migrate("ShowMenuOnMouseover", "MicroMenuVisibility", "mouseover")
            Migrate("ShowStatusBarOnMouseover", "StatusBarVisibility", "mouseover")

            -- Category ids only ever matched one profession, names replaced them
            ForeverQoLData.Configs["AlwaysCollapsedCategories"] = nil

            -- Set the scale here rather than at PLAYER_ENTERING_WORLD, so it lands before any
            -- other addon anchors its frames to UIParent and caches an absolute position
            ForeverQoL.System.Graphics.ApplyScale()
        end
	elseif (event == "PLAYER_LOGIN") then
        ForeverQoL.ForeverQoLGui:Init()

		ForeverQoL.System:Enable()
        ForeverQoL.Gameplay:Enable()
        ForeverQoL.Interface:Enable()
    end
end)
