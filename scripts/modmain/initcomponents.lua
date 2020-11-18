local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING

AddComponentPostInit("leader", function(self) 
	local OldAddFollower = self.AddFollower
	function self:AddFollower(follower)
		if self.followers[follower] == nil and follower.components.follower ~= nil then
			self.inst:PushEvent("addfollower", {follower = follower})
		end
		OldAddFollower(self, follower)
	end
end)

--修改combat，注入暴击吸血致死等属性
AddComponentPostInit("combat", function(self)
	local function IsValidVictim(victim)
	    return victim ~= nil
	        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
	                victim:HasTag("veggie") or victim:HasTag("structure") or
	                victim:HasTag("wall") or victim:HasTag("balloon") or
	                victim:HasTag("groundspike") or victim:HasTag("smashable") or
	                victim:HasTag("companion") or victim:HasTag("visible"))
	        and victim.components.health ~= nil
	        and victim.components.combat ~= nil
	        and victim.components.freezable ~= nil
	end
	local OldGetAttacked = self.GetAttacked
	function self:GetAttacked(attacker, damage, weapon, stimuli)
		--注入改写伤害
		local extra_damage = 0
		local target = self.inst

		--先计算闪避
		if target.components.dodge and target.components.dodge:GetChance() > 0 then
			if target.components.dodge:Effect() then
				--damage = 0
				return OldGetAttacked(self, attacker, 0, weapon, stimuli)
			end
		end

		if attacker and IsValidVictim(target) and not target.components.health:IsInvincible() then
			--致死优先级最高, 出现致死后后面其他逻辑可忽略
			if attacker.components.attackdeath ~= nil then
				local base = 1
				local maxhp = target.components.health.maxhealth or 4000
				if maxhp > 4000 or target:HasTag("epic") then
					base = math.min(4000/maxhp, 1)
				end
				if attacker.components.attackdeath:Effect(base) then
					local absorb = target.components.health and target.components.health.absorb or 0
					if absorb < 1 then
		            	damage = maxhp * (1- math.clamp(absorb, 0, 1)) + 1 --修改伤害为致死
		            	return OldGetAttacked(self, attacker, damage + extra_damage, weapon, stimuli)
		            end
				end
			end
			--弱点攻击为附加伤害不参与暴击
			if attacker.components.attackbroken ~= nil then
				if attacker.components.attackbroken:Effect() then
					extra_damage = extra_damage + attacker.components.attackbroken:GetBrokenPercent() * 0.01 * (target.components.health.currenthealth or 0)
				end
			end
			--复仇为附加伤害
			if attacker.components.revenge ~= nil then
				local damageup = attacker.components.revenge:GetDamageUp(target) or 0
				extra_damage = extra_damage + damage * damageup
			end
			--暴击只增加基础伤害
			if attacker.components.crit ~= nil then
				--print("暴击测试")
				if attacker.components.crit:Effect() then
					--print("暴击生效")
					damage = damage * (attacker.components.crit:GetRandomHit() + 1)
				end
			end
			--附加伤害
			if attacker.components.extradamage ~= nil then
				extra_damage = extra_damage + attacker.components.extradamage:GetDamage(target)
			end
		end

		local unblocked = OldGetAttacked(self, attacker, damage + extra_damage, weapon, stimuli)
		if unblocked and attacker then
			--注入吸血和攻击特效
			if attacker.components.attackfrozen ~= nil then
				attacker.components.attackfrozen:Effect(target)
			end
			if attacker.components.lifesteal ~= nil then
				attacker.components.lifesteal:Effect(damage) --吸血只享受基础攻击和暴击收益
			end
			--反伤
			if target.components.attackback ~= nil then
				target.components.attackback:Effect(damage)
			end
			--复仇
			if target.components.revenge ~= nil then
				target.components.revenge:Onattcked(attacker)
			end
		end

		return blocked
	end
end)

--修改加入三围最大值的额外值
AddComponentPostInit("hunger", function(self)
	local OldSetMax = self.SetMax
	function self:SetMax(amount)
		OldSetMax(self, amount)
		self.default_max = amount
		self:ResetMax()
	end

	function self:ResetMax()
		local extra_val = 0
		if self.inst.components.extrameta then
			extra_val = self.inst.components.extrameta.extra_hunger:Get()
		end
		local percent = self:GetPercent()
		self.max = self.default_max + extra_val
		self:SetPercent(percent)
	end
end)

AddComponentPostInit("sanity", function(self)
	local OldSetMax = self.SetMax
	function self:SetMax(amount)
		OldSetMax(self, amount)
		self.default_max = amount
		self:ResetMax()
	end

	function self:ResetMax()
		local extra_val = 0
		if self.inst.components.extrameta then
			extra_val = self.inst.components.extrameta.extra_sanity:Get()
		end
		local percent = self:GetPercent()
		self.max = self.default_max + extra_val
		self:SetPercent(percent)
	end
end)

AddComponentPostInit("health", function(self)
	local OldSetMax = self.SetMaxHealth
	function self:SetMaxHealth(amount)
		OldSetMax(self, amount)
		self.default_max = amount
		self:ResetMax()
	end

	function self:ResetMax()
		local extra_val = 0
		if self.inst.components.extrameta then
			extra_val = self.inst.components.extrameta.extra_health:Get()
		end
		local percent = self:GetPercent()
		self.maxhealth = self.default_max + extra_val
		self:SetPercent(percent)
	end
end)

--修改快速垂钓
AddComponentPostInit("fishingrod", function(self)
	local OldStartFishing = self.StartFishing
	function self:StartFishing(target, fisherman)
		if fisherman and fisherman:HasTag("fishmaster") then
			if self.old_minwaittime == nil then
				self.old_minwaittime = self.minwaittime
			end
			if self.old_maxwaittime == nil then
				self.old_maxwaittime = self.maxwaittime
			end
			self.minwaittime = 1
			self.maxwaittime = 1
		else
			self.minwaittime = self.old_minwaittime or self.minwaittime
			self.maxwaittime = self.old_maxwaittime or self.maxwaittime
		end
		OldStartFishing(self, target, fisherman)
	end
end)

--修改一刀砍树等工作组件
AddComponentPostInit("workable", function(self)
	local OldWorkedBy = self.WorkedBy
	function self:WorkedBy(worker, numworks)
		if worker:HasTag("chopmaster") and self.action == _G.ACTIONS.CHOP then
			numworks = self.workleft
		end
		OldWorkedBy(self, worker, numworks)
	end
end)