GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--全局变量
local TheWorld = _G.TheWorld

--print("地图大小",TheWorld.Map:GetTileAtPoint(0,0,0))

--清理非陆地上的
AddPrefabPostInit("tumbleweedspawner",function(inst) 
	inst:DoTaskInTime(1, function(inst) --初始化时坐标(0,0,0)，延迟1 赋值成功后 再判断
		local x,y,z =inst.Transform:GetWorldPosition()
		if not GLOBAL.TheWorld.Map:IsAboveGroundAtPoint(x, y, z) then --非陆地上的
			inst:Remove()
			return
		end
	end)
end)
--[[ 测试统计数量
AddPrefabPostInit("world",function(inst) 
	inst:DoTaskInTime(5, function(inst) --显示有多少个
		local js_i=0
		for _, v in pairs(_G.Ents) do
			--print("类型",type(v),type(v.prefab),v.prefab)
			if v.prefab == "tumbleweedspawner" then
				js_i=js_i+1
			end
		end
		print("存在数量 "..js_i)
	end)
end)
]]