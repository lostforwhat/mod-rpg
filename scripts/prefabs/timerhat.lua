local assets = { 
    Asset("ANIM", "anim/timerhat.zip"),
    Asset("ATLAS", "images/inventoryimages/timerhat.xml")
}

local function onequip(inst, owner, symbol_override)
    owner.AnimState:OverrideSymbol("swap_hat", "timerhat", "swap_hat")
    
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAIR_HAT")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")

    if owner:HasTag("player") then
        owner.AnimState:Hide("HEAD")
        owner.AnimState:Show("HEAD_HAT")
    end

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
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

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function simple()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("timerhat")
    inst.AnimState:SetBuild("timerhat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")

    MakeInventoryFloatable(inst)

    inst:AddTag("open_top_hat")
    inst:AddTag("umbrella")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/timerhat.xml"

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
    inst.components.armor:InitCondition(TUNING.ARMOR_FOOTBALLHAT*10, TUNING.ARMOR_FOOTBALLHAT_ABSORPTION)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(1)

    return inst
end

return Prefab("timerhat", fn, assets)