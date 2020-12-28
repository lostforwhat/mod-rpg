local assets = { 
    Asset("ANIM", "anim/heisenberghat.zip"),
    Asset("ATLAS", "images/inventoryimages/heisenberghat.xml")
}

local function GetShowItemInfo(inst)

    return "能量溢出:承受的伤害随机转换成一种增益效果"
end

local function clearbuff(owner, inst)
    owner.components.combat.externaldamagemultipliers:RemoveModifier("heisenberghat")
    owner.components.locomotor:RemoveExternalSpeedMultiplier(inst, "heisenberghat")
    owner.components.crit:RemoveExtraChance("heisenberghat")
    owner.components.dodge:RemoveExtraChance("heisenberghat")
end

local function onequip(inst, owner, symbol_override)
    owner.AnimState:OverrideSymbol("swap_hat", "heisenberghat", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end
end

local function onunequip(inst, owner)

    owner.AnimState:ClearOverrideSymbol("swap_hat")
    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAIR_HAT")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
    end
    clearbuff(owner, inst)
end


local function ontakedamage(inst, damage)
    local owner = inst.components.inventoryitem.owner
    if not owner:HasTag("player") then return end
    if owner.heisenberghat_task ~= nil then
        owner.heisenberghat_task:Cancel()
        owner.heisenberghat_task = nil
    end
    clearbuff(owner, inst)
    local rand = math.random()
    local rate = math.clamp(damage * .001, 0.01, 1)
    if rand < 0.25 then
        owner.components.combat.externaldamagemultipliers:SetModifier("heisenberghat", 1+rate)
    elseif rand < 0.5 then
        owner.components.locomotor:SetExternalSpeedMultiplier(inst, "heisenberghat", 1+rate)
    elseif rand < 0.75 then
        owner.components.crit:AddExtraChance("heisenberghat", rate)
    else
        owner.components.dodge:AddExtraChance("heisenberghat", rate)
    end
    owner.heisenberghat_task = owner:DoTaskInTime(5, clearbuff, inst)
end

local function simple()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("heisenberghat")
    inst.AnimState:SetBuild("heisenberghat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/heisenberghat.xml"

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    return inst
end


local function fn()
    local inst = simple()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT*20, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)
    inst.components.armor.ontakedamage = ontakedamage

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end

return Prefab("heisenberghat", fn, assets)