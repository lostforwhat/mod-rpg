local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
env.require = GLOBAL.require

require 'modmain/loot_table'
require 'modmain/task_constant'
require 'modmain/skill_constant'
require 'modmain/modrpc'
local PlayerStatus = require('widgets/playerstatus')
local PlayerDetail = require('widgets/playerdetail')
local ShopDetail = require('widgets/shopdetail')
local TaskScreen = require('screens/taskscreen')

Assets = {
	Asset("ANIM", "anim/coffee.zip"),
	Asset("ATLAS", "images/hud/email.xml"),
    Asset("IMAGE", "images/hud/email.tex"),
    Asset("ATLAS", "images/hud/levelbadge.xml"),
    Asset("IMAGE", "images/hud/levelbadge.tex"),
}

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

table.insert(PrefabFiles, "coffee")
table.insert(PrefabFiles, "coffeebush")
--buff
table.insert(PrefabFiles, "new_buffs")
--新装备



--引入mod文件
modimport("scripts/modmain/strings.lua")
modimport("scripts/modmain/tumbleweed_pick.lua")
modimport("scripts/modmain/modactions.lua")
modimport("scripts/modmain/task_events.lua")
modimport("scripts/modmain/modrecipes.lua")



--角色初始化
AddPlayerPostInit(function(inst) 
	inst:AddComponent("taskdata")
	inst:AddComponent("purchase")
	
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
		inst:AddComponent("fighting")
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
        inst.components.attackfrozen.chance=0
    end

end)

--abigail添加复仇属性
AddPrefabPostInit("abigail", function(inst) 
	inst:AddComponent("revenge")
	inst:AddComponent("clone")
end)

--给灰烬添加肥料属性
AddPrefabPostInit("ash", function(inst) 
	inst:AddTag("volcanic")
	if _G.TheWorld.ismastersim then
		inst:AddComponent("fertilizer")
	    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
	    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
	    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
	    inst.components.fertilizer.volcanic = true
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

		local blocked = OldGetAttacked(self, attacker, damage + extra_damage, weapon, stimuli)
		
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
	self.player_status:SetHAnchor(_G.ANCHOR_LEFT)
    self.player_status:SetVAnchor(_G.ANCHOR_TOP)
    self.player_status:MoveToFront()
end

AddClassPostConstruct("widgets/controls", AddPlayerStatus)

AddClassPostConstruct("screens/playerhud", function(self, anim, owner)
    self.ShowTaskScreen = function(_)
        
        self.taskscreen = TaskScreen(self.owner)
        self:OpenScreenUnderPause(self.taskscreen)
        return self.taskscreen
    end

    self.CloseTaskScreen = function(_)
        if self.taskscreen then
            self.taskscreen:Close()
            self.taskscreen = nil
        end
    end

    self.ShowPlayerDetail = function(_)
    	if self.playerdetail == nil then
    		self.playerdetail = self.controls.right_root:AddChild(PlayerDetail(self.owner))
    	end
	end
	self.ClosePlayerDetail = function(_) 
		if self.playerdetail then
			self.playerdetail:Close()
			self.playerdetail = nil
		end
	end

	self.ShowShopDetail = function(_)
		if self.shopdetail == nil then
			self.shopdetail = self.controls.topleft_root:AddChild(ShopDetail(self.owner))
		end
	end
	self.CloseShopDetail = function(_) 
		if self.shopdetail then
			self.shopdetail:Close()
			self.shopdetail = nil
		end
	end

	--修改esc按键关闭窗口
	local OldOnControl = self.OnControl
	self.OnControl = function(_, control, down) 
		if not down and control == _G.CONTROL_CANCEL then
			self:ClosePlayerDetail()
			self:CloseShopDetail()
		end
		return OldOnControl(self, control, down)
	end
end)