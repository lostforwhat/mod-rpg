require "utils/utils"
--world net 组件
local ShardData = Class(function(self, inst) 
    self.inst = inst

    self._sharddata = net_string(inst.GUID, "sharddata", "worldsharddatadirty")
    if TheNet:GetIsServer() then
    	self._sharddata:set("{}")
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

return ShardData