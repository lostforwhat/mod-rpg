require "utils/utils"
--world net 组件
local ShardData = Class(function(self, inst) 
    self.inst = inst

    self._sharddata = net_string(inst.GUID, "sharddata.data", "worldsharddatadirty")
    self._id = net_byte(inst.GUID, "sharddata.id", "worldsharddatadirty")
    if TheNet:GetIsServer() then
    	self._sharddata:set("{}")
    	self._id:set(TheShard:GetShardId())
    end
end)

function ShardData:SetData(data)
	if TheNet:GetIsServer() then
		self._sharddata:set(Table2String(data))
	end
end

function ShardData:Get()
	return String2Table(self._sharddata:value())
end

function ShardData:GetId()
	return self._id:value()
end

return ShardData