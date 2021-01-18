name = " 彩色风滚草R"
description = [[
本mod基于原彩色风滚草升级为新版本，大致玩法不变
新增装备等级系统，新增部分物品及装备
新增收集任务（猪王、鱼人王）
新增网络商店
新增世界活动
新增怪物强化

自带5格装备栏、99堆叠、死亡不掉落、一键复活
建议同时开启的mod: showme，简单血条，全球定位等以增强游戏体验
mod详细查看 http://www.tumbleweedofall.xyz/extend
]]
author = "五年"

version = "1.1.10"

api_version = 10

all_clients_require_mod = true
client_only_mod = false
dst_compatible = true

forumthread = ""

icon_atlas = "modicon.xml"
icon = "modicon.tex"

local world_names = {"世界", "world", "地面", "洞穴", "特殊", "永冬", "永夜", "建家", "凶险"}
local world_name_options = {}
for i = 1, #world_names do
	world_name_options[i] = {description=world_names[i], data=world_names[i], hover=world_names[i]}
end
local nums = {}
nums[1] = {description="自动", data=false, hover="自动使用服务器总人数/世界数作为当前世界人数上限"}
for i = 1, 60 do
	nums[i+1] = {description=i, data=i, hover="当前世界人数上限"..i}
end

configuration_options =
{
	{
		name = "clean",
		label = "清理工具",
		hover = "开启自带清理工具，建议开启",
		options = {
			{description = "开启", data = true, hover = "开启"},
			{description = "关闭", data = false, hover = "关闭"},
		},
		default = true,
	},
	{
		name = "world_name",
		label = "世界名称",
		hover = "多世界选项，若需要命名其他名称，可直接设置其他值",
		options = world_name_options,
		default = world_names[1],
	},
	{
		name = "max_players",
		label = "人数上限",
		hover = "多世界选项，若需要设置其他数值，可直接设置其他值",
		options = nums,
		default = false,
	},
	{
		name = "token",
		label = "服务器令牌",
		hover = "专用服务器需要，连接网络商店及抽奖必须的令牌，获取方式请查看mod网站\n http://www.tumbleweedofall.xyz",
		options = {
			{description = "无", data = false, hover = "请直接在服务器的mod设置中配置值"},
		},
		default = false,
	},
	{
		name = "save",
		label = "云存档",
		hover = "搭建专服时备份服务器数据及人物数据至云服务器\n 此选项需要配置正确的服务器令牌",
		options = {
			{description = "开启", data = true, hover = "开启，管理员可以使用命令从云存档恢复玩家数据"},
			{description = "关闭", data = false, hover = "关闭"},
		},
		default = false,
	},
	{
		name = "holiday",
		label = "服务器活动",
		hover = "非专用服务器不建议开启\n 此选项开启后会不定时开启服务器范围内的奖励活动",
		options = {
			{description = "开启", data = true, hover = "开启活动"},
			{description = "关闭", data = false, hover = "关闭"},
		},
		default = true,
	},
	{
		name = "level",
		label = "难度",
		hover = "高难度boss增强，并且对应物品掉落减少",
		options = {
			{description = "简单", data = 1, hover = "非常简单"},
			{description = "困难", data = 2, hover = "难度适中"},
			{description = "噩梦", data = 3, hover = "非常困难模式"},
			{description = "地狱", data = 4, hover = "不要轻易尝试"},
		},
		default = 3
	},
}