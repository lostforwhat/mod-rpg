require "utils/utils"

local _G = GLOBAL
local TheNet = _G.TheNet
--local TheWorld = _G.TheWorld
local TUNING = _G.TUNING
local BASE_URL = "http://api.tumbleweedofall.xyz:8888"
local TOKEN = TUNING.token or "0874689771c44c1e1828df13716801f5"
--local BASE_URL = "http://127.0.0.1:8888"

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

local function GetWorldSession()
	--world session
	return TheNet:GetSessionIdentifier()
end

local function GetSession()
	return _G.TheWorld.net.components.shardstate:GetMasterSessionId()
end

--demo
local function OnPostComplete( result, isSuccessful, resultCode )
	if isSuccessful and (resultCode == 200) then
		
	else
		
	end
end

--demo
local function OnGetComplete( result, isSuccessful, resultCode )
	if isSuccessful and (resultCode == 200) then
		
	else
		
	end
end

local function httppost(url, cb, params)
	if params == nil then
		params = {}
	end
	TheSim:QueryServer(
		url,
		function(...) 
			if type(cb) == "function" then 
				cb(...) 
			end 
		end,
		"POST",
		_G.json.encode(params) 
	)
end

local function httpget(url, cb)
	TheSim:QueryServer( 
		url, 
		function(result, isSuccessful, resultCode) 
			if type(cb) == "function" then 
				cb(result, isSuccessful, resultCode) 
			end 
		end, 
		"GET")
end

local function SaveServerInfo()
	local worldnum = 1
	if _G.TheWorld.ShardList ~= nil then
		worldnum = GetLength(_G.TheWorld.ShardList) + 1
	else
		worldnum = GetLength(_G.TheWorld.sharddata)
	end

	local url = BASE_URL.."/public/saveServer"
	local params = {
		id = GetSession(),
		name = _G.TheNet:GetServerName(),
		description = _G.TheNet:GetServerDescription(),
		maxplayer = _G.TheNet:GetServerMaxPlayers(),
		mode = _G.TheNet:GetServerGameMode(),
		isonline = true,
		userid = _G.TheNet:GetUserID(),
		snapshot = _G.TheNet:GetCurrentSnapshot(),
		status = "1",
		days = _G.TheWorld.state.cycles,
		worldnum = worldnum,
		token = TOKEN
	}
	httppost(url, function(result, isSuccessful, resultCode) 
		if isSuccessful and (resultCode == 200) then
			print("------------saved Server success--------------")
		else
			print("------------saved Server failed! ERROR:"..result.."--------------")
		end
	end, params)
end

local function SaveTaskData(player)
	local url = BASE_URL.."/public/saveAchievement"
	local params = {
		userid = player.userid,
		displayname = player:GetDisplayName(),
		prefab = player.prefab,
		serversession = GetSession()
	}
	if _G.task_data ~= nil then
		local total = 0
		for k,v in pairs(_G.task_data) do
			params[k] = player.components.taskdata[k]
			local need = v.need or 1
			if params[k] and params[k] >= need then
				total = total + 1
			end
		end
		params["total"] = total
		params["complete_time"] = player.components.taskdata.complete_time
	end

	params["age"] = player.components.age:GetAgeInDays() or 0

	httppost(url, function(result, isSuccessful, resultCode) 
		if isSuccessful and (resultCode == 200) then
			print("------------"..(player.userid).." saved Achievement success--------------")
		else
			print("------------"..(player.userid).." saved Achievement failed! ERROR:"..result.."--------------")
		end
	end, params)
end

