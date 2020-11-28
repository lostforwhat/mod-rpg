local SourceModifierList = require("util/sourcemodifierlist")
local MIN_CHANCE = 0
local MAX_CHANCE = 1
local MAX_HIT = 4

local function onchance(self, chance)
	self.net_data.chance:set(chance)
	if self.inst.components.crit then
		self.inst.components.crit:CalcRealChance()
	end
end

local function onmax_hit(self, hit)
	self.net_data.max_hit:set(hit)
end

local function onmin_hit(self, hit)
	self.net_data.min_hit:set(hit)
end

local function onextra_chance(self, extra_chance)

end

local function onreal_chance(self, val)
	if self.inst.components.crit then
		self.inst.components.crit:CalcRealChance()
	end
end

local Crit = Class(function(self, inst) 
    self.inst = inst

    self.net_data = {
    	chance = net_float(inst.GUID, "crit.chance", "critdirty"),
    	max_hit = net_shortint(inst.GUID, "crit.max_hit", "critdirty"),
    	min_hit = net_shortint(inst.GUID, "crit.min_hit", "critdirty"),
    	real_chance = net_float(inst.GUID, "cirt.real_chance", "critdirty")
    }

    self.default = 0
    self.chance = 0
    self.extra_chance = 0
    self.force_crit = false
    self.hit = 1
    self.max_hit = 2
    self.min_hit = 1
    --self.next_must_crit = false
    --self.extra_source_map = nil
    --self.luck_crit = false
    self.multipliers = SourceModifierList(self.inst)
end,
nil,
{
	chance = onchance,
	max_hit = onmax_hit,
	min_hit = onmin_hit,
	extra_chance = onreal_chance,
	force_crit = onreal_chance,
	next_must_crit = onreal_chance,
	luck_crit = onreal_chance,
})

--[[function Crit:OnSave()
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
end]]

function Crit:AddMultipliers(source, val)
	self.multipliers:SetModifier(source, val)
	self:CalcRealChance()
end

function Crit:RemoveMultipliers(source)
	self.multipliers:RemoveModifier(source)
	self:CalcRealChance()
end

function Crit:CalcRealChance()
	if TheWorld.ismastersim then
		self.net_data.real_chance:set((self.next_must_crit or self.force_crit or self.luck_crit) and 1 or self:GetFinalChance())
	end
end

function Crit:GetRealChance()
	return self.net_data.real_chance:value()
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
	return (self.chance + self.extra_chance) * (self.multipliers:Get() or 1)
end

function Crit:Effect()
	local effect = self.next_must_crit or self.force_crit or self.luck_crit or (math.random() < self:GetFinalChance())
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
	return self.net_data.max_hit:value() or self.max_hit or MAX_HIT
end

function Crit:GetMinHit()
	return self.net_data.min_hit:value() or self.min_hit < self.max_hit and self.min_hit or 1
end

function Crit:GetRandomHit()
	local max_hit = math.random(self.min_hit, self.max_hit)
	return math.random(self.min_hit, max_hit) or self.min_hit
end

function Crit:OnRemoveFromEntity()
    
end

return Crit