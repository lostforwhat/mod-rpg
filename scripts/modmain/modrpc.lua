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
