---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local ipairs = ipairs

-- WoW API
local hooksecurefunc = hooksecurefunc

local Recipes = ForeverQoL.CreateModule("Recipes", "ADDON_LOADED")

-- The row is 20 tall and its label sits 4px right of SkillUps, the icon slots in between
local ICON_SIZE = 16
local ICON_GAP = 4

local hookRegistered = false
local craftingHookRegistered = false

---@param row Button
---@return Texture
local function GetIcon(row)
	if row.ForeverQoLIcon then
		return row.ForeverQoLIcon
	end

	local icon = row:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("LEFT", row.SkillUps, "RIGHT", ICON_GAP, 0)
	row.ForeverQoLIcon = icon

	return icon
end

---Rows come from a pool and get reused, so the label is re-anchored on every pass.
---@param row Button
---@param shifted boolean
local function AnchorLabel(row, shifted)
	row.Label:ClearAllPoints()
	if shifted then
		row.Label:SetPoint("LEFT", row.ForeverQoLIcon, "RIGHT", ICON_GAP, 0)
	else
		row.Label:SetPoint("LEFT", row.SkillUps, "RIGHT", ICON_GAP, 0)
	end
end

---Blizzard fills the row then drops recipeInfo.icon on the floor, it is only read in OnEnter.
---@param row Button
---@param node table
local function AddRecipeIcon(row, node)
	local elementData = node and node:GetData()
	local recipeInfo = elementData and elementData.recipeInfo
	local iconID = recipeInfo and recipeInfo.icon

	if not ForeverQoLData.Configs["ShowRecipeIcons"] or not iconID then
		if row.ForeverQoLIcon then
			row.ForeverQoLIcon:Hide()
			AnchorLabel(row, false)
		end

		return
	end

	local icon = GetIcon(row)
	icon:SetTexture(iconID)
	icon:Show()
	AnchorLabel(row, true)
end

---The mixin lives in Blizzard_ProfessionsTemplates, and its functions are copied onto each row
---as it is created, so the table has to be hooked before the first row exists. Another addon can
---load the professions UI before this module enables, so no single event is enough: try on enable
---and on every ADDON_LOADED until it takes.
---@return boolean installed
local function TryHook()
	if hookRegistered then
		return true
	end

	if not ProfessionsRecipeListRecipeMixin then
		return false
	end

	hooksecurefunc(ProfessionsRecipeListRecipeMixin, "Init", AddRecipeIcon)
	hookRegistered = true

	return true
end

---Blizzard stores collapsed categories when the frame hides and replays them on Init, but some
---categories come back open anyway. Forcing them after Init wins because it runs last.
---Category ids are per profession, so a name prefix is what carries across all of them.
---@param name string|nil
---@return boolean
local function ShouldCollapse(name)
	local prefixes = ForeverQoLData.Configs["CollapsedCategoryNames"]
	if not name or not prefixes then
		return false
	end

	for _, prefix in ipairs(prefixes) do
		-- Plain search anchored at 1, so a prefix with a dash or bracket needs no escaping
		if name:find(prefix, 1, true) == 1 then
			return true
		end
	end

	return false
end

local function CollapseCategories()
	local page = ProfessionsFrame and ProfessionsFrame.CraftingPage
	local scrollBox = page and page.RecipeList and page.RecipeList.ScrollBox
	local provider = scrollBox and scrollBox:GetDataProvider()
	if not provider then
		return
	end

	for _, node in provider:EnumerateEntireRange() do
		local data = node:GetData()
		local categoryInfo = data and data.categoryInfo
		-- Skipping nodes already collapsed avoids a pointless Invalidate on every pass
		if categoryInfo and not node:IsCollapsed() and ShouldCollapse(categoryInfo.name) then
			node:SetCollapsed(true)
		end
	end
end

---@return boolean installed
local function TryHookCraftingPage()
	if craftingHookRegistered then
		return true
	end

	local page = ProfessionsFrame and ProfessionsFrame.CraftingPage
	if not page or not page.Init then
		return false
	end

	-- Hooking the frame itself, not the mixin, so no copy timing to worry about
	hooksecurefunc(page, "Init", CollapseCategories)
	craftingHookRegistered = true

	return true
end

function Recipes:PreEnable()
	-- Another addon can load the professions UI before this module enables, so no single
	-- event is enough: try on enable and on every ADDON_LOADED until both hooks take
	TryHook()
	TryHookCraftingPage()
end

function Recipes:OnEvent(event, ...)
	TryHook()
	TryHookCraftingPage()
end


ForeverQoL.Interface.Recipes = Recipes
