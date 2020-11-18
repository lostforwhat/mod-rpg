require "utils/utils"

local Purchase = Class(function(self, inst)
    self.inst = inst
	
	self.net_data = {
		coin_used = net_shortint(inst.GUID, "purchase.coin_used", "coindirty"),
		coin = net_shortint(inst.GUID, "purchase.coin", "coindirty"),
		goods = net_string(inst.GUID, "purchase.goods", "goodsdirty")
	}

	self.coin = 0
    self.coin_used = 0
    self.goods = {}
    self.refresh_time = 0
end,
nil,
{
    coin_used = function(self, val) self.net_data.coin_used:set(val) end,
    coin = function(self, val) self.net_data.coin:set(val) end,
    goods = function(self, val) self.net_data.goods:set(Table2String(val)) end,
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

function Purchase:Refresh(force)
	--test
	TheWorld.goods = {
		{prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="spear", use_left=0.5}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
        {prefab="achiv_clear", num=5, value=20}
    }

    local time = GetTime()
    self.goods = TheWorld.goods or {}

    if time - self.refresh_time < 10 and TheWorld.goods and not force then
    	return
    end

    local serversession = TheWorld.net.components.shardstate:GetMasterSessionId()
    HttpGet("/public/getgoods?server="..serversession, function(result, isSuccessful, resultCode)
    	if isSuccessful and (resultCode == 200) then
			print("------------ GetGoods success--------------")
			local status, data = pcall( function() return json.decode(result) end )
			if not status or not data then
		 		print("解析GetGoods失败! ", tostring(status), tostring(data))
			else
				self.goods = data
				TheWorld.goods = data
				self.refresh_time = GetTime()
			end
		else
			print("------------ GetGoods failed! ERROR:"..result.."--------------")
		end
	end)

end

function Purchase:GetGoods()
	if TheWorld.ismastersim then
		return self.goods or TheWorld.goods or {}
	else
		return String2Table(self.net_data.goods:value()) or {}
	end
end

function Purchase:Purchase(goods)
	--记录消费
	local shop_goods = String2Table(goods)
	if #shop_goods > 0 then
		local params = {
			userid = self.inst.userid,
			goods = json.encode(shop_goods)
		}
		HttpPost("/public/purchase", function(result, isSuccessful, resultCode) 
			if isSuccessful and (resultCode == 200) then
				print("------------"..(self.inst.userid).." Purchase success--------------")
				--最后需要重新获取商店列表,购买后必须拿最新数据，不能取world的缓存
				self:Refresh(true)
			else
				print("------------"..(self.inst.userid).." Purchase failed! ERROR:"..result.."--------------")
			end
		end, params)
	end
end

return Purchase