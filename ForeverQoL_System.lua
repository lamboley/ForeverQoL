local ForeverQoL = select(2, ...)

local System = CreateFrame("Frame", "ForeverQoL_System")

function System:Init()
    if ForeverQoLData.Configs["MaxOutCameraDistance"] then
        SetCVar("cameraDistanceMaxZoomFactor", 2.6)
    end

    self.Graphics:Init()
    self.Audio:Init()
end

ForeverQoL.System = System
