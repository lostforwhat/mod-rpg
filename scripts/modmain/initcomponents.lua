local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING

--修复打包导致的存档崩溃问题
AddComponentPostInit("entitytracker", function(self)
    self.OnSave = function()
        if _G.next(self.entities) == nil then
            return
        end

        local ents = {}
        local refs = {}

        for k, v in pairs(self.entities) do
            if v and v.inst and v.inst.GUID then
                table.insert(ents, { name = k, GUID = v.inst.GUID })
                table.insert(refs, v.inst.GUID)
            end
        end

        return { entities = ents }, refs
    end
end)

AddComponentPostInit("leader", function(self) 
	local OldAddFollower = self.AddFollower
	function self:AddFollower(follower)
		if self.followers[follower] == nil and follower.components.follower ~= nil then
			self.inst:PushEvent("addfollower", {follower = follower})
		end
		OldAddFollower(self, follower)
	end
end)

AddComponentPostInit("follower", function(self) 
	self.inst:ListenForEvent("killed", function(inst, data) 
		local leader = self:GetLeader()
		if leader ~= nil and leader:HasTag("player") then
			leader:PushEvent("killed", data)
		end
	end)
end)

--修改combat，注入暴击吸血致死等属性
AddComponentPostInit("combat", function(self)
	local function IsValidVictim(victim)
	    return victim ~= nil
	        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
	                victim:HasTag("veggie") or victim:HasTag("structure") or
	                victim:HasTag("wall") or victim:HasTag("balloon") or
	                victim:HasTag("groundspike") or victim:HasTag("smashable") or
	                victim:HasTag("companion") or victim:HasTag("INLIMBO"))
	        and victim.components.health ~= nil
	        and victim.components.combat ~= nil
	end
	local OldGetAttacked = self.GetAttacked
	function self:GetAttacked(attacker, damage, weapon, stimuli)
		--注入改写伤害
		local extra_damage = 0
		local target = self.inst

		if attacker ~= nil then
			--避免boss互掐
			if target:HasTag("epic") and attacker:HasTag("epic") then
				target:DoTaskInTime(0, function()
					if target.components.combat:TargetIs(attacker) then 
						target.components.combat:DropTarget()
					end
					if attacker.components.combat:TargetIs(target) then
						attacker.components.combat:DropTarget()
					end
				end)
				return OldGetAttacked(self, attacker, 0, weapon, stimuli)
			end

			--王者之巅秒杀
			if attacker:HasTag("player") and 
				not attacker:HasTag("playerghost") 
				and IsValidVictim(target)
				and attacker:HasTag("titles_king") then
				local player_health = attacker.components.health.maxhealth or 0
				local target_health = target.components.health.maxhealth or 0
				if player_health > target_health then
					target.components.health.currenthealth = 0.01
					return OldGetAttacked(self, attacker, 1, weapon, stimuli)
				end
			end

			--先计算闪避
			if target.components.dodge and target.components.dodge:GetChance() > 0 then
				if target.components.dodge:Effect() then
					--damage = 0
					return OldGetAttacked(self, attacker, 0, weapon, stimuli)
				end
			end

			if IsValidVictim(target) and not target.components.health:IsInvincible() then
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
				--如果有悠然自得，先计算悠然自得
				if attacker:HasTag("leisurely") then
					damage = math.random() * 3 * damage
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
			if unblocked then
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

			return unblocked
		else
			return OldGetAttacked(self, attacker, damage, weapon, stimuli)
		end	
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
		if worker:HasTag("minemaster") and self.action == _G.ACTIONS.MINE then
			numworks = self.workleft
		end
		OldWorkedBy(self, worker, numworks)
	end
end)

