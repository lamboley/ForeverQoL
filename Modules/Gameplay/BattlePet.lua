---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- WoW API
-- Namespaces absent from a client are read here rather than indexed, so this file still loads
local GetSummonedPetGUID = C_PetJournal and C_PetJournal.GetSummonedPetGUID
local FindPetIDByName = C_PetJournal and C_PetJournal.FindPetIDByName
local SummonPetByGUID = C_PetJournal and C_PetJournal.SummonPetByGUID
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsStealthed = IsStealthed
local GetTime = GetTime

local BattlePet = ForeverQoL.CreateModule("BattlePet", {
    "PLAYER_ENTERING_WORLD",
    "COMPANION_UPDATE",
    "ZONE_CHANGED",
    "ZONE_CHANGED_INDOORS",
    "ZONE_CHANGED_NEW_AREA"
})

local lastSummonAttempt = 0

---@return boolean
function BattlePet:IsSupported()
    return GetSummonedPetGUID ~= nil and FindPetIDByName ~= nil and SummonPetByGUID ~= nil
end

function BattlePet:OnEvent(_, ...)
    if not ForeverQoLData.Configs["KeepABattlePetSummoned"] or ForeverQoLData.Configs["BattlePetNameToSummon"] == "" then
        return
    end

    local currentTime = GetTime()
    if currentTime - lastSummonAttempt < 10 then
        return
    end

    -- Instances cover dungeons, raids, scenarios, battlegrounds and arenas, the pet is unwanted in all of them.
    if InCombatLockdown() or IsStealthed() or IsInInstance() then
        return
    end

    local _, petGUID = FindPetIDByName(ForeverQoLData.Configs["BattlePetNameToSummon"])
    if petGUID and GetSummonedPetGUID() ~= petGUID then
        SummonPetByGUID(petGUID)
        lastSummonAttempt = currentTime
    end
end

ForeverQoL.Gameplay.BattlePet = BattlePet
