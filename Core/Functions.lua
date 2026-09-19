---@class ForeverQoL
local ForeverQoL = select(2, ...)

-- Lua API
local ipairs = ipairs
local pairs = pairs
local print = print
local select = select
local tostring = tostring
local type = type
local tonumber = tonumber
local concat = table.concat
local format = string.format
local sort = table.sort

-- WoW API
local GetCursorInfo = GetCursorInfo
local ClearCursor = ClearCursor

-- WoW API
local GetSpecializationRole = GetSpecializationRole
local GetSpecialization = GetSpecialization
local CreateFrame = CreateFrame

function ForeverQoL.Print(...)
	print("|cff00D9FFForever QoL:|r", ...)
end

local reported = {}

---Says what the addon cannot do, once per distinct message. Most of these hang off an event
---that repeats -- a merchant opening, a zone change -- and a notice nobody can silence has to
---say its piece and then shut up. Deliberately not behind a setting: a capability gap that
---only speaks when asked is a capability gap nobody ever hears about.
function ForeverQoL.Info(...)
	local parts = {}
	for i = 1, select("#", ...) do
		parts[i] = tostring((select(i, ...)))
	end

	local message = concat(parts, " ")
	if reported[message] then
		return
	end
	reported[message] = true

	print("|cff00D9FFForever QoL:|r", message)
end

---Role of the current specialization, nil on a character that has none yet
---and on a client without specializations at all.
---@return string|nil
function ForeverQoL.GetRole()
	if not GetSpecialization or not GetSpecializationRole then
		return nil
	end

	local currentSpec = GetSpecialization()
	if not currentSpec then
		return nil
	end

	return GetSpecializationRole(currentSpec)
end

---Accepts a raw item ID or an item link, as produced by shift-clicking an item into a focused edit box.
---@param input string|number
---@return number|nil
local function ParseItemID(input)
	if type(input) == "number" then
		return input
	end

	if type(input) ~= "string" then
		return nil
	end

	return tonumber(input) or tonumber(input:match("item:(%d+)"))
end

---A named list of items kept in the saved variables, with the widgets to edit it.
---Shared so the sell list and the deposit list cannot drift apart.
---@param configKey string
---@param label string what the list is called in messages
---@return table
function ForeverQoL.CreateItemList(configKey, label)
	local list = {}

	---@return table<number, string>
	local function GetEntries()
		local entries = ForeverQoLData.Configs[configKey]
		if type(entries) ~= "table" then
			entries = {}
			ForeverQoLData.Configs[configKey] = entries
		end

		return entries
	end

	---@param itemID number
	---@return boolean
	function list.Contains(itemID)
		return GetEntries()[itemID] ~= nil
	end

	---@param input string|number
	function list.Add(input)
		local itemID = ParseItemID(input)
		if not itemID then
			ForeverQoL.Print("Drag an item onto the box, or type an item ID into it.")
			return
		end

		if not Item then
			ForeverQoL.Print(format("This client cannot look items up by id, nothing can be added to the %s.", label))
			return
		end

		local item = Item:CreateFromItemID(itemID)
		if not item or item:IsItemEmpty() then
			ForeverQoL.Print(format("No item found for ID %d.", itemID))
			return
		end

		-- The name is only readable once the client has the item cached, which is not the case on a fresh login
		item:ContinueOnItemLoad(function()
			local entries = GetEntries()
			local resolvedID = item:GetItemID()
			if entries[resolvedID] then
				return
			end

			entries[resolvedID] = item:GetItemName() or format("Item #%d", resolvedID)
			ForeverQoL.Print(format("Added %s to the %s.", item:GetItemLink() or entries[resolvedID], label))
		end)
	end

	---@param itemID number
	function list.Remove(itemID)
		local entries = GetEntries()
		local name = entries[itemID]
		if not name then
			return
		end

		entries[itemID] = nil
		ForeverQoL.Print(format("Removed %s (%d) from the %s.", name, itemID, label))
	end

	---Options for the removal dropdown, rebuilt every time it is opened.
	---@return table[]
	function list.GetOptions()
		local options = {}
		for itemID, name in pairs(GetEntries()) do
			options[#options + 1] = {
				label = format("%s (%d)", name, itemID),
				value = itemID,
				onclick = function()
					list.Remove(itemID)
				end,
			}
		end

		sort(options, function(a, b) return a.label < b.label end)

		-- The dropdown never opens on an empty table, so keep a placeholder row in it
		if #options == 0 then
			options[1] = {
				label = "The list is empty",
				value = 0,
				onclick = function() return end,
			}
		end

		return options
	end

	---Turns a DetailsFramework textentry into a drop target for items dragged out of the bags.
	---@param textEntry table|nil
	function list.EnableDrop(textEntry)
		local editbox = textEntry and (textEntry.editbox or textEntry.widget)
		if not editbox then
			ForeverQoL.Info("CreateItemList:", configKey, "has no text entry to drop onto")
			return
		end

		local function AddFromCursor()
			local cursorType, _, itemLink = GetCursorInfo()
			if cursorType ~= "item" then
				return
			end

			ClearCursor()
			list.Add(itemLink)
		end

		-- OnReceiveDrag catches an item dropped on the box, OnMouseDown an item already held by the cursor
		editbox:SetScript("OnReceiveDrag", AddFromCursor)
		editbox:SetScript("OnMouseDown", AddFromCursor)
	end

	return list
end

---A module may define IsSupported to stay off on a client that lacks the API it needs.
---@param name string
---@param events string|string[]
function ForeverQoL.CreateModule(name, events)
    local module = CreateFrame('Frame', "ForeverQoL_" .. name)
    module.enabled = false
    module.events = type(events) == "table" and events or {events}

    function module:Enable()
        if self.enabled then return end

        if self.IsSupported and not self:IsSupported() then
            ForeverQoL.Info(name, "is not supported on this client")
            return
        end

        if self.PreEnable then
            self:PreEnable()
        end

        for _, event in ipairs(self.events) do
            -- An event the client does not know raises, and one missing feature
            -- must not take down the rest of the module
            if not pcall(self.RegisterEvent, self, event) then
                ForeverQoL.Info(name, "cannot register", event, "on this client")
            end
        end
        self:SetScript('OnEvent', self.OnEvent)
        self.enabled = true

        if self.PostEnable then
            self:PostEnable()
        end
    end

    function module:Disable()
        if not self.enabled then return end

        if self.PreDisable then
            self:PreDisable()
        end

        for _, event in ipairs(self.events) do
            pcall(self.UnregisterEvent, self, event)
        end
        self.enabled = false

        if self.PostDisable then
            self:PostDisable()
        end
    end

    return module
end

