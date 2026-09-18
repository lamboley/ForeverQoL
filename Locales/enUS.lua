---@class ForeverQoL
local ForeverQoL = select(2, ...)

local L = setmetatable({}, { __index = function(t, k)
    local v = tostring(k)
    rawset(t, k, v)
    return v
end })

ForeverQoL.L = L
