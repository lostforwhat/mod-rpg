local assets =
{
	Asset("ANIM", "anim/coffeebush.zip"),
    Asset("IMAGE", "images/dug_coffeebush.tex"),
    Asset("ATLAS", "images/dug_coffeebush.xml"),
}

local prefabs =
{
	"coffeebean",
	"dug_coffeebush",
	--"peacock",
	"twigs",
}

local function ontransplantfn(inst)
	inst.components.pickable:MakeBarren()
end

local function pickanim(inst)
	if inst.components.pickable then
		if inst.components.pickable:CanBePicked() then
			local percent = 0
			if inst.components.pickable then
				percent = inst.components.pickable.cycles_left / inst.components.pickable.max_cycles
			end
			if percent >= .9 then
				return "berriesmost"
			elseif percent >= .33 then
				return "berriesmore"
			else
				return "berries"
			end
		else
			if inst.components.pickable:IsBarren() then
				return "idle_dead"
			else
				return "idle"
			end
		end
	end

	return "idle"
end

local function makefullfn(inst)
	inst.AnimState:PlayAnimation(pickanim(inst))
end

local function ontransplantfn(inst)
	inst.components.pickable:MakeBarren()
end

local function makeemptyfn(inst)
	if inst.components.pickable and inst.components.pickable.withered then
		inst.AnimState:PlayAnimation("dead_to_empty")
		inst.AnimState:PushAnimation("empty")
	else
		inst.AnimState:PlayAnimation("empty")
	end
end

local function makebarrenfn(inst)
	if inst.components.pickable and inst.components.pickable.withered then
		if not inst.components.pickable.hasbeenpicked then
			inst.AnimState:PlayAnimation("full_to_dead")
		else
			inst.AnimState:PlayAnimation("empty_to_dead")
		end
		inst.AnimState:PushAnimation("idle_dead")
	else
		inst.AnimState:PlayAnimation("idle_dead")
	end
end

local function pickberries(inst)
	if inst.components.pickable then
		local old_percent = (inst.components.pickable.cycles_left+1) / inst.components.pickable.max_cycles

		if old_percent >= .9 then
			inst.AnimState:PlayAnimation("berriesmost_picked")
		elseif old_percent >= .33 then
			inst.AnimState:PlayAnimation("berriesmore_picked")
		else
			inst.AnimState:PlayAnimation("berries_picked")
		end

		if inst.components.pickable:IsBarren() then
			inst.AnimState:PushAnimation("idle_dead")
		else
			inst.AnimState:PushAnimation("idle")
		end
	end	
end

local function onpickedfn(inst, picker)
	pickberries(inst)
	 
	 if inst.spawnsperd and picker and not picker:HasTag("berrythief") and math.random() < TUNING.PERD_SPAWNCHANCE then
	 	inst:DoTaskInTime(3+math.random()*3, spawnperd)
	 end
end

local function ongustpickfn(inst)
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		inst.components.pickable:MakeEmpty()
		inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
	end
end

local function getregentimefn(inst)
	if inst.components.pickable then
		local num_cycles_passed = math.min(inst.components.pickable.max_cycles - inst.components.pickable.cycles_left, 0)
		return TUNING.BERRY_REGROW_TIME + TUNING.BERRY_REGROW_INCREASE*num_cycles_passed+ math.random()*TUNING.BERRY_REGROW_VARIANCE
	else
		return TUNING.BERRY_REGROW_TIME
	end
	
end

local function digupcoffeebush(inst, chopper)	
	if inst.components.pickable and inst.components.lootdropper then
	
		if inst.components.pickable:IsBarren() or inst.components.pickable.withered then
			inst.components.lootdropper:SpawnLootPrefab("twigs")
			inst.components.lootdropper:SpawnLootPrefab("twigs")
		else
			
			if inst.components.pickable and inst.components.pickable:CanBePicked() then
				inst.components.lootdropper:SpawnLootPrefab("coffeebean")
			end
		
			inst.components.lootdropper:SpawnLootPrefab("dug_"..inst.prefab)
		end
	end	
	inst:Remove()
