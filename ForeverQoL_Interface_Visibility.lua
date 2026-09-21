local ForeverQoL = select(2, ...)

local Visibility = CreateFrame("Frame", "ForeverQoL_Visibility")

local CONST_MOUSEOVER_PADDING = 10
local CONST_MOUSEOVER_INTERVAL = 0.05

local hookedFrames = {}
local mouseoverFrames = {}
local sinceLastCheck = 0

local function UpdateAlpha(frame)
    local alpha = frame:IsMouseOver(CONST_MOUSEOVER_PADDING, -CONST_MOUSEOVER_PADDING, -CONST_MOUSEOVER_PADDING, CONST_MOUSEOVER_PADDING) and 1 or 0
    -- Only touch the frame when the alpha actually changes, this runs several times a second
    if frame:GetAlpha() ~= alpha then
        frame:SetAlpha(alpha)
    end
end

local function OnUpdate(_, elapsed)
    -- The target alpha is either 0 or 1, so hit testing the cursor on every rendered
    -- frame buys nothing the eye can see
    sinceLastCheck = sinceLastCheck + elapsed
    if sinceLastCheck < CONST_MOUSEOVER_INTERVAL then
        return
    end
    sinceLastCheck = 0

    for i = 1, #mouseoverFrames do
        UpdateAlpha(mouseoverFrames[i])
    end
end

---Blizzard shows these frames again on its own, so hiding one has to survive that.
local function KeepHidden(frame, configKey)
    if not hookedFrames[frame] then
        -- Re-read the setting so the permanent hook allows later visibility changes.
        frame:HookScript("OnShow", function(shown)
            if ForeverQoLData.Configs[configKey] == "never" then
                shown:Hide()
            end
        end)
        hookedFrames[frame] = true
    end

    frame:Hide()
end

local function ApplyVisibility(bar)
    local frame = _G[bar.name]
    if not frame then
        return
    end

    local state = ForeverQoLData.Configs[bar.key]

    if state == "mouseover" then
        -- Coming from "never" the frame is still hidden, and OnUpdate only sets the alpha
        frame:Show()
        mouseoverFrames[#mouseoverFrames + 1] = frame
    elseif state == "never" then
        KeepHidden(frame, bar.key)
    else
        -- Coming from "mouseover" the alpha is wherever the cursor left it
        frame:SetAlpha(1)
        frame:Show()
    end
end

function Visibility:UpdateVisibility()
    wipe(mouseoverFrames)

    for _, bar in ipairs(ForeverQoL.BarVisibilityFrames) do
        ApplyVisibility(bar)
    end

    self:SetScript("OnUpdate", #mouseoverFrames > 0 and OnUpdate or nil)
end

---Options for a visibility dropdown, bound to the config key it writes.
function Visibility:GetVisibilityOptions(key)
    local options = {}
    for i, state in ipairs(ForeverQoL.BarVisibilityStates) do
        options[i] = {
            label = state.label,
            value = state.value,
            onclick = function()
                ForeverQoLData.Configs[key] = state.value
                self:UpdateVisibility()
            end
        }
    end

    return options
end

local function ShouldHideCombatText()
    local wanted = ForeverQoLData.Configs["FloatingCombatTextVisibility"]
    for _, state in ipairs(ForeverQoL.CombatTextStates) do
        if state.value == wanted then
            if state.roles then
                return state.roles[ForeverQoL.GetRole() or ""] == true
            end

            return state.hide == true
        end
    end

    return false
end

function Visibility:UpdateCombatText()
    local value = ShouldHideCombatText() and 0 or 1
    for _, cvar in ipairs(ForeverQoL.CombatTextCVars) do
        SetCVar(cvar, value)
    end
end

---Options for the floating combat text dropdown.
function Visibility:GetCombatTextOptions()
    local options = {}
    for i, state in ipairs(ForeverQoL.CombatTextStates) do
        options[i] = {
            label = state.label,
            value = state.value,
            onclick = function()
                ForeverQoLData.Configs["FloatingCombatTextVisibility"] = state.value
                self:UpdateCombatText()
            end
        }
    end

    return options
end

function Visibility:OnEvent(event)
    self:UpdateCombatText()

    if event == "PLAYER_ENTERING_WORLD" then
        self:UpdateVisibility()
    end
end

function Visibility:Init()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:SetScript("OnEvent", self.OnEvent)

    self:UpdateVisibility()
    self:UpdateCombatText()

    if ForeverQoLData.Configs["HideTooltipWhileInCombat"] then
        hooksecurefunc(GameTooltip, "Show", function(tooltip)
            if UnitAffectingCombat("player") then
                tooltip:Hide()
            end
        end)
    end
end

ForeverQoL.Interface.Visibility = Visibility
