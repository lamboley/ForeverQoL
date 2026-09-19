---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local ipairs = ipairs
local wipe = wipe

local Bars = ForeverQoL.CreateModule("Bars", "PLAYER_ENTERING_WORLD")

local MOUSEOVER_PADDING = 10
local MOUSEOVER_INTERVAL = 0.05

local VISIBILITY_STATES = {
	{ value = "always", label = "Always Show" },
	{ value = "mouseover", label = "Show On Mouseover" },
	{ value = "never", label = "Always Hide" }
}

local VISIBILITY_FRAMES = {
	{ key = "BagBarVisibility", name = "BagsBar" },
	{ key = "MicroMenuVisibility", name = "MicroMenuContainer" },
	{ key = "StatusBarVisibility", name = "MainStatusTrackingBarContainer" }
}

local hookedFrames = {}
local mouseoverFrames = {}
local sinceLastCheck = 0

---@param frame Frame
local function UpdateAlpha(frame)
	local alpha = frame:IsMouseOver(MOUSEOVER_PADDING, -MOUSEOVER_PADDING, -MOUSEOVER_PADDING, MOUSEOVER_PADDING) and 1 or 0
	-- Only touch the frame when the alpha actually changes, this runs several times a second
	if frame:GetAlpha() ~= alpha then
		frame:SetAlpha(alpha)
	end
end

local function OnUpdate(_, elapsed)
	-- The target alpha is either 0 or 1, so hit testing the cursor on every rendered
	-- frame buys nothing the eye can see
	sinceLastCheck = sinceLastCheck + elapsed
	if sinceLastCheck < MOUSEOVER_INTERVAL then
		return
	end
	sinceLastCheck = 0

	for i = 1, #mouseoverFrames do
		UpdateAlpha(mouseoverFrames[i])
	end
end

---Blizzard shows these frames again on its own, so hiding one has to survive that.
---@param frame Frame
---@param configKey string
local function KeepHidden(frame, configKey)
	if not hookedFrames[frame] then
		-- The hook is permanent and cannot be removed, so it re-reads both the config and
		-- the module state, otherwise it would undo the frame PostDisable just restored
		frame:HookScript("OnShow", function(shown)
			if Bars.enabled and ForeverQoLData.Configs[configKey] == "never" then
				shown:Hide()
			end
		end)
		hookedFrames[frame] = true
	end

	frame:Hide()
end

---@param bar table an entry of VISIBILITY_FRAMES
local function ApplyVisibility(bar)
	local frame = _G[bar.name]
	if not frame then
		ForeverQoL.Info("Bars:", bar.name, "does not exist on this client")
		return
	end

	local state = ForeverQoLData.Configs[bar.key]

	if state == "mouseover" then
		-- Coming from "never" the frame is still hidden, and OnUpdate only sets the alpha
		frame:Show()
		mouseoverFrames[#mouseoverFrames + 1] = frame
	elseif state == "never" then
		KeepHidden(frame, bar.key)
	else
		-- Coming from "mouseover" the alpha is wherever the cursor left it
		frame:SetAlpha(1)
		frame:Show()
	end
end

function Bars:UpdateVisibility()
	wipe(mouseoverFrames)

	for _, bar in ipairs(VISIBILITY_FRAMES) do
		ApplyVisibility(bar)
	end

	self:SetScript("OnUpdate", #mouseoverFrames > 0 and OnUpdate or nil)
end

---Options for a visibility dropdown, bound to the config key it writes.
---@param key string
---@return table[]
function Bars.GetVisibilityOptions(key)
	local options = {}
	for i, state in ipairs(VISIBILITY_STATES) do
		options[i] = {
			label = state.label,
			value = state.value,
			onclick = function()
				ForeverQoLData.Configs[key] = state.value
				Bars:UpdateVisibility()
			end
		}
	end

	return options
end

function Bars:OnEvent(event, ...)
	self:UpdateVisibility()
end

function Bars:PostDisable()
	self:SetScript("OnUpdate", nil)
	wipe(mouseoverFrames)

	for _, bar in ipairs(VISIBILITY_FRAMES) do
		local frame = _G[bar.name]
		if frame then
			frame:SetAlpha(1)
			frame:Show()
		end
	end
end

ForeverQoL.Interface.Bars = Bars
