--多世界信息
local _G = GLOBAL
local TheNet = _G.TheNet
local TheWorld = _G.TheWorld

local DEFAULT_MAX_PLAYERS = 99

local function GetMaxPlayers()
	local server_max_players = TheNet:GetServerMaxPlayers()
	return GetModConfigData("max_players") 
		or math.ceil(server_max_players/worldnum) 
		or DEFAULT_MAX_PLAYERS
end

local function GetWorldNum()
	local worldnum = 1
	if TheWorld ~= nil and TheWorld.ShardList ~= nil then
		worldnum = #TheWorld.ShardList + 1
	end
	return worldnum
end

local function ShardMax()
	local max_players = GetMaxPlayers()
	local msg = _G.SHARD_KEY.."maxplayers"..max_players
    TheNet:SystemMessage(msg)
end

local function ShardPlayer()
	local msg = _G.SHARD_KEY.."players"..(_G.AllPlayers ~= nil and #_G.AllPlayers or 0)
    TheNet:SystemMessage(msg)
end

local function ShardPlayerAndMax()
	local max_players = GetMaxPlayers()
	local msg = _G.SHARD_KEY.."players"..(_G.AllPlayers ~= nil and #_G.AllPlayers or 0).."-"..max_players
    TheNet:SystemMessage(msg)
end

local function SetWorldData(worldId, players, maxplayers)
	if TheWorld == nil then return end
	if TheWorld.sharddata == nil then
		TheWorld.sharddata = {}
	end
	if TheWorld.sharddata[worldId] == nil then
		TheWorld.sharddata[worldId] = {
			players = 0,
			maxplayers = 0,
		}
	end
	if players ~= nil then
		TheWorld.sharddata[worldId].players = players
	end
	if maxplayers ~= nil then
		TheWorld.sharddata[worldId].maxplayers = maxplayers
	end
	if TheWorld.net ~= nil and TheWorld.net.components.sharddata ~= nil then
		TheWorld.net.components.sharddata:SetData(TheWorld.sharddata)
	end
end


local function Init()
	local worldId = _G.TheShard:GetShardId()

	local worldNum = GetWorldNum()

	_G.AddShardRule("^players(%d+)$", function(content, worldId, st, ed, num) 
		SetWorldData(worldId, num)
	end)

	_G.AddShardRule("^players(%d+)-(%d+)$", function(content, worldId, st, ed, num, maxplayers) 
		SetWorldData(worldId, num, maxplayers)
	end)

	_G.AddShardRule("^maxplayers(%d+)$", function(content, worldId, st, ed, maxplayers)
		SetWorldData(worldId, nil, maxplayers)
	end)

    TheWorld:ListenForEvent("ms_playerspawn", ShardPlayer)
    TheWorld:ListenForEvent("ms_playerleft", ShardPlayer)
    ShardMax() --先发布一个用于获取最大玩家数量
end
AddSimPostInit(Init)

local function InitWorld(inst)
	inst:AddComponent("sharddata")
end
AddPrefabPostInit("forest_network", InitWorld)
AddPrefabPostInit("cave_network", InitWorld)

--新世界连接时，通知所有世界重新发送一次当前世界状态
local Old_Shard_UpdateWorldState = _G.Shard_UpdateWorldState
_G.Shard_UpdateWorldState = function(...)
	Old_Shard_UpdateWorldState(...)
	ShardPlayerAndMax()
end

--添加客户端控件
local MultiWorldPicker = require("widgets/multiworld")
local function AddMultiWorldPicker(self)
	self.multiworldpicker = self:AddChild(MultiWorldPicker)
	self.multiworldpicker:SetPosition(0, 50, 0)
end
AddClassPostConstruct("widgets/mapcontrols", AddMultiWorldPicker)