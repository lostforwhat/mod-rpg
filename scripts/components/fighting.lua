local MAX_HIT = 20
local DEFAULT_INCREASE = 0.01
local DEFAULT_CD = 5

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or victim:HasTag("structure") or
                victim:HasTag("wall") or victim:HasTag("balloon") or
                victim:HasTag("groundspike") or victim:HasTag("smashable") or
                victim:HasTag("companion") or victim:HasTag("visible"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
        and victim.components.freezable ~= nil
end

local function OnIncrease(self, increase)
    self.inst.components.combat.externaldamagemultipliers:SetModifier("fighting", 1 + self.hit*increase)
end

local function OnHit(self, hit)
    self.hit_reduce_cd = DEFAULT_CD
    self.inst.components.combat.externaldamagemultipliers:SetModifier("fighting", 1 + hit*self.increase)
end

local function OnEnabled(self, enabled)
    if not enabled then
        self.hit = 0
        self.inst.components.combat.externaldamagemultipliers:RemoveModifier("fighting")
    end
end

local Fighting = Class(function(self, inst) 
    self.inst = inst
    self.enabled = false
    self.increase = DEFAULT_INCREASE
    self.hit = 0
    self.hit_reduce_cd = DEFAULT_CD
    self.onhitotherfn = function(inst, data)
        self:OnHitohter(data.target)
    end
    self.inst:ListenForEvent("onhitother", self.onkilledfn)
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