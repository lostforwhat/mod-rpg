local assets =
{
    Asset("ANIM", "anim/callerhorn.zip"),
    Asset("ATLAS", "images/inventoryimages/callerhorn.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("callerhorn")
    inst.AnimState:SetBuild("callerhorn")
    inst.AnimState:PlayAnimation("idle")

    --inst.Transform:SetScale(2, 2, 1)

	inst:AddTag("callerhorn")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "callerhorn"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/callerhorn.xml"

    inst:AddComponent("caller")

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CALL)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(50)
    inst.components.finiteuses:SetUses(50)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("callerhorn", fn, assets)
