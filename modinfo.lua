name = " 彩色风滚草"
description = [[
彩色风滚草物品联动了神话书说，棱镜和能力勋章，让体验更加丰富多彩！

本mod搬运自steam，作者五年，已经获得授权，通过自己添加新功能获取更新玩法，其他人不得再次搬运
彩色风滚草交流群：384301246
基于原彩色风滚草升级为新版本，大致玩法不变
新增装备等级称号系统，新增部分物品及装备
新增收集任务（猪王、鱼人王）
新增网络商店
新增世界活动
新增怪物强化

自带多世界选择器、禁用资源再生、99堆叠、死亡不掉落、一键复活、怪物增强等MOD！
为防止冲突，请勿开启相同类型的mod！
建议同时开启的mod: 提示属性，简易血条，全球定位等以增强游戏体验
理论上风滚草可以开出全部物品，只是概率问题，需要加洞穴才可完成所有任务
]]
author = "五年,波林罗"

version = "1.3.9"

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
	{name="kong",label="风滚草生成",options={{description ="",data = 0,}},default=0,},
	{name = "pattern",label = "模式",hover = "两种生成模式",
		options =
    {
			{description = "传统", data = 1, hover = "选择传统则忽略下方网格设置"}, 
			{description = "网格", data = 2, hover = "选择网格则忽略下方传统设置"},  
    },
		default = 2,
	},
	{name = "Title",label = "传统设置", 
		options = 
		{
			{description = "", data = ""},
		}, 
		default = "",
	},
	{name = "orders",label = "生成数量",hover = "正常能够满足",
		options =
    {
			{description = "大量", data = 2}, 
			{description = "普通", data = 1}, 
			{description = "无", data = 0}, 
    },
		default = 2,
	},
	{name = "Title",label = "网格设置", 
		options = 
		{
			{description = "", data = ""},
		}, 
		default = "",
	},
	{name = "spacing",label = "间距",hover = "生成间距",
		options =
    {
			{description = "大量", data = 11}, 
			{description = "普通", data = 16}, --15块地皮，大概有200个左右风滚草刷新点
			{description = "少量", data = 21}, 
        },
		default = 11,
	},
	{name = "offset",label = "混乱程度",hover = "数量越大，偏移原位置的上限越大",
		options =
    {
      {description = "混乱", data = 15}, 
			{description = "正常", data = 10}, 
			{description = "稍微偏离", data = 5}, 
			{description = "没有偏离", data = 0}, 
    },
		default = 15,
	},
	{name="kong",label="彩色风滚草",options={{description ="",data = 0,}},default=0,},
	{name = "clean",label = "清理工具",hover = "开启自带清理工具，建议开启",
		options = {
			{description = "开启", data = true, hover = "开启"},
			{description = "关闭", data = false, hover = "关闭"},
		},
		default = true,
	},
	{name = "world_name",label = "世界名称",hover = "多世界选项，若需要命名其他名称，可直接设置其他值",
		options = world_name_options,
		default = world_names[1],
	},
	{name = "max_players",label = "人数上限",hover = "多世界选项，若需要设置其他数值，可直接设置其他值",
		options = nums,
		default = false,
	},
	{name = "token",label = "服务器令牌",hover = "专用服务器需要，连接网络商店及抽奖必须的令牌，获取方式请查看mod网站\n http://www.tumbleweedofall.xyz",
		options = {
			{description = "无", data = false, hover = "请直接在服务器的mod设置中配置值"},
		},
		default = false,
	},
	{name = "save",label = "云存档",hover = "搭建专服时备份服务器数据及人物数据至云服务器\n 此选项需要配置正确的服务器令牌",
		options = {
			{description = "开启", data = true, hover = "开启，管理员可以使用命令从云存档恢复玩家数据"},
			{description = "关闭", data = false, hover = "关闭"},
		},
		default = false,
	},
	{name = "holiday",label = "服务器活动",hover = "非专用服务器不建议开启\n 此选项开启后会不定时开启服务器范围内的奖励活动",
		options = {
			{description = "开启", data = true, hover = "开启活动"},
			{description = "关闭", data = false, hover = "关闭"},
		},
		default = true,
	},
	{name = "level",label = "难度",hover = "高难度boss增强，并且对应物品掉落减少",
		options = {
			{description = "简单", data = 1, hover = "非常简单"},
			{description = "困难", data = 2, hover = "难度适中"},
			{description = "噩梦", data = 3, hover = "非常困难模式"},
			{description = "地狱", data = 4, hover = "不要轻易尝试"},
		},
		default = 4
	},
	{name="kong",label="背包设置",options={{description ="",data = 0,}},default=0,},
	{name = "INCREASEBACKPACKSIZES_BACKPACK",label = "普通背包和保鲜背包",
		options =	
		{
			{description = "默认", data = 8},
			{description = "20格", data = 20},
			{description = "30格", data = 30},
		},
		default = 30,
	  },
    {name = "INCREASEBACKPACKSIZES_PIGGYBACK",label = "猪皮背包",
			options =	
			{   
        {description = "默认", data = 12},
				{description = "20格", data = 20},	
				{description = "30格", data = 30},
				{description = "40格", data = 40},
			},
			default = 40,
	  },
    {name = "INCREASEBACKPACKSIZES_KRAMPUSSACK",label = "坎普斯背包",
			options =	
			{
        {description = "默认", data = 14},
				{description = "20格", data = 20},
				{description = "30格", data = 30},
				{description = "40格", data = 40},
				{description = "50格", data = 50},
			},
			default = 50,
	  },
	{name="kong",label="宝石种植",options={{description ="",data = 0,}},default=0,},
	{name = "growtime",label = "生长周期",hover = "宝石植株生长周期设置(天)",
    options = 
	    {
        {description = "5", data = 5},
        {description = "8", data = 8},
        {description = "10", data = 10},
	    },
    	default = 5,
   },
	{name = "gemcost",label = "消耗宝石",hover = "合成宝石植株消耗宝石数量",
    options = 
		  {
		    {description = "5", data = 5},
		    {description = "8", data = 8},
		    {description = "10", data = 10},
		  },
		  default = 5,
  },
	{name="kong",label="死亡掉落",options={{description ="",data = 0,}},default=0,},
	{name = "mindiaoluo",label = "最小掉落物品",hover = "最小掉落的物品格数",
    options =
    {
      {description = "1",  data = 1,  hover = "注意不要超过最大掉落，可以相等"},
      {description = "2",  data = 2,  hover = ""},
      {description = "3",  data = 3,  hover = ""},
      {description = "4",  data = 4,  hover = ""},
      {description = "5",  data = 5,  hover = ""}
    },
    default = 1,
  },
  {name = "maxdiaoluo",label = "最大掉落物品",hover = "最大掉落的物品格数",
    options =
    {
      {description = "1",  data = 1,  hover = "注意不要低于最小掉落，可以相等"},
      {description = "2",  data = 2,  hover = ""},
      {description = "3",  data = 3,  hover = ""},
      {description = "4",  data = 4,  hover = ""},
      {description = "5",  data = 5,  hover = ""}
    },
    default = 1,
  },
	{name="kong",label="自动公告",options={{description ="",data = 0,}},default=0,},
  {name = "interval",label = "发送间隔",
    options = {
      {description = "70秒", data = 70},
      {description = "80秒", data = 80},
      {description = "90秒", data = 90},
      {description = "100秒", data = 100},
      {description = "120秒", data = 120},
      {description = "150秒", data = 150},
      {description = "180秒", data = 180},
    },
    default = 70,
  },
	{name = "send_rule",label = "发送规律",
    options = {
      {description = "顺序发送", data = 1},
      {description = "随机发送", data = 2},
    },
    default = 2,
  },
}