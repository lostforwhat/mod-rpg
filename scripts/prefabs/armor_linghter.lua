local ABSORPTION = .75

local assets =
{
    Asset("ANIM", "anim/armor_linghter.zip"),
    Asset("ATLAS", "images/inventoryimages/armorlinghter.xml"),
}

local function GetShowItemInfo(inst)

    return "光之屏障: 免疫并反射远程投掷物"
end

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "armor_linghter", "swap_body")
    
    inst:ListenForEvent("blocked", OnBlocked, owner)
    owner:AddTag("reflectproject")

    inst.onreceivelightning = function()
        inst.components.fueled:DoDelta(180)
    end

    inst:ListenForEvent("receivelightning", inst.onreceivelightning, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    owner:RemoveTag("reflectproject")

    inst:RemoveEventCallback("receivelightning", inst.onreceivelightning, owner)
end

local function ontakedamage(inst, damage)
    if not inst.components.fueled:IsEmpty() then
        inst.components.fueled:DoDelta(-damage*.5)
    end
end

local function checkbroken(inst)
    if inst.components.fueled:IsEmpty() then
        inst:AddTag("broken")
        if inst.components.armor ~= nil then
            inst:RemoveComponent("armor")
        end
    else
        inst:RemoveTag("broken")
        if inst.components.armor == nil then
            inst:AddComponent("armor")
            inst.components.armor:AddWeakness("shadowcreature", 20)
            inst.components.armor:AddWeakness("shadowchesspiece", 50)
            inst.components.armor.ontakedamage = ontakedamage
        end
        inst.components.armor:InitIndestructible(ABSORPTION)
    end
end

local function onfuelchange(section, oldsection, inst)
    local equipped = inst.replica.equippable:IsEquipped()
    local owner = inst.components.inventoryitem.owner
    checkbroken(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_linghter")
    inst.AnimState:SetBuild("armor_linghter")
    inst.AnimState:PlayAnimation("anim")


    inst.foleysound = "dontstarve/movement/foley/logarmour"

    MakeInventoryFloatable(inst, "small", 2, 1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armorlinghter.xml"

    MakeSmallPropagator(inst)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "YELLOWGEN"
    inst.components.fueled:InitializeFuelLevel(3600)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    --inst.components.fueled:StopConsuming() 
    inst.components.fueled.accepting = true

    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(ABSORPTION)
    inst.components.armor:AddWeakness("shadowcreature", 20)
    inst.components.armor:AddWeakness("shadowchesspiece", 50)
    inst.components.armor.ontakedamage = ontakedamage

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end

return Prefab("armorlinghter", fn, assets)
