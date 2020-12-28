local assets =
{
    Asset("ANIM", "anim/schrodingersword.zip"),
    Asset("ANIM", "anim/swap_schrodingersword.zip"),
    Asset("ATLAS", "images/inventoryimages/schrodingersword.xml"),
}

local function onequip(inst, owner)

    owner.AnimState:OverrideSymbol("swap_object", "swap_schrodingersword", "swap_schrodingersword")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onattack(inst, owner, target)
    local level = inst.components.weaponlevel and inst.components.weaponlevel.level or 0
    if math.random() < 0.01 * (1 + .2*level) then
        local percent = owner.components.health:GetPercent() or 0
        if percent > 0 then
            owner.components.health:SetPercent(percent * .5)
        end
    end
    if math.random() < 0.01 * (1 + .2*level) then
        local percent = target.components.health:GetPercent() or 0
        if percent > 0 then
            target.components.health:SetPercent(percent * .5)
        end
    end
end

local function GetShowItemInfo(inst)
    local level_str
    local level = inst.components.weaponlevel and inst.components.weaponlevel.level or 0
    if level > 0 then
        local extra_damage = inst.components.weapon.extra_damage or 0
        level_str = "强化+"..level.." (伤害+"..extra_damage..")"
    end
    return  "攻击"..(1 + .2*level).."%概率使目标或自己减少50%生命值", level_str
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("schrodingersword")
    inst.AnimState:SetBuild("schrodingersword")
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
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE*.5)
    inst.components.weapon.onattack = onattack

    -------

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/schrodingersword.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end


return Prefab("schrodingersword", fn, assets)
