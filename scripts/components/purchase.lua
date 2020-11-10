local Purchase = Class(function(self, inst)
    self.inst = inst
	
	self.net_data = {
		coin_used = net_shortint(inst.GUID, "purchase.coin_used", "coin_useddirty"),
		coin = net_shortint(inst.GUID, "purchase.coin", "coindirty")
	}

	self.coin = 0
    self.coin_used = 0
end,
nil,
{
    coin_used = function(self, val) self.net_data.coin_used:set(val) end,
    coin = function(self, val) self.net_data.coin:set(val) end,
})

function Purchase:OnSave()
	local data = {}
	data.coin_used = self.coin_used or 0
	data.coin = self.coin or 0
	return data
end

function Purchase:OnLoad(data)
	for k, v in pairs(data) do
		self[k] = v or 0
	end
end

function Purchase:CoinDoDelta(value)
	self.coin = self.coin + value
	if self.coin < 0 then self.coin = 0 end --防止数据异常
end

function Purchase:Purchase(goods)
	
	--记录消费
	
end

return Purchase