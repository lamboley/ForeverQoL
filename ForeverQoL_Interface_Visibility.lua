local ForeverQoL = select(2, ...)

local Visibility = CreateFrame("Frame", "ForeverQoL_Visibility")

local CONST_MOUSEOVER_PADDING = 10
local CONST_MOUSEOVER_INTERVAL = 0.05

local mouseoverFrames = {}
local sinceLastCheck = 0

local function OnUpdate(_, elapsed)
    -- The target alpha is either 0 or 1, so hit testing the cursor on every rendered
    -- frame buys nothing the eye can see
    sinceLastCheck = sinceLastCheck + elapsed
    if sinceLastCheck < CONST_MOUSEOVER_INTERVAL then
        return
    end
    sinceLastCheck = 0
    for i = 1, #mouseoverFrames do
        local frame = mouseoverFrames[i]
        local alpha = frame:IsMouseOver(CONST_MOUSEOVER_PADDING, -CONST_MOUSEOVER_PADDING, -CONST_MOUSEOVER_PADDING, CONST_MOUSEOVER_PADDING) and 1 or 0
        -- Only touch the frame when the alpha actually changes, this runs several times a second
        if frame:GetAlpha() ~= alpha then
            frame:SetAlpha(alpha)
        end
    end
end

---Blizzard shows these frames again on its own, so hiding one has to survive that.
local function KeepHidden(frame, configKey)
    if not frame.foreverQoLHooked then
        frame.foreverQoLHooked = true
        -- Re-read the setting so the permanent hook allows later visibility changes.
        frame:HookScript("OnShow", function(shown)
            if ForeverQoLData.Configs[configKey] == "never" then
                shown:Hide()
            end
        end)
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

function Visibility:UpdateCombatText()
    local wanted = ForeverQoLData.Configs["FloatingCombatTextVisibility"]
    local hide = false
    for _, state in ipairs(ForeverQoL.CombatTextStates) do
        if state.value == wanted then
            -- A state with roles hides for those roles only, whatever its hide flag says.
            if state.roles then
                hide = state.roles[ForeverQoL.GetRole() or ""] == true
            else
                hide = state.hide == true
            end
            break
        end
    end
    for _, cvar in ipairs(ForeverQoL.CombatTextCVars) do
        SetCVar(cvar, hide and 0 or 1)
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

    -- Unregistering beats hiding: each of these is shown by its own events, so a hidden frame
    -- is put straight back the next time one fires. Not every frame ships on every build, and
    -- an error here would cost the rest of this Init and the modules that follow it.
    if ForeverQoLData.Configs["HideBossBanner"] and BossBanner then
        BossBanner:UnregisterAllEvents()
    end
    if ForeverQoLData.Configs["HideErrorMessages"] and UIErrorsFrame then
        -- Only the red errors, so the yellow notices such as loot and reputation still land.
        UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
    end
    if ForeverQoLData.Configs["HideZoneText"] and ZoneTextFrame then
        ZoneTextFrame:UnregisterAllEvents()
        SubZoneTextFrame:UnregisterAllEvents()
    end
    if ForeverQoLData.Configs["HideEventToasts"] and EventToastManagerFrame then
        EventToastManagerFrame:UnregisterAllEvents()
    end

    if ForeverQoLData.Configs["HideTooltipWhileInCombat"] then
        hooksecurefunc(GameTooltip, "Show", function(tooltip)
            if UnitAffectingCombat("player") then
                tooltip:Hide()
            end
        end)
    end
end

ForeverQoL.Interface.Visibility = Visibility
