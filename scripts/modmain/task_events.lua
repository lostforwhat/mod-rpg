local _G = GLOBAL

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
    --print("lucky_level:"..(lucky_level or "nil"))
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
end

local function OnEat(inst, data)
	local food = data.food
	local feeder = data.feeder

end

local function OnDeath(inst, data)
	local attacker = inst.components.combat.lastattacker
	local cause = data.cause

end

local function OnKilled(inst, data)
	local victim = data.victim
    if victim == nil then return end

end	

local function OnWakeup(inst, data)

end
--着火
local function OnFire(inst)

end
--冰冻
local function OnFreeze(inst)

end
--催眠
local function OnKnockedout(inst)

end
--钓鱼
local function OnFish(inst, data)

end
--采集
local function OnPick(inst, data)
	if data.object and data.object.components.pickable and not data.object.components.trader then
		local item = data.object

	end
end

local function OnFinishedwork(inst, data)
	--砍树
	if data.target and data.target:HasTag("tree") then
        
    end
    --挖矿
    if data.target and 
    	(data.target:HasTag("boulder") or 
        data.target:HasTag("statue") or 
        findprefab(rocklist, data.target.prefab)) then
        
    end
end
--复活
local function OnRespawnfromghost(inst, data)
	local source = data.source

end
--建造
local function OnConsume(inst)

end
local function OnBuildItem(inst, data)
	if data.recipe ~= nil then
		local product = data.recipe.product

	end
end
--种植
local function OnDeployItem(inst, data)
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
        
    end
end
--攻击
local function OnAttacked(inst, data)
	local damage = data.damage or 0

end

local function OnHitOther(inst, data)
	if data.damage and data.damage >= 0 then
	    local target = data.target
	    local absorb = target.components.health and target.components.health.absorb or 0
	    local damage = data.damage * (1- math.clamp(absorb, 0, 1))

   end
end
--给予
local function OnGiveSomething(inst, data)

end
--天体门重生
local function OnReRoll(inst)

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

	    --reroll
	    inst:ListenForEvent("ms_playerreroll", OnReRoll)
    end
	
end)