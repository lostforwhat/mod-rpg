local assets =
{
    Asset("ANIM", "anim/linghter_sword.zip"),
    Asset("ANIM", "anim/swap_linghter_sword.zip"),
    Asset("ANIM", "anim/swap_linghter_sword_off.zip"),
    Asset("ATLAS", "images/inventoryimages/linghter_sword.xml"),
}

local function onpocket(inst)
    inst.components.burnable:Extinguish()
end

local function onremovefire(fire)
    fire.linghter_sword.fire = nil
end

local function onequip(inst, owner)
    
    if not inst.components.fueled:IsEmpty() then
        owner.AnimState:OverrideSymbol("swap_object", "swap_linghter_sword", "swap_linghter_sword")

        inst.components.burnable:Ignite()

        if inst.fire == nil then
            inst.fire = SpawnPrefab("nightstickfire")
            inst.fire.Light:SetColour(255 / 255, 193 / 255, 37 / 255)
            inst.fire.linghter_sword = inst
            inst:ListenForEvent("onremove", onremovefire, inst.fire)
        end
        inst.fire.entity:SetParent(owner.entity)
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_linghter_sword_off", "swap_linghter_sword_off")
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
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
    inst.components.fueled:DoDelta(-1)
    local level = inst.components.weaponlevel and inst.components.weaponlevel.level or 0
    if not inst.components.fueled:IsEmpty() and math.random() < (0.1 + 0.02*level) then
        local lt = SpawnPrefab("linghter_fx")
        lt.Transform:SetPosition(owner:GetPosition():Get())
        local angle = lt:GetAngleToPoint(target:GetPosition():Get())
        lt:thrown(owner, angle)
    end
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

local function onthrown(inst)
    if inst.components.fueled:IsEmpty() then
        inst.AnimState:PlayAnimation("off")
        inst.Light:Enable(false)
    else
        inst.AnimState:PlayAnimation("idle")
        inst.Light:Enable(true)
    end
end

local function onfuelchange(section, oldsection, inst)
    local equipped = inst.replica.equippable:IsEquipped()
    local owner = inst.components.inventoryitem.owner
    if inst.components.fueled:IsEmpty() then
        inst:AddTag("broken")
        inst.components.burnable:Extinguish()
        if inst.fire ~= nil then
            inst.fire:Remove()
        end
        inst.components.weapon:SetDamage(1)
        if equipped then
            owner.AnimState:OverrideSymbol("swap_object", "swap_linghter_sword_off", "swap_linghter_sword_off")
        end
    else
        inst:RemoveTag("broken")

        if equipped and inst.fire == nil then
            owner.AnimState:OverrideSymbol("swap_object", "swap_linghter_sword", "swap_linghter_sword")
            inst.components.burnable:Ignite()

            inst.fire = SpawnPrefab("nightstickfire")
            inst.fire.Light:SetColour(12 / 255, 25 / 255, 250 / 255)
            inst.fire.linghter_sword = inst
            inst:ListenForEvent("onremove", onremovefire, inst.fire)
            inst.fire.entity:SetParent(owner.entity)
        end
        inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE)
    end
    if not equipped then
        onthrown(inst)
    end
end

local function createlight(inst, target, pos)
    local owner = inst.components.inventoryitem.owner
    if inst.components.fueled:IsEmpty() then
        owner.components.talker:Say("没有能量了")
        return
    end
    
    local equipped = inst.replica.equippable:IsEquipped()
    local level = inst.components.weaponlevel and inst.components.weaponlevel.level or 0
    if owner ~= nil and equipped then
        TheWorld:PushEvent("ms_sendlightningstrike", pos)
        for k=1, 5 do
            inst:DoTaskInTime(.2 * k, function() 
                    local lt = SpawnPrefab("linghter_fx")
                    lt.Transform:SetPosition(owner:GetPosition():Get())
                    local angle = lt:GetAngleToPoint(pos:Get())
                    lt.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE*.5 + level)
                    lt:thrown(owner, angle)
            end)
        end
        owner:ForceFacePoint(pos:Get())
        inst.components.fueled:DoDelta(-50)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    inst.entity:AddLight()
    inst.Light:SetRadius(1)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(12 / 255, 25 / 255, 250 / 255)
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

    inst:ListenForEvent("on_landed", onthrown)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BATBAT_DAMAGE)
    inst.components.weapon.onattack = onattack

    --[[inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(OnUse)]]
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canuseonpoint_water = true

    -------
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "YELLOWGEN"
    inst.components.fueled:InitializeFuelLevel(1800)
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
