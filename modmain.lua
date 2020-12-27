local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
env.require = GLOBAL.require

TUNING.level = GetModConfigData("level") or 2
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
    Asset("ATLAS", "images/hud/help.xml"),
    Asset("IMAGE", "images/hud/help.tex"),

    --称号图标
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
    Asset("ATLAS", "images/skills/suit.xml"),
    Asset("IMAGE", "images/skills/suit.tex"),
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
table.insert(PrefabFiles, "linghterhat")
table.insert(PrefabFiles, "heisenberghat")
table.insert(PrefabFiles, "armor_linghter")
table.insert(PrefabFiles, "armor_forget")
table.insert(PrefabFiles, "armor_debroglie")
table.insert(PrefabFiles, "linghter_fx")


--引入mod文件
modimport("scripts/modmain/ui.lua")
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
