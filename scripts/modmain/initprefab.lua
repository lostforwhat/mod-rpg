local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
local AllRecipes = _G.AllRecipes
local SpawnPrefab = _G.SpawnPrefab
local PI = _G.PI
local Vector3 = _G.Vector3
local FRAMES = _G.FRAMES
local TimeEvent = _G.TimeEvent

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
				inst.components.skilldata:SetLevel("potionbuilder", 1)
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "player", 1.01)
			end
			if prefab == "wendy" then
				inst.components.skilldata:SetLevel("abigailclone", 1)
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
				inst.components.skilldata:SetLevel("newbookbuilder", 1)
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
				inst.components.skilldata:SetLevel("memorykill", 1)
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

local function CheckSpawnedLoot(loot)
    if loot.components.inventoryitem ~= nil then
        loot.components.inventoryitem:TryToSink()
    else
        local lootx, looty, lootz = loot.Transform:GetWorldPosition()
        if _G.ShouldEntitySink(loot, true) or _G.TheWorld.Map:IsPointNearHole(_G.Vector3(lootx, 0, lootz)) then
            _G.SinkEntity(loot)
        end
    end
end

local function SpawnLootPrefab(inst, lootprefab)
    if lootprefab == nil then
        return
    end
    local loot = SpawnPrefab(lootprefab)
    if loot == nil then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if loot.Physics ~= nil then
        local angle = math.random() * 2 * PI
        loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))

        if inst.Physics ~= nil then
            local len = loot:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0)
            x = x + math.cos(angle) * len
            z = z + math.sin(angle) * len
        end

        loot:DoTaskInTime(1, CheckSpawnedLoot)
    end
    loot.Transform:SetPosition(x, y, z)
    loot:PushEvent("on_loot_dropped", {dropper = inst})

    return loot
end

local throwable_list = {
	["rocks"] = 25, 
	["flint"] = 25, 
	["goldnugget"] = 30,
	["cutstone"] = 60,
	["thulecite"] = 88,
	["moonrocknugget"] = 55,
	["redgem"] = 50,
	["bluegem"] = 50,
	["purplegem"] = 50,
	["orangegem"] = 50,
	["yellowgem"] = 50,
	["greengem"] = 50,
	["marble"] = 40,
}
local NO_TAGS_PVP = { "INLIMBO", "ghost", "playerghost", "FX", "NOCLICK", "DECOR", "notarget", "companion", "shadowminion" }
local NO_TAGS = { "player" }
local COMBAT_TAGS = { "_combat" }
for _, v in ipairs(NO_TAGS_PVP) do
    table.insert(NO_TAGS, v)
end
for k, v in pairs(throwable_list) do
    AddPrefabPostInit(k, function(inst)
        if _G.TheWorld.ismastersim then
        	inst:AddComponent("equippable")
        	inst.components.equippable.restrictedtag = "throwrocks"

        	inst:AddComponent("projectile")
        	inst.components.projectile:SetSpeed(60)
	        inst.components.projectile:SetOnHitFn(function(inst, attacker, target)
	            local impactfx = SpawnPrefab("impact")
	            if impactfx ~= nil then
	                local follower = impactfx.entity:AddFollower()
	                follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	                if attacker ~= nil then
	                    impactfx:FacePoint(attacker.Transform:GetWorldPosition())
	                end
	            end
	            if inst.prefab == "redgem" then
	                if target~=nil and target.components.burnable then
	                    target.components.burnable:Ignite()
	                end
	            end
	            if inst.prefab == "bluegem" then
	                if target~=nil and target.components.freezable then
	                    target.components.freezable:AddColdness(2, 2)
	                end
	            end
	            --inst:Remove()
	            local recipe = AllRecipes[inst.prefab]
	            if recipe ~= nil then
	                for i, v in ipairs(recipe.ingredients) do
	                    local amt = math.max(1, math.ceil(v.amount*0.5))
	                    for n = 1, amt do
	                        SpawnLootPrefab(inst, v.type)
	                    end
	                end
	                --hit aoe
	                local x, y, z = inst.Transform:GetWorldPosition()
	                for i, v in ipairs(TheSim:FindEntities(x, y, z, 4, COMBAT_TAGS, TheNet:GetPVPEnabled() and NO_TAGS_PVP or NO_TAGS)) do
	                    if v:IsValid() and v.entity:IsVisible() then
	                        if attacker ~= nil and attacker.components.combat:CanTarget(v) then
	                            --if target is not targeting a player, then use the catapult as attacker to draw aggro
	                            --attacker.components.combat:DoAttack(v)
	                            local damage = inst.components.weapon:GetDamage(attacker, v)
	                            v.components.combat:GetAttacked(attacker, damage)
	                        end
	                    end
	                end
	            end
	            inst:Remove()
                return
	        end)

	        local function becomeweapon(inst, owner)
        		if inst.components.weapon == nil then
		            inst:AddComponent("weapon")
		            local damage = throwable_list[inst.prefab] or 25
		            local range = 5
		            if owner.components.skilldata then
		            	local level = owner.components.skilldata.throwrocks or 0
		            	damage = damage + level * 2
		            	range = range + level * 0.5
		            end
			        inst.components.weapon:SetDamage(damage)
			        inst.components.weapon:SetRange(range, range+2)
		        end
        	end

	        inst.components.projectile:SetOnThrownFn(function(inst, owner, ...)
	            becomeweapon(inst, owner)

	            inst:AddTag("NOCLICK")
	            inst.persists = false
	        end)

	        inst.components.equippable:SetOnEquip(function(inst, owner)
	        	becomeweapon(inst, owner)
	        end)
	        inst.components.equippable:SetOnUnequip(function(inst, owner)
	        	if inst.components.weapon then
	        		inst:RemoveComponent("weapon")
	        	end
	        end)
	        inst.components.equippable.equipstack = true

        end
    end)
