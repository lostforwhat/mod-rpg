local onchangefn = {}
if titles_data then
	for k, v in pairs(titles_data) do
		if v.id ~= nil then
			onchangefn[v.id] = function(self, val) 
				self.net_data[v.id]:set(val)
			end
		end
	end
end

local Titles = Class(function(self, inst) 
	self.inst = inst

	self.net_data = {
		equip = net_string(inst.GUID, "titles.equip", "titlesequipdirty")
	}
	self.titles = {}
	self.titles_id = {}
	self.titles_id_has = {}
	self.height = 0

	self.special = false
	self.equip = ""
	
	self:Init()
end,
nil,
onchangefn)

function Titles:OnSave()
	local data = {}
	if titles_data then
		for k, v in pairs(titles_data) do
			if v.id ~= nil then
				data[v.id] = self[v.id] or {}
			end
		end
	end
	data.equip = self.equip or ""
	return data
end

function Titles:OnLoad(data)
	if data ~= nil then
		for k, v in pairs(data) do
			self[k] = v
		end
		if self.equip ~= nil and self.equip ~= "" then
			self:Equip(self.equip)
		end
	end
end

function Titles:Init()
	local inst = self.inst
	if titles_data then
		for k, v in pairs(titles_data) do
			if v.id ~= nil then
				self.net_data[v.id] = net_bytearray(inst.GUID, "titles."..v.id, "titles"..v.id.."dirty")
				self[v.id] = {}
				self.titles[v.id] = v
				table.insert(self.titles_id, v.id)
			end
		end
	end
	inst:DoTaskInTime(0, function()
		self:CheckAll()
	end)
end

function Titles:CheckAll()
	if self.titles ~= nil then
		self.titles_id_has = {}
		for k, v in pairs(self.titles) do
			local conditions = v.conditions
			if v.id ~= nil and conditions ~= nil then
				local cons = {}
				local get = true
				for _, m in pairs(conditions) do
					if m and m.fn then
						if m.fn(self.inst) then
							cons[_] = 1
						else
							cons[_] = 0
							get = false
						end
					end
				end
				self[v.id] = cons
				if get then
					table.insert(self.titles_id_has, v.id)
				end
			end
		end
	end
end

function Titles:CheckTitles(id)
	local title = self.titles[id]
	if title ~= nil then
		local conditions = title.conditions
		if conditions ~= nil then
			local get = true
			local cons = {}
			for _, v in pairs(conditions) do
				if v and v.fn then
					if v.fn(self.inst) then
						cons[_] = 1
					else
						cons[_] = 0
						get = false
					end
				end
			end
			self[id] = cons
			if not table.contains(self.titles_id_has, id) then
				table.insert(self.titles_id_has, id)
			end
			return get
		end
	end
end

function Titles:Equip(id)
	local inst = self.inst
	if PrefabExists("titles_"..id) then
		local title = SpawnPrefab("titles_"..id)
		title:Equipped(inst, self.height)

		local oldtitledata = self.titles[self.equip or ""]
		if oldtitledata ~= nil and oldtitledata.effect ~= nil then
			oldtitledata.effect(inst, false)
		end

		local titledata = self.titles[id]
		if titledata ~= nil and titledata.effect ~= nil then
			titledata.effect(inst, true, title)
		end
		if self.equip ~= id then
			self.equip = id
		end
		self.net_data.equip:set(id)
	end
end

function Titles:UnEquip(id)
	if self.equip == nil then return end
	local inst = self.inst
	if inst._titles ~= nil then
		inst._titles:Remove()
		inst._titles = nil
		local titledata = self.titles[self.equip]
		if titledata ~= nil and titledata.effect ~= nil then
			titledata.effect(inst, false)
		end
		self.equip = ""
		self.net_data.equip:set("")
	end
end

function Titles:Has(id)
	local conditions = self[id]
	if conditions == nil then return false end
	local get = true
	for k,v in pairs(conditions) do
		get = v > 0 and get or false
	end
	return get
end

function Titles:Change()
	if #self.titles_id_has == 0 then
		self:CheckAll()
		if #self.titles_id_has == 0 then
		 	return 
		end
	end
	local ids = table.invert(self.titles_id_has)
	local index = ids[self.equip] or 0
	if index == #self.titles_id_has then
		self:UnEquip()
	else
		self:Equip(self.titles_id_has[index + 1])
	end
end

return Titles