

local LineProjectile = Class(function(self, inst)
    self.inst = inst
    self.owner = nil
    self.angle = nil
    self.start = nil
    self.dest = nil
    self.cancatch = false

    self.speed = nil
    self.hitdist = 1
    self.range = nil
    self.onthrown = nil
    self.onhit = nil
    self.onmiss = nil
    self.oncaught = nil

    self.stimuli = nil
    self.maxdist = 25

    self.attacked = {}

	--self.has_damage_set = nil -- set to true if the projectile has its own damage set, instead of needed to get it from the launching weapon

    --self.delaytask = nil
    --self.delayowner = nil
    --self.delaypos = nil
    self._ondelaycancel = function() inst:Remove() end

    --NOTE: projectile and complexprojectile components are mutually
    --      exclusive because they share this tag!
    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("lineprojectile")
end,
nil,
{
})

local function StopTrackingDelayOwner(self)
    if self.delayowner ~= nil then
        self.inst:RemoveEventCallback("onremove", self._ondelaycancel, self.delayowner)
        self.inst:RemoveEventCallback("newstate", self._ondelaycancel, self.delayowner)
        self.delayowner = nil
    end
end

local function StartTrackingDelayOwner(self, owner)
    if owner ~= self.delayowner then
        StopTrackingDelayOwner(self)
        if owner ~= nil then
            self.inst:ListenForEvent("onremove", self._ondelaycancel, owner)
            self.inst:ListenForEvent("newstate", self._ondelaycancel, owner)
            self.delayowner = owner
        end
    end
end

function LineProjectile:OnRemoveFromEntity()
    self.inst:RemoveTag("projectile")
    StopTrackingDelayOwner(self)
end

function LineProjectile:GetDebugString()
    return string.format("target: %s, owner %s", tostring(self.target), tostring(self.owner))
end

function LineProjectile:SetSpeed(speed)
    self.speed = speed
end

function LineProjectile:SetStimuli(stimuli)
    self.stimuli = stimuli
end

function LineProjectile:SetRange(range)
    self.range = range
end

function LineProjectile:SetHitDist(dist)
    self.hitdist = dist
end

function LineProjectile:SetOnThrownFn(fn)
    self.onthrown = fn
end

function LineProjectile:SetOnHitFn(fn)
    self.onhit = fn
end

function LineProjectile:SetOnMissFn(fn)
    self.onmiss = fn
end

function LineProjectile:SetLaunchOffset(offset)
    self.launchoffset = offset -- x is radius, y is height, z is ignored
end


function LineProjectile:Throw(owner, angle, attacker)
    self.attacked = {}
    self.angle = angle
    self.owner = owner
    self.start = owner:GetPosition()
    self.inst.Physics:ClearCollidesWith(COLLISION.LIMITS)

    if attacker ~= nil and self.launchoffset ~= nil then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local facing_angle = attacker.Transform:GetRotation() * DEGREES
        self.inst.Transform:SetPosition(x + self.launchoffset.x * math.cos(facing_angle), y + self.launchoffset.y, z - self.launchoffset.x * math.sin(facing_angle))
        self.attacker = attacker
    end

    self:RotateTo(angle)
    self.inst.Physics:SetMotorVel(self.speed, 0, 0)
    self.inst:StartUpdatingComponent(self)
    if self.onthrown ~= nil then
        self.onthrown(self.inst, owner, angle, attacker)
    end
end


function LineProjectile:Stop()
    self.inst.Physics:CollidesWith(COLLISION.LIMITS)
    
    self.inst:StopUpdatingComponent(self)
    self.owner = nil
    self.delaypos = nil
end

function LineProjectile:Lost()
    self:Stop()
    self.inst:Remove()
end

function LineProjectile:Hit(target)
    local attacker = self.owner
    local weapon = self.inst
	
    if attacker.components.combat == nil and attacker.components.weapon ~= nil and attacker.components.inventoryitem ~= nil then
        weapon = (self.has_damage_set and weapon.components.weapon ~= nil) and weapon or attacker
        attacker = self.attacker or attacker.components.inventoryitem.owner
    end

    if target:HasTag("reflectproject") then
        --table.insert(self.attacked, target)
        local angle = math.random() * 360
        self:Throw(target, angle, target)
        return
    end

    if self.onprehit ~= nil then
        self.onprehit(self.inst, attacker, target)
    end
    if attacker ~= nil and attacker.components.combat ~= nil then
		if attacker.components.combat.ignorehitrange then
	        attacker.components.combat:DoAttack(target, weapon, self.inst, self.stimuli)
		else
			attacker.components.combat.ignorehitrange = true
			attacker.components.combat:DoAttack(target, weapon, self.inst, self.stimuli)
			attacker.components.combat.ignorehitrange = false
		end
        table.insert(self.attacked, target)
    end
    if self.onhit ~= nil then
        self.onhit(self.inst, attacker, target)
    end
end


local function CheckTarget(target)
    return target ~= nil
        and target:IsValid()
        and not target:IsInLimbo()
        and target.entity:IsVisible()
        and (target.sg == nil or
            not (target.sg:HasStateTag("flight") or
                target.sg:HasStateTag("invisible")))
end

local function RestoreDelayPos(inst, pos, rot)
    if inst.Physics ~= nil then
        inst.Physics:Teleport(pos:Get())
    else
        inst.Transform:SetPosition(pos:Get())
    end
    inst.Transform:SetRotation(rot)
end

local function AttackTarget(self, pos)
    local inst = self.inst
    local RETARGET_MUST_TAGS = { "_combat", "_health" }
    local RETARGET_CANT_TAGS = {}
    local NO_PVP_TAGS = {"player"}

    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, self.hitdist + 1, RETARGET_MUST_TAGS, (self.owner:HasTag("player") and not TheNet:GetPVPEnabled()) and NO_PVP_TAGS or RETARGET_CANT_TAGS)
    for _, guy in pairs(ents) do
        if guy.entity:IsVisible()
        and CheckTarget(guy)
        and not table.contains(self.attacked, guy)
        and not guy.components.health:IsDead()
        and (guy.components.combat.target == inst or
            guy.components.combat.target == self.owner or
            guy:HasTag("player") or
            guy:HasTag("character") or
            guy:HasTag("monster") or
            guy:HasTag("fly") or
            guy:HasTag("epic") or 
            guy:HasTag("animal"))
        and (guy.components.follower == nil or 
            guy.components.follower:GetLeader() == nil or
            not self.owner:HasTag("player") or
            (TheNet:GetPVPEnabled() and
            guy.components.follower:GetLeader() ~= self.owner or
            not guy.components.follower:GetLeader():HasTag("player"))) then

            local range = guy:GetPhysicsRadius(0) + self.hitdist
            if distsq(pos, guy:GetPosition()) < range * range then
                self:Hit(guy)
            end
        end
    end
end

local function DoUpdate(self, pos, rot, force)
    if distsq(self.owner:GetPosition(), pos) > self.maxdist * self.maxdist then
        --超出最大距离，丢失
        self:Lost()
        return
    end
    if force then
         RestoreDelayPos(self.inst, pos, rot)
    end
    AttackTarget(self, pos)

end

function LineProjectile:OnUpdate(dt)
    local angle = self.angle

    local pos = self.inst:GetPosition()

    DoUpdate(self, pos)
end

function LineProjectile:OnSave()
    
end

function LineProjectile:RotateTo(angle)
    self.inst.Transform:SetRotation(angle)
end

function LineProjectile:LoadPostPass(newents, savedata)
    
end


return LineProjectile
