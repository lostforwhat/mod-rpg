local _G = GLOBAL
local key = "##MODRPG#(%d+)#"
_G.SHARD_KEY = string.gsub(key, "%(%%d%+%)", _G.TheShard:GetShardId()); --当前世界则把key替换为具体值
_G.shards_data = {} -- {rules , fn}

--此模块作为公共模块，可能有的依赖于此模块的功能没有开启，所以采用此方式
--添加规则 系统消息命中rule时，执行fn，rule可以使用正则表达式
_G.AddShardRule = function(rule, fn)
	if _G.shards_data[rule] == nil then
		_G.shards_data[rule] = {}
	end
	table.insert(_G.shards_data[rule], fn)
end

--多世界同步信息
local OldNetworking_SystemMessage = _G.Networking_SystemMessage
_G.Networking_SystemMessage = function(message)
	local st, ed, id = string.find(message, key)
	if st == 1 then
		local content = string.sub(message, ed)
		for rule, fns in pairs(_G.shards_data) do
			local res = {string.find(content, rule)} --pack
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