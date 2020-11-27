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
	self.height = 0
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
	if titles_data then
		for k, v in pairs(titles_data) do
			if v.id ~= nil then
				self.net_data[v.id] = net_bytearray(inst.GUID, "titles."..v.id, "titles"..v.id.."dirty")
				self[v.id] = {}
				self.titles[v.id] = v
			end
		end
	end
end

function Titles:CheckAll()
	if self.titles ~= nil then
		for k, v in pairs(self.titles) do
			local conditions = v.conditions
			if conditions ~= nil then
				local cons = {}
				for _, m in pairs(conditions) do
					if m and m.fn then
						if m.fn(self.inst) then
							cons[_] = 1
						else
							cons[_] = 0
						end
					end
				end
				self[id] = cons
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
			titledata.effect(inst, true)
		end
		if self.equip ~= id then
			self.equip = id
		end
		self.net_data.equip:set(id)
	end
end

function Titles:UnEquip(id)
	local inst = self.inst
	if inst._titles ~= nil then
		inst._titles:Remove()
		inst._titles = nil
		local titledata = self.titles[id]
		if titledata ~= nil and titledata.effect ~= nil then
			titledata.effect(inst, false)
		end
		self.equip = ""
		self.net_data.equip:set("")
	end
end

return Titles