local easing = require("easing")
require("modmain/loot_table")

local AVERAGE_WALK_SPEED = 4
local WALK_SPEED_VARIATION = 2
local SPEED_VAR_INTERVAL = .5
local ANGLE_VARIANCE = 10

local colors = {
    [3] = {1,1,0.5,1},
    [2] = {1,1,0,1},
    [1] = {1,0.1,0.6,1},
    [-1] = {0.2,0.8,0.2,1},
    [-2] = {0,0,1,1},
    [0] = {1,1,1,1},
}

local assets =
{
    Asset("ANIM", "anim/tumbleweed.zip"),
}

local prefabs =
{
    "splash_ocean",
    "tumbleweedbreakfx",
    "ash",
    "cutgrass",
    "twigs",
    "petals",
    "foliage",
    "silk",
    "rope",
    "seeds",
    "purplegem",
    "bluegem",
    "redgem",
    "orangegem",
    "yellowgem",
    "greengem",
    "seeds",
    "trinket_6",
    "cutreeds",
    "feather_crow",
    "feather_robin",
    "feather_robin_winter",
    "feather_canary",
    "trinket_3",
    "beefalowool",
    "rabbit",
    "mole",
    "butterflywings",
    "fireflies",
    "beardhair",
    "berries",
    "TOOLS_blueprint",
    "LIGHT_blueprint",
    "SURVIVAL_blueprint",
    "FARM_blueprint",
    "SCIENCE_blueprint",
    "WAR_blueprint",
    "TOWN_blueprint",
    "REFINE_blueprint",
    "MAGIC_blueprint",
    "DRESS_blueprint",
    "petals_evil",
    "trinket_8",
    "houndstooth",
    "stinger",
    "gears",
    "spider",
    "frog",
    "bee",
    "mosquito",
    "boneshard",
}

local CHESS_LOOT =
{
    "chesspiece_pawn_sketch",
    "chesspiece_muse_sketch",
    "chesspiece_formal_sketch",
    "trinket_15", --bishop
    "trinket_16", --bishop
    "trinket_28", --rook
    "trinket_29", --rook
    "trinket_30", --knight
    "trinket_31", --knight
}

for k, v in ipairs(CHESS_LOOT) do
    table.insert(prefabs, v)
end

local SFX_COOLDOWN = 5

local function onplayerprox(inst)
    if not inst.last_prox_sfx_time or (GetTime() - inst.last_prox_sfx_time > SFX_COOLDOWN) then
       inst.last_prox_sfx_time = GetTime()
       inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_choir")
    end
end

local function CheckGround(inst)
    if not inst:IsOnValidGround() then
        SpawnPrefab("splash_ocean").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:PushEvent("detachchild")
        inst:Remove()
    end
end

local function startmoving(inst)
    inst.AnimState:PushAnimation("move_loop", true)
    inst.bouncepretask = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncetask = inst:DoPeriodicTask(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
            CheckGround(inst)
        end)
    end)
    inst.components.blowinwind:Start()
    inst:RemoveEventCallback("animover", startmoving)
end

local function needNotice(goods)
    local notice_goods = notice_goods or {}
    for i, v in ipairs(notice_goods) do
        if goods == v then 
            return true
        end
    end
    return false
end

