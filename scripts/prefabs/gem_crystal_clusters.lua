local assets = {
}

local prefabs = {

}

local function set_stage1(inst)
    inst.Light:Enable(false)
    inst.components.pickable.canbepicked = false
    inst.AnimState:PlayAnimation("small")
end

local function grow_to_stage1(inst)
end

local function set_stage2(inst)
    inst.Light:Enable(false)
    inst.components.pickable.canbepicked = false
    inst.AnimState:PlayAnimation("medium")
end

local function grow_to_stage2(inst)
end

local function set_stage3(inst)
    inst.Light:Enable(true)
    inst.components.pickable.canbepicked = true
    inst.AnimState:PlayAnimation("large")
    inst.components.growable:StopGrowing()
end

local function grow_to_stage3(inst)
end

local STAGE1 = "stage_1"
local STAGE2 = "stage_2"
local STAGE3 = "stage_3"

local growth_stages = {
    {
        name = STAGE1,
        time = function(inst)
            return TUNING.GEMCRYSTAL_time
        end,
        fn = set_stage1,
        growfn = grow_to_stage1
    },
    {
        name = STAGE2,
        time = function(inst)
            return TUNING.GEMCRYSTAL_time
        end,
        fn = set_stage2,
        growfn = grow_to_stage2
    },
    {
        name = STAGE3,
        time = function(inst)
            return TUNING.GEMCRYSTAL_time
        end,
        fn = set_stage3,
        growfn = grow_to_stage3
    }
}

local function on_dug_up(inst, digger)
    if inst.components.growable.stage == 3 then
        inst.components.lootdropper:SpawnLootPrefab(inst.colour.."gem")
        if inst.colour ~= "opalprecious" then
            inst.components.lootdropper:SpawnLootPrefab(math.random() < 0.5 and "ice" or "moonglass")
        else
            inst.components.lootdropper:SpawnLootPrefab("nightmarefuel")
        end
    end
    inst.components.lootdropper:SpawnLootPrefab("gembean_"..inst.colour)
    inst:Remove()
end

local function onpickedfn(inst, picker)
    inst.components.growable:SetStage(inst.colour ~= "opalprecious" and 2 or 1)
    if picker and picker.components.inventory then
        if inst.colour ~= "opalprecious" then
            picker.components.inventory:GiveItem( SpawnPrefab(math.random() < 0.5 and "ice" or "moonglass"),nil,inst:GetPosition())
        else
            picker.components.inventory:GiveItem( SpawnPrefab("nightmarefuel"),nil,inst:GetPosition())
        end
    end
    inst.components.growable:StartGrowing()
end

local function setnewskin(inst,type)
    inst.AnimState:OverrideSymbol("skin1", "gem_crystal_cluster_"..inst.colour, "skin"..type)
end

local function PickGemSkin(inst)
    local skin = math.random(3)
    inst.skintype = skin
    setnewskin(inst,inst.skintype)
end

local function on_save(inst, data)
    if inst.skintype ~= nil then
        data.skintype = inst.skintype
    end
end

local function on_load(inst, data)
    if data == nil then
        return
    end
    if data.skintype then
        inst.skintype = data.skintype
        setnewskin(inst,inst.skintype)
    end
end

local lightcolour = {
    blue = {17/255,172/255,238/255,1},
    green = {5/255,150/255,54/255,1},
    orange = {253/255,146/255,66/255,1},
    purple = {200/255,7/255,248/255,1},
    red = {253/255,2/255,2/255,1},
    yellow = {255/255,255/255,1/255,1},
    opalprecious = {255/255,255/255,255/255,1},
}
local function makebush(colour)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddSoundEmitter()
        inst.entity:AddLight()
        inst.entity:AddNetwork()

        inst.AnimState:SetBank("gem_crystal_cluster_"..colour)
        inst.AnimState:SetBuild("gem_crystal_cluster_"..colour)
        inst.AnimState:PlayAnimation("small")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        inst.MiniMapEntity:SetIcon("gem_crystal_cluster_"..colour..".tex")
        MakeSmallObstaclePhysics(inst, .2)

        inst.Transform:SetScale(2.2, 2.2, 2.2)

        inst.Light:SetFalloff(0.7)
        inst.Light:SetIntensity(.5)
        inst.Light:SetRadius(0.8)
        inst.Light:SetColour(unpack(lightcolour[colour]))
        inst.Light:Enable(false)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.colour = colour
        MakeHauntable(inst)

        inst:AddComponent("lootdropper")

        inst:AddComponent("pickable")
        inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
        inst.components.pickable.numtoharvest = 1
        inst.components.pickable.product = colour.."gem"
        inst.components.pickable.onpickedfn = onpickedfn
        inst.components.pickable.canbepicked = false

        inst:AddComponent("inspectable")

        inst:AddComponent("growable")
        inst.components.growable.stages = growth_stages
        inst.components.growable:SetStage(1)
        inst.components.growable:StartGrowing()

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.DIG)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(on_dug_up)

        if colour ~= "opalprecious" then
            inst.PickGemSkin = PickGemSkin
        end
        inst.OnSave = on_save
        inst.OnLoad = on_load

        return inst
    end

    return Prefab("gem_crystal_cluster_"..colour, fn, assets, prefabs)
end


local colours = {
    "blue", "green","orange","purple","red","yellow","opalprecious",
}

local aa = {}
for _,v in ipairs(colours) do
    table.insert(aa,makebush(v))
end
return unpack(aa)