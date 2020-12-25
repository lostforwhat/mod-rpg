require "utils/utils"
local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
local AllRecipes = _G.AllRecipes
local SpawnPrefab = _G.SpawnPrefab
local PI = _G.PI
local DEGREES = _G.DEGREES
local Vector3 = _G.Vector3
local FRAMES = _G.FRAMES
local TimeEvent = _G.TimeEvent

local function RedirectDamageFn(inst, attacker, damage, weapon, stimuli)
	local redirect_tagert = nil
	if inst.components.combat ~= nil then
		local exclusiveredirect = inst.components.combat.exclusiveredirect
		if exclusiveredirect then
			redirect_tagert = exclusiveredirect(inst, attacker, damage, weapon, stimuli)
		end
		if redirect_tagert == nil then
			--此处写所有角色伤害转移策略
			if inst:HasTag("lifeforever") and math.random() < 0.15 then
				return _G.FindEntity(
			        inst,
			        15,
			        function(guy) 
			            return guy ~= inst
			                and guy ~= inst.owner
			                and guy.entity:IsVisible()
			                and not guy.components.health:IsDead()
			                and (guy.components.combat.target == inst or
			                    guy:HasTag("character") or
			                    guy:HasTag("monster") or
			                    guy:HasTag("animal") or 
			                    guy:HasTag("fly"))
			        end,
			        { "_combat", "_health" },
			        { "prey", "INLIMBO" })
			end
			
		end
	end
	return redirect_tagert
end

local function PlayerMigrateCheck(player)
	print("check")
	if player.components.vip ~= nil and player.components.vip.level > 0 then
		return true
	end
	local portal = _G.FindEntity(
	        player,
	        5,
	        function(guy) 
	            return guy:HasTag("migrator")
	            	or guy:HasTag("multiplayer_portal")
	        end)
	if portal ~= nil then
		return true
	end
	player.components.talker:Say("我需要先找到大门或者洞口")
end

AddPrefabPostInit("player_classified", function(inst)
	local skills = {
	    resurrect = {
	        level = 0,
	        cd = 0,
	    },
	    rejectdeath = {
	        level = 0,
	        cd = 0,
	        passive = true
	    },
	    stealth = {
	        level = 0,
	        cd = 0,
	        key = _G.KEY_R
	    },
	}

	local function UpdateSkill(inst, name, data)
	    if inst._skills[name] ~= nil then
	        for k, v in pairs(inst.skills[name]) do
	            if data[k] ~= nil then
	                inst.skills[name][k] = data[k]
	            end
	        end
	        inst._skills[name]:set(_G.Table2String(inst.skills[name]))
	        inst._skillsupdate:push()
	    end
	end

	local function UpdateSkillCd(inst, name, cd)
	    if inst._skills[name] ~= nil then
	        inst.skills[name].cd = cd
	        inst._skills[name]:set(_G.Table2String(inst.skills[name]))
	        inst._skillsupdatecd:push()
	    end
	end

	local function OnSkillsUpdate(inst)
	    for k, v in pairs(inst._skills) do
	        inst.skills[k] = _G.String2Table(v:value())
	    end
	end

	local function GetSkills(inst)
	    if _G.TheWorld.ismastersim then
	        --print("skills:", _G.Table2String(inst.skills))
	        return inst.skills
	    else
	        OnSkillsUpdate(inst)
	        --print("skills:", _G.Table2String(inst.client_skills))
	        return inst.skills
	    end
	end

	inst._skills = {
        resurrect = _G.net_string(inst.GUID, "_skills.resurrect"),
        rejectdeath = _G.net_string(inst.GUID, "_skills.rejectdeath"),
        stealth = _G.net_string(inst.GUID, "_skills.stealth"),
    }
    inst._skillsupdate = _G.net_event(inst.GUID, "_skillsupdate")
    inst._skillsupdatecd = _G.net_event(inst.GUID, "_skillsupdatecd")

    inst._suit = _G.net_byte(inst.GUID, "_suit", "_suitdirty")

    inst._showhelp = _G.net_event(inst.GUID, "_showhelp")


    inst:ListenForEvent("_skillsupdate", function() 
    	inst._parent:PushEvent("_skillsupdate")
	end)
	inst:ListenForEvent("_skillsupdatecd", function() 
    	inst._parent:PushEvent("_skillsupdatecd")
	end)
	inst:ListenForEvent("_showhelp", function() 
		inst._parent:PushEvent("_showhelp")
	end)
	inst:ListenForEvent("_suitdirty", function() 
		inst._parent:PushEvent("suitdirty")
	end)

    if not _G.TheWorld.ismastersim then
        inst.skills = skills
        inst.GetSkills = GetSkills
    else
    	inst.skills = skills
	    inst.UpdateSkill = UpdateSkill
	    inst.UpdateSkillCd = UpdateSkillCd
	    inst.GetSkills = GetSkills
    end
end)

