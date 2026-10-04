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

function ActionBars:Init()
    if ForeverQoLData.Configs["HideKeybindText"] or ForeverQoLData.Configs["HideMacroText"] then
        ActionBarButtonEventsFrame:ForEachFrame(Register)
        -- Stance, vehicle and override bars hand their buttons over well after login.
        hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", function(_, button)
            Register(button)
        end)
    end
end

ForeverQoL.Interface.ActionBars = ActionBars
