
local NO_PVP_TAGS = {"ghost", "player"}
local function areahitcheck(target, attacker)
	local leader = target.components.follower and target.components.follower:GetLeader() or nil
	if leader == attacker then
		return false
	end
	if not TheNet:GetPVPEnabled() then
		for k,v in pairs(NO_PVP_TAGS) do
			if target:HasTag(v) or (leader ~= nil and leader:HasTag(v)) then
				return false
			end
		end
	end
	return true
end

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

local function OnPhotosynthesis(owner, level)
	if TheWorld.state.isday and not owner:HasTag("playerghost") then
		owner.components.hunger:DoDelta(1 + level*0.1)
	end
end

 -- 专属之一的方法，写这里，便于官方升级后不影响
local function MakeElectronic(inst, num)
    if type(num) ~= "number" then num = 0 end
    num = math.clamp(num, 0, 6)
    local left_num = num
    local leader
    if inst._electronic_formation ~= nil then
        leader = inst._electronic_formation
        if not leader.components.formationleader:IsFormationFull() then
            left_num = num - leader.components.formationleader:GetFormationSize()
        end
    end
    if left_num < 0 then
        local formation = leader.components.formationleader.formation
        for k, v in pairs(formation) do
            v:Remove()
            formation[k] = nil
            left_num = left_num + 1
            if left_num >= 0 then
                return
            end
        end
    end
    while(left_num > 0) do
        local ball = SpawnPrefab("electronic_ball")
        local x, y, z = inst.Transform:GetWorldPosition()
        ball.Transform:SetPosition(x + math.random()*4 - 2, y + math.random()*4 - 2, z + math.random()*4 - 2)
        ball.components.locomotor.walkspeed = inst.components.locomotor.runspeed or 6
        ball:MakeFormation(inst)
        left_num = left_num - 1

        ball:ListenForEvent("death", MakeElectronic, inst)
        ball:ListenForEvent("onremove", MakeElectronic, inst)
    end
end

local function RedirectToBalloon(inst, attacker, ...)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 25, {"balloon"}, {"NOCLICK", "notarget"})
	for i, ent in ipairs(ents) do
        if ent ~= attacker and ent:IsValid() then
            return ent
        end
    end
end

--保持和task_constant一致
local rate = 6

