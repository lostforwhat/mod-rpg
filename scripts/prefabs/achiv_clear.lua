local assets =
{
    Asset("ANIM", "anim/achiv_clear.zip"),
    Asset("ATLAS", "images/achiv_clear.xml"),
}


local function OnPray(inst, prayer)
    if prayer ~= nil and not prayer:HasTag("playerghost") and 
        task_data ~= nil and prayer.components.taskdata ~= nil then 
        local tasks = {}
        for k, v in pairs(task_data) do
            local need = v.need or 1
            if k ~= "all" and prayer.components.taskdata[k] <= need then
                table.insert(tasks, k)
            end
        end
        if #tasks > 0 then
            local task = tasks[math.random(#tasks)]
            prayer.components.taskdata:Completed(task)
            return true
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("achiv_clear")
    inst.AnimState:SetBuild("achiv_clear")
    inst.AnimState:PlayAnimation("idle")

	inst:AddTag("achiv_clear")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("inspectable")
	inst:AddComponent("prayable")
    inst.components.prayable:SetPrayFn(OnPray)

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "achiv_clear"
	inst.components.inventoryitem.atlasname = "images/achiv_clear.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("achiv_clear", fn, assets)
