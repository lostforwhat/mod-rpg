local assets =
{
    Asset("ANIM", "anim/potion_achiv.zip"),
    Asset("IMAGE", "images/potion_achiv.tex"),
    Asset("ATLAS", "images/potion_achiv.xml"),
}


local function Oneat(inst, eater)
    
end

--showme api
local function GetShowItemInfo(inst, viewer)
    local info = "经验值+"
    if viewer ~= nil then
        return info..inst.components.edible:GetXp(viewer)
    end
    return info..inst.components.edible.xpvalue
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    
    -- Set animation info
    inst.AnimState:SetBuild("potion_achiv")
    inst.AnimState:SetBank("potion_achiv")
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetScale(2, 2, 1)

    --inst:AddTag("irreplaceable")
    inst:AddTag("preparedfood")
    --MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = 0  -- Amount to heal
    inst.components.edible.hungervalue =  0 -- Amount to fill belly
    inst.components.edible.sanityvalue = 0  -- Amount to help Sanity
    inst.components.edible.xpvalue = 20
    inst.components.edible.foodtype = "GOODIES"
    inst.components.edible:SetOnEatenFn(Oneat) 

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
  
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/potion_achiv.xml" -- here's the atlas for our tex

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end

return Prefab("potion_achiv", fn, assets)
