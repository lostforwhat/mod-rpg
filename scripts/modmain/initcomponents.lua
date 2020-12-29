local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
local difficulty_level = TUNING.level

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

	local function AddImpact(attacker, target, scale)
		scale = scale or 1
		local impactfx = _G.SpawnPrefab("impact")
	    if impactfx ~= nil and target.components.combat then
	    	impactfx.Transform:SetScale(scale, scale, scale)
	        local follower = impactfx.entity:AddFollower()
	        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
	        if attacker ~= nil and attacker:IsValid() then
	            impactfx:FacePoint(attacker.Transform:GetWorldPosition())
	        end
	        if target.SoundEmitter ~= nil then
                target.SoundEmitter:PlaySound("dontstarve/common/whip_large", nil, 0.3)
            end
	    end
	end

	local function ApplyMiss(target, attacker)
		local miss = _G.SpawnPrefab("display_effect")
		local rad = target:GetPhysicsRadius(0)
		local x, y, z = target.Transform:GetWorldPosition()
		miss.Transform:SetPosition(x, y + .5 * rad , z)
		miss:Display("闪避", 36, {1, .2, .2})
	end

	local function ApplyBroken(attacker, target)
		local broken = _G.SpawnPrefab("display_effect")
		local rad = attacker:GetPhysicsRadius(0)
		local x, y, z = attacker.Transform:GetWorldPosition()
		broken.Transform:SetPosition(x, y + .5 * rad , z)
		broken:Display("击破", 46, {.2, .1, 1})
	end

	local function ApplyCrit(attacker, target, rate)
		local crit = _G.SpawnPrefab("display_effect")
		local rad = attacker:GetPhysicsRadius(0)
		local x, y, z = attacker.Transform:GetWorldPosition()
		crit.Transform:SetPosition(x, y + .5 * rad , z)
		local str = "暴击"
		if rate > 2 then
			str = str .. "x" .. rate
		end
		crit:Display(str, 38 + rate, {.6, .1, 1})
		AddImpact(attacker, target, .4 + .3 * rate)
	end

	local function ApplyKing(attacker, target)
		local king = _G.SpawnPrefab("display_effect")
		local rad = attacker:GetPhysicsRadius(0)
		local x, y, z = attacker.Transform:GetWorldPosition()
		king.Transform:SetPosition(x, y + .5 * rad , z)
		king:Display("蔑视", 46, {.3, .1, .5})

		if target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound("dontstarve/common/whip_large", nil, 0.3)
        end
	end

	local function ApplyDeath(attacker, target)
		local death = _G.SpawnPrefab("display_effect")
		local rad = attacker:GetPhysicsRadius(0)
		local x, y, z = attacker.Transform:GetWorldPosition()
		death.Transform:SetPosition(x, y + .5 * rad , z)
		death:Display("致死", 46, {.3, .1, .5})

		if target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound("dontstarve/common/whip_large", nil, 0.3)
        end
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
					ApplyKing(attacker, target)
					return OldGetAttacked(self, attacker, 1, weapon, stimuli)
				end
			end

			--先计算闪避
			if target.components.dodge and target.components.dodge:GetChance() > 0 then
				if target.components.dodge:Effect() then
					--damage = 0
					ApplyMiss(target, attacker)
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
			            	ApplyDeath(attacker, target)
			            	return OldGetAttacked(self, attacker, damage + extra_damage, weapon, stimuli)
			            end
					end
				end
				--如果有悠然自得，先计算悠然自得
				if attacker:HasTag("leisurely") then
					damage = math.random() * 3 * damage
				end
				--量子套装效果
				if attacker:HasTag("suit_quantum") then
					damage = damage * (1.5 - math.random())
				end
				--弱点攻击为附加伤害不参与暴击
				if attacker.components.attackbroken ~= nil then
					if attacker.components.attackbroken:Effect() then
						extra_damage = extra_damage + attacker.components.attackbroken:GetBrokenPercent() * 0.01 * (target.components.health.currenthealth or 0)
						ApplyBroken(attacker, target)
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
						local rate = attacker.components.crit:GetRandomHit() + 1
						damage = damage * rate
						ApplyCrit(attacker, target, rate)
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
		self.extra_damage = math.floor((level * level * 0.25 + level) * base * 100) * 0.01
	end
