require "utils/utils"

local MAX_RESET_TIME = 1800

--世界商店 world net
local WorldShop = Class(function(self, inst) 
    self.inst = inst

    self._shopdata = net_string(inst.GUID, "worldshop._shopdata", "shopdatadirty")

    self.refresh_time = 0
    self.reset_time = 0 --重置商店时间

    if TheNet:GetIsServer() then
    	self._shopdata:set("{}")
    	self.inst:DoTaskInTime(0, function() 
			self:Refresh()
    	end)
    	if TheWorld.ismastershard then
	    	self.inst:StartUpdatingComponent(self)
	    end
    end
end)

function WorldShop:OnSave()
	return {
		reset_time = self.reset_time
	}
end

function WorldShop:OnLoad(data)
	if data ~= nil and data.reset_time > 0 then
		self.reset_time = data.reset_time
	end
end

function WorldShop:OnUpdate(dt)
	self.reset_time = self.reset_time + dt
	if self.reset_time > MAX_RESET_TIME and not self.resetting then
		self:ResetShop()
	end
end

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

    if #self._shopdata:value() > 2 and time - world_refresh_time < 15 and not force then
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

function WorldShop:ResetShop()
	self.resetting = true
	local inst = TheWorld ~= nil and TheWorld.net or self.inst
    local serversession = inst.components.shardstate:GetMasterSessionId()
    local params = {
		serversession = serversession
	}
	HttpPost("/public/refreshShop", function(result, isSuccessful, resultCode) 
		if isSuccessful and (resultCode == 200) then
			--local status, data = pcall( function() return json.decode(result) end )
			self.reset_time = 0
			self.resetting = nil
			self:Refresh(true)
		else
			self.reset_time = 0
			self.resetting = nil
		end
	end, params)
end

return WorldShop