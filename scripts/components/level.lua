local MAX_LEVEL = 200

local function onlevel(self, level)

end

local function onxp(self, xp)

end

local function ontotalxp(self, totalxp)

end

local Level = Class(function(self, inst)
    self.inst = inst
	self.level = 1
    self.xp = 0
	self.totalxp = 0
	
end,
nil,
{
    level = onlevel,
	xp = onxp,
	totalxp = ontotalxp
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