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
		
	}
	self.titles = {}
	self:Init()
end,
nil,
onchangefn)

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
	
end

return Titles