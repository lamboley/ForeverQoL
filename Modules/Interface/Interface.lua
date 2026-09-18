---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local ipairs = ipairs

-- WoW API
local UnitAffectingCombat = UnitAffectingCombat
local hooksecurefunc = hooksecurefunc
local GetCVar = GetCVar
local SetCVar = SetCVar

local Interface = ForeverQoL.CreateModule("Interface", {
    "PLAYER_ENTERING_WORLD",
    "PLAYER_SPECIALIZATION_CHANGED"
})

-- These are CVars, not frames, so the combat conditionals the visibility dropdowns use
-- do not apply here. Only the role gating is shared.
local COMBAT_TEXT_STATES = {
    { value = "always", label = "Always Show" },
    { value = "never", label = "Always Hide", hide = true },
    { value = "hideashealer", label = "Hide As Healer", roles = { HEALER = true } },
    { value = "hideastank", label = "Hide As Tank", roles = { TANK = true } },
    { value = "hideashealerortank", label = "Hide As Healer Or Tank", roles = { HEALER = true, TANK = true } }
}

local tooltipHookRegistered = false

local floatingCombatTextCVars = {
    'floatingCombatTextCombatHealing',
    'floatingCombatTextCombatDamage',
    'floatingCombatTextCombatLogPeriodicSpells',
    'floatingCombatTextPetMeleeDamage',
    'floatingCombatTextPetSpellDamage',
    'floatingCombatTextCombatHealing_v2',
    'floatingCombatTextCombatDamage_v2',
    'floatingCombatTextCombatLogPeriodicSpells_v2',
    'floatingCombatTextPetMeleeDamage_v2',
    'floatingCombatTextPetSpellDamage_v2',
}
function Interface:PreEnable()
    if ForeverQoLData.Configs["HideTooltipWhileInCombat"] and not tooltipHookRegistered then
        hooksecurefunc(GameTooltip, 'Show', function(self)
            if UnitAffectingCombat('player') then
                self:Hide()
            end
        end)
        tooltipHookRegistered = true
    end
end

---@return boolean
local function ShouldHideCombatText()
    local wanted = ForeverQoLData.Configs["FloatingCombatTextVisibility"]
    for _, state in ipairs(COMBAT_TEXT_STATES) do
        if state.value == wanted then
            if state.roles then
                return state.roles[ForeverQoL.GetRole() or ""] == true
            end

            return state.hide == true
        end
    end

    return false
end

function Interface:UpdateCombatText()
    local value = ShouldHideCombatText() and 0 or 1
    for _, cvar in ipairs(floatingCombatTextCVars) do
        -- The _v2 variants replaced the originals, only one set exists on a given client
        if GetCVar(cvar) ~= nil then
            SetCVar(cvar, value)
        end
    end
end

---Options for the floating combat text dropdown.
---@return table[]
function Interface.GetCombatTextOptions()
    local options = {}
    for i, state in ipairs(COMBAT_TEXT_STATES) do
        options[i] = {
            label = state.label,
            value = state.value,
            onclick = function()
                ForeverQoLData.Configs["FloatingCombatTextVisibility"] = state.value
                Interface:UpdateCombatText()
            end
        }
    end

    return options
end

function Interface:OnEvent(event, ...)
    self:UpdateCombatText()
end

function Interface:PostEnable()
    self.Known:Enable()
    self.Recipes:Enable()
end

function Interface:PostDisable()
    self.Known:Disable()
    self.Recipes:Disable()
end

ForeverQoL.Interface = Interface
