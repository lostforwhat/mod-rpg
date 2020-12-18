local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
env.require = GLOBAL.require

TUNING.token = GetModConfigData("token") and 
			#GetModConfigData("token") > 10 and 
			GetModConfigData("token") or 
			nil
_G.GetToken = function()
	return TUNING.token or "0874689771c44c1e1828df13716801f5"
end

require 'modmain/loot_table'
require 'modmain/task_constant'
require 'modmain/skill_constant'
require 'modmain/titles_constant'
require 'modmain/modrpc'

Assets = {
	Asset("ANIM", "anim/coffee.zip"),
	Asset("ATLAS", "images/hud/email.xml"),
    Asset("IMAGE", "images/hud/email.tex"),

    Asset("ATLAS", "images/titles/cleverhands.xml"),
    Asset("IMAGE", "images/titles/cleverhands.tex"),
    Asset("ATLAS", "images/titles/deathbody.xml"),
    Asset("IMAGE", "images/titles/deathbody.tex"),
    Asset("ATLAS", "images/titles/fly.xml"),
    Asset("IMAGE", "images/titles/fly.tex"),
    Asset("ATLAS", "images/titles/foodexpert.xml"),
    Asset("IMAGE", "images/titles/foodexpert.tex"),
    Asset("ATLAS", "images/titles/killingheart.xml"),
    Asset("IMAGE", "images/titles/killingheart.tex"),
    Asset("ATLAS", "images/titles/king.xml"),
    Asset("IMAGE", "images/titles/king.tex"),
    Asset("ATLAS", "images/titles/leisurely.xml"),
    Asset("IMAGE", "images/titles/leisurely.tex"),
    Asset("ATLAS", "images/titles/lifeforever.xml"),
    Asset("IMAGE", "images/titles/lifeforever.tex"),
    Asset("ATLAS", "images/titles/luckbody.xml"),
    Asset("IMAGE", "images/titles/luckbody.tex"),
    Asset("ATLAS", "images/titles/vip.xml"),
    Asset("IMAGE", "images/titles/vip.tex"),

    --技能快捷键图标
    Asset("ATLAS", "images/skills/rejectdeath.xml"),
    Asset("IMAGE", "images/skills/rejectdeath.tex"),
    Asset("ATLAS", "images/skills/stealth.xml"),
    Asset("IMAGE", "images/skills/stealth.tex"),
    Asset("ATLAS", "images/skills/resurrect.xml"),
    Asset("IMAGE", "images/skills/resurrect.tex"),
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
table.insert(PrefabFiles, "potion_achiv")
table.insert(PrefabFiles, "potions")
table.insert(PrefabFiles, "deadbone")
table.insert(PrefabFiles, "wes_clone")
table.insert(PrefabFiles, "achiv_clear")
table.insert(PrefabFiles, "skillbook")
table.insert(PrefabFiles, "skillbookpage")
table.insert(PrefabFiles, "diamond")
table.insert(PrefabFiles, "callerhorn")

table.insert(PrefabFiles, "electronic_ball")
table.insert(PrefabFiles, "titles_fx")

table.insert(PrefabFiles, "coffee")
table.insert(PrefabFiles, "coffeebush")
--buff
table.insert(PrefabFiles, "new_buffs")
--table.insert(PrefabFiles, "player_skills_classified")
--新装备
table.insert(PrefabFiles, "linghter_sword")
table.insert(PrefabFiles, "space_sword")
table.insert(PrefabFiles, "schrodingersword")
table.insert(PrefabFiles, "timerhat")

--添加modUI
--if _G.TheNet:GetIsClient() then
local PlayerStatus = require('widgets/playerstatus')
local PlayerDetail = require('widgets/playerdetail')
local ShopDetail = require('widgets/shopdetail')
local EmailDetail = require('widgets/emaildetail')
local TaskScreen = require('screens/taskscreen')
local ReceiveDialog = require('widgets/receivedialog')
local SkillShortCutKey = require('widgets/skillshortcutkey')
local function AddPlayerStatus(self)
	self.player_status = self.top_root:AddChild(PlayerStatus(self.owner))
	self.player_status:SetHAnchor(_G.ANCHOR_LEFT)
    self.player_status:SetVAnchor(_G.ANCHOR_TOP)
    self.player_status:MoveToFront()

    --快捷键换称号
	_G.TheInput:AddKeyUpHandler(_G.KEY_L, function() 
		--print("---------")
		if self.owner and self.owner.HUD and self.owner.HUD:HasInputFocus() then return end
		SendModRPCToServer(MOD_RPC["RPG_titles"]["change"])
	end)
end
AddClassPostConstruct("widgets/controls", AddPlayerStatus)
local function AddDialog(self)
	self.receivedialog = self.topright_root:AddChild(ReceiveDialog(self.owner))
	self.receivedialog:SetPosition(-200, -400)
	self.receivedialog:SetClickable(true)
	self.receivedialog.OnMouseButton = function(inst, button, down, x, y)
		if button == _G.MOUSEBUTTON_LEFT then
			if down then
				self.receivedialog.dragging = true
				local mousepos = _G.TheInput:GetScreenPosition()
				self.receivedialog.dragPosDiff = self.receivedialog:GetPosition() - mousepos
			else
				self.receivedialog.dragging = false
			end
		end	
	end
	_G.TheInput:AddMoveHandler(function(x,y)
		if self.receivedialog.dragging then
			local offset = self.receivedialog.dragPosDiff or {0, 0, 0}
			local pos
			if type(x) == "number" then
				pos = _G.Vector3(x, y, 1) + offset
			else
				pos = x + offset
			end
			self.receivedialog:SetPosition(pos:Get())
		end
	end)
end
AddClassPostConstruct("widgets/controls", AddDialog)

local function AddSkillShortCutKey(self)
	self.skillskey = self.bottom_root:AddChild(SkillShortCutKey(self.owner))
	self.skillskey:SetPosition(0, 100)
end
AddClassPostConstruct("widgets/controls", AddSkillShortCutKey)

AddClassPostConstruct("screens/playerhud", function(self)
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

    self.CloseDefaultPlayerInfo = function(_)
    	if self.playeravatarpopup ~= nil and
	        self.playeravatarpopup.started and
	        self.playeravatarpopup.inst:IsValid() then
	        self.playeravatarpopup:Close()
	    end
	end

    self.ShowPlayerDetail = function(_)
    	if self.playerdetail == nil then
    		self:CloseDefaultPlayerInfo()
    		self.playerdetail = self.controls.right_root:AddChild(PlayerDetail(self.owner))
    	end
	end
	self.ClosePlayerDetail = function(_) 
		if self.playerdetail then
			self.playerdetail:Close()
			self.playerdetail = nil
		end
	end

	local OldTogglePlayerAvatarPopup = self.TogglePlayerAvatarPopup
	self.TogglePlayerAvatarPopup = function(...)
		self:ClosePlayerDetail()
		OldTogglePlayerAvatarPopup(...)
	end

	self.ShowShopDetail = function(_)
		if self.shopdetail == nil then
			self:CloseEmailDetail()
			self.shopdetail = self.controls.topleft_root:AddChild(ShopDetail(self.owner))
		end
	end
	self.CloseShopDetail = function(_) 
		if self.shopdetail then
			self.shopdetail:Close()
			self.shopdetail = nil
		end
	end

	self.ShowEmailDetail = function(_)
		if self.emaildetail == nil then
			self:CloseShopDetail()
			self.emaildetail = self.controls.topleft_root:AddChild(EmailDetail(self.owner))
		end
	end
	self.CloseEmailDetail = function(_)
		if self.emaildetail then
			self.emaildetail:Close()
			self.emaildetail = nil
		end
	end

	--修改esc按键关闭窗口
	local OldOnControl = self.OnControl
	self.OnControl = function(_, control, down) 
		if not down and control == _G.CONTROL_CANCEL then
			self:ClosePlayerDetail()
			self:CloseShopDetail()
			self:CloseEmailDetail()
		end
		return OldOnControl(self, control, down)
	end
end)
--end

--引入mod文件
modimport("scripts/modmain/worldshard.lua")
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
if GetModConfigData("save") then
	modimport("scripts/modmain/save.lua")
end
if GetModConfigData("clean") then
	modimport("scripts/modmain/clean.lua")
end
if GetModConfigData("holiday") then
	modimport("scripts/modmain/holiday.lua")
end
modimport("scripts/modmain/multiworld.lua")
modimport("scripts/modmain/weapon_strengthen.lua")
--debug
modimport("scripts/modmain/debug.lua")
