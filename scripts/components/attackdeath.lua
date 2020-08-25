local MIN_CHANCE = 0
local MAX_CHANCE = 100
local DEFAULT_CHANCE = 1

local function onchance(self, chance)

end

local AttackDeath = Class(function(self, inst) 
    self.inst = inst
    self.default = 0
    self.chance = DEFAULT_CHANCE
    self.extra_chance = 0
    self.force_death = false
    --self.next_force_death = false
end,
nil,
{
    chance = onchance,
})

function AttackDeath:SetExtra(extra)
    if extra <= MAX_CHANCE and extra >= MIN_CHANCE then
        self.extra_chance = extra
    end
end

function AttackDeath:GetChance()
    return self.chance + self.extra_chance
end

function AttackDeath:Effect(base)
    base = base or 1
    local effect = self.next_force_death or self.force_death or (math.radom(100)<self:GetChance() and (base and math.radom()<base))
    if self.next_force_death then self.next_force_death = false end
    return effect
end

function AttackDeath:OnRemoveFromEntity()
    
end

function AttackDeath:OnSave()
    return {
        chance = self.chance
    }
end

function AttackDeath:OnLoad(data)
    if data ~= nil then
        self.chance = data.chance or DEFAULT_CHANCE
    end
end


return AttackDeath