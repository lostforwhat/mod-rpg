require "utils/utils"

local _G = GLOBAL
local TheNet = _G.TheNet
local TUNING = _G.TUNING
local DEGREES = _G.DEGREES
local tonumber = _G.tonumber

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
		_G.TheWorld.net._holiday:set("")
		_G.TheWorld.net._holiday_time:set(0)

		--活动结束删除活动物品
		_G.c_removeallwithtags("rpg_holiday")
		TheNet:Announce("[世界"..shardId.."] 活动结束！")
		cb()
	end)
end

local function GetNextSpawnAngle(pt, radius)

    local base_angle = math.random() * _G.PI
    local deviation = math.random(-TUNING.TRACK_ANGLE_DEVIATION, TUNING.TRACK_ANGLE_DEVIATION)*DEGREES
    local start_angle = base_angle + deviation

    local offset, result_angle = _G.FindWalkableOffset(pt, start_angle, radius, 14, true, true)

    return result_angle
end

local function GetSpawnPoint(pt, radius)

	local angle = GetNextSpawnAngle(pt, radius)
	if angle then
	    local offset = _G.Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
	    local spawn_point = pt + offset
	    return spawn_point
	end

	return nil
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

local function AddWeapLevel(picker)
    if picker == nil or picker.components.inventory == nil then return end
    --装备栏
    for k,v in pairs(picker.components.inventory.equipslots) do
        if v.components.weaponlevel ~= nil and v.components.weaponlevel.level < 20 then
            v.components.weaponlevel:AddLevel(1)
        end
    end
end

local function OnBossKilled(inst, data)
	if inst.level ~= nil and inst.level < 3 then return end
	for k, v in pairs(_G.AllPlayers) do
		AddWeapLevel(v)
	end
end

