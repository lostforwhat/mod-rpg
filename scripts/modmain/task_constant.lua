--task constant

--任务数据
task_data = {
	all = {
		name="毕业",
		desc="完成所有主要任务",
		reward=10
	},
	--风滚草部分
	pick_one_tumbleweed = {
		name="初见风滚草",
		desc="采集%s次风滚草",
		reward=1
	},
	pick_tumbleweed_88 = {
		name="渐入佳境",
		desc="采集风滚草%s次",
		need=88,
		reward=1
	},
	pick_tumbleweed_288 = {
		name="初窥门径",
		desc="采集风滚草%s次",
		need=288,
		reward=2
	},
	pick_tumbleweed_888 = {
		name="习以为常",
		desc="采集风滚草%s次",
		need=888,
		reward=3
	},
	pick_tumbleweed_2888 = {
		name="摸宝专家",
		desc="采集风滚草%s次",
		need=2888,
		reward=5
	},
	pick_tumbleweed_6666 = {
		name="忠实草迷",
		desc="采集风滚草%s次",
		need=6666,
		reward=6,
		hide=true
	},
	pick_tumbleweed_red_100 = {
		name="好运气",
		desc="采集红色风滚草%s次",
		need=100,
		reward=3
	},
	pick_tumbleweed_yellow_60 = {
		name="发现宝藏",
		desc="采集橙色风滚草%s次",
		need=60,
		reward=4
	},
	pick_tumbleweed_light_20 = {
		name="神秘宝物",
		desc="采集发光风滚草%s次",
		need=20,
		reward=5,
		hide=true
	},
	pick_tumbleweed_green_120 = {
		name="灾厄之物",
		desc="采集绿色风滚草%s次",
		need=120,
		reward=3
	},
	pick_tumbleweed_blue_60 = {
		name="厄运之兆",
		desc="采集蓝色风滚草%s次",
		need=60,
		reward=4
	},

	--食物部分
	eat_100 = {
		name="吃饱",
		desc="吃食物%s次",
		need=100,
		reward=1
	},
	eat_1888 = {
		name="饱荒",
		desc="吃食物%s次",
		need=1888,
		reward=4
	},
	eat_type_20 = {
		name="尝鲜",
		desc="吃%s种不同的食物",
		need=20,
		reward=2
	},
	eat_type_40 = {
		name="佳肴",
		desc="吃%s种不同的食物",
		need=40,
		reward=4
	},
	eat_special_10 = {
		name="特殊料理",
		desc="吃%s次特殊料理的食物",
		need=10,
		reward=3
	},
	eat_prefared_200 = {
		name="挑食",
		desc="吃%s次烹饪锅食物",
		need=200,
		reward=5
	},
	eat_hot_10 = {
		name="热食",
		desc="吃%s次热食",
		need=10,
		reward=2
	},

	--击杀部分
	kill_100 = {
		name="弱肉强食",
		desc="击杀%s只怪物",
		need=100,
		reward=1
	},
	kill_1000 = {
		name="狩猎",
		desc="击杀%s只怪物",
		need=1000,
		reward=3
	},
	kill_spider_100 = {
		name="清理蜘蛛",
		desc="击杀%s只蜘蛛",
		need=100,
		reward=2
	},
	kill_hound_100 = {
		name="清理猎犬",
		desc="击杀%s只猎犬",
		need=100,
		reward=2
	},
	kill_bee_100 = {
		name="清理蜜蜂",
		desc="击杀%s只蜜蜂",
		need=100,
		reward=2
	},
	kill_mosquito_100 = {
		name="清理蚊子",
		desc="击杀%s只蚊子",
		need=100,
		reward=2
	},
	kill_frog_100 = {
		name="清理青蛙",
		desc="击杀%s只青蛙",
		need=100,
		reward=2
	},
	kill_koale_5 = {
		name="征服大象",
		desc="击杀%s只大象",
		need=5,
		reward=2
	},
	kill_monkey_20 = {
		name="戏耍猴子",
		desc="击杀%s只猴子",
		need=20,
		reward=1
	},
	kill_leif_5 = {
		name="行走的树",
		desc="击杀%s个树人",
		need=5,
		reward=2
	},
	kill_bunnyman_20 = {
		name="不干净",
		desc="击杀%s个兔人",
		need=20,
		reward=2
	},
	kill_tallbird_50 = {
		name="追人的高鸟",
		desc="击杀%s只高脚鸟",
		need=50,
		reward=3
	},
	kill_worm_20 = {
		name="会动的植物",
		desc="击杀%s只蠕虫",
		need=20,
		reward=2
	},
	kill_slurtle_20 = {
		name="致命蜗牛",
		desc="击杀%s只蜗牛",
		need=20,
		reward=2
	},
	kill_rabbit_10 = {
		name="小兔子乖乖",
		desc="击杀%s只小兔子",
		need=10,
		reward=1
	},
	kill_ghost_10 = {
		name="我不怕鬼",
		desc="击杀%s个鬼魂",
		need=10,
		reward=1
	},
	kill_tentacle_50 = {
		name="小心脚下",
		desc="击杀%s根触手",
		need=50,
		reward=2
	},
	kill_terrorbeak_50 = {
		name="消除噩梦",
		desc="击杀%s只梦魇",
		need=50,
		reward=2
	},
	kill_birchnutdrake_20 = {
		name="坚果成精",
		desc="击杀%s只桦树坚果",
		need=20,
		reward=2
	},
	kill_lightninggoat_20 = {
		name="带电的羊",
		desc="击杀%s只电羊",
		need=20,
		reward=2
	},
	kill_spiderqueen_10 = {
		name="蜘蛛首领",
		desc="击杀%s只蜘蛛女王",
		need=10,
		reward=3
	},
	kill_warg_5 = {
		name="猎犬首领",
		desc="击杀%s只狗王",
		need=5,
		reward=3
	},
	kill_catcoon_20 = {
		name="喵喵喵",
		desc="击杀%s只浣熊猫",
		need=20,
		reward=2
	},
	kill_walrus_20 = {
		name="海象爸爸",
		desc="击杀%s只海象",
		need=20,
		reward=2
	},
	kill_butterfly_20 = {
		name="黄油诅咒",
		desc="击杀%s只蝴蝶",
		need=20,
		reward=1
	},
	kill_bat_20 = {
		name="吸血蝙蝠",
		desc="击杀%s只蝙蝠",
		need=20,
		reward=2
	},
	kill_merm_30 = {
		name="浪哩个波",
		desc="击杀%s只鱼人",
		need=30,
		reward=2
	},
	kill_penguin_10 = {
		name="冬季过客",
		desc="击杀%s只企鹅",
		need=10,
		reward=2
	},
	kill_perd_20 = {
		name="今晚吃鸡",
		desc="击杀%s只火鸡",
		need=20,
		reward=2
	},
	kill_bird_20 = {
		name="捕鸟人",
		desc="击杀%s只鸟",
		need=20,
		reward=2
	},
	kill_pigman_20 = {
		name="你是个好人",
		desc="击杀%s只猪人",
		need=20,
		reward=2
	},
	kill_krampus_30 = {
		name="包包留下",
		desc="击杀%s个坎普斯",
		need=30,
		reward=3
	},
	kill_spat = {
		name="挑战刚羊",
		desc="击杀刚羊",
		need=1,
		reward=2
	},
	kill_moonpig_10 = {
		name="月下起武",
		desc="满月击杀%s只疯猪",
		need=10,
		reward=2
	},
	--boss
	kill_moose = {
		name="挑战鹿鸭",
		desc="击杀鹿鸭",
		need=1,
		reward=5
	},
	kill_dragonfly = {
		name="挑战龙蝇",
		desc="击杀龙蝇",
		need=1,
		reward=5
	},
	kill_beager = {
		name="挑战熊獾",
		desc="击杀熊獾",
		need=1,
		reward=5
	},
	kill_deerclops = {
		name="挑战巨鹿",
		desc="击杀巨鹿",
		need=1,
		reward=5
	},
	kill_killshadow_3 = {
		name="暗影三基佬",
		desc="击杀暗影主教、战车、骑士各一次，共%s次",
		need=3,
		reward=5
	},
	kill_stalker = {
		name="挑战远古狩猎者",
		desc="击杀远古狩猎者",
		need=1,
		reward=5
	},
	kill_stalker_atrium = {
		name="挑战远古暗影编织者",
		desc="击杀远古暗影编织者",
		need=1,
		reward=8
	},
	kill_klaus = {
		name="挑战克劳斯",
		desc="击杀克劳斯",
		need=1,
		reward=8
	},
	kill_antlion = {
		name="挑战蚁狮",
		desc="击杀蚁狮",
		need=1,
		reward=5
	},
	kill_minotaur = {
		name="挑战远古守护者",
		desc="击杀远古守护者",
		need=1,
		reward=6
	},
	kill_beequeen = {
		name="挑战蜜蜂女王",
		desc="击杀蜜蜂女王",
		need=1,
		reward=6
	},
	kill_toadstool = {
		name="挑战毒菌蘑菇",
		desc="击杀毒菌蘑菇",
		need=1,
		reward=6
	},
	kill_toadstool_dark = {
		name="挑战暗黑毒菌蘑菇",
		desc="击杀暗黑毒菌蘑菇",
		need=1,
		reward=8
	},
	kill_malbatross = {
		name="挑战邪天翁",
		desc="击杀邪天翁",
		need=1,
		reward=5
	},
	kill_crabking = {
		name="挑战帝王蟹",
		desc="击杀帝王蟹",
		need=1,
		reward=5
	},

	--伤害部分
	attack_30000 = {
		name="战斗",
		desc="总共造成有效伤害%s",
		need=30000,
		reward=2
	},
	hurt_10000 = {
		name="虚弱",
		desc="总共承受有效伤害%s",
		need=10000,
		reward=2
	},
	damage_1 = {
		name="手无缚鸡之力",
		desc="单次造成伤害1点",
		need=1,
		reward=1
	},
	hurt_1 = {
		name="不痛不痒",
		desc="单次受到伤害1点",
		need=1,
		reward=1
	},
	damage_66 = {
		name="计算精准",
		desc="单次造成伤害66点",
		need=1,
		reward=1
	},

	--种植收割部分


	--制作部分


	--交友与互动
	
}