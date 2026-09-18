---@class ForeverQoL
local ForeverQoL = select(2, ...)

local System = ForeverQoL.CreateModule("System", "PLAYER_ENTERING_WORLD")

function System:OnEvent(event, ...)
    -- Placeholder for future system-level event handling
    -- This ensures consistent architecture across all Core modules
end

function System:PostEnable()
    self.Graphics:Enable()
    self.Audio:Enable()
end

function System:PostDisable()
    self.Graphics:Disable()
    self.Audio:Disable()
end

ForeverQoL.System = System
