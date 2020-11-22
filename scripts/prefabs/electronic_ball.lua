local assets =
{
    Asset("ANIM", "anim/electronic_ball.zip"),
    Asset("SOUND", "sound/chess.fsb"),
}


local FORMATION_ROTATION_SPEED = 6.2
local FORMATION_RADIUS = 2.7
local FORMATION_SEARCH_RADIUS = 8
local FORMATION_MAX_SPEED = 18.5
local FORMATION_MAX_OFFSET = 0.3
local FORMATION_OFFSET_LERP = 0.2
local FORMATION_MAX_DELTA_SQ = 16*16



local function LeaderOnUpdate(inst)
    local leader = inst.components.formationleader
    if leader.target ~= nil and leader.target:IsValid() then
        local x, y, z = inst.Transform:GetWorldPosition()
        local tx, ty, tz = leader.target.Transform:GetWorldPosition()

        if VecUtil_LengthSq(tx - x, tz - z) > FORMATION_MAX_DELTA_SQ then
            leader:DisbandFormation()
            return
        end

        local r = -(leader.target.Transform:GetRotation() / RADIANS)

        local targetoffsetdistance = leader.target.components.locomotor.walkspeed * (leader.target.components.locomotor.wantstomoveforward and FORMATION_MAX_OFFSET or 0)
        local targetoffset_x = tx + math.cos(r) * targetoffsetdistance
        local targetoffset_z = tz + math.sin(r) * targetoffsetdistance

        -- inst._offset is initialized in MakeFormation()
        inst._offset.x = Lerp(inst._offset.x, targetoffset_x, FORMATION_OFFSET_LERP)
        inst._offset.z = Lerp(inst._offset.z, targetoffset_z, FORMATION_OFFSET_LERP)
        
        inst.Transform:SetPosition(inst._offset.x, ty, inst._offset.z)
    end
end

local function CheckStatus(inst)
    if inst.components.follower:GetLeader() == nil then
        inst:Remove()
    end
end

local function FollowerOnUpdate(inst, targetpos)
    CheckStatus(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local dist = VecUtil_Length(targetpos.x - x, targetpos.z - z)

    inst.components.locomotor.walkspeed = math.max(dist * 30, FORMATION_MAX_SPEED)
    inst:FacePoint(targetpos.x, 0, targetpos.z)
    if inst.updatecomponents[inst.components.locomotor] == nil then
        inst.components.locomotor:WalkForward(true)
    end
end


local function OnLeaveFormation(inst, leader)
    --inst:Remove()
end

local function OnEnterFormation(inst, leader)
    inst.components.locomotor:Stop()

    inst:AddTag("NOBLOCK")
end

local function onformationdisband(inst)
    if inst.components.formationleader.target ~= nil then
        inst.components.formationleader.target._electronic_formation = nil
        inst:Remove()
    end
end

local MakeFormation = function(inst, target)
    if target._electronic_formation ~= nil then
        local leaders = {target._electronic_formation}
        inst.components.formationfollower:SearchForFormation(leaders)
        return
    end
    local leader = SpawnPrefab("formationleader")
    leader.persists = false
    
    local x, y, z = inst.Transform:GetWorldPosition()
    leader.Transform:SetPosition(x, y, z)
    leader._offset = leader:GetPosition()

    leader.components.formationleader:SetUp(target, inst)

    target._electronic_formation = leader
    leader.components.formationleader.ondisbandfn = onformationdisband

    leader.components.formationleader.min_formation_size = 1
    leader.components.formationleader.max_formation_size = 6

    leader.components.formationleader.radius = FORMATION_RADIUS
    leader.components.formationleader.thetaincrement = FORMATION_ROTATION_SPEED
    
    leader.components.formationleader.onupdatefn = LeaderOnUpdate

    inst.components.formationfollower.active = true
    inst.components.locomotor.directdrive = true

    leader:ListenForEvent("onremove", function() onformationdisband(leader) end, target)
    leader:ListenForEvent("death", function() onformationdisband(leader) end, target)

    inst:ListenForEvent("onremove", function() inst:Remove() end, leader)
end

local function oncollide(inst, other)
    local leader = inst.components.follower:GetLeader()
    if other ~= nil and other:IsValid() and leader ~= nil then
        if other.components.health ~= nil and
            not other.components.health:IsDead() and 
            leader.components.combat ~= nil and
            leader.components.combat:CanTarget(other) and
            (not TheNet:GetPVPEnabled() and not other:HasTag("player") or true) then
                local damage = 5
                if leader.components.skilldata then
                    local skill = leader.components.skilldata.skills["electricprotection"]
                    local extra_damge = skill:level_fn(leader) * (skill.step or 0)
                    damage = damage + extra_damge
                end
                other.components.combat:GetAttacked(leader, damage)
        end
    end
end

local function updateLight(inst)
    if TheWorld.state.isnight then
        inst.Light:Enable(true)
    else
        inst.Light:Enable(false)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    --inst.entity:AddDynamicShadow()
    inst.entity:AddLightWatcher()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeGhostPhysics(inst, 1, .5)
    inst.Physics:CollidesWith(COLLISION.FLYERS)
    inst.Transform:SetScale(.7, .7, 1)
    
    --inst.DynamicShadow:SetSize(1, .5)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("electronic_ball")
    inst.AnimState:SetBuild("electronic_ball")
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:SetLightOverride(1)
    
    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(0.2)
    inst.Light:SetColour(237/255, 237/255, 209/255)
    inst.Light:Enable(true)

    inst:AddTag("flying")
    inst:AddTag("ignorewalkableplatformdrowning")
    inst:AddTag("insect")
    inst:AddTag("smallcreature")
    inst:AddTag("lightbattery")

    inst:AddTag("NOCLICK")

    --MakeInventoryFloatable(inst)
    
    --MakeFeedableSmallLivestockPristine(inst)

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end
    inst.persists = false

    inst.Physics:SetCollisionCallback(oncollide)

    -- inst._formation_distribution_toggle = nil

    -- inst._find_target_task = nil

    inst:AddComponent("locomotor")
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.walkspeed = TUNING.LIGHTFLIER.WALK_SPEED
    inst.components.locomotor.pathcaps = { allowocean = true }

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "lightbulb"

    inst:AddComponent("follower")

    inst:AddComponent("formationfollower")
    inst.components.formationfollower.searchradius = FORMATION_SEARCH_RADIUS
    inst.components.formationfollower.formation_type = "electronic_ball"
    inst.components.formationfollower.onupdatefn = FollowerOnUpdate
    inst.components.formationfollower.onleaveformationfn = OnLeaveFormation
    inst.components.formationfollower.onenterformationfn = OnEnterFormation

    inst.MakeFormation = MakeFormation

    inst:WatchWorldState("isnight", updateLight)
    updateLight(inst)

    inst:DoTaskInTime(5, CheckStatus)
    return inst
end

return Prefab("electronic_ball", fn, assets)
