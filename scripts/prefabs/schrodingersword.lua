local assets =
{
    Asset("ANIM", "anim/batbat.zip"),
    Asset("ANIM", "anim/swap_batbat.zip"),
    Asset("ANIM", "anim/floating_items.zip"),
}

local function onequip(inst, owner)

    owner.AnimState:OverrideSymbol("swap_object", "swap_batbat", "swap_batbat")

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

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("batbat")
    inst.AnimState:SetBuild("batbat")
    inst.AnimState:PlayAnimation("idle")

    --inst:AddTag("dull")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    local swap_data = {sym_build = "swap_batbat"}
    MakeInventoryFloatable(inst, "large", 0.05, {0.8, 0.35, 0.8}, true, -27, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE*1.5)
    inst.components.weapon.onattack = onattack

    -------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BATBAT_USES)
    inst.components.finiteuses:SetUses(TUNING.BATBAT_USES)

    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end


return Prefab("schrodingersword", fn, assets)
