local ForeverQoL = select(2, ...)

local ActionBars = CreateFrame("Frame", "ForeverQoL_ActionBars")

---The extra action and vehicle buttons are action buttons without the full furniture:
---ExtraActionButton1 carries a hotkey label but no macro name.
local function Register(button)
    if ForeverQoLData.Configs["HideKeybindText"] and button.HotKey then
        button.HotKey:SetAlpha(0)
    end
    if ForeverQoLData.Configs["HideMacroText"] and button.Name then
        button.Name:SetAlpha(0)
    end
end

---The griffons flanking the main bar. Each is scaled on its own so it grows from where it is
---anchored, rather than drifting away from the bar as a scaled container would.
function ActionBars:UpdateEndCaps()
    local endCaps = MainActionBar and MainActionBar.EndCaps
    if endCaps and endCaps.LeftEndCap and endCaps.RightEndCap then
        local scale = ForeverQoLData.Configs["EndCapScale"]
        endCaps.LeftEndCap:SetScale(scale)
        endCaps.RightEndCap:SetScale(scale)
    end
end

function ActionBars:Init()
    self:UpdateEndCaps()

    if ForeverQoLData.Configs["HideKeybindText"] or ForeverQoLData.Configs["HideMacroText"] then
        ActionBarButtonEventsFrame:ForEachFrame(Register)
        -- Stance, vehicle and override bars hand their buttons over well after login.
        hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
            Register(button)
        end)
    end
end

ForeverQoL.Interface.ActionBars = ActionBars