local function SavePlayerInfo(player)
	local url = BASE_URL.."/public/savePlayer"
	local params = {
		userid = player.userid,
		displayname = player:GetDisplayName(),
		prefab = player.prefab,
		world = _G.TheShard:GetShardId(),
		worldsession = GetWorldSession(),
		serversession = GetSession()
	}
	params["level"] = player.components.level and player.components.level.level or 0
	params["totalxp"] = player.components.level and player.components.level.totalxp or 0
	params["xp"] = player.components.level and player.components.level.xp or 0

	local coin = player.components.purchase and player.components.purchase.coin or 0
	local purchase_used = player.components.purchase and player.components.purchase.coin_used or 0
	local skill_used = player.components.skilldata and player.components.skilldata.coin_used or 0
	params["purchase_used"] = purchase_used
	params["skill_used"] = skill_used
	params["coin_used"] = math.ceil(coin + purchase_used + skill_used)
	params["coin"] = math.ceil(coin)
	params["age"] = player.components.age:GetAgeInDays()

	local deathtimes = player.components.level and player.components.level.deathtimes or 0
	params["death"] = deathtimes

	
	if _G.task_data ~= nil and player.components.taskdata then
		local total = 0
		for k,v in pairs(_G.task_data) do
			local need = v.need or 1
			if player.components.taskdata[k] and player.components.taskdata[k] >= need then
				total = total + 1
			end
		end
		params["task"] = total
		params["complete_time"] = player.components.taskdata.complete_time
		params["collect"] = player.components.taskdata.collect
		params["tumbleweednum"] = player.components.taskdata.tumbleweednum
		params["killboss"] = player.components.taskdata.killboss

	end

	httppost(url, function(result, isSuccessful, resultCode) 
		if isSuccessful and (resultCode == 200) then
			print("------------"..(player.userid).." saved playerinfo success--------------")
		else
			print("------------"..(player.userid).." saved playerinfo failed! ERROR:"..result.."--------------")
		end
	end, params)
end

local function SaveSkills(player)
	local url = BASE_URL.."/public/saveSkills"
	local params = {
		userid = player.userid,
		displayname = player:GetDisplayName(),
		prefab = player.prefab,
		serversession = GetSession(),
		age = player.components.age:GetAgeInDays() or 0
	}

	if _G.skill_constant ~= nil then
		local skills = player.components.skilldata and player.components.skilldata.skills or {}
		for k,v in pairs(skills) do
			local level = player.components.skilldata:GetLevel(k) or 0
			if level > 0 then
				params[k] = level
			end
		end
	end

	httppost(url, function(result, isSuccessful, resultCode) 
		if isSuccessful and (resultCode == 200) then
			print("------------"..(player.userid).." saved Skills success--------------")
		else
			print("------------"..(player.userid).." saved Skills failed! ERROR:"..result.."--------------")
		end
	end, params)
end

local function loadGift(player, data)
	--[[ 
		{
			{
				{prefab="ash", num=1},
				{prefab="cutgrass", num=10},
				{prefab="potion_achiv", num=5},
				{prefab="package_ball", num=1, package="moonbase"}
			},
			{
				...
			}
		}
		
	 ]]
	if player.components.email.list == nil or #player.components.email.list==0 then 
		player.components.email.list = data
		return
	end
	for k, v in pairs(data) do
		if v then
			table.insert(player.components.email.list, v)
		end
	end
end

local function GetPlayerGift(player)
	local  url = BASE_URL.."/public/getGift?userid="..player.userid.."&serversession="..GetSession()
	httpget(url, function(result, isSuccessful, resultCode)
		if isSuccessful and (resultCode == 200) then
			print("------------"..(player.userid).." getGift success--------------")
			local status, data = _G.pcall( function() return _G.json.decode(result) end )
			if not status or not data then
		 		print("解析gift失败" .. tostring(player.userid) .."! ", tostring(status), tostring(data))
			else
				loadGift(player, data)
			end
		else
			print("------------"..(player.userid).." getGift failed! ERROR:"..result.."--------------")
		end
	end)
end

local function SaveOnePlayer(player)
	SavePlayerInfo(player)

	if player ~= nil and player.components.taskdata then
		SaveTaskData(player)
	end
	if player ~= nil and player.components.skilldata then
		SaveSkills(player)
	end
end

