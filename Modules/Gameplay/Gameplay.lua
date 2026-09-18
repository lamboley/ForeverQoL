---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- WoW API
local GetNumLootItems = GetNumLootItems
local LootSlot = LootSlot

local Gameplay = ForeverQoL.CreateModule("Gameplay", "LOOT_READY")

local mouselookInitialized = false

function Gameplay:PreEnable()
    if ForeverQoLData.Configs["DisableRightClickTargeting"] and not mouselookInitialized then
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

        mouselookInitialized = true
    end
end

function Gameplay:OnEvent(event, ...)
    if ForeverQoLData.Configs["FasterAutoLoot"] then
        LootFrame:SetAlpha(0)
        for i = 1, GetNumLootItems() do
            LootSlot(i)
        end
    end
end

function Gameplay:PostEnable()
    self.Vendor:Enable()
    self.Bank:Enable()
    self.Voice:Enable()
    self.ThichNhatHanh:Enable()
    self.BattlePet:Enable()
end

function Gameplay:PostDisable()
    self.Vendor:Disable()
    self.Bank:Disable()
    self.Voice:Disable()
    self.ThichNhatHanh:Disable()
    self.BattlePet:Disable()
end

ForeverQoL.Gameplay = Gameplay
