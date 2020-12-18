local assets =
{
    Asset("ANIM", "anim/linghter_sword.zip"),
    Asset("ANIM", "anim/swap_linghter_sword.zip"),
    Asset("ATLAS", "images/inventoryimages/linghter_sword.xml"),
}

local function onpocket(inst)
    inst.components.burnable:Extinguish()
end

local function onremovefire(fire)
    fire.linghter_sword.fire = nil
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_linghter_sword", "swap_linghter_sword")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if not inst.components.fueled:IsEmpty() then
        inst.components.burnable:Ignite()

        if inst.fire == nil then
            inst.fire = SpawnPrefab("nightstickfire")
            inst.fire.Light:SetColour(255 / 255, 193 / 255, 37 / 255)
            inst.fire.linghter_sword = inst
            inst:ListenForEvent("onremove", onremovefire, inst.fire)
        end
        inst.fire.entity:SetParent(owner.entity)
    end
end

local function onunequip(inst, owner)
    if inst.fire ~= nil then
        inst.fire:Remove()
    end
    inst.components.burnable:Extinguish()
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

local function onfuelchange(section, oldsection, inst)
    if inst.components.fueled:IsEmpty() then
        inst:AddTag("broken")
        inst.components.burnable:Extinguish()
        if inst.fire ~= nil then
            inst.fire:Remove()
        end
    else
        inst:RemoveTag("broken")

        local equipped = inst.replica.equippable:IsEquipped()
        if equipped and inst.fire == nil then
            inst.components.burnable:Ignite()

            inst.fire = SpawnPrefab("nightstickfire")
            inst.fire.Light:SetColour(255 / 255, 193 / 255, 37 / 255)
            inst.fire.linghter_sword = inst
            inst:ListenForEvent("onremove", onremovefire, inst.fire)
            local owner = inst.components.inventoryitem.owner
            inst.fire.entity:SetParent(owner.entity)
        end
    end
end

local function OnUse(inst)
    local owner = inst.components.inventoryitem.owner
    if inst.components.fueled:IsEmpty() then
        owner.components.talker:Say("没有能量了")
        inst.components.useableitem:StopUsingItem()
        return
    end
    
    local equipped = inst.replica.equippable:IsEquipped()
    if owner ~= nil and equipped then
        inst.components.fueled:DoDelta(-80)
        owner:StartThread(function()
            local x,y,z = owner.Transform:GetWorldPosition()
            local num = 10
            for k = 1, num do
                local r = math.random(1, 5)
                local angle = k * 2 * PI / num
                local pos = Point(r*math.cos(angle)+x, y, r*math.sin(angle)+z)
                TheWorld:PushEvent("ms_sendlightningstrike", pos)
                Sleep(.3 + math.random())
            end
        end)
    end
    inst.components.useableitem:StopUsingItem()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    inst.entity:AddLight()
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(255 / 255, 193 / 255, 37 / 255)
    inst.Light:Enable(true)

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("linghter_sword")
    inst.AnimState:SetBuild("linghter_sword")
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
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE)
    inst.components.weapon.onattack = onattack

    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(OnUse)

    -------
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "YELLOWGEN"
    inst.components.fueled:InitializeFuelLevel(800)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    --inst.components.fueled:StopConsuming() 
    inst.components.fueled.accepting = true
    inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION*2)

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages/linghter_sword.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeHauntableLaunch(inst)

    inst.GetShowItemInfo = GetShowItemInfo

    return inst
end


return Prefab("linghter_sword", fn, assets)
