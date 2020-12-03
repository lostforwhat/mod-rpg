name = "彩色风滚草R"
description = ""
author = "五年"

version = "0.0.1"

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
		name = "token",
		label = "服务器令牌",
		hover = "专用服务器需要，连接网络商店及抽奖必须的令牌，获取方式请查看mod网站\n http://www.tumbleweedofall.com",
		options = {
			{description = "无", data = "", hover = "请直接在服务器的mod设置中配置值"},
		},
		default = "",
	}
}