local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
env.require = GLOBAL.require

local PlayerStatus = require('widgets/playerstatus')


PrefabFiles = {}

--添加mod新物品
table.insert(PrefabFiles, "package_ball")
table.insert(PrefabFiles, "package_staff")
table.insert(PrefabFiles, "prayer_symbol")
table.insert(PrefabFiles, "seffc")
table.insert(PrefabFiles, "abigail_clone")
table.insert(PrefabFiles, "book_treat")
table.insert(PrefabFiles, "book_kill")
table.insert(PrefabFiles, "book_season")
table.insert(PrefabFiles, "magic_circle")
table.insert(PrefabFiles, "potion_achiv")
table.insert(PrefabFiles, "potions")
table.insert(PrefabFiles, "deadbone")
table.insert(PrefabFiles, "wes_clone")
table.insert(PrefabFiles, "achiv_clear")

table.insert(PrefabFiles, "titles_fx")

modimport("scripts/strings.lua")
modimport("scripts/tumbleweed_pick.lua")
modimport("scripts/modactions")

Assets = {
	Asset("ATLAS", "images/hud/email.xml"),
    Asset("IMAGE", "images/hud/email.tex"),
}

--角色初始化
AddPlayerPostInit(function(inst) 
	inst:AddComponent("attackdeath")
	inst:AddComponent("attackbroken")
	inst:AddComponent("attackback")
	inst:AddComponent("attackfrozen")
	inst:AddComponent("lifesteal")
	inst:AddComponent("crit")
	inst:AddComponent("level")
	inst:AddComponent("luck")
	inst:AddComponent("extradamage")
	--inst:AddComponent("revenge")

	local prefab = inst.prefab
	if prefab == "wilson" then

	end
	if prefab == "wendy" then
		inst:AddComponent("revenge")
	end
	if prefab == "willow" then

	end
	if prefab == "wathgrithr" then

	end
	if prefab == "wolfgang" then

	end
	if prefab == "wortox" then

	end
	if prefab == "wx78" then

	end
	if prefab == "winona" then

	end
	if prefab == "wickerbottom" then

	end
	if prefab == "wes" then

	end
	if prefab == "woodie" then

	end
	if prefab == "wormwood" then

	end
	if prefab == "wurt" then

	end
	if prefab == "walter" then

	end
	if prefab == "waxwell" then

	end

	if not GLOBAL.TheNet:GetIsClient() then
        inst.components.attackdeath:SetChance(0)
        inst.components.attackbroken:SetChance(0)
        inst.components.attackfrozen:SetChance(0)
    end

end)

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

--修改combat，注入暴击吸血致死等属性
AddComponentPostInit("combat", function(self)
	local self.OldGetAttacked = self.GetAttacked
	function self:GetAttacked(attacker, damage, weapon, stimuli)
		--注入改写伤害
		local extra_damage = 0
		local target = self.inst

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
		            	return self:OldGetAttacked(attacker, damage + extra_damage, weapon, stimuli)
		            end
				end
			else
				--弱点攻击为附加伤害不参与暴击
				if attacker.components.attackbroken ~= nil then
					if attacker.components.attackbroken:Effect() then
						extra_damage = extra_damage + attacker.components.attackbroken:GetBrokenPercent() * (target.components.health.currenthealth or 0)
					end
				end
				--复仇为附加伤害
				if attacker.components.revenge ~= nil then
					local damageup = attacker.components.revenge:GetDamageUp(target) or 0
					extra_damage = extra_damage + damage * damageup
				end
				--暴击只增加基础伤害
				if attacker.components.crit ~= nil then
					if attacker.components.crit:Effect() then
						damage = damage * (attacker.components.crit:GetRandomHit() + 1)
					end
				end
				--附加伤害
				if attacker.components.extradamage ~= nil then
					extra_damage = extra_damage + attacker.components.extradamage:GetDamage(target)
				end
			end
		end

		local blocked = self:OldGetAttacked(attacker, damage + extra_damage, weapon, stimuli)
		
		if not blocked then
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

--添加modUI
local function AddPlayerStatus(self)
	self.player_status = self.top_root:AddChild(PlayerStatus(self.owner))
	self.player_status:SetHAnchor(0)
    self.player_status:SetVAnchor(0)
    self.player_status:MoveToFront()
end

AddClassPostConstruct("widgets/controls", AddPlayerStatus)