local MIN_CHANCE = 0
local MAX_CHANCE = 100
local DEFAULT_CHANCE = 5

local function onchance(self, chance)

end

local AttackBroken = Class(function(self, inst) 
    self.inst = inst
    self.chance = DEFAULT_CHANCE
    self.extra_chance = 0
    self.force_broken = false
    --self.next_force_broken = false
    self.broken_percent = 10
end,
nil,
{
    chance = onchance,
})

function AttackBroken:SetChance(chance)
    if chance>=MIN_CHANCE and chance<=MAX_CHANCE then
        self.chance = chance
    end
end

function AttackBroken:SetExtra(extra)
    if extra>=MIN_CHANCE and extra<=MAX_CHANCE then
        self.extra_chance = extra
    end
end

function AttackBroken:GetFinalChance()
    return (self.chance + self.extra_chance) or 0
end

function AttackBroken:GetBrokenPercent()
    return self.broken_percent or 0
end

--每次攻击执行这个函数，若返回true，则执行触发代码
function AttackBroken:Effect()
    local effect = self.next_force_broken or self.force_broken or (math.random(100)<self:GetFinalChance())
    if self.next_force_broken then self.next_force_broken = false end
    return effect
end

function AttackBroken:OnRemoveFromEntity()
    
end

function AttackBroken:OnSave()
    return {
        chance = self.chance,
        extra_chance = self.extra_chance
    }
end

function AttackBroken:OnLoad(data)
    if data ~= nil then
        self.chance = data.chance or DEFAULT_CHANCE
        self.extra_chance = data.extra_chance or 0
    end
end


return AttackBroken