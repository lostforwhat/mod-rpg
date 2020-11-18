local MAX_CHANCE = 1
local MIN_CHANCE = 0

local function onchance(self, val)
	self.net_data.chance:set(val)
end 

local function onextra_chance(self, val)
	self.net_data.extra_chance:set(val)
end

local Dodge = Class(function(self, inst) 
    self.inst = inst
    self.net_data = {
    	chance = net_float(inst.GUID, "dodge.chance", "dodgedirty"),
    	extra_chance = net_float(inst.GUID, "dodge.extra_chance", "dodgedirty")
    }
    self.chance = 0
    self.extra_chance = 0
end, 
nil,
{
	chance = onchance,
	extra_chance = onextra_chance,
})

--[[function Dodge:OnSave()
	return {
		chance = self.chance or 0
	}
end

function Dodge:OnLoad(data)
	self.chance = data.chance or 0
end]]

function Dodge:SetChance(chance)
	if TheWorld.ismastersim then
		self.chance = chance
		if self.chance < MIN_CHANCE then
			self.chance = MIN_CHANCE
		end
		if self.chance > MAX_CHANCE then
			self.chance = MAX_CHANCE
		end
	end	
end

function Dodge:GetChance()
	if TheWorld.ismastersim then
		return self.chance
	else
		return self.net_data.chance:value()
	end
end

function Dodge:GetExtraChance()
	if TheWorld.ismastersim then
		return self.extra_chance
	else
		return self.net_data.extra_chance:value()
	end
end

function Dodge:GetFinalChance()
	if TheWorld.ismastersim then
		return self.chance + self.extra_chance
	else
		return self.net_data.chance:value() + self.net_data.extra_chance:value()
	end
end

function Dodge:AddExtraChance(source, val)
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

function Dodge:RemoveExtraChance(source)
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

function Dodge:Effect()
    return math.random() < self.chance
end

return Dodge