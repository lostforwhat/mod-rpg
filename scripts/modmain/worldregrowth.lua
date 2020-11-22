local _G = GLOBAL

AddComponentPostInit("regrowthmanager", function(self)
    function self:LongUpdate()
        
    end
end)

AddComponentPostInit("desolationspawner", function(self)
    function self:LongUpdate()
        
    end
end)

_G.require("gamemodes")
for k, v in pairs(_G.GAME_MODES) do
    if v.resource_renewal then
        v.resource_renewal = false
    end
end

AddComponentPostInit("plantregrowth", function(self)
    function self:TrySpawnNearby()
        
    end
end)

AddPrefabPostInit("world", function(inst)
    if inst.components.forestresourcespawner ~= nil then
        inst:RemoveComponent("forestresourcespawner")
    end
    if inst.components.regrowthmanager ~= nil then
        inst:RemoveComponent("regrowthmanager")
    end
    if inst.components.desolationspawner ~= nil then
        inst:RemoveComponent("desolationspawner")
    end
end)