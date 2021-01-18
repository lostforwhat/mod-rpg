-------------------------------------------------------------------------
---------------------- Attach and dettach functions ---------------------
-------------------------------------------------------------------------

local function attack_attach(inst, target)
    if target.components.combat ~= nil then
        target:ApplyScale("potion", 1.5)
        target.components.combat.externaldamagemultipliers:SetModifier("potion", 2)
    end
end

local function attack_detach(inst, target)
    if target.components.combat ~= nil then
        target:ApplyScale("potion", 1)
        target.components.combat.externaldamagemultipliers:RemoveModifier("potion")
    end
end

local function speed_attach(inst, target)
    if target.components.locomotor ~= nil then
        target.components.locomotor:SetExternalSpeedMultiplier(inst, inst.prefab.."speedup", 1.75)
    end
end

local function speed_detach(inst, target)
    if target.components.locomotor ~= nil then
        target.components.locomotor:RemoveExternalSpeedMultiplier(inst, inst.prefab.."speedup")
    end
end

local function taunt_attach(inst, target)
    inst:DoPeriodicTask(1, function() 
        local x, y, z = target.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 15, {"_combat", "_health"}, nil, {"monster", "animal", "flying", "pig", "merm"})
        for k,v in pairs(ents) do
            if v.components.combat and v:IsValid() then
                v.components.combat:SetTarget(target)
            end
        end
    end)
end

local function waterwalk_attach(inst, target)
    if target.components.drownable and target.components.drownable.enabled ~= false then
        target.components.drownable.enabled = false
        target.Physics:ClearCollisionMask()
        target.Physics:CollidesWith(COLLISION.GROUND)
        target.Physics:CollidesWith(COLLISION.OBSTACLES)
        target.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        target.Physics:CollidesWith(COLLISION.CHARACTERS)
        target.Physics:CollidesWith(COLLISION.GIANTS)
        target.Physics:Teleport(target.Transform:GetWorldPosition())
    end
end

local function waterwalk_detach(inst, target)
    if target.components.drownable and target.components.drownable.enabled == false then
        target.components.drownable.enabled = true
        if not target:HasTag("playerghost") then
            target.Physics:ClearCollisionMask()
            target.Physics:CollidesWith(COLLISION.WORLD)
            target.Physics:CollidesWith(COLLISION.OBSTACLES)
            target.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
            target.Physics:CollidesWith(COLLISION.CHARACTERS)
            target.Physics:CollidesWith(COLLISION.GIANTS)
            target.Physics:Teleport(target.Transform:GetWorldPosition())
        end
    end
end


-------------------------------------------------------------------------
----------------------- Prefab building functions -----------------------
-------------------------------------------------------------------------

local function OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end

local function MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration, priority, prefabs)
    local function OnAttached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0) --in case of loading
        inst:ListenForEvent("death", function()
            inst.components.debuff:Stop()
        end, target)

        target:PushEvent("foodbuffattached", { buff = "ANNOUNCE_ATTACH_BUFF_"..string.upper(name), priority = priority })
        if onattachedfn ~= nil then
            onattachedfn(inst, target)
        end
    end

    local function OnExtended(inst, target)
        inst.components.timer:StopTimer("buffover")
        inst.components.timer:StartTimer("buffover", duration)

        target:PushEvent("foodbuffattached", { buff = "ANNOUNCE_ATTACH_BUFF_"..string.upper(name), priority = priority })
        if onextendedfn ~= nil then
            onextendedfn(inst, target)
        end
    end

    local function OnDetached(inst, target)
        if ondetachedfn ~= nil then
            ondetachedfn(inst, target)
        end

        target:PushEvent("foodbuffdetached", { buff = "ANNOUNCE_DETACH_BUFF_"..string.upper(name), priority = priority })
        inst:Remove()
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()

        --[[Non-networked entity]]
        --inst.entity:SetCanSleep(false)
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetDetachedFn(OnDetached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff.keepondespawn = true

        inst:AddComponent("timer")
        inst.components.timer:StartTimer("buffover", duration)
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end

    return Prefab("buff_"..name, fn, nil, prefabs)
end

return MakeBuff("super_attack", attack_attach, nil, attack_detach, 10, 1),
    MakeBuff("speedup", speed_attach, nil, speed_detach, TUNING.BUFF_ATTACK_DURATION, 1),
    MakeBuff("taunt", taunt_attach, nil, nil, 15, 1),
    MakeBuff("waterwalk", waterwalk_attach, nil, waterwalk_detach, TUNING.BUFF_ATTACK_DURATION, 1)