end)

--修改怪物掉落
AddComponentPostInit("lootdropper", function(self) 
	local OldGenerateLoot = self.GenerateLoot
	function self:GenerateLoot()
		local newloots = {}
	    local loots = OldGenerateLoot(self)
	    for _, v in pairs(loots) do
	    	if math.random() < (1 / difficulty_level) then
	    		table.insert(newloots, v)
	    	end
	    end
	    return newloots
	end

	local OldDropLoot = self.DropLoot
	function self:DropLoot(pt)
		OldDropLoot(self, pt)
		if _G.TheWorld:HasTag("doubledrop") then
			OldDropLoot(self, pt)
		end
	end
end)

--修改弹道类组件
AddComponentPostInit("projectile", function(self)
	local function CreateWeapon()
		local weapon = _G.CreateEntity()
        --[[Non-networked entity]]
        weapon.entity:AddTransform()
        weapon:AddComponent("weapon")
        weapon.components.weapon:SetDamage(10)
        weapon:AddComponent("inventoryitem")
        weapon.persists = false
        weapon.components.inventoryitem:SetOnDroppedFn(weapon.Remove)
        return weapon
	end

	local function StopTrackingDelayOwner(self)
	    if self.delayowner ~= nil then
	        self.inst:RemoveEventCallback("onremove", self._ondelaycancel, self.delayowner)
	        self.inst:RemoveEventCallback("newstate", self._ondelaycancel, self.delayowner)
	        self.delayowner = nil
	    end
	end

	local OldHit = self.Hit
	function self:Hit(target)
		if target:HasTag("reflectproject") then
			if target ~= self.owner then
				--self:Throw(target, self.owner)
				local attacker = self.owner
				local weapon = self.inst
				if attacker.components.combat == nil and attacker.components.weapon ~= nil and attacker.components.inventoryitem ~= nil then
			        weapon = (self.has_damage_set and weapon.components.weapon ~= nil) and weapon or attacker
			        attacker = attacker.components.inventoryitem.owner
			    end
				self:Miss(target)
				local newprojectile = _G.SpawnPrefab(self.inst.prefab)
				newprojectile.Transform:SetPosition(target.Transform:GetWorldPosition())

				weapon = target.components.combat:GetWeapon() or weapon
				newprojectile.components.projectile:Throw(weapon, attacker, target)
				newprojectile.components.projectile.attacker = target
				self.inst:Remove()
			elseif self.cancatch and target.components.catcher ~= nil then
				self:Catch(target)
			else
				self:Miss(target)
			end
		else
			local attacker = self.owner
		    local weapon = self.inst
		    StopTrackingDelayOwner(self)
		    self:Stop()
		    self.inst.Physics:Stop()
			
		    if attacker.components.combat == nil and attacker.components.weapon ~= nil and attacker.components.inventoryitem ~= nil then
		        weapon = (self.has_damage_set and weapon.components.weapon ~= nil) and weapon or attacker
		        attacker = self.attacker or attacker.components.inventoryitem.owner
		    end

		    if self.onprehit ~= nil then
		        self.onprehit(self.inst, attacker, target)
		    end
		    if attacker ~= nil and attacker.components.combat ~= nil then
				if attacker.components.combat.ignorehitrange then
			        attacker.components.combat:DoAttack(target, weapon, self.inst, self.stimuli)
				else
					attacker.components.combat.ignorehitrange = true
					attacker.components.combat:DoAttack(target, weapon, self.inst, self.stimuli)
					attacker.components.combat.ignorehitrange = false
				end
		    end
		    if self.onhit ~= nil then
		        self.onhit(self.inst, attacker, target)
		    end
			--return OldHit(self, target)
		end
	end

end)