--角色初始化
AddPlayerPostInit(function(inst) 
	inst:AddComponent("vip")
	inst:AddComponent("taskdata")
	inst:AddComponent("skilldata")
	inst:AddComponent("purchase")
	
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
	inst:AddComponent("titles")
	inst:AddComponent("email")
	inst:AddComponent("reciever")
	local prefab = inst.prefab
	if prefab == "wilson" then

	end
	if prefab == "wendy" then
		
	end
	if prefab == "willow" then

	end
	if prefab == "wathgrithr" then
		--inst:AddComponent("fighting") --新版本使用女武神自带的sing组件代替
	end
	if prefab == "wolfgang" then
		
	end
	if prefab == "wortox" then
		inst:AddComponent("groundpounder")
		inst.components.groundpounder.destroyer = true
	    inst.components.groundpounder.damageRings = 2
	    inst.components.groundpounder.destructionRings = 2
	    inst.components.groundpounder.platformPushingRings = 2
	    inst.components.groundpounder.numRings = 3
	    inst.components.groundpounder.noTags = TheNet:GetPVPEnabled() 
	    and { "FX", "NOCLICK", "DECOR", "INLIMBO" } 
	    or {"FX", "NOCLICK", "DECOR", "INLIMBO", "player"}
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
		inst:AddComponent("suit")
		inst:AddComponent("stealth")
		inst:AddComponent("resurrect")
		inst.components.resurrect.level = 1
		inst:AddComponent("stealer")
		inst:AddComponent("timer")
		inst:AddComponent("migrater")
		inst.components.migrater:SetCheckFn(PlayerMigrateCheck)
		--inst:DoTaskInTime(0.1, function() 
	        local prefab = inst.prefab
			if prefab == "wilson" then
				inst.components.skilldata:SetLevel("potionbuilder", 1)
				inst.components.locomotor:SetExternalSpeedMultiplier(inst, "player", 1.01)
			end
			if prefab == "wendy" then
				inst:AddComponent("revenge")
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
				inst.components.skilldata:SetLevel("metalbody", 1)
				inst.components.attackback:SetPercent(1)
			end
			if prefab == "winona" then
				inst.components.dodge:AddExtraChance("player", 0.01)
			end
			if prefab == "wickerbottom" then
				inst.components.skilldata:SetLevel("newbookbuilder", 1)
			end
			if prefab == "wes" then
				inst.components.dodge:AddExtraChance("player", 0.01)
				inst.components.skilldata:SetLevel("balloondummy", 1)
			end
			if prefab == "woodie" then
				inst.components.health.externalabsorbmodifiers:SetModifier("player", .01)
			end
			if prefab == "wormwood" then
				inst.components.attackback:SetPercent(1)
			end
			if prefab == "wurt" then
				inst.components.dodge:AddExtraChance("player", 0.01)
			end
			if prefab == "walter" then

			end
			if prefab == "waxwell" then
				inst.components.skilldata:SetLevel("sanityprotection", 1)
			end
			if prefab == "warly" then
				inst.components.combat:SetRange(2.5)
				inst.components.skilldata:SetLevel("memorykill", 1)
			end
			if prefab == "webber" then
				inst.components.skilldata:SetLevel("spiderbody", 1)
			end
		--end)
		--全局注册伤害转移方法
		if inst.components.combat ~= nil then
			inst.components.combat.redirectdamagefn = RedirectDamageFn
		end
		--取消死亡掉落(还需要修改死亡state)
		if inst.components.inventory ~= nil then
			inst.components.inventory:DisableDropOnDeath()
		end

		inst.GetShowItemInfo = function(inst)
			local level = inst.components.level and inst.components.level.level or 1
			local crit = inst.components.crit and inst.components.crit:GetRealChance() or 0
			local dodge = inst.components.dodge and inst.components.dodge:GetFinalChance() or 0
			return "Lv: "..level, "暴击+"..(crit*100).."% / 闪避+"..(dodge*100).."%"
		end
    end

end)