end

AddPrefabPostInit("slingshot", function(inst)
	if _G.TheWorld.ismastersim then
		local old_onequipfn = inst.components.equippable.onequipfn
		inst.components.equippable.onequipfn = function(inst, owner)
			old_onequipfn(inst, owner)
			if owner.components.skilldata then
				local level = owner.components.skilldata.shootingmaster or 0
				inst.components.weapon:SetRange(TUNING.SLINGSHOT_DISTANCE + level * 0.5, TUNING.SLINGSHOT_DISTANCE_MAX + level * 0.5)
			end
		end

		local old_onunequipfn = inst.components.equippable.onunequipfn
		inst.components.equippable.onunequipfn = function(inst, owner) 
			old_onunequipfn(inst, owner)
			inst.components.weapon:SetRange(TUNING.SLINGSHOT_DISTANCE, TUNING.SLINGSHOT_DISTANCE_MAX)
		end
	end
end)





------分割线------------
----以下用于初始化状态图
AddStategraphPostInit("wilson", function(sg)
    local slingshot_shoot = sg.states.slingshot_shoot
    local oldonenter = slingshot_shoot.onenter
    slingshot_shoot.onenter = function(inst)
        
        if not inst:HasTag("shootingmaster") then
            oldonenter(inst)
        else
        	if inst.components.combat:InCooldown() then
                inst.sg:RemoveStateTag("abouttoattack")
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle", true)
                return
            end
            local buffaction = inst:GetBufferedAction()
            local target = buffaction ~= nil and buffaction.target or nil
            if target ~= nil and target:IsValid() then
                for i, v in ipairs(NO_TAGS_PVP) do
                    table.insert(NO_TAGS, v)
                end
                inst:ForceFacePoint(target.Transform:GetWorldPosition())
                inst.sg.statemem.attacktarget = target
                local x, y, z = target.Transform:GetWorldPosition()
                for i, v in ipairs(TheSim:FindEntities(x, y, z, 4, COMBAT_TAGS, _G.TheNet:GetPVPEnabled() and NO_TAGS_PVP or NO_TAGS)) do
                    if v:IsValid() and v.entity:IsVisible() then
                        if target ~= v and inst.components.combat:CanTarget(v) then
                            --if target is not targeting a player, then use the catapult as attacker to draw aggro
                            inst.components.combat:DoAttack(v)
                            --v.components.combat:GetAttacked(attacker, damage + level*.25)
                        end
                    end
                end
            end

            inst.sg.statemem.abouttoattack = true
            --inst.AnimState:PlayAnimation("slingshot_pre")
            --inst.AnimState:PushAnimation("slingshot", false)
            inst.AnimState:PlayAnimation("slingshot")

            inst.components.combat:StartAttack()
            inst.components.combat:SetTarget(target)
            inst.components.locomotor:Stop()
        end
    end
    slingshot_shoot.timeline = {
    	TimeEvent(5 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")
        end),
        TimeEvent(7 * FRAMES, function(inst)
            inst:PerformBufferedAction()
			inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
        end),
    }
end)

AddStategraphPostInit("wilson_client", function(sg)
    local slingshot_shoot = sg.states.slingshot_shoot
    local oldonenter = slingshot_shoot.onenter
    slingshot_shoot.onenter = function(inst)
        
        if not inst:HasTag("slingshot_sharpshooter") then
            oldonenter(inst)
        else
            inst.components.locomotor:Stop()
            --inst.AnimState:PlayAnimation("slingshot_pre")
            --inst.AnimState:PushAnimation("slingshot_lag", false)
            inst.AnimState:PlayAnimation("slingshot")
            local buffaction = inst:GetBufferedAction()
            if buffaction ~= nil then
                if buffaction.target ~= nil and buffaction.target:IsValid() then
                    inst:ForceFacePoint(buffaction.target:GetPosition())
                end

                inst:PerformPreviewBufferedAction()
            end
        end
    end
end)