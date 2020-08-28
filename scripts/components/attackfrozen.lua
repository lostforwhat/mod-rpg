local MIN_CHANCE = 0
local MAX_CHANCE = 1
local DEFAULT_CHANCE = 0.2

local function onchance(self, chance)

end

local AttackFrozen = Class(function(self, inst) 
    self.inst = inst
    self.default = 0
    self.chance = DEFAULT_CHANCE
    self.coldness = 1
    self.freezetime = 2
    self.extra_chance = 0
    self.force_frozen = false
    --self.next_force_frozen = false
end,
nil,
{
    chance = onchance,
})

function AttackFrozen:GetFinalChance()
    return self.chance + self.extra_chance
end

function AttackFrozen:Effect(target)
    local effect = self.force_frozen or self.next_force_frozen or math.random() < self:GetFinalChance()
    if effect and target and target.components.freezable ~= nil then
        target.components.freezable:AddColdness(self.coldness, self.freezetime)
        if self.next_force_frozen then self.next_force_frozen = false end
    end
    return effect
end

function AttackFrozen:OnRemoveFromEntity()
    
end

function AttackFrozen:OnSave()
    return {
        chance = self.chance,
        coldness = self.coldness,
        freezetime = self.freezetime,
    }
end

function AttackFrozen:OnLoad(data)
    if data ~= nil then
        self.chance = data.chance or DEFAULT_CHANCE
        self.coldness = data.coldness or 1
        self.freezetime = data.freezetime or 2
    end
end


return AttackFrozen