--其实也可以写在AddPlayerPostInit中，此处为了便于区分
AddPrefabPostInit("wortox", function(inst) 
	if _G.TheWorld.ismastersim then
		local function IsSoul(item)
		    return item.prefab == "wortox_soul"
		end
		local function GetStackSize(item)
		    return item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
		end
		local function SortByStackSize(l, r)
		    return GetStackSize(l) < GetStackSize(r)
		end
		local function CheckSoulsAdded(inst)
			local extra_num = 0
			if inst.components.skilldata and inst.components.skilldata["moresouls"] > 0 then
				local level = inst.components.skilldata["moresouls"] or 0
				extra_num = level
			end
			local max_souls = TUNING.WORTOX_MAX_SOULS + extra_num
		    inst._checksoulstask = nil
		    local souls = inst.components.inventory:FindItems(IsSoul)
		    local count = 0
		    for i, v in ipairs(souls) do
		        count = count + GetStackSize(v)
		    end
		    if count > max_souls then
		        --convert count to drop count
		        count = count - math.floor(max_souls * 0.3) + math.random(0, 2) - 1
		        table.sort(souls, SortByStackSize)
		        local pos = inst:GetPosition()
		        for i, v in ipairs(souls) do
		            local vcount = GetStackSize(v)
		            if vcount < count then
		                inst.components.inventory:DropItem(v, true, true, pos)
		                count = count - vcount
		            else
		                if vcount == count then
		                    inst.components.inventory:DropItem(v, true, true, pos)
		                else
		                    v = v.components.stackable:Get(count)
		                    v.Transform:SetPosition(pos:Get())
		                    v.components.inventoryitem:OnDropped(true)
		                end
		                break
		            end
		        end
		        inst.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
		        inst:PushEvent("souloverload")
		    elseif count > max_souls * .8 then
		        inst:PushEvent("soultoomany")
		    end
		end
		local function OnGotNewItem(inst, data)
		    if data.item ~= nil and data.item.prefab == "wortox_soul" then
		        if inst._checksoulstask ~= nil then
		            inst._checksoulstask:Cancel()
		        end
		        inst._checksoulstask = inst:DoTaskInTime(0, CheckSoulsAdded)
		    end
		end
		_G.RemoveLastEventListener(inst, "gotnewitem")
		inst:ListenForEvent("gotnewitem", OnGotNewItem)
	end
end)

AddPrefabPostInit("wendy", function(inst) 
	if _G.TheWorld.ismastersim then
		if inst.components.health ~= nil then
			inst.components.health.redirect = function(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb) 
				if amount < 0 then

				end
			end
		end
	end
end)

