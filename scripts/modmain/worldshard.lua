local _G = GLOBAL
local key = "##MODRPG##"
_G.SHARD_KEY = key
_G.shards_data = {} -- {rules , fn}

--此模块作为公共模块，可能有的依赖于此模块的功能没有开启，所以采用此方式
--添加规则
_G.AddShardRule = function(rule, fn)
	if _G.shards_data[rule] == nil then
		_G.shards_data[rule] = {}
	end
	table.insert(_G.shards_data[rule], fn)
end

--多世界同步信息
local OldNetworking_SystemMessage = _G.Networking_SystemMessage
_G.Networking_SystemMessage = function(message)
	if string.sub(message, 1, 10) == key then
		local content = string.sub(message, 11)
		for rule, fns in pairs(_G.shards_data) do
			if string.find(content, rule) == 1 then
				for _, fn in ipairs(fns) do
					fn(content)
				end
			end
		end
		return
	end
    return OldNetworking_SystemMessage(message)
end