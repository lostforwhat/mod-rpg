local assets =
{
    Asset("ANIM", "anim/skillbookpage.zip"),
    Asset("ATLAS", "images/inventoryimages/skillbookpage.xml"),
}

local binding_data = {
    [5] = {"skillbook_1"},
    [20] = {"skillbook_2", "skillbook"},
    [30] = {"skillbook_3", "skillbook"},
    [40] = {"skillbook_4", "skillbook"},
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("skillbookpage")
    inst.AnimState:SetBuild("skillbookpage")
    inst.AnimState:PlayAnimation("idle")

    inst.Transform:SetScale(2, 2, 1)

	inst:AddTag("skillbookpage")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "skillbookpage"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/skillbookpage.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("tradable")

    inst:AddComponent("bindingable")
    inst.components.bindingable:SetData(binding_data)

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("skillbookpage", fn, assets)
