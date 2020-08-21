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

end)

--添加modUI
local function AddPlayerStatus(self)
	self.player_status = self.top_root:AddChild(PlayerStatus(self.owner))
	self.player_status:SetHAnchor(0)
    self.player_status:SetVAnchor(0)
    self.player_status:MoveToFront()
end

AddClassPostConstruct("widgets/controls", AddPlayerStatus)