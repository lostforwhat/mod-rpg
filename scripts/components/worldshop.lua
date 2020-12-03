require "utils/utils"

--世界商店 world net
local WorldShop = Class(function(self, inst) 
    self.inst = inst

    self._shopdata = net_string(inst.GUID, "worldshop._shopdata", "shopdatadirty")
end)


function WorldShop:Refresh()
	
end

return WorldShop