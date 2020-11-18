local MAX_LEVEL = 100

local function DefaultLevelUp(inst, level)
	if inst.components.extrameta then
		inst.components.extrameta.extra_hunger:SetModifier("levelup", level)
		inst.components.extrameta.extra_sanity:SetModifier("levelup", level)
		inst.components.extrameta.extra_health:SetModifier("levelup", level)
	end
end

local function WxLevelUp(inst, level)
	if inst.components.extrameta then
		inst.components.extrameta.extra_hunger:SetModifier("levelup", level*2)
		inst.components.extrameta.extra_sanity:SetModifier("levelup", level*2)
		inst.components.extrameta.extra_health:SetModifier("levelup", level*2)
	end
end

local level_fn_data = {
	wilson = DefaultLevelUp,
	wendy = DefaultLevelUp,
	willow = DefaultLevelUp,
	wathgrithr = DefaultLevelUp,
	wolfgang = DefaultLevelUp,
	wortox = DefaultLevelUp,
	wx78 = WxLevelUp,
	winona = DefaultLevelUp,
	wickerbottom = DefaultLevelUp,
	wes = DefaultLevelUp,
	woodie = DefaultLevelUp,
	wormwood = DefaultLevelUp,
	wurt = DefaultLevelUp,
	walter = DefaultLevelUp,
	waxwell = DefaultLevelUp,
	warly = DefaultLevelUp,
}

local function RecalcMeta(inst, level)
	local level_fn = level_fn_data[inst.prefab] or DefaultLevelUp
	level_fn(inst, level)
end

local function GetLevelUpNeedXp(lv)
	return lv*100 + lv*(lv-1)
end

local function OnLevel(self, level)
	self.net_data.level:set(level)
	RecalcMeta(self.inst, level)
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
		totalxp = net_float(inst.GUID, "level.totalxp", "xpdirty"),
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

function Level:OnSave()
	return {
		level = self.level or 1,
		xp = self.xp or 0,
		totalxp = self.totalxp or self.xp or 0
	}
end

function Level:OnLoad(data)
	if data and type(data) == "table" then
		self.level = data.level or 1
		self.xp = data.xp or 0
		self.totalxp = data.totalxp or data.xp or 0
	end
end

function Level:AddXp(xp)
	self.totalxp = self.totalxp + xp
	self.xp = self.xp + xp
	self:LevelCheck()
end

function Level:GetLevelUpNeedXp()
	if TheWorld.ismastersim then
		return GetLevelUpNeedXp(self.level or 1)
	else
		return GetLevelUpNeedXp(self.net_data.level:value() or 1)
	end
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