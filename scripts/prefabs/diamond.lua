local assets =
{
    Asset("ANIM", "anim/diamond.zip"),
    Asset("ATLAS", "images/inventoryimages/diamond.xml"),
}


local function GetShowItemInfo(inst)
    local value = inst.components.diamond.value or 1
    local size = inst.components.stackable:StackSize() or 1
    return "钻石+"..(value * size)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("diamond")
    inst.AnimState:SetBuild("diamond")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("diamond")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	inst:AddComponent("diamond")
    inst.components.diamond.value = 1

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "diamond"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/diamond.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end

return Prefab("diamond", fn, assets)