AddComponentPostInit("groundpounder", function(self)
	local WALKABLEPLATFORM_TAGS = {"walkableplatform"}
	local OldDestroyPoints = self.DestroyPoints
	function self:DestroyPoints(points, breakobjects, dodamage, pushplatforms)
		if self.inst:HasTag("soulstealer") then
			self.inst.components.combat.ignorehitrange = true
			local getEnts = breakobjects or dodamage
		    local map = _G.TheWorld.Map
		    for k, v in pairs(points) do
		        if getEnts then
		            local ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
		            if #ents > 0 then
		                if breakobjects then
		                    for i, v2 in ipairs(ents) do
		                        if v2 ~= self.inst and v2:IsValid() then
		                            -- Don't net any insects when we do work
		                            if self.destroyer and
		                                v2.components.workable ~= nil and
		                                v2.components.workable:CanBeWorked() and
		                                v2.components.workable.action ~= _G.ACTIONS.NET then
		                                v2.components.workable:Destroy(self.inst)
		                            end
		                            if v2:IsValid() and --might've changed after work?
		                                not v2:IsInLimbo() and --might've changed after work?
		                                self.burner and
		                                v2.components.fueled == nil and
		                                v2.components.burnable ~= nil and
		                                not v2.components.burnable:IsBurning() and
		                                not v2:HasTag("burnt") then
		                                v2.components.burnable:Ignite()
		                            end
		                        end
		                    end
		                end
		                if dodamage then
		                    for i, v2 in ipairs(ents) do
		                        if v2 ~= self.inst and
		                            v2:IsValid() and
		                            v2.components.health ~= nil and
		                            not v2.components.health:IsDead() and 
		                            self.inst.components.combat:CanTarget(v2) then
		                            self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
		                        end
		                    end
		                end
		            end
		        end

		        if pushplatforms then
		            local platform_ents = TheSim:FindEntities(v.x, v.y, v.z, 3 + TUNING.MAX_WALKABLE_PLATFORM_RADIUS, WALKABLEPLATFORM_TAGS, self.noTags)
		            for i, p_ent in ipairs(platform_ents) do
		                if p_ent ~= self.inst and p_ent:IsValid() and p_ent.Transform ~= nil and p_ent.components.boatphysics ~= nil then
		                    local v2x, v2y, v2z = p_ent.Transform:GetWorldPosition()
		                    local mx, mz = v2x - v.x, v2z - v.z
		                    if mx ~= 0 or mz ~= 0 then
		                        local normalx, normalz = _G.VecUtil_Normalize(mx, mz)
		                        p_ent.components.boatphysics:ApplyForce(normalx, normalz, 5)
		                    end
		                end
		            end
		        end

		        if map:IsPassableAtPoint(v:Get()) then
		            _G.SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
		        end
		    end
		    self.inst.components.combat.ignorehitrange = false
		else
			OldDestroyPoints(self, points, breakobjects, dodamage, pushplatforms)
		end
	end
end)

AddComponentPostInit("edible", function(self)
	self.xpvalue = self.xpvalue or 0
	function self:GetXp(eater)
		if self.xpvalue == 0 then
			local hunger_val = self:GetHunger(eater)
	        local sanity_val = self:GetSanity(eater)
	        local health_val = self:GetHealth(eater)
	        return math.floor(hunger_val*0.05 + sanity_val*0.12 + health_val*0.1)
	    end
	    return self.xpvalue
	end
end)

AddComponentPostInit("eater", function(self)
	local Old_Eat = self.Eat
	function self:Eat(food, feeder)
		if Old_Eat(self, food, feeder) then
			if self.inst.components.level ~= nil then
				local mult = self.inst.components.vip and self.inst.components.vip.level > 0 and 1.5 or 1
	            local delta = food.components.edible:GetXp(self.inst)
	            if delta ~= 0 then
	                self.inst.components.level:AddXp(delta * mult)
	            end
	        end
			return true
		end
	end
end)

--修改死亡掉落
AddComponentPostInit("inventory", function(self)
	local Old_DropEverything = self.DropEverything
	function self:DropEverything(ondeath, keepequip)
		if not ondeath or not self.inst:HasTag("player") then
			return Old_DropEverything(self, ondeath, keepequip)
		end
		if self.activeitem ~= nil then
	        self:DropItem(self.activeitem)
	        self:SetActiveItem(nil)
	    end

	    local items = {}
		for k = 1, self.maxslots do
	        local v = self.itemslots[k]
	        if v ~= nil then
	        	if v.prefab == "amulet" then
	        		self:DropItem(v, true, true)
	        	else
	        		table.insert(items, v)
	        	end
	        end
	    end
	    if #items > 0 then
		    local shoulddropped = items[math.random(#items)]
		    self:DropItem(shoulddropped, true, true)
		end

	    if not keepequip then
	        for k, v in pairs(self.equipslots) do
	            if not (ondeath and v.components.inventoryitem.keepondeath) then
	                self:DropItem(v, true, true)
	            end
	        end
	    end
	end
end)

--修改武器等级附加伤害
AddComponentPostInit("weapon", function(self)
	function self:SetDamage(dmg)
		self.damage = dmg
		self:RecalcDamage()
	end

	function self:GetDamage(attacker, target)
		local extra_damage = self.extra_damage or 0
		return ((type(self.damage) == "function" and self.damage(self.inst, attacker, target))
            or self.damage or 0) + extra_damage
	end

	function self:RecalcDamage()
		local base = type(self.damage) == "number" and (self.damage * 0.03) or 1
		--公式: y = 0.25*x2 + x
		local level = self.inst.components.weaponlevel and self.inst.components.weaponlevel.level or 0
		self.extra_damage = (level * level * 0.25 + level) * base
	end
end)

--修改怪物掉落
AddComponentPostInit("lootdropper", function(self) 
	
end)