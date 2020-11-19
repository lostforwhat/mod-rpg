--debug
local _G = GLOBAL
local GetDebugEntity = GetDebugEntity or _G.GetDebugEntity or nil

local function ConsoleCommandPlayer()
	return GetDebugEntity and GetDebugEntity() or _G.ThePlayer or _G.AllPlayers[1]
end

_G.x_addxp = function(val)
	local player = ConsoleCommandPlayer()
	if player and player.components.level then
		val = type(val) == "number" and val or 1000
		player.components.level:AddXp(val)
		print("x_addxp: "..val)
	end
end

_G.x_cleartask = function()
	local player = ConsoleCommandPlayer()
	if player and player.components.taskdata then
		player.components.taskdata:GrantAll("123456")
		print("x_cleartask: true")
	end
end

_G.x_addcoin = function(val)
	local player = ConsoleCommandPlayer()
	if player and player.components.purchase then
		val = type(val) == "number" and val or 1000
		player.components.purchase:CoinDoDelta(val)
		print("x_addcoin: "..val)
	end
end