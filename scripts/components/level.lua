local MAX_LEVEL = 100
--[[
	*****************
	特别注意！
	只有跟等级相关的变化才写这里，避免资源消耗
	人物初始化属性写postinit里
	*****************
]]
local function DefaultLevelUp(inst, level)
	if inst.components.extrameta then
		inst.components.extrameta.extra_hunger:SetModifier("levelup", level)
		inst.components.extrameta.extra_sanity:SetModifier("levelup", level)
		inst.components.extrameta.extra_health:SetModifier("levelup", level)
	end
end

local function WxLevelUp(inst, level)
	if inst.components.extrameta then
		inst.components.extrameta.extra_hunger:SetModifier("levelup", (level)*2)
		inst.components.extrameta.extra_sanity:SetModifier("levelup", (level)*2)
		inst.components.extrameta.extra_health:SetModifier("levelup", (level)*2)
	end
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("electricprotection", math.clamp(math.floor(level*0.05) + 1, 1, 5))
	end
end

local function WathgrithrLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	
	if inst.components.skilldata then
		local inspiratelevel = math.floor(level*0.1) + 1
		inst.components.skilldata:SetLevel("inspirate", inspiratelevel)
	end
end

local function WolfgangLevelUp(inst, level)
	DefaultLevelUp(inst, level)

	if inst.components.skilldata then
		local skilllevel = math.floor(level*0.1) + 1
		inst.components.skilldata:SetLevel("hitaoe", skilllevel)
	end
end

local function WinonaLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("throwrocks", math.floor(level*0.1) + 1)
	end
end

local function WalterLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("shootingmaster", math.floor(level*0.1) + 1)
	end
end

local function WortoxLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("superjump", math.floor(level*0.1) + 1)
		inst.components.skilldata:SetLevel("moresouls", math.clamp(math.ceil(level * 0.5), 1, 30))
	end
end

local function WurtLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("smoothskin", math.clamp(math.ceil(level * 0.5), 1, 20))
	end
end

local function WormwoodLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("photosynthesis", math.clamp(math.ceil(level * 0.5), 1, 20))
		inst.components.skilldata:SetLevel("seedsmagic", math.clamp(math.ceil(level * 0.1), 1, 11))
	end
end

local function WoodieLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("flylucy", math.clamp(math.ceil(level*0.2), 1, 11))
	end
end

local function WebberLevelUp(inst, level)
	if inst.components.extrameta then
		inst.components.extrameta.extra_hunger:SetModifier("levelup", level)
		inst.components.extrameta.extra_health:SetModifier("levelup", (level)*2)
	end
end

local function WesLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		
	end
end

local function WillowLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("angrybernie", level)
	end
end

local function WendyLevelUp(inst, level)
	DefaultLevelUp(inst, level)
	if inst.components.skilldata then
		inst.components.skilldata:SetLevel("revengebody", math.clamp(math.ceil(level * 0.5), 1, 20))
	end
end

local level_fn_data = {
	wilson = DefaultLevelUp,
	wendy = WendyLevelUp,
	willow = WillowLevelUp,
	wathgrithr = WathgrithrLevelUp,
	wolfgang = WolfgangLevelUp,
	wortox = WortoxLevelUp,
	wx78 = WxLevelUp,
	winona = WinonaLevelUp,
	wickerbottom = DefaultLevelUp,
	wes = WesLevelUp,
	woodie = WoodieLevelUp,
	wormwood = WormwoodLevelUp,
	wurt = WurtLevelUp,
	walter = WalterLevelUp,
	waxwell = DefaultLevelUp,
	warly = DefaultLevelUp,
	webber = WebberLevelUp,
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
	self.deathtimes = 0
	self.killplayers = 0
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
		totalxp = self.totalxp or self.xp or 0,
		deathtimes = self.deathtimes or 0,
		killplayers = self.killplayers or 0
	}
end

function Level:OnLoad(data)
	if data and type(data) == "table" then
		self.level = data.level or 1
		self.xp = data.xp or 0
		self.totalxp = data.totalxp or data.xp or 0
		self.deathtimes = data.deathtimes or 0
		self.killplayers = data.killplayers or 0
	end
	self:LevelUp() -- trigger RecalcMeta(self.inst, level)
end

function Level:ReduceXp(value)
	if self.xp >= value then
		self.xp = self.xp - value
	elseif self.level > 1 then
		self.level = self.level - 1
		if self.xp + GetLevelUpNeedXp(self.level) >= value then
			self.xp = self.xp + GetLevelUpNeedXp(self.level) - value
		else
			self.xp = 0
		end
	else
		self.xp = 0
	end
end

function Level:AddKillPlayer()
	self.killplayers = self.killplayers + 1
end

function Level:ReduceXpOnDeath()
	self.deathtimes = self.deathtimes + 1
	self:ReduceXp(self.level * 40 + 50)
end

function Level:ReduceLevel()
	if self.level > 1 then
		self.level = self.level - 1
		self:LevelCheck()
	else
		self.xp = 0
	end
end

function Level:AddXp(xp)
	xp = math.clamp(xp, 0, 99999) --防止崩内存
	self.totalxp = self.totalxp + xp
	self.xp = self.xp + xp
	if self.level < MAX_LEVEL then
		self:LevelCheck()
	end
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
	RecalcMeta(self.inst, self.level)
end

return Level