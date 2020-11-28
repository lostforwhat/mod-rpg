local assets =
{
	Asset("ANIM", "anim/titles_fx.zip"),
}

local function updateLight(inst)
    if TheWorld.state.isnight then
        inst.Light:Enable(true)
    else
        inst.Light:Enable(false)
    end
end

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


local function common_fn(id, postinit)
    return function()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.AnimState:SetBank("titles_fx")
        inst.AnimState:SetBuild("titles_fx")
        inst.AnimState:PlayAnimation(id)
        
        inst.entity:AddLight()
        inst.Light:SetColour(255,222,0)
        inst.Light:SetFalloff(0.3)
        inst.Light:SetIntensity(0.8)
        inst.Light:SetRadius(2)
        inst.Light:Enable(false)

        inst.entity:SetPristine()
        inst:AddTag("FX")

        if postinit ~= nil then
            postinit(inst)
        end

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

return unpack(prefabs)