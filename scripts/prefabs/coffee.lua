local assets =
{
    Asset("ANIM", "anim/meat.zip"),
    Asset("ANIM", "anim/meat_monster.zip")
}

local prefabs =
{
    "coffeebean_cooked",
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

local function EatCoffeeFn(inst, eater)

end

local function fn_prepared()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBuild("coffee")
    inst.AnimState:SetBank("coffee")
    

    inst.AnimState:PlayAnimation("idle")
    --inst.AnimState:OverrideSymbol("swap_food", data.overridebuild or "cook_pot_food", data.basename or data.name)

    inst:AddTag("preparedfood")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 3
    inst.components.edible.hungervalue = 10
    inst.components.edible.foodtype = FOODTYPE.GENERIC
    inst.components.edible.secondaryfoodtype = nil
    inst.components.edible.sanityvalue = -5
    inst.components.edible.temperaturedelta = 0
    inst.components.edible.temperatureduration = 0
    inst.components.edible.nochill = nil
    --inst.components.edible.spice = nil
    inst.components.edible:SetOnEatenFn(EatCoffeeFn)

    inst:AddComponent("inspectable")
    inst.wet_prefix = data.wet_prefix

    inst:AddComponent("inventoryitem")

    if spicename ~= nil then
        inst.components.inventoryitem:ChangeImageName(spicename.."_over")
    elseif data.basename ~= nil then
        inst.components.inventoryitem:ChangeImageName(data.basename)
    end

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    if data.perishtime ~= nil and data.perishtime > 0 then
        inst:AddComponent("perishable")
        inst.components.perishable:SetPerishTime(data.perishtime)
        inst.components.perishable:StartPerishing()
        inst.components.perishable.onperishreplacement = "spoiled_food"
    end

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableLaunchAndPerish(inst)
    ---------------------

    inst:AddComponent("bait")

    ------------------------------------------------
    inst:AddComponent("tradable")

    ------------------------------------------------

    return inst
end

return Prefab("coffeebean", fn, assets, prefabs),
    Prefab("coffeebean_cooked", fn_cooked, assets, prefabs)