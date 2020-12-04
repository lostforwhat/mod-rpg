require "utils/utils"

local Purchase = Class(function(self, inst)
    self.inst = inst
	
	self.net_data = {
		coin_used = net_shortint(inst.GUID, "purchase.coin_used", "coindirty"),
		coin = net_shortint(inst.GUID, "purchase.coin", "coindirty"),
		--goods = net_string(inst.GUID, "purchase.goods", "goodsdirty")
	}

	self.coin = 0
    self.coin_used = 0
    --self.goods = {}
    self.refresh_time = 0
end,
nil,
{
    coin_used = function(self, val) self.net_data.coin_used:set(val) end,
    coin = function(self, val) self.net_data.coin:set(val) end,
    --goods = function(self, val) self.net_data.goods:set(Table2String(val)) end,
})

function Purchase:OnSave()
	local data = {}
	data.coin_used = self.coin_used or 0
	data.coin = self.coin or 0
	data.spend_temp = self.spend_temp or 0
	return data
end

function Purchase:OnLoad(data)
	for k, v in pairs(data) do
		self[k] = v or 0
	end
	self:ResetTemp() --仅仅在加载游戏时执行一次
end

function Purchase:ResetTemp()
	if self.spend_temp ~= nil and self.spend_temp > 0 then
		self:CoinDoDelta(self.spend_temp)
	end
end

function Purchase:CoinDoDelta(value)
	self.coin = self.coin + value
	if self.coin < 0 then self.coin = 0 end --防止数据异常
end


function Purchase:GetCoinFromGoods(goods)
	local coin = 0
	for k,v in pairs(goods) do
		local num = v.num or 1
		local value = v.value or 1
		coin = coin + num * value
	end
	return coin
end

function Purchase:Refresh(force)
	if TheWorld.ismastersim then
		TheWorld.net.components.worldshop:Refresh(force)
	end
end

function Purchase:Purchase(goods)
	if TheWorld.ismastersim then
		--记录消费
		local shop_goods = String2Table(goods)
		if #shop_goods > 0 then
			--先扣除钻石
			self.spend_temp = self:GetCoinFromGoods(shop_goods)
			if self.coin < spend then
				--钱不够
				if self.inst.components.talker ~= nil then
					self.inst.components.talker:Say("我得再攒攒钱...")
				end
				self.spend_temp = 0
				return
			end
			self:CoinDoDelta(-self.spend_temp)
			local params = {
				userid = self.inst.userid,
				goods = json.encode(shop_goods)
			}
			HttpPost("/public/purchase", function(result, isSuccessful, resultCode) 
				if isSuccessful and (resultCode == 200) then
					print("------------"..(self.inst.userid).." Purchase success--------------")
					--最后需要重新获取商店列表,购买后必须拿最新数据，不能取world的缓存
					TheWorld.net.components.worldshop:Refresh(true)
					--成功后扣除
				else
					print("------------"..(self.inst.userid).." Purchase failed! ERROR:"..result.."--------------")
					--失败后返还
					self:CoinDoDelta(self.spend_temp)
				end
				self.spend_temp = 0
			end, params)
		end
	end
end

return Purchase