local function onpickup(inst, picker)
    --添加多世界宣告支持
    local picker_name = picker and picker:GetDisplayName() or "???"
    local function resetNotice(...)
        local worldShardId = TheShard:GetShardId()
        local serverName = ""
        if worldShardId ~= nil and worldShardId ~= "0" then
            serverName = "[" .. STRINGS.TUM.WORLD .. worldShardId .. "] "
        end
        local msg = picker_name .. STRINGS.TUM.PICKTUMBLEWEED
        for k ,v in pairs({...}) do
            msg = msg .. " " .. v
        end
        TheNet:Announce(serverName .. msg)
    end
    local x, y, z = inst.Transform:GetWorldPosition()

    inst:PushEvent("detachchild")

	if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
		if math.random() < TUNING.HALLOWEEN_ORNAMENT_TUMBLEWEED_CHANCE then
            table.insert(inst.loot, "halloween_ornament_" ..tostring(math.random(NUM_HALLOWEEN_ORNAMENTS)))
            table.insert(inst.lootaggro, false)
		end
	end

    TheWorld:PushEvent("tumbleweedpicked", {target=inst, picker=picker})
    picker:PushEvent("tumbleweedpicked", {target=inst, level = inst.level or 0})

    local item = nil
    for i, v in ipairs(inst.loot) do
        if PrefabExists(v) then
            item = SpawnPrefab(v)
            item.Transform:SetPosition(x, y, z)
            if item.components.inventoryitem ~= nil and item.components.inventoryitem.ondropfn ~= nil then
                item.components.inventoryitem.ondropfn(item)
            end
            if inst.lootaggro[i] and item.components.combat ~= nil and picker ~= nil then
                if not (item:HasTag("spider") and (picker:HasTag("spiderwhisperer") or picker:HasTag("spiderdisguise") or (picker:HasTag("monster") and not picker:HasTag("player")))) then
                    item.components.combat:SuggestTarget(picker)
                end
            end
            local item_name = item:GetDisplayName()
            if needNotice(v) then
                resetNotice(item_name)
                picker:PushEvent("tumbleweeddropped", {item = item})
            end
            item:AddTag("tumbleweeddropped")
        end
    end

    SpawnPrefab("tumbleweedbreakfx").Transform:SetPosition(x, y, z)
    inst:Remove()
    return true --This makes the inventoryitem component not actually give the tumbleweed to the player
end


