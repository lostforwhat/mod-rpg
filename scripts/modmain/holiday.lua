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

local function GetPlayerNum()
	return #TheNet:GetClientTable() or 0
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

local function delaycloseholiday(time, cb)
	_G.TheWorld:DoTaskInTime(time, function() 
		--_G.TheWorld.holiday = nil
		_G.TheWorld._holiday:set("")

		--活动结束删除活动物品
		_G.c_removeallwithtags("rpg_holiday")
		cb()
	end)
end

local function getrandomposition() 
	local ground = _G.TheWorld 
	local centers = {} 
	for i, node in ipairs(ground.topology.nodes) do 
		if ground.Map:IsPassableAtPoint(node.x, 0, node.y) and node.type ~= _G.NODE_TYPE.SeparatedRoom then 
			table.insert(centers, {x = node.x, z = node.y}) 
		end 
	end 
	if #centers > 0 then 
		local pos = centers[math.random(#centers)] 
		return _G.Point(pos.x, 0, pos.z) 
	else 
		return nil  
	end 
end

local function spawnTumbleweed(level, num)   
	for k=1, num do 
		local pos = getrandomposition() 
		if pos ~= nil then 
			local item = _G.SpawnPrefab("tumbleweed_"..level) 
			item.Transform:SetPosition(pos.x, 0, pos.z) 
			--print("created:"..pos.x..","..pos.z) 
			item:AddTag("rpg_holiday")
		end 
	end
end

local function delayspawnboss(delay)
	local boss_list = {"moose", "dragonfly", "bearger", "deerclops", "stalker", "klaus", 
                       "minotaur", "beequeen", "toadstool", "toadstool_dark", 
              		  "shadow_rook", "shadow_knight", "shadow_bishop"}
    local prefab = boss_list[math.random(#boss_list)]

    local pos = nil
    while (pos == nil) do
    	pos = getrandomposition()
    end
    if pos ~= nil then
    	
    	_G.TheWorld:DoTaskInTime(delay, function() 
    		local boss = _G.SpawnPrefab(prefab)
	    	boss:AddTag("rpg_holiday")
	    	boss.Transform:SetPosition(pos.x, 0, pos.z)
    	end)
    end
end

local monster_tb = {
	"spider",
    "frog",
    "bee",
    "mosquito",
    "pigguard",--猪人守卫
    "bunnyman",--兔人
    "merm",--鱼人
    "spider_warrior",--蜘蛛战士
    "spiderqueen",--蜘蛛女王
    "hound",--猎狗
    "firehound",--火狗
    "icehound",--冰狗
    "leif",--树精
    "leif_sparse",--稀有树精
    "walrus",--海象
    "tallbird",--高鸟
    "bat",--蝙蝠
    "monkey",--猴子
    "knight",--发条骑士
    "bishop",--发条主教
    "rook",--发条战车
    "worm",--洞穴蠕虫
    "krampus",--小偷
    "slurtle", -- 蜗牛1
    "snurtle", -- 蜗牛2
    "slurper", -- slurper
    "penguin", -- 企鹅
    "ghost",
}
local function delayspawnprefab(delay)
	_G.TheWorld:DoTaskInTime(delay, function() 
		for k=1, 50 do 
			local pos = getrandomposition() 
			if pos ~= nil then 
				local prefab = monster_tb[math.random(#monster_tb)]
				local monster = _G.SpawnPrefab(prefab) 
				monster.Transform:SetPosition(pos.x, 0, pos.z) 
				monster:AddTag("rpg_holiday")
			end 
		end
	end)
end


local holidays = {
	[1] = {--多倍掉落活动
		name = "多倍掉落",
		time = 1800,
		fn = function() 
			_G.TheWorld:AddTag("doubledrop")
		end,
		closefn = function()
			_G.TheWorld:RemoveTag("doubledrop")
		end,
	},
	[2] = {
		name = "多倍经验",
		time = 1800,
		fn = function() 
			_G.TheWorld:AddTag("doublexp")
		end,
		closefn = function()
			_G.TheWorld:RemoveTag("doublexp")
		end,
	},
	[3] = {
		name = "多开风滚草",
		time = 1800,
		fn = function() 
			_G.TheWorld:AddTag("pick_tumbleweed_aoe")
		end,
		closefn = function()
			_G.TheWorld:RemoveTag("pick_tumbleweed_aoe")
		end,
	},
	[4] = {
		name = "多倍风滚草",
		time = 1800,
		fn = function() 
			_G.TheWorld:AddTag("pick_tumbleweed_more")
		end,
		closefn = function()
			_G.TheWorld:RemoveTag("pick_tumbleweed_more")
		end,
	},
	[5] = {
		name = "武器祝福",
		time = 300,
		fn = function() 
			_G.TheWorld:AddTag("weaponprotect")
		end,
		closefn = function()
			_G.TheWorld:RemoveTag("weaponprotect")
		end,
	},
	[6] = {
		name = "怪物来袭",
		time = 1200,
		fn = function() 
			delayspawnprefab(10)
		end,
		closefn = function()
			
		end,
	},
	[7] = {
		name = "寻找发光风滚草",
		time = 600,
		fn = function(num) 
			if num == nil then
				num = 50
			end
			spawnTumbleweed(5, num)
		end,
		closefn = function()
			
		end,
	},
	[8] = {
		name = "寻找粉色风滚草",
		time = 600,
		fn = function(num) 
			if num == nil then
				num = 50
			end
			spawnTumbleweed(4, num)
		end,
		closefn = function()
			
		end,
	},
	[9] = {
		name = "寻找紫色风滚草",
		time = 600,
		fn = function(num) 
			if num == nil then
				num = 50
			end
			spawnTumbleweed(0, num)
		end,
		closefn = function()
			
		end,
	},
	[10] = {
		name = "消灭领主",
		time = 1200,
		fn = function(prefab) 
			
		end,
		closefn = function()
			
		end,
	},
	[11] = {--暂留空
		name = "",
		time = 600,
		fn = function() 
			
		end,
		closefn = function()
			
		end,
	},
}

local function CurrentHoliday()
	return _G.TheWorld.holiday
end

local function StartHoliday(index)
	local holiday_fn = holidays[index] and holidays[index].fn
	local closefn = holidays[index] and holidays[index].closefn
	if holiday_fn ~= nil then
		holiday_fn()
		--_G.TheWorld.holiday = index
		_G.TheWorld._holiday:set("正在进行 "..name.." 活动")

		local delay_time = holidays[index].time or 120
		delaycloseholiday(delay_time, closefn or function() end)
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

    		_G.TheWorld.holiday = index
    		local time = holidays[index].time or 120
    		_G.TheWorld:DoTaskInTime(time, function() 
    			_G.TheWorld.holiday = nil
    		end)
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
				local playerNum = GetPlayerNum()
				if CurrentHoliday() == nil and math.random() < 0.01 + 0.002*playerNum then
					TriggerHoliday()
				end
			end)
		end
	end)
end

AddPrefabPostInit("world", function(inst)
    inst._holiday = net_string(inst.GUID, "world._holiday", "worldholidaydirty")
    inst._holiday:set("")
end)