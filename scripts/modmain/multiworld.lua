--多世界信息
local _G = GLOBAL
local TheNet = _G.TheNet
--local TheWorld = _G.TheWorld

local DEFAULT_MAX_PLAYERS = 99

local function GetLength(tab)
    local count = 0
    if type( tab ) ~= "table" then
        return 0
    end
    for k, v in pairs( tab ) do
        count = count + 1
    end
    return count
end

if TheNet:GetIsServer() or TheNet:IsDedicated() then
	local function GetWorldNum()
		local worldnum = 1
		if _G.TheWorld ~= nil and _G.TheWorld.ShardList ~= nil then
			worldnum = #_G.TheWorld.ShardList + 1
		end
		return worldnum
	end

	local function GetMaxPlayers()
		local server_max_players = TheNet:GetServerMaxPlayers()
		local worldnum = GetWorldNum()
		return GetModConfigData("max_players") 
			or math.ceil(server_max_players/worldnum) 
			or DEFAULT_MAX_PLAYERS
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
		if _G.TheWorld == nil then return end
		if _G.TheWorld.sharddata == nil then
			_G.TheWorld.sharddata = {}
		end
		if _G.TheWorld.sharddata[worldId] == nil then
			_G.TheWorld.sharddata[worldId] = {
				players = 0,
				maxplayers = 0,
			}
		end
		if players ~= nil then
			_G.TheWorld.sharddata[worldId].players = players
		end
		if maxplayers ~= nil then
			_G.TheWorld.sharddata[worldId].maxplayers = maxplayers
		end
		if _G.TheWorld.net ~= nil and _G.TheWorld.net.components.sharddata ~= nil then
			_G.TheWorld.net.components.sharddata:SetData(_G.TheWorld.sharddata)
		end
	end


	local function Init()

		--if TheWorld ~= nil then
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

		    _G.TheWorld:ListenForEvent("ms_playerspawn", ShardPlayer)
		    _G.TheWorld:ListenForEvent("ms_playerleft", ShardPlayer)
		    ShardMax() --先发布一个用于获取最大玩家数量
		--end
	end
	AddSimPostInit(Init)
end

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
	self.multiworldpicker = self:AddChild(MultiWorldPicker())
	self.multiworldpicker:SetPosition(-30, -5)
	self.multiworldpicker:SetScale(.6)

	--self:ReLayout()
	function self:ReLayout(multi)
		if multi then
			self.minimapBtn:SetScale(.3)
			self.minimapBtn:SetPosition(25, 0)
			self.multiworldpicker:Show()
		else
			self.minimapBtn:SetScale(0.5)
			self.minimapBtn:SetPosition(0, 0)
			self.multiworldpicker:Hide()
		end
	end

	self.inst:ListenForEvent("worldsharddatadirty", function() 
		local sharddata = _G.TheWorld.net.components.sharddata:Get() or {}
		if GetLength(sharddata) < 1 then
			self:ReLayout(false)
		else
			self:ReLayout(true)
		end
	end, _G.TheWorld.net)
end
AddClassPostConstruct("widgets/mapcontrols", AddMultiWorldPicker)