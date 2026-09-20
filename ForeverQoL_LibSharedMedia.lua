local LSM = LibStub('LibSharedMedia-3.0')

local mediaPath = {
	statusbar = [[Interface\AddOns\ForeverQoL\Medias\Statusbar\]],
	sound = [[Interface\AddOns\ForeverQoL\Medias\Sounds\]],
	font = [[Interface\AddOns\ForeverQoL\Medias\Font\]],
}

local function AddMedia(type, name, file)
	LSM:Register(type, name, mediaPath[type] .. file)
end

AddMedia('statusbar','ForeverQoLOnePixel', 'ForeverQoLOnePixel')
AddMedia('statusbar','ForeverQoLClean', 'ForeverQoLClean')
AddMedia('sound','|cFF00FF00ForeverQoL silence|r', 'silence.ogg')
AddMedia('sound','|cFF00FF00ForeverQoLGTFO|r', 'GTFO.ogg')
AddMedia('sound','|cFF00FF00ForeverQoLGTFO Quiet|r', 'GTFO_quiet.ogg')
AddMedia('sound','|cFF00FF00ForeverQoLGTFO Soft|r', 'GTFO_soft.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL dispelboss|r', 'dispelboss.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL dispelnow|r', 'dispelnow.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL stopmove|r', 'stopmove.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL stopattack|r', 'stopattack.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL runout|r', 'runout.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL runin|r', 'runin.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL runaway|r', 'runaway.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL movetotank|r', 'movetotank.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL movemelee|r', 'movemelee.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL mobsoon|r', 'mobsoon.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL killmob|r', 'killmob.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL keepmove|r', 'keepmove.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL keepjump|r', 'keepjump.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL incomingdebuff|r', 'incomingdebuff.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL helpsoak|r', 'helpsoak.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL healfull|r', 'healfull.ogg')
AddMedia('sound','|cFF00FF00ForeverQoL silence|r', 'silence.ogg')
AddMedia('font','FiraSansCondensed', 'FiraSansCondensed-Medium.ttf')
