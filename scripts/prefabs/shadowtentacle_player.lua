local assets =
{
    Asset("ANIM", "anim/tentacle_arm.zip"),
    Asset("ANIM", "anim/tentacle_arm_black_build.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
}

local RETARGET_MUST_TAGS = { "_combat", "_health" }
local RETARGET_CANT_TAGS = { "prey" }
local NO_PVP_TAGS = {"prey", "player"}
local function retargetfn(inst)
    return FindEntity(
        inst,
        2,
        function(guy) 
            return guy.prefab ~= inst.prefab
                and guy ~= inst.owner
                and guy.entity:IsVisible()
                and not guy.components.health:IsDead()
                and (guy.components.combat.target == inst or
                    guy.components.combat.target == inst.owner or
                    guy:HasTag("character") or
                    guy:HasTag("monster") or
                    guy:HasTag("animal"))
                and (guy.components.follower == nil or 
                    guy.components.follower:GetLeader() == nil or
                    (TheNet:GetPVPEnabled() and
                    guy.components.follower:GetLeader() ~= inst.owner or
                    not guy.components.follower:GetLeader():HasTag("player")))
        end,
        RETARGET_MUST_TAGS,
        TheNet:GetPVPEnabled() and RETARGET_CANT_TAGS or NO_PVP_TAGS)
end

local function shouldKeepTarget(inst, target)
    return target ~= nil
        and target:IsValid()
        and target.entity:IsVisible()
        and target.components.health ~= nil
        and not target.components.health:IsDead()
        and target:IsNear(inst, TUNING.TENTACLE_STOPATTACK_DIST)
end

local function SetOwner(inst, owner)
    inst.owner = owner
    if owner.components.level ~= nil then
        local level = owner.components.level.level or 0
        inst.components.combat:SetDefaultDamage(TUNING.TENTACLE_DAMAGE + level)
    end
end

--转移击杀事件
local function OnKilled(inst, data)
    if inst.owner ~= nil then
        inst:PushEvent("killed", data)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    inst.Physics:SetCylinder(0.25, 2)

    inst.Transform:SetScale(0.5, 0.5, 0.5)

    inst.AnimState:SetMultColour(1, 1, 1, 0.5)

    inst.AnimState:SetBank("tentacle_arm")
    inst.AnimState:SetBuild("tentacle_arm_black_build")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("shadow")
    inst:AddTag("notarget")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(2)
    inst.components.combat:SetDefaultDamage(TUNING.TENTACLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TENTACLE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(2, 0.5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
   
    MakeLargeFreezableCharacter(inst)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({})

    inst:SetStateGraph("SGshadowtentacle")

    inst:DoTaskInTime(30, inst.Remove)
    inst.persists = false

    inst:ListenForEvent("killed", OnKilled)

    return inst
end

return Prefab("shadowtentacle_player", fn, assets)