local function RecoveryPlayer(player, data)
	if player.prefab ~= data.prefab then
		print("角色不一致，无法恢复")
		return
	end
	if player.components.taskdata ~= nil then
		for k,v in pairs(_G.task_data or {}) do
	        if k ~= nil then
	            player.components.taskdata[k] = data[k] or 0
	        end
	    end
	    player.components.taskdata.killboss = data["killboss"] or 0
	    if player.components.taskdata.all > 0 then
	    	player.components.taskdata.complete_time = data["complete_time"] or nil
	    end
	    player.components.taskdata.collect = data["collect"] or 0
	    player.components.taskdata.tumbleweednum = data["tumbleweednum"] or 0
	end
	if player.components.skilldata ~= nil then
		for k,v in pairs(_G.skill_constant) do
			player.components.skilldata[v.id] = data[v.id] or 0
		end
		player.components.skilldata.skill_used = data["skill_used"] or 0
	end
	player.components.purchase.coin = data["coin"] or 0
	player.components.purchase.coin_used = data["purchase_used"] or 0
	if player.components.level ~= nil then
		player.components.level.xp = data["xp"] or 0
		player.components.level.totalxp = data["totalxp"] or 0
		player.components.level.level = data["level"] or 1
	end
	--[[SaveAchieve["killboss"] = self.killboss or 0
    SaveAchieve["complete_time"] = self.complete_time or nil
    SaveAchieve["temp_total"] = self.temp_total or 0
    SaveAchieve["tumbleweednum"] = self.tumbleweednum or 0]]
    local age = data["age"] or 1
    player.components.age.saved_age = age * TUNING.TOTAL_DAY_TIME
end

--保存人物数据
_G.SaveAllPlayers = function()
	print("--------------开始上传人物数据----------------")
	for i, v in ipairs(_G.AllPlayers) do
        SaveOnePlayer(v)
    end
end

_G.SaveServer = function()
	if _G.TheWorld.ismastershard then
		print("--------------同步服务器信息--------------")
		SaveServerInfo()
		_G.TheWorld.syncTask = _G.TheWorld:DoPeriodicTask(TUNING.TOTAL_DAY_TIME, SaveServerInfo)
	end
end

_G.DownPlayer = function(userid)
	local player = _G.UserToPlayer(userid)
	if player then
		local url = BASE_URL.."/public/downPlayer?userid="..player.userid.."&serversession="..GetSession()
		httpget(url, function(result, isSuccessful, resultCode)
			if isSuccessful and (resultCode == 200) then
				print("------------"..(player.userid).." downPlayer success--------------")
				local status, data = _G.pcall( function() return _G.json.decode(result) end )
				if not status or not data then
			 		print("解析player失败" .. tostring(player.userid) .."! ", tostring(status), tostring(data))
				else
					RecoveryPlayer(player, data)
				end
			else
				print("------------"..(player.userid).." downPlayer failed! ERROR:"..result.."--------------")
			end
		end)
	else
		print("当前user不在线")
	end
end
--DownPlayer("KU_lMqc62PN")

--[[_G.GetGiftFromWeb = function(player)
	print("--------------同步奖励信息--------------")
	if player and player.components.email then
		GetPlayerGift(player)
	end
end

AddPlayerPostInit(function(inst)
	--定时获取玩家礼包信息
	inst.gift_task = inst:DoPeriodicTask(TUNING.TOTAL_DAY_TIME*0.25, _G.GetGiftFromWeb)
end)]]
if TheNet:GetIsServer() then
	AddSimPostInit(function() 
		if _G.TheWorld.ismastershard then
			_G.TheWorld.save_task = _G.TheWorld:DoPeriodicTask(TUNING.TOTAL_DAY_TIME, _G.SaveAllPlayers)
		    _G.TheWorld:DoTaskInTime(10, _G.SaveServer)
		end
	    _G.TheWorld:ListenForEvent("ms_playerdespawnandmigrate", function(inst, data)
	    	local player = data.player
	    	SaveOnePlayer(player)
		end)
	end)
end