-- skill constant
skill_constant = {
	--专属
	{
		id="potionbuilder",
		name="魔法实验",
		max_level=1,
		exclusive={"wilson"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."通过魔法栏可以制作一些特殊能力的药水"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("potionbuilder")
			else
				owner:RemoveTag("potionbuilder")
			end
		end
	},
	{
		id="angrybernie",
		name="伯尼之怒",
		max_level=100,
		exclusive={"willow"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."伯尼因为愤怒而强化，增加生命值和攻击力\n"
			.."生命值: +"..(level * 10).."\n"
			.."攻击力: +"..(level + 20)
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			
		end
	},
	{
		id="limbofire",
		name="地狱之火",
		max_level=100,
		exclusive={"willow"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."攻击着火的敌人，附加100%伤害，伯尼附加"..(4*level).."%伤害"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			
		end
	},
	{
		id="hitaoe",
		name="横扫千军",
		max_level=11,
		step=0.05,
		exclusive={"wolfgang"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."攻击时对周围3码范围内单位附带"..(45 + level*self.step*100).."%伤害"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner.components.combat:EnableAreaDamage(true)
        		owner.components.combat:SetAreaDamage(3, 0.45 + level*self.step, areahitcheck)
			else
				owner.components.combat:EnableAreaDamage(false)
			end
		end
	},
	{
		id="abigailclone",
		name="灵魂分裂",
		max_level=1,
		exclusive={"wendy"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."阿比盖尔可以分裂出4个分身"
			return desc_str
		end,
	},
	{
		id="revengebody",
		name="复仇",
		max_level=20,
		exclusive={"wendy"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."伤害我们的人，都去死吧\n"
			.."伤害温蒂和阿比盖尔的单位会受到更多的伤害\n"
			.."每次提升伤害"..(5 + level).."%"
			return desc_str
		end,
		effect_fn=function(self, owner)
			local level = self:level_fn(owner)
			owner.components.revenge:SetPercent(level>0 and (5 + level) or 0)
		end
	},
	{
		id="metalbody",
		name="A处理器",
		max_level=1,
		exclusive={"wx78"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."齿轮额外提升100经验值（取消原升级效果）\n"
			.."升级属性额外+1"
			return desc_str
		end,
	},
	{
		id="electricprotection",
		name="电场保护",
		max_level=5,
		step = 3,
		exclusive={"wx78"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."过载时召唤电场离子保护自己\n"
			.."当前数量："..level.."\n"
			.."伤害: "..(5+level*self.step)
			return desc_str
		end,
		effect_fn=function(self, owner)
			local level = self:level_fn(owner)
			--owner:DoTaskInTime(.3, function(owner) 
			if owner:HasTag("overcharge") then
				MakeElectronic(owner, level)
			else
				MakeElectronic(owner, 0)
			end
			--end)
		end
	},
	{
		id="wxrunhit",
		name="机械冲刺",
		max_level=1,
		exclusive={"wx78"},
		hide=true,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."(未实现)"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				--owner:AddTag("wxrunhit")
			else
				--owner:RemoveTag("wxrunhit")
			end
		end
	},
	{
		id="newbookbuilder",
		name="禁忌之书",
		max_level=1,
		exclusive={"wickerbottom"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."学会编写图书馆未曾收藏的禁忌书籍"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("newbookbuilder")
			else
				owner:RemoveTag("newbookbuilder")
			end
		end
	},
	{
		id="flylucy",
		name="露西飞斧",
		max_level=11,
		step=0.5,
		exclusive={"woodie"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."扔出去命中的是斧头还是斧把呢\n"
			.."投掷范围: "..(5 + level*0.5).."\n"
			.."伤害: "..(TUNING.AXE_DAMAGE * .5).."~"..(TUNING.AXE_DAMAGE * .5 + level*20)
			return desc_str
		end,
	},
	{
		id="balloondummy",
		name="气球替身",
		max_level=1,
		exclusive={"wes"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."周围25码的气球会代替维斯承受伤害"
			return desc_str
		end,
		effect_fn=function(self, owner)
			local level = self:level_fn(owner)
			if level > 0 then
				owner.components.combat.exclusiveredirect = RedirectToBalloon
			else
				owner.components.combat.exclusiveredirect = nil
			end
		end
	},
	{
		id="sanityprotection",
		name="精神护体",
		max_level=1,
		exclusive={"waxwell"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."拥有强大的精神修为，可以投影出精神护盾\n"
			.."理智高于50%时每点理智可以抵消2点伤害"
			return desc_str
		end,
	},
	{
		id="inspirate",
		name="战技",
		max_level=11,
		step=0.0005,
		exclusive={"wathgrithr"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."每点鼓舞值提升"..(0.4 + level*self.step*100).."%伤害\n"
			.."鼓舞值大于90提升"..(10+level).."%暴击"
			return desc_str
		end
	},
	{
		id="spiderbody",
		name="蜘蛛体质",
		max_level=1,
		exclusive={"webber"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."合格的怪物是不需要理智的\n"
			.."升级不提升理智值，双倍提升生命值"
			return desc_str
		end,
	},
	{
		id="toomany",
		name="人多势众",
		max_level=1,
		exclusive={"webber"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."伙伴越多越强大，每个伙伴提升5%伤害和1%速度"
			return desc_str
		end,
	},
	{
		id="throwrocks",
		name="飞石术",
		max_level=11,
		exclusive={"winona"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."可使用石头作为武器，升级提升攻击及距离"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("throwrocks")
			else
				owner:RemoveTag("throwrocks")
			end
		end
	},
	{
		id="memorykill",
		name="鲜血记忆",
		max_level=1,
		exclusive={"warly"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."记忆每次击杀目标，下次对该目标伤害提升"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			if owner.components.extradamage then
				local step = self.step or 1
				local level = self:level_fn(owner) or 0
				owner.components.extradamage:EnableMemory(level > 0 )
			end
		end
	},
	{
		id="shootingmaster",
		name="连续射击",
		max_level=11,
		exclusive={"walter"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."提升弹弓射速和射程"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("shootingmaster")
			else
				owner:RemoveTag("shootingmaster")
			end
		end
	},
	{
		id="moresouls",
		name="灵魂掌控",
		max_level=30,
		step=1,
		exclusive={"wortox"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local step = self.step
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."提升可掌控的灵魂数量\n"
			.."可掌控灵魂数："..(level + TUNING.WORTOX_MAX_SOULS)
			return desc_str
		end,
	},
	{
		id="superjump",
		name="魔力跃击",
		max_level=11,
		step=0.2,
		exclusive={"wortox"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local step = self.step
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."灵魂跳跃时造成一次范围伤害\n"
			.."当前范围："..(5 + math.floor(level*step)).."  伤害: "..((1 + level*step)*100).."%"
			return desc_str
		end,
	},
	{
		id="photosynthesis",
		name="光合作用",
		max_level=20,
		exclusive={"wormwood"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."白天可通过阳光获取能量\n"
			.."每10秒补充饥饿值: "..(level * 0.1 + 1)
			return desc_str
		end,
		effect_fn=function(self, owner)
			local level = self:level_fn(owner)
			if owner.photosynthesis_task ~= nil then
				owner.photosynthesis_task:Cancel()
				owner.photosynthesis_task = nil
			end
			if level > 0 then
				owner.photosynthesis_task = owner:DoPeriodicTask(10, OnPhotosynthesis, 10, level)
			end
		end,
	},
	{
		id="seedsmagic",
		name="撒豆成兵",
		max_level=11,
		exclusive={"wormwood"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."种子就是我最大的武器，上吧我的伙伴\n"
			.."投掷伤害: " .. (level * 2 + 5).."\n"
			.."生成生物: " .. (level + 3)
			return desc_str
		end,
		effect_fn=function(self, owner)
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("seedsmagic")
			end
		end
	},
	{
		id="smoothskin",
		name="如鱼得水",
		max_level=20,
		exclusive={"wurt"},
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."光滑的皮肤很容易让对手攻击落空\n"
			.."潮湿值提升闪避,最大: "..(20 + level).."%"
			return desc_str
		end,
	},

	--基础技能
	{
		id="extra_hunger",
		name="额外饱腹",
		cost=5*rate,
		max_level=100,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."增加最大饥饿值: "..(level)
			return desc_str
		end,
		effect_fn=function(self, owner) 
			if owner.components.extrameta then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.extrameta.extra_hunger:SetModifier("extra_hunger", step*level)
				owner.components.hunger:ResetMax()
			end
		end
	},
	{
		id="extra_sanity",
		name="额外精神",
		cost=5*rate,
		max_level=100,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."增加最大精神值: "..(level)
			return desc_str
		end,
		effect_fn=function(self, owner) 
			if owner.components.extrameta then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.extrameta.extra_sanity:SetModifier("extra_sanity", step*level)
				owner.components.sanity:ResetMax()
			end
		end
	},
	{
		id="extra_health",
		name="额外生命",
		cost=6*rate,
		max_level=100,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."增加最大生命值: "..(level)
			return desc_str
		end,
		effect_fn=function(self, owner) 
			if owner.components.extrameta then
				local step = self.step or 1
				local level = self:level_fn(owner)
				owner.components.extrameta.extra_health:SetModifier("extra_health", step*level)
				owner.components.health:ResetMax()
			end
		end
	},
	{
		id="extra_damage",
		name="附加伤害",
		cost=12*rate,
		max_level=100,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."每次攻击附加伤害: "..(level)
			return desc_str
		end,
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
		cost=10*rate,
		step=0.01,
		max_level=10,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."增加移动速度: "..(level*self.step*100).."%"
			return desc_str
		end,
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
		cost=5*rate,
		step=0.01,
		max_level=60,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."增加暴击几率: "..(level*self.step*100).."%"
			return desc_str
		end,
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
		cost=10*rate,
		step=1,
		max_level=20,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."每次攻击恢复当前伤害"..(level*self.step).."%的生命值"
			return desc_str
		end,
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
		cost=10*rate,
		max_level=20,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."基础伤害提升: "..(level).."%"
			return desc_str
		end,
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
		cost=20*rate,
		step=0.01,
		max_level=10,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."增加闪避几率: "..(level*self.step*100).."%"
			return desc_str
		end,
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
		cost=5*rate,
		step=1,
		max_level=100,
		grade=1,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."增加荆棘值："..(level*self.step).."%"
			return desc_str
		end,
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
		--cost=30,
		max_level=5,
		step=0.02,
		grade=3,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."攻击有几率附加基于目标最大生命值的伤害\n"
			.."触发几率: "..(level*self.step*100).."%\n"
			.."伤害值: "..(level*5).."%"
			return desc_str
		end,
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
		grade=4,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."每次攻击有"..(level).."%几率直接使目标死亡"
			return desc_str
		end,
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
		name="冰霜攻击",
		cost=20*rate,
		max_level=5,
		step=0.05,
		grade=3,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."攻击时有几率使目标冰冻："..(level*self.step*100).."%"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			if owner.components.attackfrozen then
				local step = self.step or 0.01
				local level = self:level_fn(owner)
				owner.components.attackfrozen:SetChance(step*level)
			end
		end
	},
	{
		id="rejectdeath",
		name="回光返照",
		max_level=1,
		hide=true,
		grade=3,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."免疫一次死亡并在5秒内持续回复50%生命值"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				if owner.components.rejectdeath == nil then
					owner:AddComponent("rejectdeath")
				end

			else
				if owner.components.rejectdeath ~= nil then
					owner:RemoveComponent("rejectdeath")
				end
			end
		end
	},
	{
		id="stealth",
		name="伪装",
		max_level=5,
		hide=true,
		grade=3,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."短时间内进行伪装，怪物无法看到自己\n"
			.."持续时间: "..(5 + level).."s (R)"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if owner.components.stealth then
				owner.components.stealth:Enabled(level > 0)
				owner.components.stealth.level = level
			end
		end
	},

	--生活技能
	{
		id="fishmaster",
		name="快速垂钓",
		cost=40*rate,
		grade=2,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."提升钓鱼技巧，一秒上钩"
			return desc_str
		end,
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
		cost=40*rate,
		grade=2,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."伐木能手，一刀砍倒"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("chopmaster")
			else
				owner:RemoveTag("chopmaster")
			end
		end
	},
	{
		id="minemaster",
		name="快速采矿",
		cost=40*rate,
		grade=2,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."再多的矿，一秒挖光"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("minemaster")
			else
				owner:RemoveTag("minemaster")
			end
		end
	},
	{
		id="cookmaster",
		name="快速烹饪",
		grade=2,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."加大火力，即刻完成烹饪"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("cookmaster")
			else
				owner:RemoveTag("cookmaster")
			end
		end
	},
	{
		id="pickmaster",
		name="快速采集",
		grade=2,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."采集手法熟练到位"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if level > 0 then
				owner:AddTag("pickmaster")
			else
				owner:RemoveTag("pickmaster")
			end
		end
	},
	{
		id="stealer",
		name="探云手",
		max_level=5,
		--grade=3,
		desc_fn=function(self, owner)
			local desc_str = self.name
			local level = self:level_fn(owner)
			local max_level = self.max_level or 1
			local max = level >= max_level and " (Max)" or ""
			desc_str = desc_str.."\n Lv:"..level..max.."\n"
			.."每次攻击有几率偷取物品\n"
			.."当前几率: "..(level).."%"
			return desc_str
		end,
		effect_fn=function(self, owner) 
			local level = self:level_fn(owner)
			if owner.components.stealer ~= nil then
				owner.components.stealer.level = level
				owner.components.stealer.chance = level * 0.01
			end
		end
	},
}

local skills_str = {unknown="???"}
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

	skills_str[string.upper(v.id)] = v.name
end
ids = nil
STRINGS.NAMES.SKILLS = skills_str