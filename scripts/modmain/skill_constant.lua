function DefaultSkillLevelFn(self, owner)
	local id = self.id
	if owner and owner.components.skilldata then
		return owner.components.skilldata:GetLevel(id)
	end
	return 0
end

function DefaultSkillLevelUpFn(self, owner, amount)
	if type(amount) ~= "number" then
		amount = 1
	end
	if owner and owner.components.skilldata then
		local id = self.id
		local max_level = self.max_level or 1
		local level = owner.components.skilldata:GetLevel(id)
		if level + amount > max_level then
			return
		end
		owner.components.skilldata:LevelUp(id, amount)
	end
end

function DefaultSkillDescFn(self, owner)
	local name = self.name
	local level = self:level_fn(owner)
	local max_level = self.max_level or 1
	if level >= max_level then
		level = ""..level.." (MAX)"
	end
	local desc_str = name.."\n".."Lv: "..level
	local cost = self.cost or 0
	if cost > 0 then
		desc_str = desc_str.."\n".."消耗: "..cost
	end
	return desc_str
end

-- skill constant
skill_constant = {
	{
		id="extra_hunger",
		name="额外饱腹",
		cost=5,
		max_level=100,
		effect_fn=function(self, owner) 
			if owner.components.extrameta then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.extrameta.extra_hunger:SetModifier("extra_hunger", step*level)
			end
		end
	},
	{
		id="extra_sanity",
		name="额外精神",
		cost=5,
		max_level=100,
		effect_fn=function(self, owner) 
			if owner.components.extrameta then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.extrameta.extra_sanity:SetModifier("extra_sanity", step*level)
			end
		end
	},
	{
		id="extra_health",
		name="额外生命",
		cost=6,
		max_level=100,
		effect_fn=function(self, owner) 
			if owner.components.extrameta then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.extrameta.extra_health:SetModifier("extra_health", step*level)
			end
		end
	},
	{
		id="extra_damage",
		name="附加伤害",
		cost=12,
		max_level=100,
		effect_fn=function(self, owner) 
			if owner.components.extradamage then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.extradamage:SetDamage(step*level)
			end
		end
	},
	{
		id="extra_speed",
		name="额外移速",
		cost=10,
		max_level=10,
		effect_fn=function(self, owner) 
			if owner.components.locomotor then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.locomotor:SetExternalSpeedMultiplier(owner, "extra_speed", 1 + step*level)
			end
		end
	},
	{
		id="crit",
		name="暴击",
		cost=5,
		max_level=60,
		effect_fn=function(self, owner) 
			if owner.components.crit then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.crit:SetChance(step*level)
			end
		end
	},
	{
		id="lifesteal",
		name="生命偷取",
		cost=10,
		max_level=20,
		effect_fn=function(self, owner) 
			if owner.components.lifesteal then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.lifesteal:SetPercent(step*level)
			end
		end
	},
	{
		id="damageup",
		name="力量",
		cost=10,
		max_level=20,
		effect_fn=function(self, owner) 
			if owner.components.combat then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.combat.externaldamagemultipliers:SetModifier("damageup", 1 + step*level)
			end
		end
	},
	{
		id="miss",
		name="闪避",
		cost=20,
		max_level=10,
		effect_fn=function(self, owner) 
			if owner.components.dodge then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.dodge:SetChance(step*level)
			end
		end
	},
	{
		id="attackback",
		name="伤害反弹",
		cost=5,
		max_level=100,
		effect_fn=function(self, owner) 
			if owner.components.attackback then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.attackback:SetPercent(step*level)
			end
		end
	},
	{
		id="attackbroken",
		name="弱点击破",
		cost=30,
		max_level=5,
		step=0.02,
		effect_fn=function(self, owner) 
			if owner.components.attackbroken then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.attackbroken:SetChance(step*level)
				owner.components.attackbroken:SetBrokenPercent(5*level)
			end
		end
	},
	{
		id="attackdeath",
		name="致死",
		--cost=80,
		effect_fn=function(self, owner) 
			if owner.components.attackdeath then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.attackdeath:SetChance(step*level)
			end
		end
	},
	{
		id="attackfrozen",
		name="冰冻",
		cost=20,
		max_level=5,
		step=0.05,
		effect_fn=function(self, owner) 
			if owner.components.attackfrozen then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.attackfrozen:SetChance(step*level)
			end
		end
	},
	

	--生活技能
	{
		id="fishmaster",
		name="快速垂钓",
		cost=40,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("fishmaster")
			else
				owner:RemoveTag("fishmaster")
			end
		end
	},
	{
		id="chopmaster",
		name="一刀伐木",
		cost=40,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("chopmaster")
			else
				owner:RemoveTag("chopmaster")
			end
		end
	},
	
}

--检测data数据
local ids = {}
for k,v in pairs(skill_constant) do
	if v.id == nil then
		v.id = k
	end
	if v.level_fn == nil then
		v.level_fn = DefaultSkillLevelFn
	end
	if v.levelup_fn == nil then
		v.levelup_fn = DefaultSkillLevelUpFn
	end
	if v.desc_fn == nil then
		v.desc_fn = DefaultSkillDescFn
	end
	if table.contains(ids, v.id) then
		v.id = v.id..k
	end
	table.insert(ids, v.id)
end
ids = nil