local function delayspawnboss(delay)
	local boss_list = {"moose", "dragonfly", "bearger", "deerclops", "stalker", "klaus", 
                       "minotaur", "beequeen", "toadstool", "toadstool_dark", "shadow_boss"}
    local prefab = boss_list[math.random(#boss_list)]

    local pos = nil
    while (pos == nil) do
    	pos = getrandomposition()
    end
    if pos ~= nil then
    	
    	_G.TheWorld:DoTaskInTime(delay, function() 
    		local prefabs = {}
    		if prefab == "shadow_boss" then
    			prefabs = {"shadow_rook", "shadow_knight", "shadow_bishop"}
    		else
    			prefabs = {prefab}
    		end
    		for k, v in pairs(prefabs) do
	    		local boss = _G.SpawnPrefab(v)
		    	boss:AddTag("rpg_holiday")
		    	boss.Transform:SetPosition(pos.x, 0, pos.z)
		    	boss:ListenForEvent("death", OnBossKilled)

		    	local title = _G.SpawnPrefab("titles_king")
		    	title:Equipped(boss, 3)
		    	TheNet:Announce("[世界"..shardId.."] 领主出现在坐标("..pos.x..","..pos.z..")附近！")

		    	boss:DoPeriodicTask(30, function() 
		    		if boss ~= nil and boss:IsValid() then
		    			local x,y,z = boss.Transform:GetWorldPosition()
		    			TheNet:Announce("[世界"..shardId.."] 领主出现在坐标("..x..","..z..")附近！")
		    		end
		    	end)
		    end
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
local function delayspawnprefab(delay, times)
	times = times or 10

	for i=0, times do
		_G.TheWorld:DoTaskInTime(15 + delay*i, function() 
			for k, v in pairs(_G.AllPlayers) do
				if not v:HasTag("playerghost") then
					_G.TheWorld:PushEvent("ms_sendlightningstrike", v:GetPosition())

					for m=1, math.random(5, 10) do
						local pos = GetSpawnPoint(v:GetPosition(), math.random(8, 20))
						if pos ~= nil then
							local prefab = monster_tb[math.random(#monster_tb)]
							local monster = _G.SpawnPrefab(prefab) 
							monster.Transform:SetPosition(pos.x, 0, pos.z) 
							monster:AddTag("rpg_holiday")
							if monster.components.combat ~= nil then
								monster.components.combat:SuggestTarget(v)
							end
						end
					end
				end
			end
		end)
	end
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
		time = 600,
		fn = function() 
			delayspawnprefab(45)
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
		name = "寻找橙色风滚草",
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
		time = 600,
		fn = function(prefab) 
			delayspawnboss(30)
		end,
		closefn = function()
			
		end,
	},
	[11] = {--暂留空
		name = "猪王的奖励",
		time = 1200,
		fn = function() 
			_G.TheWorld:AddTag("pigking_task_double")
		end,
		closefn = function()
			_G.TheWorld:RemoveTag("pigking_task_double")
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
		local name = holidays[index].name
		local time = holidays[index].time or 120
		_G.TheWorld.net._holiday_time:set(time)
		_G.TheWorld.net._holiday:set("正在进行 "..name.." 活动")

		if _G.TheWorld.holiday_task ~= nil then
			_G.TheWorld.holiday_task:Cancel()
			_G.TheWorld.holiday_task = nil
		end
		_G.TheWorld.holiday_task = _G.TheWorld.net:DoPeriodicTask(1, function() 
			time = time - 1
			_G.TheWorld.net._holiday_time:set(time)
			if time <= 0 and _G.TheWorld.holiday_task ~= nil then
				_G.TheWorld.holiday_task:Cancel()
				_G.TheWorld.holiday_task = nil
			end
		end)
		TheNet:Announce("[世界"..shardId.."] 正在进行 "..name.." 活动")

		local delay_time = holidays[index].time or 120
		delaycloseholiday(delay_time, closefn or function() end)
	end
end

--only run in world 1
_G.TriggerHoliday = function(num, id)
	num = num or 0
	id = id or 0
	if not _G.TheWorld.ismastershard then 
		TheNet:SystemMessage(_G.SHARD_KEY.."triggerholiday"..num..":"..id)
		return
	end
	if _G.TheWorld.holiday == nil then
		local worlds = {}
		local shards = _G.Shard_GetConnectedShards()
		for k, v in pairs(shards) do
			table.insert(worlds, k)
		end

		if #worlds > 0 then
			if #worlds < 2 then
				table.insert(worlds, shardId)
			end

			local world = worlds[math.random(#worlds)]
			local index = math.random(#holidays)
			if math.random() < 0.1 then
				world = 9999
			end

			if id ~= 0 then
				world = id
			end
			if num ~= 0 then
				index = num
			end

			--TheNet:SystemMessage("##MODRPG#1#holiday5:3")
			local msg = _G.SHARD_KEY.."holiday"..index..":"..world
    		TheNet:SystemMessage(msg)
    		print(msg)

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
		--print("compare:", shardId, id, shardId == id)
		if id == nil or _G.tonumber(id) == 9999 or shardId == id then
			num = _G.tonumber(num)
			_G.TheWorld:DoTaskInTime(0, function() 
				StartHoliday(num)
			end)
		end
	end)

	_G.AddShardRule("^triggerholiday(%d+):(%d+)$", function(content, worldId, st, ed, num, id) 
		if _G.TheWorld.ismastershard and worldId ~= 1 then
			num = num ~= nil and _G.tonumber(num) or 0
			id = id ~= nil and _G.tonumber(id) or 0
			_G.TriggerHoliday(num, id)
		end
	end)


	AddSimPostInit(function() 
		--仅主服务器接受网络推送的活动消息
		if _G.TheWorld.ismastershard then
			
			--自动活动，每次转钟触发一次
			--[[_G.TheWorld.WatchWorldState("cycles", function(inst) 
				local playerNum = GetPlayerNum()
				if CurrentHoliday() == nil and math.random() < 0.01 + 0.02*playerNum then
					print("--开始触发活动--")
					TriggerHoliday()
				end
			end)]]
			_G.TheWorld:DoPeriodicTask(333, function() 
				local playerNum = GetPlayerNum()
				if CurrentHoliday() == nil and GetWorldNum() > 1 and playerNum >= 3 and math.random() < 0.01 + 0.02*playerNum then
					print("--开始触发活动--")
					_G.TriggerHoliday()
				end
			end)
		end
	end)
end

--[[AddPrefabPostInit("world", function(inst)
    inst._holiday = _G.net_string(inst.GUID, "world._holiday", "worldholidaydirty")
    --inst._holiday:set("")
end)]]

local function InitWorld(inst)
	inst._holiday = _G.net_string(inst.GUID, "world._holiday", "worldholidaydirty")
	inst._holiday_time = _G.net_shortint(inst.GUID, "world._holiday_time")
	if TheNet:GetIsServer() then
		inst._holiday:set_local("")
		inst._holiday_time:set_local(0)
	end
end
AddPrefabPostInit("forest_network", InitWorld)
AddPrefabPostInit("cave_network", InitWorld)

local Widget = require "widgets/widget"
local Text = require "widgets/text"
AddClassPostConstruct("widgets/controls", function(self)

	local function SecondsToTime(ts)

	    local seconds = ts % 60
	    local min = math.floor(ts/60)
	    local hour = math.floor(min/60) 
	    local day = math.floor(hour/24)
	    
	    local str = ""
	        
	    if tonumber(seconds) > 0 and tonumber(seconds) < 60 then
	        str = ""..seconds.."秒" ..str
	    end

	    if tonumber(min - hour*60)>0 and tonumber(min - hour*60)<60 then
	        str = ""..(min - hour*60).."分"..str
	    end

	    if tonumber(hour - day*24)>0 and tonumber(hour - day*60)<24 then
	        str = (hour - day*24).."时"..str
	    end
	    
	    if tonumber(day) > 0 then
	        str = day.."天"..str
	    end

	    return str
	end

	local function GetHolidayText(time)
		local title = _G.TheWorld.net._holiday:value() or ""
		time = time or _G.TheWorld.net._holiday_time:value() or 0
		if time > 0 and title ~= "" then
			return title.." ["..SecondsToTime(time).."]"
		end
		return ""
	end

	self.time = 0
	self.holiday = self.top_root:AddChild(Widget("holiday"))
	self.holiday:SetHAnchor(_G.ANCHOR_MIDDLE)
    self.holiday:SetVAnchor(_G.ANCHOR_TOP)
    self.holiday.text = self.holiday:AddChild(Text(_G.NUMBERFONT, 30))
    self.holiday.text:SetString(GetHolidayText())
    self.holiday.text:SetColour({0, 1, 0, 1})
    self.holiday.text:SetPosition(0, -20)
    self.holiday:MoveToFront()
    --self.holiday:Hide()

    self.holiday.inst:ListenForEvent("worldholidaydirty", function() 
    	--print("---------", _G.TheWorld.net._holiday:value())
    	self.time = _G.TheWorld.net._holiday_time:value() or 0
    	if self.time > 0 then
	    	self.holiday.text:SetString(GetHolidayText(self.time))
	    	--self.holiday:Show()
	    else
	    	self.holiday.text:SetString("")
	    	--self.holiday:Hide()
	    end

	end, _G.TheWorld.net)

    self.time = _G.TheWorld.net._holiday_time:value() or 0
	self.holiday.inst:DoPeriodicTask(1, function() 
		if self.time > 0 then
			self.time = self.time - 1
			self.holiday.text:SetString(GetHolidayText(self.time))
		end
	end)
end)