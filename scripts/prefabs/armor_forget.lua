local assets =
{
    Asset("ANIM", "anim/armor_forget.zip"),
    Asset("ALTAS", "images/inventoryimages/armorforget.xml"),
}

local function GetShowItemInfo(inst)

    return "特殊:遗忘光环"
end

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "armor_forget", "swap_body")
    
    inst:ListenForEvent("blocked", OnBlocked, owner)
    owner:AddTag("reflectproject")
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    owner:RemoveTag("reflectproject")
end

local function checkbroken(inst)
    if inst.components.fueled:IsEmpty() then
        inst:AddTag("broken")
        inst.components.armor:InitIndestructible(0)
    else
        inst:RemoveTag("broken")
        inst.components.armor:InitIndestructible(TUNING.ARMORWOOD_ABSORPTION)
    end
end

local function onfuelchange(section, oldsection, inst)
    local equipped = inst.replica.equippable:IsEquipped()
    local owner = inst.components.inventoryitem.owner
    checkbroken(inst)
end

local function ontakedamage(inst, damage)
    if not inst.components.fueled:IsEmpty() then
        inst.components.fueled:DoDelta(-damage*.5)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_forget")
    inst.AnimState:SetBuild("armor_forget")
    inst.AnimState:PlayAnimation("anim")


    inst.foleysound = "dontstarve/movement/foley/logarmour"

    MakeInventoryFloatable(inst, "small", 0.2, 0.80)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/armorforget.xml"

    MakeSmallPropagator(inst)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "ORANGEGEM"
    inst.components.fueled:InitializeFuelLevel(3600)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    --inst.components.fueled:StopConsuming() 
    inst.components.fueled.accepting = true

    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(TUNING.ARMORWOOD_ABSORPTION)
    inst.components.armor:AddWeakness("epic", 100)
    inst.components.armor.ontakedamage = ontakedamage

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end

return Prefab("armorforget", fn, assets)
