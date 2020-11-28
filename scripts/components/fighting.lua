--女武神改版后废弃，直接使用激励值代替
local MAX_HIT = 20
local DEFAULT_INCREASE = 0.01
local DEFAULT_CD = 5

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or victim:HasTag("structure") or
                victim:HasTag("wall") or victim:HasTag("balloon") or
                victim:HasTag("groundspike") or victim:HasTag("smashable") or
                victim:HasTag("companion") or victim:HasTag("INLIMBO"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
end

local function OnIncrease(self, increase)
    if self.inst.components.fighting then
        self.inst.components.fighting:CalcDamage()
    end
end

local function OnHit(self, hit)
    if self.inst.components.fighting then
        self.inst.components.fighting:RestCooldown()
        self.inst.components.fighting:CalcDamage()
    end
end

local function OnEnabled(self, enabled)
    if self.inst.components.fighting then
        self.inst.components.fighting:CalcDamage()
    end
end

local function OnHitohter(inst, data)
    if inst.components.fighting then
        inst.components.fighting:OnHitohter(data.target)
    end
end

local Fighting = Class(function(self, inst) 
    self.inst = inst
    self.increase = DEFAULT_INCREASE
    self.hit = 0
    self.hit_reduce_cd = DEFAULT_CD
    self.enabled = false

    self.inst:ListenForEvent("onhitother", OnHitohter)
    self.inst:StartUpdatingComponent(self)
end,
nil,
{
    increase = OnIncrease,
    hit = OnHit,
    enabled = OnEnabled
})

function Fighting:Enable(enabled)
    self.enabled = enabled == true
end

function Fighting:OnHitohter(target)
    if self.enabled and IsValidVictim(target) then
        self.hit = self.hit + 1
    end
end

function Fighting:ReduceCD(dt)
    self.hit_reduce_cd = self.hit_reduce_cd - dt
    if self.hit_reduce_cd < 0 then
        self.hit_reduce_cd = 0
    end
end

function Fighting:RestCooldown()
    if self.enabled and self.hit > 0 and self.increase > 0 then
        self.hit_reduce_cd = DEFAULT_CD
    end
end

function Fighting:CalcDamage()
    if self.enabled then
        local hit = self.hit or 0
        local increase = self.increase or 0
        self.inst.components.combat.externaldamagemultipliers:SetModifier("fighting", 1 + hit*increase)
    else
        self.inst.components.combat.externaldamagemultipliers:RemoveModifier("fighting")
        --self.hit = 0
    end
end


function Fighting:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("onhitother", self.onhitotherfn)
end

function Fighting:OnSave()
    return {
        enabled = self.enabled,
        increase = self.increase,
        --hit = self.hit
    }
end

function Fighting:OnLoad(data)
    if data ~= nil then
        self.enabled = data.enabled or false
        self.increase = data.increase or DEFAULT_INCREASE
        --self.hit = data.hit or 0
    end
end

function Fighting:OnUpdate(dt)
    if self.hit > 0 then
        if self.hit_reduce_cd > 0 then
            self:ReduceCD(dt)
        else
            self.hit = self.hit - 1
        end
    end
end


return Fighting