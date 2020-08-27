local MIN_CHANCE = 0
local MAX_CHANCE = 100
local MAX_HIT = 4

local function onchance(self, chance)

end

local Crit = Class(function(self, inst) 
    self.inst = inst
    self.default = 0
    self.chance = 0
    self.extra_chance = 0
    self.force_crit = false
    self.hit = 1
    self.max_hit = MAX_HIT
    self.min_hit = 1
    --self.next_must_crit = false
    --self.extra_source_map = nil
    --self.luck_crit = false
end,
nil,
{
	chance = onchance,
})

function Crit:OnSave()
	return {
		chance = self.chance,
		max_hit = self.max_hit
	}
end

function Crit:OnLoad(data)
	if data ~= nil then
		self.chance = data.chance or 0
		self.max_hit = data.max_hit or MAX_HIT
	end
end

function Crit:SetChance(val)
	if val > MAX_CHANCE then
		self.chance = MAX_CHANCE
		return
	end
	if val < MIN_CHANCE then
		self.chance = MIN_CHANCE
		return
	end
	self.chance = val
end

function Crit:AddExtraChance(source, val)
	if self.extra_source_map == nil then
		self.extra_source_map = {}
	end
	self.extra_source_map[source] = val
	self.extra_chance = 0
	for k, v in pairs(self.extra_source_map) do
		if k and v then
			self.extra_chance = self.extra_chance + v
		end
	end
end

function Crit:RemoveExtraChance(source)
	if self.extra_source_map ~= nil and self.extra_source_map[source] then
		self.extra_source_map[source] = nil
		self.extra_chance = 0
		for k, v in pairs(self.extra_source_map) do
			if k and v then
				self.extra_chance = self.extra_chance + v
			end
		end
	end
end

function Crit:GetExtra()
	return self.extra_chance or 0
end

function Crit:GetFinalChance()
	return self.chance + self.extra_chance
end

function Crit:Effect()
	local effect = self.next_must_crit or self.force_crit or self.luck_crit or (math.random(100) < self:GetFinalChance())
	if self.next_must_crit then self.next_must_crit=false end
	return effect
end

function Crit:SetMaxHit(hit)
	self.max_hit = hit
end

function Crit:SetMinHit(hit)
	self.min_hit = hit
end

function Crit:GetMaxHit()
	return self.max_hit or MAX_HIT
end

function Crit:GetMinHit()
	return self.min_hit < self.max_hit and self.min_hit or 1
end

function Crit:GetRandomHit()
	local max_hit = math.random(self.min_hit, self.max_hit)
	return math.random(self.min_hit, max_hit) or self.min_hit
end

function Crit:OnRemoveFromEntity()
    
end

return Crit