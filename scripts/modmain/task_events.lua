require "utils/utils"
local _G = GLOBAL
local TheNet = _G.TheNet
local ExistInTable = _G.ExistInTable
local HttpGet = _G.HttpGet
local ACTIONS = _G.ACTIONS
local SpawnPrefab = _G.SpawnPrefab

local function GiveExp(inst, exp)
    --预留插槽，用于提升或减少额外经验等
    if inst:HasTag("doublexp") or _G.TheWorld:HasTag("doublexp") then
        exp = exp * 2
    end

    if inst:HasTag("leisurely") then
        exp = exp * 1.1
    end

    local viplevel = inst.components.vip and inst.components.vip.level or 0
    if viplevel > 0 then
        exp = exp * 1.2 + math.log10(viplevel) * .25
    end

    exp = math.floor(exp)
    if exp > 0 and inst.components.level then
        inst.components.level:AddXp(exp)
    end
end

local function OnTumbleweedDroped(inst, data)
    local taskdata = inst.components.taskdata   
	local item = data.item
    if not item:HasTag("monster") and item.components.combat == nil then
        taskdata:AddOne("pick_tumbleweed_gift_50")

        if inst.components.luck then
            inst.components.luck:DoDelta(math.random(0,5)-4)
        end
    end
end

local function OnTumbleweedPicked(inst, data)
	local taskdata = inst.components.taskdata	
    local level = data.level
    
    taskdata:AddOne("pick_one_tumbleweed")
    taskdata:AddOne("pick_tumbleweed_88")
    taskdata:AddOne("pick_tumbleweed_288")
    taskdata:AddOne("pick_tumbleweed_888")
    taskdata:AddOne("pick_tumbleweed_2888")
    taskdata:AddOne("pick_tumbleweed_6666")
    if level ~= nil then
        if level == 1 then
            taskdata:AddOne("pick_tumbleweed_red_100")
        elseif level == 2 then
            taskdata:AddOne("pick_tumbleweed_yellow_60")
        elseif level == 3 then
            taskdata:AddOne("pick_tumbleweed_light_30")
        elseif level == -1 then
            taskdata:AddOne("pick_tumbleweed_green_120")
        elseif level == -2 then
            taskdata:AddOne("pick_tumbleweed_blue_60")
        end
    end
    taskdata.tumbleweednum = taskdata.tumbleweednum + 1

    GiveExp(inst, math.random(1, 5))

    if _G.TheWorld:HasTag("pick_tumbleweed_aoe") then
        local target = data.target
        if target ~= nil and not inst.picking then
            inst.picking = true
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x,y,z, 5)
            for k,v in pairs(ents) do
                if v.prefab == "tumbleweed" and v~=target and v.onpickup then
                    v:onpickup(inst)
                end
            end
            inst.picking = nil
        end
    end
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

    --[[if food.components.edible then
        local hunger_val = food.components.edible:GetHunger(inst)
        local sanity_val = food.components.edible:GetSanity(inst)
        local health_val = food.components.edible:GetHealth(inst)
        GiveExp(inst, hunger_val*0.05 + sanity_val*0.12 + health_val*0.1)
    end]] -- 已注入组件中
end

local function OnDeath(inst, data)
	local attacker = inst.components.combat.lastattacker
	local cause = data.cause
	local taskdata = inst.components.taskdata
    
    --死亡计数
    if inst.components.level ~= nil then
        inst.components.level.deathtimes = inst.components.level.deathtimes + 1
    end

    --死亡惩罚, 使用自带复活时惩罚
    --[[if inst.components.level then
        inst.components.level:ReduceXpOnDeath()
    end]]

    --特殊称号死亡掉落
    if inst.components.titles ~= nil and inst.components.titles.special then
        inst.components.titles.special = false
        if inst.components.titles.equip == "fly" then
            inst.components.titles:UnEquip("fly")
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        local item = _G.SpawnPrefab("titles_fly_item")
        item.Transform:SetPosition(x, y, z)
    end
end

