--debug 测试使用，正式服务器请勿随意使用
local _G = GLOBAL
local TheNet = _G.TheNet
local os = _G.os
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

_G.x_addemail = function()
	local player = ConsoleCommandPlayer()
	if player and player.components.email then
		local email = {
			_id = math.random(999999),
			title = "感谢支持",
			content = "感谢您支持本mod，祝您游戏愉快！",
			prefabs = {
				{
					prefab = "ash",
					num = 2,
				}
			},
			sender = "system",
			time = tostring(os.date())
		}
		player.components.email:AddEmail(email)
	end
end

_G.x_refreshshop = function()
	if _G.TheWorld and _G.TheWorld.net and _G.TheWorld.net.components.worldshop ~= nil then
		_G.TheWorld.net.components.worldshop:ResetShop()
	end
end

_G.x_printworlds = function() 
	if _G.TheWorld and _G.TheWorld.net then
		local sharddata = _G.TheWorld.net.components.sharddata._sharddata:value()
		print("sharddata:", sharddata)
	end
end

_G.x_openholiday = function()
	_G.TriggerHoliday()
end

_G.x_updatehelp = function(text)
	local msg = _G.SHARD_KEY.."updatehelp:"..text
    TheNet:SystemMessage(msg)
end