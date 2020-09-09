local assets =
{
    Asset("ANIM", "anim/meat.zip"),
    Asset("ANIM", "anim/meat_monster.zip")
}

local prefabs =
{
    "coffee_cooked",
    "spoiled_food",
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(name)
    inst.AnimState:SetBuild(name)
    inst.AnimState:PlayAnimation("idle")

    --cookable (from cookable component) added to pristine state for optimization
    inst:AddTag("cookable")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 10
    inst.components.edible.sanityvalue = -5    
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.secondaryfoodtype = FOODTYPE.BERRY

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    ---------------------        

    inst:AddComponent("bait")

    ------------------------------------------------
    inst:AddComponent("tradable")

    ------------------------------------------------  

    inst:AddComponent("cookable")
    inst.components.cookable.product = name.."_cooked"

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/veggies").master_postinit(inst)
    end

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function fn_cooked()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(name)
    inst.AnimState:SetBuild(name)
    inst.AnimState:PlayAnimation("cooked")


    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 10
    inst.components.edible.sanityvalue = -5
    inst.components.edible.foodtype = FOODTYPE.VEGGIE
    inst.components.edible.secondaryfoodtype = FOODTYPE.BERRY

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    ---------------------        

    inst:AddComponent("bait")

    ------------------------------------------------
    inst:AddComponent("tradable")

    if TheNet:GetServerGameMode() == "quagmire" then
        event_server_data("quagmire", "prefabs/veggies").master_postinit_cooked(inst)
    end

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

return Prefab("coffee", fn, assets, prefabs),
    Prefab("coffee_cooked", fn_cooked, assets, prefabs)