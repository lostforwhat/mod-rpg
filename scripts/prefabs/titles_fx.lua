local assets =
{
	Asset("ANIM", "anim/titles_fx.zip"),
    Asset("ATLAS", "images/inventoryimages/titles_fly_item.xml"),
}



local function Equipped(inst, owner, offset)
    if type(offset) ~= "number" then 
        offset = 0 
    end
    if owner._titles ~= nil then
        owner._titles:Remove()
        owner._titles = nil
    end
    owner._titles = inst
    owner._titles.entity:SetParent(owner.entity)
    owner._titles.Transform:SetPosition(0, 3.5 + offset, 0)
end

local function GetShowItemInfo(inst)
    return "获得【天外飞仙】称号"
end

local function OnPickUp(inst, picker, pos)
    if picker.components.titles ~= nil then
        picker.components.titles.special = true
    else
        inst:Remove()
    end
end

local function fly_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("titles_fx")
    inst.AnimState:SetBuild("titles_fx")
    inst.AnimState:PlayAnimation("fly")

    inst:AddTag("titles_fly_item")
    inst:AddTag("unpackage")
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/titles_fly_item.xml"
    inst.components.inventoryitem:SetOnPickupFn(OnPickUp)

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end


local function common_fn(id, postinit)
    return function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.AnimState:SetBank("titles_fx")
        inst.AnimState:SetBuild("titles_fx")
        inst.AnimState:PlayAnimation(id)

        if postinit ~= nil then
            postinit(inst)
        end

        inst:AddTag("FX")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.Equipped = Equipped
        
        return inst
    end
end


local prefabs = {}
if titles_data then
    for _, v in pairs(titles_data) do
        local postinit = v.postinit
        table.insert(prefabs, Prefab("titles_"..v.id, common_fn(v.id, postinit), assets))
    end
end

return unpack(prefabs),
    Prefab("titles_fly_item", fly_fn, assets)