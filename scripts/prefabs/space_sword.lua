local assets =
{
    Asset("ANIM", "anim/space_sword.zip"),
    Asset("ANIM", "anim/swap_space_sword.zip"),
    Asset("ATLAS", "images/inventoryimages/space_sword.xml"),
}

local function onequip(inst, owner)

    owner.AnimState:OverrideSymbol("swap_object", "swap_space_sword", "swap_space_sword")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, owner, target)
    
end

local function GetShowItemInfo(inst)

    local level_str
    local level = inst.components.weaponlevel and inst.components.weaponlevel.level or 0
    if level > 0 then
        local extra_damage = inst.components.weapon.extra_damage or 0
        level_str = "强化+"..level.." (伤害+"..extra_damage..")"
    end
    return level_str
end

local function onblink(staff, pos, caster)
    if caster.components.sanity ~= nil then
        caster.components.sanity:DoDelta(-TUNING.SANITY_MED)
    end
    staff.components.fueled:DoDelta(-2)
end

local function onfuelchange(section, oldsection, inst)
    if inst.components.fueled:IsEmpty() then
        inst:AddTag("broken")
        if inst.components.blinkstaff ~= nil then
            inst:RemoveComponent("blinkstaff")
        end
    else
        inst:RemoveTag("broken")
        if inst.components.blinkstaff == nil then
            inst:AddComponent("blinkstaff")
            inst.components.blinkstaff:SetFX("sand_puff_large_front", "sand_puff_large_back")
            inst.components.blinkstaff.onblinkfn = onblink
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("space_sword")
    inst.AnimState:SetBuild("space_sword")
    inst.AnimState:PlayAnimation("idle")

    --inst:AddTag("dull")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    MakeInventoryFloatable(inst, nil)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE*1.2)
    inst.components.weapon.onattack = onattack

    inst.fxcolour = {1, 145/255, 0}
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("blinkstaff")
    inst.components.blinkstaff:SetFX("sand_puff_large_front", "sand_puff_large_back")
    inst.components.blinkstaff.onblinkfn = onblink
    -------
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "ORANGEGEM"
    inst.components.fueled:InitializeFuelLevel(200)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    --inst.components.fueled:StopConsuming() 
    inst.components.fueled.accepting = true

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/space_sword.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end


return Prefab("space_sword", fn, assets)
