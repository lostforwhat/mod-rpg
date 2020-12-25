require 'util'
local _G = GLOBAL
local unpack = _G.unpack

local key = "##MODRPG#(%d+)#"
_G.SHARD_KEY = string.gsub(key, "%(%%d%+%)", _G.TheShard:GetShardId()); --当前世界则把key替换为具体值
_G.SHARD_RULES = {} -- {rules , fn}

--此模块作为公共模块，可能有的依赖于此模块的功能没有开启，所以采用此方式
--添加规则 系统消息命中rule时，执行fn，rule可以使用正则表达式
_G.AddShardRule = function(rule, fn)
	if _G.SHARD_RULES[rule] == nil then
		_G.SHARD_RULES[rule] = {}
	end
	table.insert(_G.SHARD_RULES[rule], fn)
end

--多世界同步信息
local OldNetworking_SystemMessage = _G.Networking_SystemMessage
_G.Networking_SystemMessage = function(message)
	local st, ed, id = string.find(message, key)
--	print("st", st)
	if st == 1 then
		local content = string.sub(message, ed + 1)
		--print("content", content)
		for rule, fns in pairs(_G.SHARD_RULES) do
			--print("rule", rule)
			local res = {string.find(content, rule)} --pack
			--print("res", unpack(res))
			if res ~= nil and res[1] == 1 then
				for _, fn in ipairs(fns) do
					fn(content, id, unpack(res))
				end
			end
		end
		return
	end
    return OldNetworking_SystemMessage(message)
end


_G.CHAT_KEY = "#"
_G.CHAT_RULES = {
	["^pos$"] = {
		function(player, ...)
			if player.components.talker ~= nil then
				local x,y,z = player.Transform:GetWorldPosition()
				player.components.talker:Say("POS:"..math.ceil(x)..","..math.ceil(z))
			end
		end
	},
	["^move%s?(%d+),(%d+)$"] = {
		function(player, st, ed, x, z)
			if player:HasTag("titles_king") or player:HasTag("suit_space") or player.Network:IsServerAdmin() then
				if (player._move_cd == nil or _G.GetTime() - player._move_cd >= 30) then
					if _G.TheWorld.Map:IsPassableAtPoint(x, 0, z) then
						player.Transform:SetPosition(x, 0, z)
						player._move_cd = _G.GetTime()
					end
				else
					player.components.talker:Say("CD:"..math.floor(30 - (_G.GetTime() - player._move_cd)))
				end
			end
		end
	},
	["^help$"] = {
		function(player, ...)
			if player ~= nil and player.player_classified ~= nil 
				and player.player_classified._showhelp ~= nil then
				player.player_classified._showhelp:push()
			end
		end
	}
} --默认指令

--依旧提供对外api
_G.AddChatRule = function(rule, fn)
	if _G.CHAT_RULES[rule] == nil then
		_G.CHAT_RULES[rule] = {}
	end
	table.insert(_G.CHAT_RULES[rule], fn)
end
_G.RemoveChatRules = function(rule)
	if _G.CHAT_RULES ~= nil then
		_G.CHAT_RULES[rule] = nil
	end
end
--inst.Network:IsServerAdmin()  --判断是否管理员
--指令信息，亦可作为多世界通信使用
--if _G.TheNet:GetIsServer() or _G.TheNet:IsDedicated() then
local function GetPlayerById(playerid)
    for _, v in ipairs(_G.AllPlayers) do
        if v ~= nil and v.userid and v.userid == playerid then
            return v
        end
    end
    return nil
end
local OldNetworking_Say = _G.Networking_Say
_G.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, ...)
    local player = GetPlayerById(userid)
    if player ~= nil then
    	local st, ed = string.find(message, _G.CHAT_KEY)
		--	print("st", st)
		if st == 1 then
			local content = string.sub(message, ed + 1)
			local ordered = false
			for rule, fns in pairs(_G.CHAT_RULES) do
				--print("rule", rule)
				local res = {string.find(content, rule)} --pack
				--print("res", unpack(res))
				if res ~= nil and res[1] == 1 then
					for _, fn in ipairs(fns) do
						fn(player, unpack(res))
						ordered = true
					end
				end
			end
			if ordered then return end --指令生效则吃掉这条消息
		end
    end
    --修改字体颜色
	local st1, ed1, hex, msg = string.find(message, "^(#%x%x%x%x%x%x)(.*)$")
	if st1 == 1 then
		--print(_G.HexToPercentColor(hex))
		local r, g, b = _G.HexToPercentColor(hex)
		r = r or 0
		g = g or 0
		b = b or 0
		colour = {r, g, b, 1}
		message = msg
	end
    --local shardId = _G.TheShard:GetShardId() or 1
    OldNetworking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, ...)
end
--end