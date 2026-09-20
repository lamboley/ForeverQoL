local ForeverQoL = select(2, ...)

local Gameplay = CreateFrame("Frame", "ForeverQoL_Gameplay")

local lootFrameAlpha

function Gameplay:UpdateAutoLoot()
    if ForeverQoLData.Configs["FasterAutoLoot"] then
        if lootFrameAlpha == nil then
            lootFrameAlpha = LootFrame:GetAlpha()
        end
        LootFrame:SetAlpha(0)
        for i = 1, GetNumLootItems() do
            LootSlot(i)
        end
    elseif lootFrameAlpha ~= nil then
        LootFrame:SetAlpha(lootFrameAlpha)
        lootFrameAlpha = nil
    end
end

function Gameplay:Init()
    if ForeverQoLData.Configs["DisableRightClickTargeting"] then
        local statusMouseover = CreateFrame('frame', nil, nil, 'SecureHandlerStateTemplate')
        RegisterStateDriver(statusMouseover, 'mouseunitexist', '[@mouseover,exists,combat]1;0')
        statusMouseover:SetAttribute('_onstate-mouseunitexist', [[
            if newstate == 1 then
                self:SetBindingClick(1, 'BUTTON2','ButtonMouselookFrame')
            else
                self:ClearBindings()
            end
        ]])

        local ButtonMouselookFrame = CreateFrame('button', 'ButtonMouselookFrame')
        ButtonMouselookFrame:RegisterForClicks('AnyDown', 'AnyUp')
        ButtonMouselookFrame:SetScript('OnClick', function(_, _, down)
            if down then
                MouselookStart()
            else
                MouselookStop()
            end
        end)
    end

    self:RegisterEvent("LOOT_READY")
    self:SetScript("OnEvent", self.UpdateAutoLoot)

    self.Merchant:Init()
    self.Bank:Init()
end

ForeverQoL.Gameplay = Gameplay