AddPrefabPostInit("waxwell", function(inst) 
	if _G.TheWorld.ismastersim then
		local function HealthRedirect(inst, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
			if amount >= 0 or 
				(not ignore_invincible and 
					(inst.components.health:IsInvincible() or 
						inst.components.health.inst.is_teleporting)) then
				return false
			end
			if inst.components.sanity ~= nil then
				local sanity_percent = inst.components.sanity:GetPercent() or 0
				local current = inst.components.sanity.current or 0
				if sanity_percent > 0.5 and current > 0 then					
					if current + amount * 0.5 >= 0 then
						if inst._shadow_fx == nil then
							inst._shadow_fx = SpawnPrefab("shadow_shield"..math.random(6))
							inst._shadow_fx.entity:SetParent(inst.entity)
							inst:DoTaskInTime(1, function() inst._shadow_fx=nil end)
						end
						inst.components.sanity:DoDelta(amount*0.5)
					else
						inst.components.sanity:DoDelta(current)
						inst.components.Health:DoDelta(current + amount * 0.5, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
					end
					return true
				end
			end
		end
		if inst.components.health ~= nil then
			inst.components.health.redirect = HealthRedirect
		end
	end
end)

--伯尼添加击杀事件
AddPrefabPostInit("bernie_big", function(inst) 
	if _G.TheWorld.ismastersim then
		inst:ListenForEvent("killed", function(inst, data) 
			if (inst.brain ~= nil and inst.brain._leader ~= nil) or inst._leader ~= nil then
				local player = inst.brain._leader or inst._leader
				player:PushEvent("killed", data)
			end
		end)

		inst.components.health.externalabsorbmodifiers:SetModifier("bernie_big", 0.5)
	end
end)

--abigail添加复仇属性
AddPrefabPostInit("abigail", function(inst) 
	if _G.TheWorld.ismastersim then
		inst:AddComponent("revenge")
		inst:AddComponent("clone")

		inst.components.health.externalabsorbmodifiers:SetModifier("abigail", 0.7)
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
for _, m in pairs(throwable_list) do
    AddPrefabPostInit(_, function(inst)
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

local function SeedsBecomeWeapon(inst, owner)
	if inst.components.weapon == nil then
        inst:AddComponent("weapon")
        local damage = 10
        local range = 10
        if owner.components.skilldata then
        	local level = owner.components.skilldata:GetLevel("seedsmagic")
        	damage = damage + level * 2
        end
        inst.components.weapon:SetDamage(damage)
        inst.components.weapon:SetRange(range, range+2)
    end
end

local function SpawnAtGround(prefab, x, y, z)
	if _G.TheWorld.Map:IsPassableAtPoint(x, y, z) then
        local item = SpawnPrefab(prefab)
        item.Transform:SetPosition(x, y, z)
        return item
    end
end

local NO_PVP_TAGS = {"ghost", "player"}
local function areahitcheck(target, attacker)
	local leader = target.components.follower and target.components.follower:GetLeader() or nil
	if leader == attacker then
		return false
	end
	if not TheNet:GetPVPEnabled() then
		for k,v in pairs(NO_PVP_TAGS) do
			if target:HasTag(v) or (leader ~= nil and leader:HasTag(v)) then
				return false
			end
		end
	end
	return true
end

local function SeedsOnHit(inst, attacker, target)
	local num = 3
	if attacker.components.skilldata then
    	local level = attacker.components.skilldata:GetLevel("seedsmagic")
    	num = 3 + level
    end
	--[[
	local loot = SpawnLootPrefab(inst, "")
	if loot ~= nil and loot.components.follower ~= nil and attacker.components.leader ~= nil then
		attacker.components.leader:AddFollower(loot)
	end
	if loot.components.combat ~= nil and target ~= nil then
		loot.components.combat:SetTarget(target)
	end
	]]
	--root
	local x,y,z = target.Transform:GetWorldPosition()
	for k=1, num do
        local angle = k * 2 * PI / num
        local item = SpawnAtGround("deciduous_root", 2*math.cos(angle)+x, y, 2*math.sin(angle)+z)
        if item ~= nil then
        	item.components.combat:SetAreaDamage(TUNING.DECID_MONSTER_ROOT_ATTACK_RADIUS, 1.2, areahitcheck)
    		item.components.combat:SetDefaultDamage(TUNING.DECID_MONSTER_DAMAGE)
    		local pos = Vector3(x,y,z)
    		local targetangle = item:GetAngleToPoint(rootpos) * DEGREES
        	item:PushEvent("givetarget", { target = target, targetpos = pos, targetangle = targetangle, owner = inst })
    		--击杀的话转移事件到玩家
    		item:ListenForEvent("killed", function(item, data) attacker:PushEvent("killed", data) end)
    	end
    end
    inst:Remove()
end

local function SeedsOnThrown(inst, owner, ...)
	SeedsBecomeWeapon(inst, owner)
	inst:AddTag("NOCLICK")
    inst.persists = false
end

AddPrefabPostInit("seeds", function(inst) 
	if _G.TheWorld.ismastersim then
		inst:AddComponent("equippable")
    	inst.components.equippable.restrictedtag = "seedsmagic"

    	inst:AddComponent("projectile")
    	inst.components.projectile:SetSpeed(30)
    	inst.components.projectile:SetOnHitFn(SeedsOnHit)
    	inst.components.projectile:SetOnThrownFn(SeedsOnThrown)
    	inst.components.equippable:SetOnEquip(function(inst, owner)
        	SeedsBecomeWeapon(inst, owner)
        end)
        inst.components.equippable:SetOnUnequip(function(inst, owner)
        	if inst.components.weapon then
        		inst:RemoveComponent("weapon")
        	end
        end)
    	inst.components.equippable.equipstack = true
	end
end)

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

--world添加网络商店
local function InitShop(inst)
	inst:AddComponent("worldshop")
end
AddPrefabPostInit("forest_network", InitShop)
AddPrefabPostInit("cave_network", InitShop)
--AddPrefabPostInit("world", InitShop)


--为所有武器添加等级
AddPrefabPostInitAny(function(inst) 
	if inst.components.weapon ~= nil and inst.components.stackable == nil then
		if inst.components.weaponlevel == nil then
			inst:AddComponent("weaponlevel")
		end
	
		if inst.GetShowItemInfo == nil then
			inst.GetShowItemInfo = function(inst)
				local level = inst.components.weaponlevel and inst.components.weaponlevel.level or 0
				if level > 0 then
					local extra_damage = inst.components.weapon.extra_damage or 0
					return "强化+"..level.." (伤害+"..extra_damage..")"
				end
			end
		end
		if inst.components.named == nil then
			inst:AddComponent("named")
		end
	end
end)

AddPrefabPostInit("pigking", function(inst)
	inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = _G.TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = _G.Vector3(0, -500, 0)
    inst.components.talker:MakeChatter()
	inst:AddTag("npctask")
	if _G.TheWorld.ismastersim then
		inst:AddComponent("npctask")
	end
end)

AddPrefabPostInit("mermking", function(inst)
	if inst.components.talker == nil then
		inst:AddComponent("talker")
	end
    inst.components.talker.fontsize = 35
    inst.components.talker.font = _G.TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = _G.Vector3(0, -500, 0)
    inst.components.talker:MakeChatter()
	inst:AddTag("npctask")
	if _G.TheWorld.ismastersim then
		inst:AddComponent("npctask")
	end
end)

_G.FUELTYPE.ORANGEGEM = "ORANGEGEM"
_G.FUELTYPE.YELLOWGEN = "YELLOWGEN"
AddPrefabPostInit("orangegem", function(inst) 
	if _G.TheWorld.ismastersim then
		if inst.components.fuel == nil then
			inst:AddComponent("fuel")
		end
		inst.components.fuel.fuelvalue = 1000
		inst.components.fuel.fueltype = "ORANGEGEM"
	end
end)
AddPrefabPostInit("yellowgem", function(inst) 
	if _G.TheWorld.ismastersim then
		if inst.components.fuel == nil then
			inst:AddComponent("fuel")
		end
		inst.components.fuel.fuelvalue = 900
		inst.components.fuel.fueltype = "YELLOWGEN"
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

