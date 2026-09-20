local ForeverQoL = select(2, ...)

function ForeverQoL:CreateDataTables()
    local CONST_LEATHER = 2
    local CONST_MAIL = 3
    local CONST_PLATE = 4
    local CONST_SHIELD = 6

    -- Identify armor a class cannot wear so it can be tinted red.
    self.WearableArmor = {
        WARRIOR = { [CONST_LEATHER] = true, [CONST_MAIL] = true, [CONST_PLATE] = true, [CONST_SHIELD] = true },
        PALADIN = { [CONST_LEATHER] = true, [CONST_MAIL] = true, [CONST_PLATE] = true, [CONST_SHIELD] = true },
        DEATHKNIGHT = { [CONST_LEATHER] = true, [CONST_MAIL] = true, [CONST_PLATE] = true },
        HUNTER = { [CONST_LEATHER] = true, [CONST_MAIL] = true },
        SHAMAN = { [CONST_LEATHER] = true, [CONST_MAIL] = true, [CONST_SHIELD] = true },
        EVOKER = { [CONST_MAIL] = true },
        ROGUE = { [CONST_LEATHER] = true },
        DRUID = { [CONST_LEATHER] = true },
        MONK = { [CONST_LEATHER] = true },
        DEMONHUNTER = { [CONST_LEATHER] = true },
        PRIEST = {},
        MAGE = {},
        WARLOCK = {},
    }

    -- Keep combat-text choices and their role-based visibility rules together.
    self.CombatTextStates = {
        { value = "always", label = "Always Show" },
        { value = "never", label = "Always Hide", hide = true },
        { value = "hideashealer", label = "Hide As Healer", roles = { HEALER = true } },
        { value = "hideastank", label = "Hide As Tank", roles = { TANK = true } },
        { value = "hideashealerortank", label = "Hide As Healer Or Tank", roles = { HEALER = true, TANK = true } }
    }

    -- Apply the same visibility setting to player and pet combat text.
    self.CombatTextCVars = {
        'floatingCombatTextCombatHealing',
        'floatingCombatTextCombatDamage',
        'floatingCombatTextCombatLogPeriodicSpells',
        'floatingCombatTextPetMeleeDamage',
        'floatingCombatTextPetSpellDamage',
        'floatingCombatTextCombatHealing_v2',
        'floatingCombatTextCombatDamage_v2',
        'floatingCombatTextCombatLogPeriodicSpells_v2',
        'floatingCombatTextPetMeleeDamage_v2',
        'floatingCombatTextPetSpellDamage_v2',
    }

    -- Give all bars the same visibility choices.
    self.BarVisibilityStates = {
        { value = "always", label = "Always Show" },
        { value = "mouseover", label = "Show On Mouseover" },
        { value = "never", label = "Always Hide" }
    }

    -- Connect each visibility setting to the bar it controls.
    self.BarVisibilityFrames = {
        { key = "BagBarVisibility", name = "BagsBar" },
        { key = "MicroMenuVisibility", name = "MicroMenuContainer" },
        { key = "StatusBarVisibility", name = "MainStatusTrackingBarContainer" }
    }

    -- These are the sound that will be muted by the annoying feature.
    self.DefaultSoundToMute = {
        569854, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclewalkrun.ogg
        569858, -- sound/vehicles/motorcyclevehicle/motorcyclevehicleattackthrown.ogg
        569859, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclestand.ogg
        569861, -- sound/vehicles/motorcyclevehicle/motorcyclevehicleloadthrown.ogg
        569856, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart1.ogg
        569862, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart2.ogg
        569860, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart3.ogg
        569863, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend1.ogg
        569855, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend3.ogg
        569857, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend2.ogg
        598748, -- sound/vehicles/vehicle_ground_gearshift_1.ogg
        598736, -- sound/vehicles/vehicle_ground_gearshift_2.ogg
        569852, -- sound/vehicles/vehicle_ground_gearshift_3.ogg
        598745, -- sound/vehicles/vehicle_ground_gearshift_4.ogg
        569845, -- sound/vehicles/vehicle_ground_gearshift_5.ogg
        1663845, -- sound/creature/manaray/mon_manaray_chuff_01.ogg
        1663846, -- sound/creature/manaray/mon_manaray_chuff_02.ogg
        1663826, -- sound/creature/manaray/mon_manaray_chuff_03.ogg
        1663827, -- sound/creature/manaray/mon_manaray_chuff_04.ogg
        1663828, -- sound/creature/manaray/mon_manaray_chuff_05.ogg
        1663829, -- sound/creature/manaray/mon_manaray_chuff_06.ogg
        1663830, -- sound/creature/manaray/mon_manaray_chuff_07.ogg
        1663831, -- sound/creature/manaray/mon_manaray_chuff_08.ogg
        1663835, -- sound/creature/manaray/mon_manaray_summon_01.ogg
        1663836, -- sound/creature/manaray/mon_manaray_summon_02.ogg
        1323566, -- sound/creature/druidcat/mon_dr_catform_attack01.ogg
        1323567, -- sound/creature/druidcat/mon_dr_catform_attack02.ogg
        1323568, -- sound/creature/druidcat/mon_dr_catform_attack03.ogg
        1323569, -- sound/creature/druidcat/mon_dr_catform_attack04.ogg
        1323570, -- sound/creature/druidcat/mon_dr_catform_attack05.ogg
        1323571, -- sound/creature/druidcat/mon_dr_catform_attack06.ogg
        1323572, -- sound/creature/druidcat/mon_dr_catform_attack07.ogg
        1323573, -- sound/creature/druidcat/mon_dr_catform_attack08.ogg
        1323574, -- sound/creature/druidcat/mon_dr_catform_spellattack01.ogg
        1323575, -- sound/creature/druidcat/mon_dr_catform_spellattack02.ogg
        1323576, -- sound/creature/druidcat/mon_dr_catform_spellattack03.ogg
        1323577, -- sound/creature/druidcat/mon_dr_catform_spellattack04.ogg
        1323578, -- sound/creature/druidcat/mon_dr_catform_spellattack05.ogg
        1324558, -- sound/creature/druidcat/mon_dr_catform_wound01.ogg
        1324559, -- sound/creature/druidcat/mon_dr_catform_wound02.ogg
        1324560, -- sound/creature/druidcat/mon_dr_catform_wound03.ogg
        1324561, -- sound/creature/druidcat/mon_dr_catform_wound04.ogg
        1324562, -- sound/creature/druidcat/mon_dr_catform_wound05.ogg
        1324563, -- sound/creature/druidcat/mon_dr_catform_wound06.ogg
        1324564, -- sound/creature/druidcat/mon_dr_catform_wound07.ogg
        1324565, -- sound/creature/druidcat/mon_dr_catform_wound08.ogg
        1324566, -- sound/creature/druidcat/mon_dr_catform_woundcrit01.ogg
        1324567, -- sound/creature/druidcat/mon_dr_catform_woundcrit02.ogg
        1324568, -- sound/creature/druidcat/mon_dr_catform_woundcrit03.ogg
        1324569, -- sound/creature/druidcat/mon_dr_catform_woundcrit04.ogg
        1324570, -- sound/creature/druidcat/mon_dr_catform_woundcrit05.ogg
        600278, -- sound/creature/goblintrike/veh_goblintrike_turn_02.ogg
        600281, -- sound/creature/goblintrike/veh_goblintrike_idle_loop_01.ogg
        600290, -- sound/creature/goblintrike/veh_goblintrike_turn_01.ogg
        600293 -- sound/creature/goblintrike/veh_goblintrike_drive_loop_01.ogg
    }
end
