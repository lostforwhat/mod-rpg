local Purchase = Class(function(self, inst)
    self.inst = inst
	
	self.net_data = {
		coin_used = net_shortint(inst.GUID, "coin_used", "coin_useddirty")
	}

	self.coin = 0
    self.coin_used = 0
end,
nil,
{
    coin_used = function(self, val) self.net_data.coin_used:set(val) end
})

function Purchase:OnSave()
	local data = {}
	data.coin_used = self.coin_used
	return data
end

function Purchase:OnLoad(data)
	for k, v in pairs(data) do
		self[k] = v or 0
	end
end

function Purchase:Purchase(goods)
	
end

return Purchase