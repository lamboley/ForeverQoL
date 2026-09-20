local ForeverQoL = select(2, ...)

local CONST_ARMOR_CLASS = 4
local CONST_LEATHER = 2
local CONST_MAIL = 3
local CONST_PLATE = 4
local CONST_SHIELD = 6

---Role of the current specialization, nil on a character that has none yet
function ForeverQoL.GetRole()
	local currentSpec = GetSpecialization()
	if not currentSpec then
		return nil
	end

	return GetSpecializationRole(currentSpec)
end
