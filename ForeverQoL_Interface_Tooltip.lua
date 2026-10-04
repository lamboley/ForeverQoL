local ForeverQoL = select(2, ...)

local Tooltip = CreateFrame("Frame", "ForeverQoL_Tooltip")

function Tooltip:Init()
    if not ForeverQoLData.Configs["ShowTargetInTooltip"] then
        return
    end
    -- OnTooltipSetUnit no longer fires on this client; unit tooltips are filled through the
    -- data processor instead.
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip)
        local _, unit = tooltip:GetUnit()
        local target = unit and UnitName(unit .. "target")
        if target and target ~= "" then
            tooltip:AddLine(string.format("%s: %s", TARGET, target), 1, 0.82, 0)
        end
    end)
end

ForeverQoL.Interface.Tooltip = Tooltip
