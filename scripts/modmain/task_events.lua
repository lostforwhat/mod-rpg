require "utils/utils"
local _G = GLOBAL
local ExistInTable = _G.ExistInTable

local function GiveExp(inst, exp)
    --预留插槽，用于提升或减少额外经验等

    exp = math.floor(exp)
    if exp > 0 and inst.components.level then
        inst.components.level:AddXp(exp)
    end
end

local function OnTumbleweedDroped(inst, data)
	local item = data.item
    if not item:HasTag("monster") and item.components.combat == nil then
        

        if inst.components.luck then
            inst.components.luck:DoDelta(math.random(0,5)-4)
        end
    end
end

local function OnTumbleweedPicked(inst, data)
	local taskdata = inst.components.taskdata	
    local lucky_level = data.lucky_level
    
    taskdata:AddOne("pick_one_tumbleweed")
    taskdata:AddOne("pick_tumbleweed_88")
    taskdata:AddOne("pick_tumbleweed_288")
    taskdata:AddOne("pick_tumbleweed_888")
    taskdata:AddOne("pick_tumbleweed_2888")
    taskdata:AddOne("pick_tumbleweed_6666")
    if lucky_level ~= nil then
        if lucky_level == 1 then
            taskdata:AddOne("pick_tumbleweed_red_100")
        elseif lucky_level == 2 then
            taskdata:AddOne("pick_tumbleweed_yellow_60")
        elseif lucky_level == 3 then
            taskdata:AddOne("pick_tumbleweed_light_20")
        elseif lucky_level == -1 then
            taskdata:AddOne("pick_tumbleweed_green_120")
        elseif lucky_level == -2 then
            taskdata:AddOne("pick_tumbleweed_blue_60")
        end
    end
    taskdata.tumbleweednum = taskdata.tumbleweednum + 1

    GiveExp(inst, math.random(1, 5))
end

local function OnEat(inst, data)
	local food = data.food
	local feeder = data.feeder
	local taskdata = inst.components.taskdata
	taskdata:AddOne("eat_100")
	taskdata:AddOne("eat_1888")

	local eat_types = taskdata.eat_types or {}
	local function HasEated(type)
		for k,v in pairs(eat_types) do
			if v == type then
				return true
			end
		end
		return false
	end
	if food:HasTag("preparedfood") then
		taskdata:AddOne("eat_prefared_200")

		if not HasEated(food.prefab) then
			table.insert(taskdata.eat_types, food.prefab)
			taskdata:AddOne("eat_type_20")
			taskdata:AddOne("eat_type_40")
		end
	end
	if food:HasTag("spicedfood") then
		taskdata:AddOne("eat_special_10")
	end
	--冷热食
	local temp = food.components.edible.temperaturedelta or 0
    local temperatureduration = food.components.edible.temperatureduration or 0
    local chill = food.components.edible.chill or 0
    if temp ~= 0 and temperatureduration ~= 0 and chill < 1 then
       --print(temp, temperatureduration, chill)
    	if temp < 0 then
    		taskdata:AddOne("eat_cold_10")
    	elseif temp > 0 then
    		taskdata:AddOne("eat_hot_10")
    	end
    end

    if food.components.edible then
        local hunger_val = food.components.edible:GetHunger(inst)
        local sanity_val = food.components.edible:GetSanity(inst)
        local health_val = food.components.edible:GetHealth(inst)
        GiveExp(inst, hunger_val*0.05 + sanity_val*0.12 + health_val*0.1)
    end
end

local function OnDeath(inst, data)
	local attacker = inst.components.combat.lastattacker
	local cause = data.cause
	local taskdata = inst.components.taskdata

