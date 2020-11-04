AddModRPCHandler("RPG_shop", "purchase", function(player, goods)
	player.components.purchase:Purchase(goods)
end)