end

local function onload(inst, data)
	-- just from world gen really
	if data and data.makebarren then
		makebarrenfn(inst)
		inst.components.pickable:MakeBarren()
	end
end

local function shake(inst)
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		inst.AnimState:PlayAnimation("shake")
	else
		inst.AnimState:PlayAnimation("shake_empty")
	end
	inst.AnimState:PushAnimation(pickanim(inst), false)
end

local function fn()
	local inst = CreateEntity()

	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local minimap = inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst:AddTag("bush")
	inst:AddTag("plant")
	inst:AddTag("witherable")
	inst:AddTag("volcanic")

	inst.MiniMapEntity:SetIcon("coffeebush.png")
	inst.AnimState:SetBank("coffeebush")
	inst.AnimState:SetBuild("coffeebush")
	inst.AnimState:PlayAnimation("idle", true)
	
	MakeObstaclePhysics(inst, .1)

	MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"

	inst.components.pickable.getregentimefn = getregentimefn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makebarrenfn = makebarrenfn
	inst.components.pickable.makefullfn = makefullfn
	inst.components.pickable.ontransplantfn = ontransplantfn
	inst.components.pickable.max_cycles = TUNING.BERRYBUSH_CYCLES + math.random(2)
	inst.components.pickable.cycles_left = inst.components.pickable.max_cycles
	inst.spawnsperd = true
	local variance = math.random() * 4 - 2
	--inst.makewitherabletask = inst:DoTaskInTime(TUNING.WITHER_BUFFER_TIME + variance, function(inst) inst.components.pickable:MakeWitherable() end)
	inst:AddComponent("witherable")

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.DIG)
	inst.components.workable:SetWorkLeft(1)

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "berrybush"

	-- inst:AddComponent("blowinwindgust")
	-- inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.BERRYBUSH_WINDBLOWN_SPEED)
	-- inst.components.blowinwindgust:SetDestroyChance(TUNING.BERRYBUSH_WINDBLOWN_FALL_CHANCE)
	-- inst.components.blowinwindgust:SetDestroyFn(ongustpickfn)
	-- inst.components.blowinwindgust:Start()

	inst:ListenForEvent("onwenthome", shake)
	MakeSnowCovered(inst, .01)
	MakeNoGrowInWinter(inst)
	--master_postinit(inst)

	inst.components.workable:SetOnFinishCallback(digupcoffeebush)
	inst.components.inspectable.nameoverride = "coffeebush"

	inst.components.pickable:SetUp("coffeebean", TUNING.BERRY_REGROW_TIME)
	--inst.components.pickable:SetReverseSeasons(true)
	inst.spawnsperd = false 
	inst:AddTag("fire_proof")

	inst.OnLoad = onload

	return inst

end

local function ondeploy(inst, pt, deployer)
    local tree = SpawnPrefab("coffeebush")
    if tree ~= nil then
        tree.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        if tree.components.pickable ~= nil then
            tree.components.pickable:OnTransplant()
        end
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            --V2C: WHY?!! because many of the plantables don't
            --     have SoundEmitter, and we don't want to add
            --     one just for this sound!
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function dug_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    --inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("deployedplant")

    inst.AnimState:SetBank("coffeebush")
    inst.AnimState:SetBuild("coffeebush")
    inst.AnimState:PlayAnimation("dropped")

    MakeInventoryFloatable(inst)


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "dug_coffeebush"
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/dug_coffeebush.xml"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("deployable")
    --inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)

    ---------------------
    return inst
end

return Prefab("coffeebush", fn, assets, prefabs),
	Prefab("dug_coffeebush", dug_fn, assets, prefabs),
	MakePlacer("dug_coffeebush_placer", "coffeebush", "coffeebush", "idle")