local function IsValidVictim(victim)
    return victim ~= nil
        and not (victim:HasTag("wall") or victim:HasTag("balloon"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
end

local function OnKilled(inst, data)
	local victim = data.victim
    if not IsValidVictim(victim) then return end
    local taskdata = inst.components.taskdata
    if taskdata.killed_temp[victim] then
    	return
    end
    taskdata.killed_temp[victim] = true
    inst:DoTaskInTime(1, function()
        taskdata.killed_temp[victim] = nil
    end)

    if victim:HasTag("monster") then
	    taskdata:AddOne("kill_100")
	    taskdata:AddOne("kill_1000")
        taskdata:AddOne("kill_9999")
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
    local boss_list = {"moose", "dragonfly", "bearger", "deerclops",
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
    	elseif prefab == "bearger" then
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
    	elseif prefab == "klaus" and victim:IsUnchained() then
    		for k, v in pairs(ents) do
    			v.components.taskdata:AddOne("kill_klaus")
    		end
            if victim.enraged then
                taskdata:AddOne("kill_klaus_rage")
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
        if not (prefab == "klaus" and not victim:IsUnchained()) then
            taskdata:AddOne("kill_boss_100")
            --taskdata.killboss = taskdata.killboss + 1
            taskdata:KillBoss()
        end

        local health = victim.components.health.maxhealth or 0
        local num = #ents
        for k, v in pairs(ents) do
            GiveExp(v, math.floor((health/num)*0.02))
        end
    else
        local health = victim.components.health.maxhealth or 0
        GiveExp(inst, math.floor(health*0.02))
    end
    
    --击杀掉落事件
    if inst:HasTag("cleverhands") and math.random() < 0.05 then
        if not (prefab == "stalker" 
            or prefab == "stalker_atrium" 
            or prefab == "stalker_forest")
            and victim.components.lootdropper ~= nil then
                victim.components.lootdropper:DropLoot()
        end
    end

    --非pvp击杀玩家，给予惩罚
    if not TheNet:GetPVPEnabled() and victim:HasTag("player") then
        inst.components.luck:SetLuck(0)
        inst.components.level:ReduceXp(100)
        inst.components.level:AddKillPlayer()
    end

    if inst:HasTag("lifeforever") then
        local health = victim.components.health and victim.components.health.maxhealth or 0
        inst.components.health:DoDelta(health * 0.02)
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
		elseif string.find(prefab, "mushroom") then
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

        --添加双倍采集逻辑
        if data.loot ~= nil and inst:HasTag("doublepicker") then
            if loot.components.stackable ~= nil then
                local num = loot.components.stackable:StackSize() or 1
                loot.components.stackable:SetStackSize(num * 2)
            else
                local new_loot = SpawnPrefab(loot.prefab)
                if new_loot.components.inventoryitem ~= nil then
                    new_loot.components.inventoryitem:InheritMoisture(_G.TheWorld.state.wetness, _G.TheWorld.state.iswet)
                end
                inst.components.inventory:GiveItem(new_loot, nil, item:GetPosition())
            end
        end
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
	local source = data and data.source or nil
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
    local product = data.product
    if product == "butterflymuffin" then
        taskdata:AddOne("cook_butterflymuffin_5")
    end
    if product == "frogglebunwich" then
        taskdata:AddOne("cook_frogglebunwich_5")
    end
    if product == "taffy" then
        taskdata:AddOne("cook_taffy_5")
    end
    if product == "pumpkincookie" then
        taskdata:AddOne("cook_pumpkincookie_5")
    end
    if product == "stuffedeggplant" then
        taskdata:AddOne("cook_stuffedeggplant_5")
    end
    if product == "fishsticks" then
        taskdata:AddOne("cook_fishsticks_5")
    end
    if product == "honeynuggets" then
        taskdata:AddOne("cook_honeynuggets_5")
    end
    if product == "honeyham" then
        taskdata:AddOne("cook_honeyham_5")
    end
    if product == "dragonpie" then
        taskdata:AddOne("cook_dragonpie_5")
    end
    if product == "kabobs" then
        taskdata:AddOne("cook_kabobs_5")
    end
    if product == "mandrakesoup" then
        taskdata:AddOne("cook_mandrakesoup_2")
    end
    if product == "baconeggs" then
        taskdata:AddOne("cook_baconeggs_5")
    end
    if product == "perogies" then
        taskdata:AddOne("cook_perogies_5")
    end
    if product == "turkeydinner" then
        taskdata:AddOne("cook_turkeydinner_5")
    end
    if product == "jammypreserves" then
        taskdata:AddOne("cook_jammypreserves_5")
    end
    if product == "fruitmedley" then
        taskdata:AddOne("cook_fruitmedley_5")
    end
    if product == "fishtacos" then
        taskdata:AddOne("cook_fishtacos_5")
    end
    if product == "waffles" then
        taskdata:AddOne("cook_waffles_5")
    end
    if product == "unagi" then
        taskdata:AddOne("cook_unagi_10")
    end
    if product == "flowersalad" then
        taskdata:AddOne("cook_flowersalad_10")
    end
    if product == "icecream" then
        taskdata:AddOne("cook_icecream_5")
    end
    if product == "watermelonicle" then
        taskdata:AddOne("cook_watermelonicle_5")
    end
    if product == "trailmix" then
        taskdata:AddOne("cook_trailmix_5")
    end
    if product == "hotchili" then
        taskdata:AddOne("cook_hotchili_5")
    end
    if product == "bananapop" then
        taskdata:AddOne("cook_bananapop_5")
    end
    if product == "guacamole" then
        taskdata:AddOne("cook_guacamole_10")
    end

    GiveExp(inst, 1)
end
--addfollower
local function OnAddFollower(inst, data)
	local taskdata = inst.components.taskdata
	local follower = data.follower
	local prefab = follower.prefab or ""
	if prefab == "pigman" then
		taskdata:AddOne("makefriend_pigman")
	elseif prefab == "bunnyman" then
		taskdata:AddOne("makefriend_bunnyman")
	elseif prefab == "catcoon" then
		taskdata:AddOne("makefriend_catcoon")
	elseif string.find(prefab, "spider") then
		taskdata:AddOne("makefriend_spider")
	elseif prefab == "mandrake_active" then
		if not _G.TheWorld.state.isday then
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

        if inst.components.skilldata ~= nil then
            local level = inst.components.skilldata:GetLevel("inspirate")
            local step = inst.components.skilldata.skills["inspirate"] and inst.components.skilldata.skills["inspirate"].step or 0

            if inst.components.combat ~= nil then
                local add = inspiration * (0.004 + level * step)
                inst.components.combat.externaldamagemultipliers:SetModifier("inspirate", 1 + add)
            end

            if inst.components.crit ~= nil then
                local add = (inspiration >= inspiration_max * 0.9) and (inspiration_max * 0.1 + level) or 0 
                inst.components.crit:AddExtraChance("inspirate", add*0.01)
            end
        end
        
    end
end

--[[local function OnWorking(inst, data)
    if inst:HasTag("chopmaster") and data.target and data.target:HasTag("tree") then
        data.target.components.workable.workleft = 0
    end
end]]


local function OnSoulhop(inst)
    if inst.components.skilldata and inst.components.skilldata.superjump > 0 then
        local level = inst.components.skilldata:GetLevel("superjump")
        local step = inst.components.skilldata.skills["superjump"] and inst.components.skilldata.skills["superjump"].step or 0
        
        if inst.components.groundpounder then
            local ringadd = math.floor(level * step)
            inst.components.groundpounder.damageRings = 2 + ringadd
            inst.components.groundpounder.destructionRings = 2 + ringadd
            inst.components.groundpounder.platformPushingRings = 2 + ringadd
            inst.components.groundpounder.numRings = 3 + ringadd
            --inst.components.groundpounder.initialRadius = 1 + level*step
            inst.components.groundpounder.groundpounddamagemult = 1 + level * step
            inst.components.groundpounder:GroundPound()
        end
    end
end

local function OnMoisture(inst, data)
    if inst.components.skilldata and inst.components.skilldata["smoothskin"] > 0
        and inst.components.dodge then
        local moisture = inst.components.moisture and inst.components.moisture.moisture or 0
        local level = inst.components.skilldata:GetLevel("smoothskin")
        local miss = math.clamp(moisture * (0.2 +  0.02 * level), 0, 20 + level)
        inst.components.dodge:SetChance(miss * 0.01)
    end
end

local function OnMinHealth(inst, data)

end

local function OnTaskCompleted(inst, data)
    if inst.components.titles then
        inst.components.titles:CheckAll()
    end
end

local function OnCycles(inst)
    if inst.components.titles then
        inst.components.titles:CheckAll()
    end
end

local function OnCollectTask(inst, data)
    if inst.components.taskdata ~= nil then
        inst.components.taskdata:AddOne("collect_30")
        inst.components.taskdata:AddOne("collect_300")
    end
end

local function OnWeaponStrengthen(inst, data)
    if inst.components.taskdata ~= nil then
        inst.components.taskdata:AddOne("strength_10")
        inst.components.taskdata:AddOne("strength_100")
        if data.level ~= nil and data.level >= 10 then
            inst.components.taskdata:AddOne("strength_level_10")
        end
        if data.level ~= nil and data.level >= 20 then
            inst.components.taskdata:AddOne("strength_level_20")
        end
    end
end

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

        --恶魔跳跃
        inst:ListenForEvent("soulhop", OnSoulhop)

        --潮湿度
        inst:ListenForEvent("moisturedelta", OnMoisture)

        --空血事件(回光返照已有组件代替)
        --inst:ListenForEvent("minhealth", OnMinHealth)

        inst:ListenForEvent("completecollect", OnCollectTask)

        inst:ListenForEvent("weaponstrengthen", OnWeaponStrengthen)

        --监听任务完成事件
        inst:ListenForEvent("taskcompleted", OnTaskCompleted)

        --世界天数改变
        inst:WatchWorldState("cycles", OnCycles)
    end
	
end)


local function OnEntityDropLoot(world, data)
    local inst = data.inst
    if inst == nil then
        return
    end
    if inst.prefab == "stalker_atrium" and not inst:IsNearAtrium() then
        return
    end
    if inst.prefab == "stalker" or inst.prefab == "stalker_forest" then
        return
    end

    if inst:HasTag("rpg_holiday") then
        if inst:HasTag("epic") then
            if math.random() < 0.5 then
                inst.components.lootdropper:SpawnLootPrefab("skillbook_1")
            end
            if math.random() < 0.04 then
                inst.components.lootdropper:SpawnLootPrefab("skillbook_2")
            end
            if math.random() < 0.5 then
                inst.components.lootdropper:SpawnLootPrefab("diamond")
            end
            if math.random() < 0.5 then
                inst.components.lootdropper:SpawnLootPrefab("diamond")
            end
            if math.random() < 0.5 then
                inst.components.lootdropper:SpawnLootPrefab("diamond")
            end
            if math.random() < 0.5 then
                inst.components.lootdropper:SpawnLootPrefab("diamond")
            end
            if math.random() < 0.5 then
                inst.components.lootdropper:SpawnLootPrefab("diamond")
            end

            if inst.components.health ~= nil and inst.components.health.maxhealth >= 12000 then
                if math.random() < 0.05 then
                    inst.components.lootdropper:SpawnLootPrefab("timerhat")
                elseif math.random() < 0.05 then
                    inst.components.lootdropper:SpawnLootPrefab("linghterhat")
                elseif math.random() < 0.05 then
                    inst.components.lootdropper:SpawnLootPrefab("armorlinghter")
                elseif math.random() < 0.05 then
                    inst.components.lootdropper:SpawnLootPrefab("armordebroglie")
                end
            end
        else
            if math.random() < 0.1 then
                inst.components.lootdropper:SpawnLootPrefab("skillbookpage")
            end
            if math.random() < 0.02 then
                inst.components.lootdropper:SpawnLootPrefab("diamond")
            end
        end
    end

    if inst:HasTag("epic") then --大型boss
        local loot = {}
        if math.random() < 0.01 then
            table.insert(loot, "pray_symbol")
        end
        if math.random() < 0.05 then
            table.insert(loot, "potion_achiv")
        end
        if math.random() < 0.01 then
            table.insert(loot, "potion_blue")
        end
        if math.random() < 0.01 then
            table.insert(loot, "potion_green")
        end
        if math.random() < 0.01 then
            table.insert(loot, "potion_lucky")
        end
        if math.random() < 0.01 then
            table.insert(loot, "skillbookpage")
        end
        if inst.prefab == "klaus" then
            if inst.enraged then
                table.insert(loot, "pray_symbol")
                table.insert(loot, "pray_symbol")
                table.insert(loot, "pray_symbol")
                table.insert(loot, "package_staff")
                table.insert(loot, "skillbook")
            end
        end
        if #loot > 0 then
            inst.components.lootdropper:SpawnLootPrefab(loot[math.random(#loot)])
        end
    else
        if inst.prefab == "little_walrus" and math.random() < 0.15 then
            inst.components.lootdropper:SpawnLootPrefab("pray_symbol")
        end
        if inst.prefab == "krampus" and math.random() < 0.003 then
            inst.components.lootdropper:SpawnLootPrefab("stealer_skillbook")
        end
    end
end

local function GetItemForStart(player)
    local serversession = _G.TheWorld.net.components.shardstate:GetMasterSessionId()
    HttpGet("/public/checkFirstGift?serversession="..serversession.."&userid="..player.userid, function(result, isSuccessful, resultCode)
        if isSuccessful and (resultCode == 200) then
            print("-- checkFirstGift success--")
            if player.components.email ~= nil then
                player.components.email:GetEmailsFromServer()
            end
        else
            print("-- GetGoods failed! ERROR:"..result.."--")
        end
    end)
end

local function OnPlayerSpawn(world, player)
    local OldOnNewSpawn = player.OnNewSpawn or function() return true end
    player.OnNewSpawn = function(...)
        GetItemForStart(player)
        --夜晚
        if _G.TheWorld.state.isnight or (_G.TheWorld.state.isdusk and _G.TheWorld.state.timeinphase > .8) then
            player.components.inventory:GiveItem(_G.SpawnPrefab("torch"))
        end
        
        return OldOnNewSpawn(...)
    end
end

local function OnPlayerDespawn(world, player)
    if player.components.titles ~= nil and player.components.titles.special then
        player.components.titles.special = false
        if player.components.titles.equip == "fly" then
            player.components.titles:UnEquip("fly")
        end

        local x, y, z = player.Transform:GetWorldPosition()
        local item = _G.SpawnPrefab("titles_fly_item")
        item.Transform:SetPosition(x, y, z)
    end
end

--world 事件
AddPrefabPostInit(
    "world",
    function(inst)
        -- 新添加物品掉落
        inst:ListenForEvent("entity_droploot", OnEntityDropLoot)
        -- 新人礼包
        inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn)
        inst:ListenForEvent("ms_playerdespawn", OnPlayerDespawn)
    end
)