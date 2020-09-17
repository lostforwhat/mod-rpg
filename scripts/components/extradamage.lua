local DEFAULT_DAMAGE = 0

local function OnCommon(self, common)

end

local function OnSpecail(self, special)

end

local function OnMemorykilldata(self, memorykilldata)

end


local ExtraDamage = Class(function(self, inst) 
    self.inst = inst
    self.common = DEFAULT_DAMAGE
    self.memorykilldata = {}
    self.memory_enable = false
    self.next_temp = 0
    self.onkilledfn = function(inst, data)
        self:OnKilled(data.victim)
    end
    self.inst:ListenForEvent("killed", self.onkilledfn)
end,
nil,
{
    common = OnCommon,
    memorykilldata = OnMemorykilldata
})

function ExtraDamage:OnKilled(victim)
    if self.memory_enable and not victim:HasTag("invisible") and not victim:HasTag("INLIMBO") then
        local hp = victim.components.health and victim.components.health.maxhealth or 0

        self:AddMemoryDamage(victim, 1 + math.floor(hp*0.0002))
    end
end

function ExtraDamage:AddMemoryDamage(target, damage)
    local prefab = target.prefab
    if self.memorykilldata[prefab] == nil then
        self.memorykilldata[prefab] = damage
    else
        self.memorykilldata[prefab] = self.memorykilldata[prefab] + damage
    end
end

--孰能生巧技能需打开此开关
function ExtraDamage:EnableMemory(enable)
    self.memory_enable = enable == true
end

function ExtraDamage:SetDamage(damage)
    self.common = damage
end

function ExtraDamage:AddDamage(damage)
    self.common = self.common + damage
end

function ExtraDamage:GetDamage(target)
    if self.memory_enable and target and target.prefab then
        local memory = self.memorykilldata[target.prefab] or 0
        return self.common + memory + self.next_temp
    end
    return self.common + self.next_temp
end

function ExtraDamage:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("killed", self.onkilledfn)
end

function ExtraDamage:OnSave()
    return {
        common = self.common,
        memorykilldata = self.memorykilldata,
        memory_enable = self.memory_enable
    }
end

function ExtraDamage:OnLoad(data)
    if data ~= nil then
        self.common = data.common or DEFAULT_DAMAGE
        self.memorykilldata = data.memorykilldata or {}
        self.memory_enable = data.memory_enable or false
    end
end


return ExtraDamage