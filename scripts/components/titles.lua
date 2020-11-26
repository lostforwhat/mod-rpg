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

	
end,
nil,
onchangefn)

return Titles