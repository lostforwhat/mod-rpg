local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING

--角色初始化
AddPlayerPostInit(function(inst) 
	inst:AddComponent("taskdata")
	inst:AddComponent("skilldata")
	inst:AddComponent("purchase")
	inst:AddComponent("suit")
	
	inst:AddComponent("attackdeath")
	inst:AddComponent("attackbroken")
	inst:AddComponent("attackback")
	inst:AddComponent("attackfrozen")
	inst:AddComponent("lifesteal")
	inst:AddComponent("crit")
	inst:AddComponent("dodge")
	inst:AddComponent("level")
	inst:AddComponent("luck")
	inst:AddComponent("extradamage")
	inst:AddComponent("extrameta")

	--inst:AddComponent("revenge")
	local prefab = inst.prefab
	if prefab == "wilson" then

	end
	if prefab == "wendy" then
		inst:AddComponent("revenge")
	end
	if prefab == "willow" then

	end
	if prefab == "wathgrithr" then
		--inst:AddComponent("fighting") --新版本使用女武神自带的舞蹈组件代替
	end
	if prefab == "wolfgang" then
		
	end
	if prefab == "wortox" then

	end
	if prefab == "wx78" then

	end
	if prefab == "winona" then

	end
	if prefab == "wickerbottom" then

	end
	if prefab == "wes" then

	end
	if prefab == "woodie" then

	end
	if prefab == "wormwood" then

	end
	if prefab == "wurt" then

	end
	if prefab == "walter" then

	end
	if prefab == "waxwell" then

	end
	if prefab == "warly" then

	end

	if _G.TheWorld.ismastersim then
		--inst:DoTaskInTime(0.1, function() 
	        local prefab = inst.prefab
			if prefab == "wilson" then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "player", 1.01)
			end
			if prefab == "wendy" then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "player", 1.01)
			end
			if prefab == "willow" then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "player", 1.01)
			end
			if prefab == "wathgrithr" then
				inst.components.lifesteal:AddExtraPercent("player", 0.01)
			end
			if prefab == "wolfgang" then
				inst.components.crit:AddExtraChance("player", 0.01)
			end
			if prefab == "wortox" then
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "player", 1.01)
			end
			if prefab == "wx78" then
				inst.components.attackback:SetPercent(1)
			end
			if prefab == "winona" then

			end
			if prefab == "wickerbottom" then

			end
			if prefab == "wes" then
				inst.components.dodge:AddExtraChance("player", 0.01)
			end
			if prefab == "woodie" then

			end
			if prefab == "wormwood" then

			end
			if prefab == "wurt" then
				inst.components.dodge:AddExtraChance("player", 0.01)
			end
			if prefab == "walter" then

			end
			if prefab == "waxwell" then

			end
			if prefab == "warly" then

			end
		--end)
    end

end)

--abigail添加复仇属性
AddPrefabPostInit("abigail", function(inst) 
	inst:AddComponent("revenge")
	if _G.TheWorld.ismastersim then
		inst:AddComponent("clone")
	end
end)

--给灰烬添加肥料属性
AddPrefabPostInit("ash", function(inst) 
	inst:AddTag("volcanic")
	if _G.TheWorld.ismastersim then
		inst:AddComponent("fertilizer")
	    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
	    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
	    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
	    inst.components.fertilizer.volcanic = true
	end
end)

--修改荆棘甲
AddPrefabPostInit("armor_bramble", function(inst)
	if _G.TheWorld.ismastersim then
		local function onequip(inst, owner) 
		    owner.AnimState:OverrideSymbol("swap_body", "armor_bramble", "swap_body")

		    if owner.components.attackback then
		    	owner.components.attackback:SetCommon(TUNING.ARMORBRAMBLE_DMG)
		    end	
		end

		local function onunequip(inst, owner) 
		    owner.AnimState:ClearOverrideSymbol("swap_body")

		    if owner.components.attackback then
		    	owner.components.attackback:SetCommon(0)
		    end	
		end
		inst.components.equippable:SetOnEquip(onequip)
	    inst.components.equippable:SetOnUnequip(onunequip)
	end
end)