require "utils/utils"

local _G = GLOBAL
local TheNet = _G.TheNet

--发布全服活动

local BASE_URL = _G.GetBaseUrl()
local TOKEN = _G.GetToken()
local HttpGet = _G.HttpGet
local HttpPost = _G.HttpPost
local shardId = _G.TheShard:GetShardId()

local function GetSession()
	return _G.TheWorld.net.components.shardstate:GetMasterSessionId()
end


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

local function GetWorldNum()
	local worldnum = 1
	if _G.TheWorld.ShardList ~= nil then
		worldnum = GetLength(_G.TheWorld.ShardList) + 1
	else
		worldnum = GetLength(_G.TheWorld.sharddata)
	end
	return worldnum
end

local holidays = {
	[1] = function() 
		--多倍掉落活动

	end,
	[2] = function()
		--多倍经验活动

	end,
	[3] = function()
		--范围风滚草活动
	end,
	[4] = function()
		--多倍风滚草活动
	end,
	[5] = function()
		--强化不掉等级活动
	end,
	[6] = function()
		--强化几率活动
	end,
	[7] = function()
		--各类颜色风滚草活动
	end,
	[8] = function()
		--商店打折活动
	end,
	[9] = function()
		--消灭固定怪物全服活动
	end,
	[10] = function()
		--
	end,
}

local function CurrentHoliday()
	return _G.TheWorld.holiday
end

local function StartHoliday(index)
	local holiday_fn = holidays[index]
	if holiday_fn ~= nil then
		holiday_fn()
	end
end

--only run in world 1
local function TriggerHoliday()
	if _G.TheWorld.holiday == nil then
		local worlds = {}
		local shards = _G.Shard_GetConnectedShards()
		for k, v in pairs(shards) do
			table.insert(worlds, k)
		end

		if #worlds > 0 then
			local world = worlds[math.random(#world)]
			local index = math.random(#holidays)

			local msg = _G.SHARD_KEY.."holiday"..index..":"..world
    		TheNet:SystemMessage(msg)
		end
	end
end

if TheNet:GetIsServer() then
	--注册世界通信
	_G.AddShardRule("^holiday(%d+):(%d*)$", function(content, worldId, st, ed, num, id) 
		if id == nil or shardId == id then
			StartHoliday(num)
		end
	end)


	AddSimPostInit(function() 
		--仅主服务器接受网络推送的活动消息
		if _G.TheWorld.ismastershard and GetWorldNum() > 1 then
			
			--自动活动，每次转钟触发一次
			_G.TheWorld.WatchWorldState("cycles", function(inst) 
				if CurrentHoliday() == nil and math.random() < 0.02 then
					TriggerHoliday()
				end
			end)
		end
	end)
end