end

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or victim:HasTag("structure") or
                victim:HasTag("wall") or victim:HasTag("balloon") or
                victim:HasTag("groundspike") or victim:HasTag("smashable") or
                victim:HasTag("companion") or victim:HasTag("visible"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
        and victim.components.freezable ~= nil
end

local function OnKilled(inst, data)
	local victim = data.victim
    if not IsValidVictim(victim) then return end
    local taskdata = inst.components.taskdata
    if taskdata.killed_temp[victim.GUID] then
    	return
    end
    taskdata.killed_temp[victim.GUID] = true
    inst:DoTaskInTime(1, function()
        taskdata.killed_temp[victim.GUID] = nil
    end)

    if victim:HasTag("monster") then
	    taskdata:AddOne("kill_100")
	    taskdata:AddOne("kill_1000")
	end
	local prefab = victim.prefab
	if string.find(prefab, "spider") then
        taskdata:AddOne("kill_spider_100")
    end
    if string.find(prefab, "hound") then
        taskdata:AddOne("kill_hound_100")
    end
    if string.find(prefab, "bee") then
        taskdata:AddOne("kill_bee_100")
    end
    if prefab == "mosquito" then
        taskdata:AddOne("kill_mosquito_100")
    end
    if prefab == "frog" then
        taskdata:AddOne("kill_frog_100")
    end
    if string.find(prefab, "koale") then
        taskdata:AddOne("kill_koale_5")
    end
    if prefab == "monkey" then
        taskdata:AddOne("kill_monkey_20")
    end
    if prefab == "leif" or prefab == "leif_sparse" then
        taskdata:AddOne("kill_leif_5")
    end
    if prefab == "bunnyman" then
        taskdata:AddOne("kill_bunnyman_20")
    end
    if prefab == "tallbird" then
        taskdata:AddOne("kill_tallbird_50")
    end
    if prefab == "worm" then
        taskdata:AddOne("kill_worm_20")
    end
    if prefab == "slurtle" or prefab == "snurtle" then
        taskdata:AddOne("kill_slurtle_20")
    end
    if prefab == "rabbit" then
        taskdata:AddOne("kill_rabbit_10")
    end
    if prefab == "ghost" then
        taskdata:AddOne("kill_ghost_10")
    end
    if prefab == "tentacle" then
        taskdata:AddOne("kill_tentacle_50")
    end
    if prefab == "terrorbeak" or prefab == "crawlinghorror"
    	or prefab == "crawlingnightmare" or prefab == "nightmarebeak" then
        taskdata:AddOne("kill_terrorbeak_50")
    end
    if prefab == "birchnutdrake" then
        taskdata:AddOne("kill_birchnutdrake_20")
    end
    if prefab == "lightninggoat" then
        taskdata:AddOne("kill_lightninggoat_20")
    end
    if prefab == "spiderqueen" then
        taskdata:AddOne("kill_spiderqueen_10")
    end
    if prefab == "warg" then
        taskdata:AddOne("kill_warg_5")
    end
    if prefab == "catcoon" then
        taskdata:AddOne("kill_catcoon_20")
    end
    if prefab == "walrus" then
        taskdata:AddOne("kill_walrus_20")
    end
    if prefab == "butterfly" then
    	taskdata:AddOne("kill_butterfly_20")
    end
    if prefab == "bat" then
    	taskdata:AddOne("kill_bat_20")
    end
    if prefab == "merm" then
    	taskdata:AddOne("kill_merm_30")
    end
    if prefab == "butterfly" then
    	taskdata:AddOne("kill_butterfly_20")
    end
    if string.find(prefab, "penguin") then
    	taskdata:AddOne("kill_penguin_10")
    end
    if prefab == "perd" then
    	taskdata:AddOne("kill_perd_20")
    end
    if prefab == "crow" 
        or prefab == "canary"
        or prefab == "puffin"
        or prefab == "robin_winter"
        or prefab == "robin" then
    	taskdata:AddOne("kill_bird_20")
    end
    if prefab == "pigman" then
    	taskdata:AddOne("kill_pigman_20")
    end
    if prefab == "krampus" then
    	taskdata:AddOne("kill_krampus_30")
    end
    if prefab == "spat" then
    	taskdata:AddOne("kill_spat")
    end
    if prefab == "moonpig" then
    	if _G.TheWorld.state.isfullmoon then
            taskdata:AddOne("kill_moonpig_10")
        end
    end
    --以下为挑战boss
    local boss_list = {"moose", "dragonfly", "beager", "deerclops",
    				  "stalker", "stalker_atrium", "klaus", "crabking",
                      "antlion", "minotaur", "beequeen", "toadstool", 
              		  "toadstool_dark", "malbatross", 
              		  "shadow_rook", "shadow_knight", "shadow_bishop"}
    if ExistInTable(boss_list, prefab) then
        local x,y,z = victim.Transform:GetWorldPosition()
    	local ents = TheSim:FindEntities(x, y, z, 15, {"player"}, {"playerghost"})
    	if prefab == "moose" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_moose")
    		end
    	elseif prefab == "dragonfly" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_dragonfly")
    		end
    	elseif prefab == "beager" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_beager")
    		end
    	elseif prefab == "deerclops" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_deerclops")
    		end
    	elseif ExistInTable({"shadow_bishop", "shadow_knight", "shadow_rook"}, prefab) then
    		for k, v in pairs(ents) do
    			if not ExistInTable(v.components.taskdata.shadowboss_killed, prefab) then
    				table.insert(v.components.taskdata.shadowboss_killed, prefab)
    				v.components.taskdata:AddOne("kill_killshadow_3")
    			end
    		end
    	elseif prefab == "stalker" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_stalker")
    		end
    	elseif prefab == "stalker_atrium" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_stalker_atrium")
    		end
    	elseif prefab == "klaus" and inst:IsUnchained() then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_klaus")
    		end
    	elseif prefab == "antlion" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_antlion")
    		end
    	elseif prefab == "minotaur" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_minotaur")
    		end
    	elseif prefab == "beequeen" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_beequeen")
    		end
    	elseif prefab == "toadstool" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_toadstool")
    		end
    	elseif prefab == "toadstool_dark" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_toadstool_dark")
    		end
    	elseif prefab == "malbatross" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_malbatross")
    		end
    	elseif prefab == "crabking" then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_crabking")
    		end
    	end
    	-- 此处添加重复击杀boss获得奖励,注意排除一段克劳斯

        local health = victim.components.health.maxhealth or 0
        local num = #ents
        for k, v in pairs(ents) do
            GiveExp(v, math.floor((health/num)*0.01))
        end
    else
        local health = victim.components.health.maxhealth or 0
        GiveExp(inst, math.floor(health*0.01))
    end
    
end	

local function OnWakeup(inst, data)
	local taskdata = inst.components.taskdata

end
--着火
local function OnFire(inst)
	local taskdata = inst.components.taskdata

end
--冰冻
local function OnFreeze(inst)
	local taskdata = inst.components.taskdata

end
--催眠
local function OnKnockedout(inst)
	local taskdata = inst.components.taskdata

end
--钓鱼
local function OnFish(inst, data)
	local taskdata = inst.components.taskdata

end
--采集
local function OnPick(inst, data)
	local taskdata = inst.components.taskdata
	if data.object and data.object.components.pickable and not data.object.components.trader then
		local item = data.object
		taskdata:AddOne("pick_100")
		taskdata:AddOne("pick_1000")

		local prefab = item.prefab
		if prefab == "cactus" then
			taskdata:AddOne("pick_cactus_50")
		elseif prefab == "mushroom" then
			taskdata:AddOne("pick_mushroom_100")
		elseif string.find(prefab, "flower_cave") then
			taskdata:AddOne("pick_flower_cave_100")
		elseif prefab == "tallbirdnest" then
			taskdata:AddOne("pick_tallbirdnest_10")
		elseif prefab == "rock_avocado_bush" then
			taskdata:AddOne("pick_rock_avocado_bush_100")
		elseif prefab == "cave_banana_tree" then
			taskdata:AddOne("pick_cave_banana_tree_50")
		elseif prefab == "wormlight_plant" then
			taskdata:AddOne("pick_wormlight_plant_40")
		elseif prefab == "reeds" then
			taskdata:AddOne("pick_reeds_50")
		elseif prefab == "coffeebush" then
			taskdata:AddOne("pick_coffeebush_50")
		end

        GiveExp(inst, 1)
	end
end

local function OnFinishedwork(inst, data)
	local taskdata = inst.components.taskdata
    if data.target and data.target.components.workable then
        local action = data.action
        --砍树
        if data.target:HasTag("tree") and action == _G.ACTIONS.CHOP then
            taskdata:AddOne("chop_100")
            taskdata:AddOne("chop_1000")
        end
        --挖矿
        if action == _G.ACTIONS.MINE then
            taskdata:AddOne("mine_60")
            taskdata:AddOne("mine_500")
        end
        --移植
        if not data.target:HasTag("tree") and action == _G.ACTIONS.DIG then

        end

        GiveExp(inst, 1)
    end
end
--复活
local function OnRespawnfromghost(inst, data)
	local source = data.source
	local taskdata = inst.components.taskdata

end
--建造
local function OnConsume(inst)
	local taskdata = inst.components.taskdata
	taskdata:AddOne("build_30")
	taskdata:AddOne("build_300")

    GiveExp(inst, 1)
end
local function OnBuildItem(inst, data)
	local taskdata = inst.components.taskdata
	if data.recipe ~= nil then
		local product = data.recipe.product
		if product == "pumpkin_lantern" then
			taskdata:AddOne("build_pumpkin_lantern")
		elseif product == "armorruins" then
			taskdata:AddOne("build_armorruins")
		elseif product == "ruinshat" then
			taskdata:AddOne("build_ruinshat")
		elseif product == "ruins_bat" then
			taskdata:AddOne("build_ruins_bat")
		elseif product == "gunpowder" then
			taskdata:AddOne("build_gunpowder")
		elseif product == "healingsalve" then
			taskdata:AddOne("build_healingsalve")
		elseif product == "bandage" then
			taskdata:AddOne("build_bandage")
		elseif product == "blowdart_pipe" then
			taskdata:AddOne("build_blowdart_pipe")
		elseif product == "blowdart_sleep" then
			taskdata:AddOne("build_blowdart_sleep")
		elseif product == "blowdart_yellow" then
			taskdata:AddOne("build_blowdart_yellow")
		elseif product == "blowdart_fire" then
			taskdata:AddOne("build_blowdart_fire")
		elseif product == "nightsword" then
			taskdata:AddOne("build_nightsword")
		elseif product == "amulet" then
			taskdata:AddOne("build_amulet")
		elseif product == "panflute" then
			taskdata:AddOne("build_panflute")
		elseif product == "molehat" then
			taskdata:AddOne("build_molehat")
		elseif product == "lifeinjector" then
			taskdata:AddOne("build_lifeinjector")
		elseif product == "batbat" then
			taskdata:AddOne("build_batbat")
		elseif product == "multitool_axe_pickaxe" then
			taskdata:AddOne("build_multitool_axe_pickaxe")
		elseif product == "thulecite" then
			taskdata:AddOne("build_thulecite")
		elseif product == "yellowstaff" then
			taskdata:AddOne("build_yellowstaff")
		elseif product == "footballhat" then
			taskdata:AddOne("build_footballhat")
		elseif product == "armorwood" then
			taskdata:AddOne("build_armorwood")
		elseif product == "hambat" then
			taskdata:AddOne("build_hambat")
		elseif product == "glasscutter" then
			taskdata:AddOne("build_glasscutter")
		end
		
	end
end
--种植
local function OnDeployItem(inst, data)
	local taskdata = inst.components.taskdata
	if data.prefab == "pinecone" or 
	    data.prefab == "acorn" or 
	    data.prefab == "twiggy_nut"  or 
	    data.prefab == "jungletreeseed" or
	    data.prefab == "coconut" or
	    data.prefab == "teatree_nut" or
	    data.prefab == "butterfly" or 
	    data.prefab == "moonbutterfly" or 
	    string.find(data.prefab, "seeds") ~= nil or 
	    data.prefab == "burr" then
        taskdata:AddOne("plant_100")
        taskdata:AddOne("plant_1000")

        GiveExp(inst, 1)
    end
end
--攻击
local function OnAttacked(inst, data)
	local taskdata = inst.components.taskdata
	local damage = data.damage or 0

	taskdata:AddMulti("hurt_10000", math.floor(damage))
	if damage > 0 and damage < 1.5 then
		taskdata:AddOne("hurt_1")
	end
end

local function OnHitOther(inst, data)
	local taskdata = inst.components.taskdata
	if data.damage and data.damage >= 0 then
	    local target = data.target
	    local absorb = target.components.health and target.components.health.absorb or 0
	    local damage = math.floor(data.damage * (1- math.clamp(absorb, 0, 1)) + 0.5)

	    taskdata:AddMulti("attack_30000", damage)
	    taskdata:AddMulti("attack_99999", damage)

	    if damage < 2 then
	    	taskdata:AddOne("damage_1")
	    end

	    if damage == 66 then
	    	taskdata:AddOne("damage_66")
	    end
   end
end
--给予
local function OnGiveSomething(inst, data)
	local taskdata = inst.components.taskdata

end
--cook
local function OnDoCook(inst, data)
	local taskdata = inst.components.taskdata
	taskdata:AddOne("cook_100")
	taskdata:AddOne("cook_888")
	--预留烹饪特殊食物

    GiveExp(inst, 1)
end
--addfollower
local function OnAddFollower(inst, data)
	local taskdata = inst.components.taskdata
	local follower = data.follower
	local prefab = follower.prefab
	if prefab == "pigman" then
		taskdata:AddOne("makefriend_pigman")
	elseif prefab == "bunnyman" then
		taskdata:AddOne("makefriend_bunnyman")
	elseif prefab == "catcoon" then
		taskdata:AddOne("makefriend_catcoon")
	elseif string.find(prefab, "spider") then
		taskdata:AddOne("makefriend_spider")
	elseif prefab == "mandrake_active" then
		if not TheWorld.state.isday then
			taskdata:AddOne("makefriend_mandrake_active")
		end
	elseif prefab == "smallbird" then
		taskdata:AddOne("makefriend_smallbird")
	elseif prefab == "rocky" then
		taskdata:AddOne("makefriend_rocky")
	end
end
--天体门重生
local function OnReRoll(inst)
	local taskdata = inst.components.taskdata

end

local function OnInspirationdelta(inst, data)
    if inst.components.singinginspiration then
        local inspiration = inst.components.singinginspiration.current or 0
        local inspiration_max = inst.components.singinginspiration:GetMaxInspiration()

        if inst.components.combat ~= nil then
            local add = inspiration * 0.004
            inst.components.combat.externaldamagemultipliers:SetModifier("inspirate", 1 + add)
        end

        if inst.components.crit ~= nil then
            local add = (inspiration >= inspiration_max * 0.9) and inspiration_max * 0.1 or 0 
            inst.components.crit:AddExtraChance("inspirate", add*0.01)
        end
        
    end
end

--[[local function OnWorking(inst, data)
    if inst:HasTag("chopmaster") and data.target and data.target:HasTag("tree") then
        data.target.components.workable.workleft = 0
    end
end]]

--玩家事件
AddPlayerPostInit(function(inst)
	--只进行服务端事件监听
	if not _G.TheNet:GetIsClient() then
        --风滚草 
	    inst:ListenForEvent("tumbleweeddropped", OnTumbleweedDroped)
	    inst:ListenForEvent("tumbleweedpicked", OnTumbleweedPicked)

	    --eat
	    inst:ListenForEvent("oneat", OnEat)

	    --death
	    inst:ListenForEvent("death", OnDeath)

	    --kill
	    inst:ListenForEvent("killed", OnKilled)

	    --sleep
	    inst:ListenForEvent("wakeup", OnWakeup)

	    --着火
	    inst:ListenForEvent("onignite", OnFire)
	    --冰冻
	    inst:ListenForEvent("freeze", OnFreeze)
	    --催眠
	    inst:ListenForEvent("knockedout", OnKnockedout)
	    --fish
	    inst:ListenForEvent("fishingstrain", OnFish)
	    --pick
	    inst:ListenForEvent("picksomething", OnPick)
	    --砍树挖矿
	    inst:ListenForEvent("finishedwork", OnFinishedwork)
	    --复活
	    inst:ListenForEvent("respawnfromghost", OnRespawnfromghost)

	    --建造
	    inst:ListenForEvent("consumeingredients", OnConsume)
	    inst:ListenForEvent("builditem", OnBuildItem)
	    --种植
	    inst:ListenForEvent("deployitem", OnDeployItem)

	    --攻击
	    inst:ListenForEvent("attacked", OnAttacked)
	    inst:ListenForEvent("onhitother", OnHitOther)

	    --give
	    inst:ListenForEvent("givesomething", OnGiveSomething)
	    --cook
	    inst:ListenForEvent("docook", OnDoCook)
	    --follower
	    inst:ListenForEvent("addfollower", OnAddFollower)

	    --reroll
	    inst:ListenForEvent("ms_playerreroll", OnReRoll)

        --女武神激励值事件
        if inst.prefab == "wathgrithr" then
            inst:ListenForEvent("inspirationdelta", OnInspirationdelta)
        end

        --技能相关事件
        --不合适，无法触发完成工作条件
        --inst:ListenForEvent("working", OnWorking)
    end
	
end)