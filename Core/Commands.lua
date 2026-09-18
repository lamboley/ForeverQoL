---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local select = select
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local format = string.format

-- WoW API
-- Namespaces absent from a client are read here rather than indexed, so this file still loads
local GetSummonedPetGUID = C_PetJournal and C_PetJournal.GetSummonedPetGUID
local GetPetInfoByPetID = C_PetJournal and C_PetJournal.GetPetInfoByPetID
local ReloadUI = ReloadUI

SLASH_ForeverQoL1 = "/foreverqol"
SLASH_ForeverQoL2 = "/fql"

SlashCmdList["ForeverQoL"] = function(msg)
    if msg == "debug" then
        ForeverQoL.Print(ForeverQoLData.Configs["FloatingCombatTextVisibility"])
    elseif msg == "pet" then
        if not GetSummonedPetGUID or not GetPetInfoByPetID then
            ForeverQoL.Print("This client has no pet journal, there is nothing to report.")
            return
        end

        local summonedPetGUID = GetSummonedPetGUID()
        if summonedPetGUID then
            local petName = select(8, GetPetInfoByPetID(summonedPetGUID))
            ForeverQoL.Print(petName)
        else
            ForeverQoL.Print("There is not battle pet summoned.")
        end
    elseif msg == "prof" then
        if not C_TradeSkillUI or not C_TradeSkillUI.GetFilteredRecipeIDs then
            ForeverQoL.Print("This client has no profession recipe API, there are no categories to list.")
            return
        end

        -- There is no GetCategories, so the categories are collected from the recipes themselves
        local recipes = C_TradeSkillUI.GetFilteredRecipeIDs()
        if not recipes or #recipes == 0 then
            ForeverQoL.Print("Open a profession window first.")
            return
        end

        local seen = {}
        ForeverQoL.Print("Categories of the open profession:")
        for _, recipeID in ipairs(recipes) do
            local recipe = C_TradeSkillUI.GetRecipeInfo(recipeID)
            local categoryID = recipe and recipe.categoryID
            if categoryID and not seen[categoryID] then
                seen[categoryID] = true
                local info = C_TradeSkillUI.GetCategoryInfo(categoryID)
                print(format("  |cff00ff00%d|r %s |cff909090(parent %s)|r",
                    categoryID,
                    info and info.name or "?",
                    info and tostring(info.parentCategoryID) or "?"))
            end
        end
    elseif msg == "h" or msg == "help" then
        ForeverQoL.Print("Command usage:")
        print("|cff00ff00/fql|r - Toggle options menu")
        print("|cff00ff00/fql pet|r - Display currently summoned battle pet name")
        print("|cff00ff00/fql prof|r - List the categories of the open profession with their id")
        print("|cff00ff00/fql help|r - Show this help message")
    else
        ForeverQoL.ForeverQoLGui:ToggleOptions()
    end
end

SLASH_RELOADUI1 = "/rel"
SlashCmdList.RELOADUI = ReloadUI
