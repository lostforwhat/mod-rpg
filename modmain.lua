local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
env.require = GLOBAL.require
-- 
TUNING.PERISH_FRIDGE_MULT = -10;
AddPrefabPostInit("krampus_sack", function(inst)
    inst:AddTag("fridge")
end)
AddPrefabPostInit("piggyback", function(inst)
    inst:AddTag("fridge")
end)
--
TUNING.level = GetModConfigData("level") or 2
TUNING.token = GetModConfigData("token") and 
			#GetModConfigData("token") > 10 and 
			GetModConfigData("token") or 
			nil
            
TUNING.GRASSGEKKO_MORPH_CHANCE = 0

_G.GetToken = function()
	return TUNING.token or "0874689771c44c1e1828df13716801f5"
end

require 'modmain/loot_table'
require 'modmain/task_constant'--任务数据
require 'modmain/skill_constant'--技能系统
require 'modmain/titles_constant'--称号任务
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
    --引入赃物袋图片
    Asset("ATLAS", "images/inventoryimages/klaus_sack.xml"),
    Asset("IMAGE", "images/inventoryimages/klaus_sack.tex"),
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
table.insert(PrefabFiles, "display_effect")
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

table.insert(PrefabFiles, "klaus_sack1")
table.insert(PrefabFiles, "gembeans")
table.insert(PrefabFiles, "gem_crystal_clusters")
--引入mod文件
modimport("scripts/modmain/ui.lua")
modimport("scripts/modmain/worldshard.lua")
modimport("scripts/modmain/stacksize.lua")
modimport("scripts/modmain/initcomponents.lua")
modimport("scripts/modmain/initprefab.lua")--雷
modimport("scripts/modmain/strings.lua")
modimport("scripts/modmain/tumbleweed_pick.lua")
modimport("scripts/modmain/modactions.lua")
modimport("scripts/modmain/task_events.lua")--经验
modimport("scripts/modmain/modrecipes.lua")--添加配方
modimport("scripts/modmain/monster_enhancement.lua")--BOSS强化
modimport("scripts/modmain/worldregrowth.lua")

modimport("scripts/modmain/add_llb.lua")
modimport("scripts/modmain/not_drop.lua")
modimport("scripts/modmain/notice.lua")
modimport("scripts/modmain/booty_bag.lua")
modimport("scripts/modmain/generate_tumbleweed.lua")
modimport("scripts/modmain/super_pack.lua")

--宝石种植
local map_icons= {
    "blue", "green","orange","purple","red","yellow","opalprecious",
}

TUNING.GEMCRYSTAL_COST = GetModConfigData("gemcost")
TUNING.GEMCRYSTAL_time = GetModConfigData("growtime")*480
local locale_code = LOC.GetLocaleCode()
local L = locale_code ~= "zh" and locale_code ~= "zhr"

local zhongwen = L and 
{
    blue = "Blue ",green = "Green ",orange = "Orange ",purple = "Purple ",
    red = "Red ",yellow = "Yellow ",opalprecious = "Opal "
}
or 
{
    blue = "蓝",green = "绿",orange = "橙",purple = "紫",
    red = "红",yellow = "黄",opalprecious = "彩"
}
for k,v in pairs(map_icons) do
    table.insert(Assets, Asset( "IMAGE", "images/minimap/gem_crystal_cluster_"..v..".tex" )) 
    table.insert(Assets, Asset( "ATLAS", "images/minimap/gem_crystal_cluster_"..v..".xml" ))
    AddMinimapAtlas("images/minimap/gem_crystal_cluster_"..v..'.xml')

    if L  then
        STRINGS.NAMES[string.upper("gembean_"..v)]= zhongwen[v].."Crystal Seed"
        STRINGS.RECIPE_DESC[string.upper("gembean_"..v)] = "Precious and Special"
        STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper("gembean_"..v)] = "Precious and Special"
    else
        STRINGS.NAMES[string.upper("gembean_"..v)]= zhongwen[v].."色水晶籽"
        STRINGS.RECIPE_DESC[string.upper("gembean_"..v)] = "是很贵重的东西！"
        STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper("gembean_"..v)] = "是很贵重的东西！"
    end
    if L  then
        STRINGS.NAMES[string.upper("gem_crystal_cluster_"..v)]= zhongwen[v].."Gem Crystal Cluster"
        STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper("gem_crystal_cluster_"..v)] = "So Beautiful!"
    else
        STRINGS.NAMES[string.upper("gem_crystal_cluster_"..v)]= zhongwen[v].."色水晶簇"
        STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper("gem_crystal_cluster_"..v)] = "真是美丽呢！"
    end
end

--新制作栏
local new = {
"gembean_blue", 
"gembean_green",
"gembean_orange",
"gembean_purple",
"gembean_red",
"gembean_yellow",
"gembean_opalprecious",
}

for k,v in pairs(new) do
    table.insert(Assets, Asset( "IMAGE", "images/inventoryimages/"..v..".tex" )) 
    table.insert(Assets, Asset( "ATLAS", "images/inventoryimages/"..v..".xml" ))
    RegisterInventoryItemAtlas("images/inventoryimages/"..v..".xml", v..".tex")
    AddRecipeToFilter(v,"REFINE")
end

for k,v in pairs(map_icons) do
    AddRecipe2("gembean_"..v,
    {Ingredient("ice", 40),Ingredient(v.."gem", TUNING.GEMCRYSTAL_COST),Ingredient("moonglass", 20)}, 
    TECH.SCIENCE_TWO,{})
end
--End

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