local function MakeLoot(inst)
    local possible_loot =
    {
        {chance = 20,   item = "cutgrass"},
        {chance = 15,   item = "twigs"},
        {chance = 1,    item = "petals"},
        {chance = 1,    item = "foliage"},
        {chance = 1,    item = "silk"},
        {chance = 1,    item = "rope"},
        {chance = 2,    item = "seeds"},
        {chance = 0.01, item = "purplegem"},
        {chance = 0.04, item = "bluegem"},
        {chance = 0.02, item = "redgem"},
        {chance = 0.02, item = "orangegem"},
        {chance = 0.01, item = "yellowgem"},
        {chance = 0.02, item = "greengem"},
        {chance = 0.5,  item = "trinket_6"},
        {chance = 0.5,  item = "trinket_4"},
        {chance = 1,    item = "cutreeds"},
        {chance = 0.33, item = "feather_crow"},
        {chance = 0.33, item = "feather_robin"},
        {chance = 0.33, item = "feather_robin_winter"},
        {chance = 0.33, item = "feather_canary"},
        {chance = 1,    item = "trinket_3"},
        {chance = 1,    item = "beefalowool"},
        {chance = 0.1,  item = "rabbit"},
        {chance = 0.1,  item = "mole"},
        {chance = 0.1,  item = "spider", aggro = true},
        {chance = 0.1,  item = "frog", aggro = true},
        {chance = 0.1,  item = "bee", aggro = true},
        {chance = 0.1,  item = "mosquito", aggro = true},
        {chance = 1,    item = "butterflywings"},
        {chance = .02,  item = "beardhair"},
        {chance = 1,    item = "berries"},
        {chance = 0.1,    item = "TOOLS_blueprint"},
        {chance = 0.1,    item = "LIGHT_blueprint"},
        {chance = 0.1,    item = "SURVIVAL_blueprint"},
        {chance = 0.1,    item = "FARM_blueprint"},
        {chance = 0.1,    item = "SCIENCE_blueprint"},
        {chance = 0.1,    item = "WAR_blueprint"},
        {chance = 0.1,    item = "TOWN_blueprint"},
        {chance = 0.1,    item = "REFINE_blueprint"},
        {chance = 0.1,    item = "MAGIC_blueprint"},
        {chance = 0.1,    item = "DRESS_blueprint"},
        {chance = 1,    item = "petals_evil"},
        {chance = 1,    item = "trinket_8"},
        {chance = 1,    item = "houndstooth"},
        {chance = 1,    item = "stinger"},
        {chance = 1,    item = "gears"},
        {chance = 0.1,  item = "boneshard"}, 
    }


    local chessunlocks = TheWorld.components.chessunlocks
    if chessunlocks ~= nil then
        for i, v in ipairs(CHESS_LOOT) do
            if not chessunlocks:IsLocked(v) then
                table.insert(possible_loot, { chance = .1, item = v })
            end
        end
    end

    local level = inst.level or 0
    if level == 0 then
        for a,b in ipairs(loot_table.new_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.good_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.luck_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.bad_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.monstor_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.big_boss_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
    elseif level == 1 then
        for a,b in ipairs(loot_table.new_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.good_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.luck_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
    elseif level == 2 then
        for a,b in ipairs(loot_table.good_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.luck_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
    elseif level == 3 then
        possible_loot = deepcopy(loot_table.luck_loot) --此处一个深坑
    elseif level == -1 then
        for a,b in ipairs(loot_table.bad_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.monstor_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.big_boss_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
    elseif level == -2 then
        possible_loot = deepcopy(loot_table.monstor_loot)
        for a,b in ipairs(loot_table.monstor_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
        for a,b in ipairs(loot_table.big_boss_loot) do
            if b.chance > 0 then
                table.insert(possible_loot, b)
            end
        end
    end

    local totalchance = 0
    for m, n in ipairs(possible_loot) do
        totalchance = totalchance + n.chance
    end

    inst.loot = {}
    inst.lootaggro = {}
    local next_loot = nil
    local next_aggro = nil
    local next_chance = nil
    local num_loots = math.floor(math.random()*2) --根据风滚草颜色固定对应等级1种物品
    while num_loots > 0 do
        next_chance = math.random()*totalchance
        next_loot = nil
        next_aggro = nil
        for m, n in ipairs(possible_loot) do
            next_chance = next_chance - n.chance
            if next_chance <= 0 then
                next_loot = n.item
                if n.aggro then next_aggro = true end
                break
            end
        end
        if next_loot ~= nil then
            table.insert(inst.loot, next_loot)
            if next_aggro then 
                table.insert(inst.lootaggro, true)
            else
                table.insert(inst.lootaggro, false)
            end
            num_loots = num_loots - 1
        end
    end
end

local function DoDirectionChange(inst, data)

    if not inst.entity:IsAwake() then return end

    if data and data.angle and data.velocity and inst.components.blowinwind then
        if inst.angle == nil then
            inst.angle = math.clamp(GetRandomWithVariance(data.angle, ANGLE_VARIANCE), 0, 360)
            inst.components.blowinwind:Start(inst.angle, data.velocity)
        else
            inst.angle = math.clamp(GetRandomWithVariance(data.angle, ANGLE_VARIANCE), 0, 360)
            inst.components.blowinwind:ChangeDirection(inst.angle, data.velocity)
        end
    end
end

local function spawnash(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local ash = SpawnPrefab("ash")
    ash.Transform:SetPosition(x, y, z)

    if inst.components.stackable ~= nil then
        ash.components.stackable.stacksize = math.min(ash.components.stackable.maxsize, inst.components.stackable.stacksize)
    end

    inst:PushEvent("detachchild")
    SpawnPrefab("tumbleweedbreakfx").Transform:SetPosition(x, y, z)
    inst:Remove()
end

local function onburnt(inst)
    inst:PushEvent("detachchild")
    inst:AddTag("burnt")

    inst.components.pickable.canbepicked = false
    inst.components.propagator:StopSpreading()

    inst.Physics:Stop()
    inst.components.blowinwind:Stop()
    inst:RemoveEventCallback("animover", startmoving)

    if inst.bouncepretask then
        inst.bouncepretask:Cancel()
        inst.bouncepretask = nil
    end
    if inst.bouncetask then
        inst.bouncetask:Cancel()
        inst.bouncetask = nil
    end
    if inst.restartmovementtask then
        inst.restartmovementtask:Cancel()
        inst.restartmovementtask = nil
    end
    if inst.bouncepst1 then
        inst.bouncepst1:Cancel()
        inst.bouncepst1 = nil
    end
    if inst.bouncepst2 then
        inst.bouncepst2:Cancel()
        inst.bouncepst2 = nil
    end

    inst.AnimState:PlayAnimation("move_pst")
    inst.AnimState:PushAnimation("idle")
    inst.bouncepst1 = inst:DoTaskInTime(4*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst1 = nil
    end)
    inst.bouncepst2 = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst2 = nil
    end)

    inst:DoTaskInTime(1.2, spawnash)
end

local function OnSave(inst, data)
    data.burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") or nil
    data.level = inst.level or 0
end

local function OnLoad(inst, data)
    if data ~= nil and data.burnt then
        onburnt(inst)
    end
    if data ~= nil and data.level ~= nil then
        local level = data.level
        inst.level = level
        if inst.components.colourtweener == nil then
            inst:AddComponent("colourtweener")
        end
        inst.components.colourtweener:StartTween(colors[level], 0)
        if inst.components.named == nil then
            inst:AddComponent("named")
        end
        inst.components.named:SetName(STRINGS.NAMES["TUMBLEWEED_"..(level+2)])
        inst.Light:Enable(level == 3)
        MakeLoot(inst)
    end
end

local function CancelRunningTasks(inst)
    if inst.bouncepretask then
       inst.bouncepretask:Cancel()
        inst.bouncepretask = nil
    end
    if inst.bouncetask then
        inst.bouncetask:Cancel()
        inst.bouncetask = nil
    end
    if inst.restartmovementtask then
        inst.restartmovementtask:Cancel()
        inst.restartmovementtask = nil
    end
    if inst.bouncepst1 then
       inst.bouncepst1:Cancel()
        inst.bouncepst1 = nil
    end
    if inst.bouncepst2 then
        inst.bouncepst2:Cancel()
        inst.bouncepst2 = nil
    end
end

local function OnEntityWake(inst)
    inst.AnimState:PlayAnimation("move_loop", true)
    inst.bouncepretask = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncetask = inst:DoPeriodicTask(24*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
            CheckGround(inst)
        end)
    end)
end

local function OnLongAction(inst)
    inst.Physics:Stop()
    inst.components.blowinwind:Stop()
    inst:RemoveEventCallback("animover", startmoving)

    CancelRunningTasks(inst)

    inst.AnimState:PlayAnimation("move_pst")
    inst.bouncepst1 = inst:DoTaskInTime(4*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst1 = nil
    end)
    inst.bouncepst2 = inst:DoTaskInTime(10*FRAMES, function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/tumbleweed_bounce")
        inst.bouncepst2 = nil
    end)
    inst.AnimState:PushAnimation("idle", true)
    inst.restartmovementtask = inst:DoTaskInTime(math.random(2,6), function(inst)
        if inst and inst.components.blowinwind then
            inst.AnimState:PlayAnimation("move_pre")
            inst.restartmovementtask = nil
            inst:ListenForEvent("animover", startmoving)
        end
    end)
end

local function burntfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBuild("tumbleweed")
    inst.AnimState:SetBank("tumbleweed")
    inst.AnimState:PlayAnimation("break")

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    inst:ListenForEvent("animover", inst.Remove)
    -- In case we're off screen and animation is asleep
    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + FRAMES, inst.Remove)

    return inst
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()
    inst.DynamicShadow:SetSize(1.7, .8)

    inst.AnimState:SetBuild("tumbleweed")
    inst.AnimState:SetBank("tumbleweed")
    inst.AnimState:PlayAnimation("move_loop", true)

    MakeCharacterPhysics(inst, .5, 1)

    inst.Light:SetIntensity(.8)
    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(.3)
    inst.Light:Enable(false)
    inst.Light:SetColour(180 / 255, 195 / 255, 225 / 255)

    --inst:AddTag("_named")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    --inst:RemoveTag("_named")
    --inst:AddComponent("colourtweener")

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetTriggersCreep(false)

    inst:AddComponent("blowinwind")
    inst.components.blowinwind.soundPath = "dontstarve_DLC001/common/tumbleweed_roll"
    inst.components.blowinwind.soundName = "tumbleweed_roll"
    inst.components.blowinwind.soundParameter = "speed"
    inst.angle = (TheWorld and TheWorld.components.worldwind) and TheWorld.components.worldwind:GetWindAngle() or nil
    inst:ListenForEvent("windchange", function(world, data)
        DoDirectionChange(inst, data)
    end, TheWorld)
    if inst.angle ~= nil then
        inst.angle = math.clamp(GetRandomWithVariance(inst.angle, ANGLE_VARIANCE), 0, 360)
        inst.components.blowinwind:Start(inst.angle)
    else
        inst.components.blowinwind:StartSoundLoop()
    end

    ---local color = 0.5 + math.random() * 0.5
    ---inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetOnPlayerNear(onplayerprox)
    inst.components.playerprox:SetDist(5,10)

    --inst:AddComponent("lootdropper")

    inst:AddComponent("inspectable")

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/harvest_sticks"
    inst.components.pickable.onpickedfn = onpickup
    inst.components.pickable.canbepicked = true

    inst:ListenForEvent("startlongaction", OnLongAction)

    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("character_fire", Vector3(.1, 0, .1), "swap_fire")
    inst.components.burnable.canlight = true
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:SetBurnTime(10)

    MakeSmallPropagator(inst)
    inst.components.propagator.flashpoint = 5 + math.random()*3
    inst.components.propagator.propagaterange = 5

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = CancelRunningTasks
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
            --onpickup(inst, nil)
            --inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
        end
        return true
    end)

    --inst:AddComponent("named")
    inst.onpickup = onpickup
    inst.MakeLoot = MakeLoot

    return inst
end

local function RandomType()
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local num = math.random(1000)
    if num >= 999 then
        return 3
    elseif num >=986 then
        return 2
    elseif num <=20 then
        return -2
    elseif num <=120 then
        return -1
    elseif num >=900 then
        return 1
    else
        return 0
    end
end

local function MakeAnyTumbleweed()
    local inst = fn()
    if not TheWorld.ismastersim then
        return inst
    end
    local level = RandomType()
    inst.level = level
    if inst.components.colourtweener == nil then
        inst:AddComponent("colourtweener")
    end
    inst.components.colourtweener:StartTween(colors[level], 0)
    if inst.components.named == nil then
        inst:AddComponent("named")
    end
    inst.components.named:SetName(STRINGS.NAMES["TUMBLEWEED_"..(level+2)])
    inst.Light:Enable(level == 3)
    MakeLoot(inst)
    return inst
end

local function MakeTumbleweed(level)
    return function()
        local inst = fn()
        if not TheWorld.ismastersim then
            return inst
        end
        if level == nil then
            level = RandomType()
        end
        inst.level = level
        if inst.components.colourtweener == nil then
            inst:AddComponent("colourtweener")
        end
        inst.components.colourtweener:StartTween(colors[level], 0)
        if inst.components.named == nil then
            inst:AddComponent("named")
        end
        inst.components.named:SetName(STRINGS.NAMES["TUMBLEWEED_"..(level+2)])
        inst.Light:Enable(level == 3)
        MakeLoot(inst)
        return inst
    end
end

return Prefab("tumbleweed", MakeAnyTumbleweed, assets, prefabs),
    Prefab("tumbleweed_2", MakeTumbleweed(0), assets, prefabs),
    Prefab("tumbleweed_3", MakeTumbleweed(1), assets, prefabs),
    Prefab("tumbleweed_4", MakeTumbleweed(2), assets, prefabs),
    Prefab("tumbleweed_5", MakeTumbleweed(3), assets, prefabs),
    Prefab("tumbleweed_1", MakeTumbleweed(-1), assets, prefabs),
    Prefab("tumbleweed_0", MakeTumbleweed(-2), assets, prefabs),
    Prefab("tumbleweedbreakfx", burntfxfn, assets)
