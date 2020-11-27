local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
env.require = GLOBAL.require

require 'modmain/loot_table'
require 'modmain/task_constant'
require 'modmain/skill_constant'
require 'modmain/titles_constant'
require 'modmain/modrpc'

Assets = {
	Asset("ANIM", "anim/coffee.zip"),
	Asset("ATLAS", "images/hud/email.xml"),
    Asset("IMAGE", "images/hud/email.tex"),
}

PrefabFiles = {}

--添加mod新物品
table.insert(PrefabFiles, "package_ball")
table.insert(PrefabFiles, "package_staff")
table.insert(PrefabFiles, "pray_symbol")
table.insert(PrefabFiles, "seffc")
table.insert(PrefabFiles, "abigail_clone")
table.insert(PrefabFiles, "book_treat")
table.insert(PrefabFiles, "book_kill")
table.insert(PrefabFiles, "book_season")
table.insert(PrefabFiles, "magic_circle")
table.insert(PrefabFiles, "shadowtentacle_player")
--table.insert(PrefabFiles, "potion_achiv")
table.insert(PrefabFiles, "potions")
table.insert(PrefabFiles, "deadbone")
table.insert(PrefabFiles, "wes_clone")
table.insert(PrefabFiles, "achiv_clear")
table.insert(PrefabFiles, "skillbook")

table.insert(PrefabFiles, "electronic_ball")
table.insert(PrefabFiles, "titles_fx")

table.insert(PrefabFiles, "coffee")
table.insert(PrefabFiles, "coffeebush")
--buff
table.insert(PrefabFiles, "new_buffs")
--新装备


--添加modUI
--if _G.TheNet:GetIsClient() then
local PlayerStatus = require('widgets/playerstatus')
local PlayerDetail = require('widgets/playerdetail')
local ShopDetail = require('widgets/shopdetail')
local TaskScreen = require('screens/taskscreen')
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

	self.ShowTitlesDetail = function(_)
		if self.titlesdetail == nil then
			self.titlesdetail = self.controls.topleft_root:AddChild(TitlesDetail(self.owner))
		end
	end
	self.CloseTitlesDetail = function(_)
		if self.titlesdetail then
			self.titlesdetail:Close()
			self.titlesdetail = nil
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
--end

--引入mod文件
modimport("scripts/modmain/stacksize.lua")
modimport("scripts/modmain/initcomponents.lua")
modimport("scripts/modmain/initprefab.lua")
modimport("scripts/modmain/strings.lua")
modimport("scripts/modmain/tumbleweed_pick.lua")
modimport("scripts/modmain/modactions.lua")
modimport("scripts/modmain/task_events.lua")
modimport("scripts/modmain/modrecipes.lua")
modimport("scripts/modmain/extra_slots.lua")
modimport("scripts/modmain/monster_enhancement.lua")
modimport("scripts/modmain/worldregrowth.lua")
--可在设置中关闭
modimport("scripts/modmain/asyncworld.lua")
--modimport("scripts/modmain/save.lua")
modimport("scripts/modmain/clean.lua")
--debug
modimport("scripts/modmain/debug.lua")
