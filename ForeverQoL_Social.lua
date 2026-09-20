local ForeverQoL = select(2, ...)

local Social = CreateFrame("Frame", "ForeverQoL_Social")

function Social:Init()
    self.Chat:Init()
end

ForeverQoL.Social = Social
