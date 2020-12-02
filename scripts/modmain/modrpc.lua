AddModRPCHandler("RPG_shop", "purchase", function(player, goods)
	player.components.purchase:Purchase(goods)
end)

AddModRPCHandler("RPG_shop", "refresh", function(player)
	player.components.purchase:Refresh()
end)

--skill rpc
AddModRPCHandler("RPG_skill", "levelup", function(player, skillid, amount)
	player.components.skilldata:LevelUp(skillid, amount)
end)

AddModRPCHandler("RPG_skill", "use", function(player, skill, data) 
	player.components.skilldata:use(skill, data)
end)

AddModRPCHandler("RPG_skill", "stealth", function(player) 
	player.components.stealth:Effect()
end)

--titles rpc
AddModRPCHandler("RPG_titles", "check", function(player) 
	player.components.titles:CheckAll()
end)

AddModRPCHandler("RPG_titles", "equip", function(player, name) 
	player.components.titles:Equip(name)
end)

AddModRPCHandler("RPG_titles", "unequip", function(player, name) 
	player.components.titles:UnEquip(name)
end)

AddModRPCHandler("RPG_titles", "change", function(player) 
	player.components.titles:Change()
end)

--vip rpc
AddModRPCHandler("RPG_vip", "refresh", function(player) 
	player.components.vip:Get()
end)

--worldpicker
AddModRPCHandler("RPG_worldpicker", "migrate", function(player, id)
	if player ~= nil and player:HasTag("player") 
		and not player:HasTag("playerghost") then
		player.components.migrater:StartMigrate(id)
	end
end)