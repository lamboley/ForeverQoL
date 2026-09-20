local ForeverQoL = select(2, ...)

local Audio = CreateFrame("Frame", "ForeverQoL_Audio")

function Audio:Init()
    if ForeverQoLData.Configs["MuteAnnoyingSound"] then
        for _, soundID in ipairs(ForeverQoL.DefaultSoundToMute) do
            MuteSoundFile(soundID)
        end
    end
end

ForeverQoL.System.Audio = Audio
