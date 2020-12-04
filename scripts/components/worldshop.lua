require "utils/utils"

--世界商店 world net
local WorldShop = Class(function(self, inst) 
    self.inst = inst

    self._shopdata = net_string(inst.GUID, "worldshop._shopdata", "shopdatadirty")

    self.refresh_time = 0

    if TheNet:GetIsServer() then
    	self._shopdata:set("{}")
    	self:DoTaskInTime(0, function() 
			self:Refresh()
    	end)
    end
end)


function WorldShop:Refresh(force)
	--test
	--[[TheWorld.goods = {
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
    }]]

    local time = GetTime()
    local world_refresh_time = self.refresh_time or 0

    if time - world_refresh_time < 15 and not force then
    	return
    end

    local inst = TheWorld ~= nil and TheWorld.net or self.inst
    local serversession = inst.components.shardstate:GetMasterSessionId()
    HttpGet("/public/getGoods?serversession="..serversession.."&userid="--[[..self.inst.userid]], function(result, isSuccessful, resultCode)
    	if isSuccessful and (resultCode == 200) then
			print("-- GetGoods success--")
			local status, data = pcall( function() return json.decode(result) end )
			if not status or not data then
		 		print("解析GetGoods失败! ", tostring(status), tostring(data))
			else
				self._shopdata:set(Table2String(data))
				self.refresh_time = GetTime()
				--成功
			end
		else
			print("-- GetGoods failed! ERROR:"..result.."--")
		end
	end)

end

function WorldShop:GetGoods()
	return String2Table(self._shopdata:value()) or {}
end

return WorldShop