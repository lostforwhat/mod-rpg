local assets = {
    Asset( "ANIM", "anim/linghter_fx.zip" ),
}

local prefabs = {}

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx ~= nil and target.components.combat then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        if attacker ~= nil and attacker:IsValid() then
            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
        end
    end
    --inst:Remove()
end

local function onthrown(inst, attacker, target)

end

local function thrown(inst, attacker, angle)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.components.lineprojectile:Throw(attacker, angle)
end

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Light:SetRadius(.8)
    inst.Light:SetFalloff(.8)
    inst.Light:SetIntensity(.8)
    inst.Light:SetColour(12 / 255, 25 / 255, 250 / 255)
    inst.Light:Enable(true)

    MakeInventoryPhysics(inst)

    inst:AddTag("NOCLICK")

    inst:AddTag("blowdart")
    inst:AddTag("sharp")

    inst.AnimState:SetBank("linghter_fx")
    inst.AnimState:SetBuild("linghter_fx")
    inst.AnimState:PlayAnimation("idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(8)

    inst:DoTaskInTime(2, inst.Remove)

    inst:AddComponent("lineprojectile")
    inst.components.lineprojectile:SetSpeed(20)
    inst.components.lineprojectile:SetOnHitFn(onhit)
    inst.components.lineprojectile:SetHitDist(1)
    --inst.components.projectile:SetOnThrownFn(onthrown)

    inst.thrown = thrown

    inst.persists = false

    return inst
end

return Prefab("linghter_fx", fn, assets, prefabs)