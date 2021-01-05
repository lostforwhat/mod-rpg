local assets = { 
    Asset("ANIM", "anim/linghterhat.zip"),
    Asset("ATLAS", "images/inventoryimages/linghterhat.xml")
}

local function GetShowItemInfo(inst)

    return "激光反击: 随机向敌方反馈激光束"
end

local function onequip(inst, owner, symbol_override)
    owner.AnimState:OverrideSymbol("swap_hat", "linghterhat", "swap_hat")
    
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

local function ontakedamage(inst, damage)
    if inst.take ~= nil then
        inst.take = inst.take + 1
        if inst.take >= 20 or math.random() < 0.1 then
            local owner = inst.components.inventoryitem.owner
            
            if owner ~= nil then
                local num = math.random(8)
                for k=1, num do
                    local angle = k * 360 / num
                    local lt = SpawnPrefab("linghter_fx")
                    lt.Transform:SetPosition(owner:GetPosition():Get())
                    lt:thrown(owner, angle)
                end
                
                inst.take = 0
            end
        end
    end
end

local function simple()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("linghterhat")
    inst.AnimState:SetBuild("linghterhat")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/linghterhat.xml"

    inst:AddComponent("inspectable")

    inst:AddComponent("tradable")


    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

    MakeHauntableLaunch(inst)

    return inst
end


local function fn()
    local inst = simple()

    if not TheWorld.ismastersim then
        return inst
    end
    inst.take = 0

    inst:AddComponent("armor")
    inst.components.armor:InitIndestructible(.75)
    inst.components.armor.ontakedamage = ontakedamage

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end

return Prefab("linghterhat", fn, assets)