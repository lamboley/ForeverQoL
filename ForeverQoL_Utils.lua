local ForeverQoL = select(2, ...)

local CONST_ARMOR_CLASS = 4
local CONST_LEATHER, CONST_MAIL, CONST_PLATE, CONST_SHIELD = 2, 3, 4, 6

---Role of the current specialization, nil on a character that has none yet
function ForeverQoL.GetRole()
	local currentSpec = GetSpecialization()
	if not currentSpec then
		return nil
	end

	return GetSpecializationRole(currentSpec)
end

---Accepts a raw item ID or an item link, as produced by shift-clicking an item into a focused edit box.
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
function ForeverQoL.CreateItemList(configKey, label)
	local list = {}

	local function GetEntries()
		local entries = ForeverQoLData.Configs[configKey]
		if type(entries) ~= "table" then
			entries = {}
			ForeverQoLData.Configs[configKey] = entries
		end

		return entries
	end

	function list:Contains(itemID)
		return GetEntries()[itemID] ~= nil
	end

	function list:Add(input)
		local itemID = ParseItemID(input)
		if not itemID then
			ForeverQoL.Print("Drag an item onto the box, or type an item ID into it.")
			return
		end

		local item = Item:CreateFromItemID(itemID)
		if not item or item:IsItemEmpty() then
			ForeverQoL.Print(string.format("No item found for ID %d.", itemID))
			return
		end

		-- The name is only readable once the client has the item cached, which is not the case on a fresh login
		item:ContinueOnItemLoad(function()
			local entries = GetEntries()
			local resolvedID = item:GetItemID()
			if entries[resolvedID] then
				return
			end

			entries[resolvedID] = item:GetItemName()
				or (C_Item.GetItemInfo(resolvedID))
				or string.format("Item #%d", resolvedID)
			ForeverQoL.Print(string.format("Added %s to the %s (%s).", item:GetItemLink() or entries[resolvedID], label, resolvedID))

			-- The name only arrives here, long after Add returned, so a window showing the
			-- list has no other way of knowing an entry appeared
			if self.OnChanged then
				self.OnChanged()
			end
		end)
	end

	function list:Remove(itemID)
		local entries = GetEntries()
		local name = entries[itemID]
		if not name then
			return
		end

		entries[itemID] = nil
		ForeverQoL.Print(string.format("Removed %s (%d) from the %s.", name, itemID, label))

		if self.OnChanged then
			self.OnChanged()
		end
	end

	---The entries as an array sorted by name, ready for a list widget.
	function list:GetSorted()
		local entries = {}
		for itemID, name in pairs(GetEntries()) do
			-- The stored name is whatever could be resolved the moment the item was added,
			-- which on a fresh login is often nothing. Ask again rather than trust it, so a
			-- placeholder never outlives the one session that produced it. Quality is never
			-- stored at all, it only matters to whoever is drawing the entry.
			local resolved, _, quality = C_Item.GetItemInfo(itemID)

			entries[#entries + 1] = { id = itemID, name = resolved or name, quality = quality }
		end

		table.sort(entries, function(a, b) return a.name < b.name end)

		return entries
	end

	---Turns a frame into a drop target for items dragged out of the bags.
	function list:EnableDrop(frame)
		if not frame then
			return
		end

		local function AddFromCursor()
			local cursorType, _, itemLink = GetCursorInfo()
			-- Nil whenever the cursor is empty, so an ordinary click falls straight through
			if cursorType ~= "item" then
				return
			end

			ClearCursor()
			self:Add(itemLink)
		end

		-- OnReceiveDrag catches an item released over the frame, OnMouseDown one already held
		frame:EnableMouse(true)
		frame:SetScript("OnReceiveDrag", AddFromCursor)
		frame:HookScript("OnMouseDown", AddFromCursor)
	end

	return list
end
