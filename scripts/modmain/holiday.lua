require "utils/utils"

local _G = GLOBAL
local TheNet = _G.TheNet

--发布全服活动

local BASE_URL = _G.GetBaseUrl()
local TOKEN = _G.GetToken()
local HttpGet = _G.HttpGet
local HttpPost = _G.HttpPost

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
	end
	return worldnum
end

local holidays = {
	[1] = function() end,
}

local function StartHoliday(index)

end

if TheNet:GetIsServer() then
	--注册世界通信
	_G.AddShardRule("^holiday(%d+)$", function(content, worldId, st, ed, num) 
		StartHoliday(num)
	end)


	AddSimPostInit(function() 
		--仅主服务器接受活动消息
		if _G.TheWorld.ismastershard and GetWorldNum() > 1 then
			
		end
	end)
end