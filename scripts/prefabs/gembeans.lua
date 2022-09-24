require "prefabutil"

local prefabs = {
}

local function makebean(colour)
    local assets = {
        Asset("ANIM", "anim/gem_crystal_cluster_"..colour..".zip"),
        Asset("ATLAS", "images/inventoryimages/gembean_"..colour..".xml"),
    }

    local function ondeploy(inst, pt, deployer)
        local sapling = SpawnPrefab("gem_crystal_cluster_"..colour)
        if sapling.PickGemSkin then
            sapling:PickGemSkin()
        end
        sapling.Transform:SetPosition(pt:Get())
        sapling.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
        if inst.components.stackable then
            inst.components.stackable:Get():Remove()
        else
            inst:Remove()
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("gem_crystal_cluster_"..colour)
        inst.AnimState:SetBuild("gem_crystal_cluster_"..colour)
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag("treeseed")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem:SetSinks(true)
        inst.components.inventoryitem.atlasname = "images/inventoryimages/gembean_"..colour..".xml"

        MakeHauntableLaunch(inst)

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
        inst.components.deployable.ondeploy = ondeploy

        return inst
    end

    return Prefab("gembean_"..colour, fn, assets)
end

local colours = {
    "blue", "green","orange","purple","red","yellow","opalprecious",
}

local aa = {}
for _,v in ipairs(colours) do
    table.insert(aa,makebean(v))
    table.insert(aa,MakePlacer("gembean_"..v.."_placer","gem_crystal_cluster_"..v,"gem_crystal_cluster_"..v,"small"))
end
return unpack(aa)

