local LSM = LibStub('LibSharedMedia-3.0')

local mediaPath = {
	statusbar = [[Interface\AddOns\ForeverQoL\Medias\Statusbar\]],
	sound = [[Interface\AddOns\ForeverQoL\Medias\Sounds\]],
	font = [[Interface\AddOns\ForeverQoL\Medias\Font\]],
}

local function AddMedia(type, name, file)
	LSM:Register(type, name, mediaPath[type] .. file)
end

AddMedia('statusbar','ForeverQoLOnePixel', 'ForeverQoLOnePixel.tga')
AddMedia('sound','|cFF00FF00ForeverQoL silence|r', 'silence.ogg')
AddMedia('font','FiraSansCondensed', 'FiraSansCondensed-Medium.ttf')
