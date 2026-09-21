local ForeverQoL = select(2, ...)

---Role of the current specialization, nil on a character that has none yet
function ForeverQoL.GetRole()
    local currentSpec = GetSpecialization()
    return currentSpec and GetSpecializationRole(currentSpec)
end
