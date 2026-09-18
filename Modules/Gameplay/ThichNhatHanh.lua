---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local ipairs = ipairs
local wipe = wipe

-- WoW API
local NewTicker = C_Timer.NewTicker
local NewTimer = C_Timer.NewTimer

local ThichNhatHanh = ForeverQoL.CreateModule("ThichNhatHanh", "PLAYER_ENTERING_WORLD")

local CYCLE_INTERVAL = 2000
local STEP_DELAY = 60

local steps = {
    {"|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00Breathing in, I know I am breathing in.|r",
     "|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00Breathing out, I know I am breathing out.|r"},
    {"|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00As my in-breath grows deep,|r",
     "|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00My out-breath grows slow.|r"},
    {"|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00Breathing in, I am aware of my body.|r",
     "|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00Breathing out, I calm my body.|r"},
    {"|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00Dwelling in the present moment,|r",
     "|cffFF9FFFThich Nhat Hanh says:|r |cffFFFF00I know this is a wonderful moment.|r"},
}

local quoteTicker = nil
local stepTimers = {}

local function CancelAllTimers()
    if quoteTicker then
        quoteTicker:Cancel()
        quoteTicker = nil
    end
    for _, timer in ipairs(stepTimers) do
        timer:Cancel()
    end
    wipe(stepTimers)
end

local function DisplayStep(step)
    for _, line in ipairs(step) do
        ---@diagnostic disable-next-line: undefined-global
        DEFAULT_CHAT_FRAME:AddMessage(line)
    end
end

function ThichNhatHanh:OnEvent(_, ...)
    if ForeverQoLData.Configs["PrintQuoteFromThichNhatHanh"] then
        CancelAllTimers()

        quoteTicker = NewTicker(CYCLE_INTERVAL, function()
            for _, timer in ipairs(stepTimers) do
                timer:Cancel()
            end
            wipe(stepTimers)

            DisplayStep(steps[1])

            for i = 2, #steps do
                local timer = NewTimer(STEP_DELAY * (i - 1), function()
                    DisplayStep(steps[i])
                end)
                stepTimers[#stepTimers + 1] = timer
            end
        end)
    end
end

function ThichNhatHanh:PreDisable()
    CancelAllTimers()
end

ForeverQoL.Gameplay.ThichNhatHanh = ThichNhatHanh
