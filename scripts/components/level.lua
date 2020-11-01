local MAX_LEVEL = 200

local function OnLevel(self, level)
	self.net_data.level:set(level)
end

local function OnXp(self, xp)
	self.net_data.xp:set(xp)
end

local function OnTotalxp(self, totalxp)
	self.net_data.totalxp:set(totalxp)
end

local Level = Class(function(self, inst)
    self.inst = inst
	
	self.net_data = {
		level = net_shortint(inst.GUID, "level.level", "leveldirty"),
		xp = net_float(inst.GUID, "level.xp", "xpdirty"),
		totalxp = net_float(inst.GUID, "level.totalxp", "totalxpdirty"),
	}

	self.level = 1
    self.xp = 0
	self.totalxp = 0
end,
nil,
{
    level = OnLevel,
	xp = OnXp,
	totalxp = OnTotalxp
})


function Level:AddXp(xp)
	self.totalxp = self.totalxp + xp
	self.xp = self.xp + xp
	self:LevelCheck()
end

function Level:GetLevelUpNeedXp()
	return self.level*100 + self.level*self.level
end

function Level:LevelCheck()
	while(self.xp >= self:GetLevelUpNeedXp()) do
		self:LevelUp()
	end
end

function Level:LevelUp()
	--升级,二次判断
	if self.level < MAX_LEVEL and self.xp >= self:GetLevelUpNeedXp() then
		self.xp = self.xp - self:GetLevelUpNeedXp()
		self.level = self.level + 1
		self.inst.SoundEmitter:PlaySound("dontstarve/HUD/research_available")
	end
end

return Level