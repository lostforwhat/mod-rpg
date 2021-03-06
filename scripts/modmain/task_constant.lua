--task constant

--由于商店价格最小为1，调整任务奖励率
local rate = 6

--任务数据
task_data = {
	all = {
		category="other",
		name="毕业",
		desc="完成所有主要任务",
		reward=10*rate
	},
	--风滚草部分
	pick_one_tumbleweed = {
		category="tumbleweed",
		name="初见风滚草",
		desc="采集%s次风滚草",
		reward=1*rate
	},
	pick_tumbleweed_88 = {
		category="tumbleweed",
		name="渐入佳境",
		desc="采集风滚草%s次",
		need=88,
		reward=1*rate
	},
	pick_tumbleweed_288 = {
		category="tumbleweed",
		name="初窥门径",
		desc="采集风滚草%s次",
		need=288,
		reward=2*rate
	},
	pick_tumbleweed_888 = {
		category="tumbleweed",
		name="习以为常",
		desc="采集风滚草%s次",
		need=888,
		reward=3*rate
	},
	pick_tumbleweed_2888 = {
		category="tumbleweed",
		name="摸宝专家",
		desc="采集风滚草%s次",
		need=2888,
		reward=5*rate
	},
	pick_tumbleweed_6666 = {
		category="tumbleweed",
		name="忠实草迷",
		desc="采集风滚草%s次",
		need=6666,
		reward=6*rate,
		hide=true
	},
	pick_tumbleweed_red_100 = {
		category="tumbleweed",
		name="好运气",
		desc="采集红色风滚草%s次",
		need=100,
		reward=3*rate
	},
	pick_tumbleweed_yellow_60 = {
		category="tumbleweed",
		name="发现宝藏",
		desc="采集橙色风滚草%s次",
		need=60,
		reward=4*rate
	},
	pick_tumbleweed_light_30 = {
		category="tumbleweed",
		name="发光之草",
		desc="采集发光风滚草%s次",
		need=30,
		reward=5*rate,
		hide=true
	},
	pick_tumbleweed_green_120 = {
		category="tumbleweed",
		name="灾厄之物",
		desc="采集绿色风滚草%s次",
		need=120,
		reward=3*rate
	},
	pick_tumbleweed_blue_60 = {
		category="tumbleweed",
		name="厄运之兆",
		desc="采集蓝色风滚草%s次",
		need=60,
		reward=4*rate
	},
	pick_tumbleweed_gift_50 = {
		category="tumbleweed",
		name="神秘宝物",
		desc="采集风滚草获得宝物%s次",
		need=50,
		reward=5*rate,
	},

	--食物部分
	eat_100 = {
		category="eat",
		name="吃饱",
		desc="吃食物%s次",
		need=100,
		reward=1*rate
	},
	eat_1888 = {
		category="eat",
		name="饱荒",
		desc="吃食物%s次",
		need=1888,
		reward=4*rate
	},
	eat_type_20 = {
		category="eat",
		name="尝鲜",
		desc="吃%s种不同的烹饪食物",
		need=20,
		reward=2*rate
	},
	eat_type_40 = {
		category="eat",
		name="佳肴",
		desc="吃%s种不同的烹饪食物",
		need=40,
		reward=4*rate
	},
	eat_special_10 = {
		category="eat",
		name="特殊料理",
		desc="吃%s次特殊料理的食物",
		need=10,
		reward=2*rate
	},
	eat_prefared_200 = {
		category="eat",
		name="挑食",
		desc="吃%s次烹饪锅食物",
		need=200,
		reward=5*rate
	},
	eat_hot_10 = {
		category="eat",
		name="热食",
		desc="吃%s次热食",
		need=10,
		reward=2*rate
	},
	eat_cold_10 = {
		category="eat",
		name="冷食",
		desc="吃%s次冷食",
		need=10,
		reward=2*rate
	},

	--击杀部分
	kill_100 = {
		category="kill",
		name="弱肉强食",
		desc="击杀%s只怪物",
		need=100,
		reward=1*rate
	},
	kill_1000 = {
		category="kill",
		name="狩猎",
		desc="击杀%s只怪物",
		need=1000,
		reward=3*rate
	},
	kill_9999 = {
		category="kill",
		name="杀戮",
		desc="击杀%s只怪物",
		need=9999,
		reward=5*rate,
		hide=true
	},
	kill_spider_100 = {
		category="kill",
		name="清理蜘蛛",
		desc="击杀%s只蜘蛛",
		need=100,
		reward=2*rate
	},
	kill_hound_100 = {
		category="kill",
		name="清理猎犬",
		desc="击杀%s只猎犬",
		need=100,
		reward=2*rate
	},
	kill_bee_100 = {
		category="kill",
		name="清理蜜蜂",
		desc="击杀%s只蜜蜂",
		need=100,
		reward=2*rate
	},
	kill_mosquito_100 = {
		category="kill",
		name="清理蚊子",
		desc="击杀%s只蚊子",
		need=100,
		reward=2*rate
	},
	kill_frog_100 = {
		category="kill",
		name="清理青蛙",
		desc="击杀%s只青蛙",
		need=100,
		reward=2*rate
	},
	kill_koale_5 = {
		category="kill",
		name="征服大象",
		desc="击杀%s只大象",
		need=5,
		reward=2*rate
	},
	kill_monkey_20 = {
		category="kill",
		name="戏耍猴子",
		desc="击杀%s只猴子",
		need=20,
		reward=2*rate
	},
	kill_bunnyman_20 = {
		category="kill",
		name="不干净",
		desc="击杀%s个兔人",
		need=20,
		reward=2*rate
	},
	kill_tallbird_50 = {
		category="kill",
		name="追人的高鸟",
		desc="击杀%s只高脚鸟",
		need=50,
		reward=3*rate
	},
	kill_worm_20 = {
		category="kill",
		name="会动的植物",
		desc="击杀%s只蠕虫",
		need=20,
		reward=2*rate
	},
	kill_slurtle_20 = {
		category="kill",
		name="致命蜗牛",
		desc="击杀%s只蜗牛",
		need=20,
		reward=2*rate
	},
	kill_rabbit_10 = {
		category="kill",
		name="小兔子乖乖",
		desc="击杀%s只小兔子",
		need=10,
		reward=1*rate
	},
	kill_ghost_10 = {
		category="kill",
		name="我不怕鬼",
		desc="击杀%s个鬼魂",
		need=10,
		reward=1*rate
	},
	kill_tentacle_50 = {
		category="kill",
		name="小心脚下",
		desc="击杀%s根触手",
		need=50,
		reward=2*rate
	},
	kill_terrorbeak_50 = {
		category="kill",
		name="消除噩梦",
		desc="击杀%s只梦魇",
		need=50,
		reward=2*rate
	},
	kill_birchnutdrake_20 = {
		category="kill",
		name="坚果成精",
		desc="击杀%s只桦树坚果",
		need=20,
		reward=2*rate
	},
	kill_lightninggoat_20 = {
		category="kill",
		name="带电的羊",
		desc="击杀%s只电羊",
		need=20,
		reward=2*rate
	},
	kill_catcoon_20 = {
		category="kill",
		name="喵喵喵",
		desc="击杀%s只浣熊猫",
		need=20,
		reward=2*rate
	},
	kill_walrus_20 = {
		category="kill",
		name="海象爸爸",
		desc="击杀%s只海象",
		need=20,
		reward=2*rate
	},
	kill_butterfly_20 = {
		category="kill",
		name="黄油诅咒",
		desc="击杀%s只蝴蝶",
		need=20,
		reward=1*rate
	},
	kill_bat_20 = {
		category="kill",
		name="吸血蝙蝠",
		desc="击杀%s只蝙蝠",
		need=20,
		reward=2*rate
	},
	kill_merm_30 = {
		category="kill",
		name="浪哩个波",
		desc="击杀%s只鱼人",
		need=30,
		reward=2*rate
	},
	kill_penguin_10 = {
		category="kill",
		name="冬季过客",
		desc="击杀%s只企鹅",
		need=10,
		reward=2*rate
	},
	kill_perd_20 = {
		category="kill",
		name="今晚吃鸡",
		desc="击杀%s只火鸡",
		need=20,
		reward=2*rate
	},
	kill_bird_20 = {
		category="kill",
		name="捕鸟人",
		desc="击杀%s只鸟",
		need=20,
		reward=2*rate
	},
	kill_pigman_20 = {
		category="kill",
		name="你是个好人",
		desc="击杀%s只猪人",
		need=20,
		reward=2*rate
	},
	kill_krampus_30 = {
		category="kill",
		name="包包留下",
		desc="击杀%s个坎普斯",
		need=30,
		reward=3*rate
	},
	kill_moonpig_10 = {
		category="kill",
		name="月下起武",
		desc="满月击杀%s只疯猪",
		need=10,
		reward=2*rate
	},
	--boss
	kill_leif_5 = {
		category="kill",
		name="行走的树",
		desc="击杀%s个树人",
		need=5,
		reward=2*rate
	},
	kill_spat = {
		category="kill",
		name="挑战刚羊",
		desc="击杀刚羊",
		need=1,
		reward=2*rate
	},
	kill_spiderqueen_10 = {
		category="kill",
		name="蜘蛛首领",
		desc="击杀%s只蜘蛛女王",
		need=10,
		reward=3*rate
	},
	kill_warg_5 = {
		category="kill",
		name="猎犬首领",
		desc="击杀%s只狗王",
		need=5,
		reward=3*rate
	},
	kill_moose = {
		category="killboss",
		name="挑战鹿鸭",
		desc="击杀鹿鸭",
		need=1,
		reward=5*rate
	},
	kill_dragonfly = {
		category="killboss",
		name="挑战龙蝇",
		desc="击杀龙蝇",
		need=1,
		reward=5*rate
	},
	kill_beager = {
		category="killboss",
		name="挑战熊獾",
		desc="击杀熊獾",
		need=1,
		reward=5*rate
	},
	kill_deerclops = {
		category="killboss",
		name="挑战巨鹿",
		desc="击杀巨鹿",
		need=1,
		reward=5*rate
	},
	kill_killshadow_3 = {
		category="killboss",
		name="暗影三巨头",
		desc="击杀暗影主教、战车、骑士各一次，共%s次",
		need=3,
		reward=5*rate
	},
	kill_stalker = {
		category="killboss",
		name="挑战远古狩猎者",
		desc="击杀远古狩猎者",
		need=1,
		reward=5*rate
	},
	kill_stalker_atrium = {
		category="killboss",
		name="挑战远古暗影编织者",
		desc="击杀远古暗影编织者",
		need=1,
		reward=8*rate
	},
	kill_klaus = {
		category="killboss",
		name="挑战克劳斯",
		desc="击杀克劳斯",
		need=1,
		reward=8*rate
	},
	kill_antlion = {
		category="killboss",
		name="挑战蚁狮",
		desc="击杀蚁狮",
		need=1,
		reward=5*rate
	},
	kill_minotaur = {
		category="killboss",
		name="挑战远古守护者",
		desc="击杀远古守护者",
		need=1,
		reward=6*rate
	},
	kill_beequeen = {
		category="killboss",
		name="挑战蜜蜂女王",
		desc="击杀蜜蜂女王",
		need=1,
		reward=6*rate
	},
	kill_toadstool = {
		category="killboss",
		name="挑战毒菌蘑菇",
		desc="击杀毒菌蘑菇",
		need=1,
		reward=6*rate
	},
	kill_toadstool_dark = {
		category="killboss",
		name="挑战暗黑毒菌蘑菇",
		desc="击杀暗黑毒菌蘑菇",
		need=1,
		reward=8*rate
	},
	kill_malbatross = {
		category="killboss",
		name="挑战邪天翁",
		desc="击杀邪天翁",
		need=1,
		reward=5*rate
	},
	kill_crabking = {
		category="killboss",
		name="挑战帝王蟹",
		desc="击杀帝王蟹",
		need=1,
		reward=6*rate
	},
	kill_klaus_rage = {
		category="killboss",
		name="暴怒的克劳斯",
		desc="击杀暴怒克劳斯",
		need=1,
		reward=10*rate,
		hide=true
	},
	kill_boss_100 = {
		category="killboss",
		name="巨人杀手",
		desc="击杀BOSS %s次",
		need=100,
		reward=9*rate,
		hide=true
	},

	--伤害部分
	attack_30000 = {
		category="damage",
		name="战斗",
		desc="总共造成有效伤害%s",
		need=30000,
		reward=2*rate
	},
	attack_99999 = {
		category="damage",
		name="战神",
		desc="总共造成有效伤害%s",
		need=99999,
		reward=2*rate,
		hide=true
	},
	hurt_10000 = {
		category="damage",
		name="虚弱",
		desc="总共承受有效伤害%s",
		need=10000,
		reward=2*rate
	},
	damage_1 = {
		category="damage",
		name="手无缚鸡之力",
		desc="单次造成伤害1点",
		need=1,
		reward=1*rate
	},
	hurt_1 = {
		category="damage",
		name="不痛不痒",
		desc="单次受到伤害1点",
		need=1,
		reward=1*rate
	},
	damage_66 = {
		category="damage",
		name="计算精准",
		desc="单次造成伤害66点",
		need=1,
		reward=1*rate
	},

	--种植收割部分
	plant_100 = {
		category="farm",
		name="园丁",
		desc="种植作物%s次",
		need=100,
		reward=2*rate
	},
	plant_1000 = {
		category="farm",
		name="绿化大师",
		desc="种植作物%s次",
		need=1000,
		reward=4*rate
	},
	pick_100 = {
		category="farm",
		name="收割者",
		desc="采集作物%s次",
		need=100,
		reward=2*rate
	},
	pick_1000 = {
		category="farm",
		name="收割机",
		desc="采集作物%s次",
		need=1000,
		reward=4*rate
	},
	pick_cactus_50 = {
		category="farm",
		name="扎手手",
		desc="采集仙人掌%s棵",
		need=50,
		reward=2*rate
	},
	pick_mushroom_100 = {
		category="farm",
		name="采蘑菇",
		desc="采集蘑菇%s棵",
		need=100,
		reward=2*rate
	},
	pick_flower_cave_100 = {
		category="farm",
		name="小灯泡",
		desc="采集发光果%s棵",
		need=100,
		reward=2*rate
	},
	pick_tallbirdnest_10 = {
		category="farm",
		name="掏鸟蛋",
		desc="采集高鸟蛋%s个",
		need=10,
		reward=1*rate
	},
	pick_rock_avocado_bush_100 = {
		category="farm",
		name="石头果实",
		desc="采集石果%s个",
		need=100,
		reward=2*rate
	},
	pick_cave_banana_tree_50 = {
		category="farm",
		name="摘香蕉",
		desc="采集香蕉%s次",
		need=50,
		reward=2*rate
	},
	pick_wormlight_plant_40 = {
		category="farm",
		name="浆果会发光",
		desc="采集小发光浆果%s次",
		need=40,
		reward=2*rate
	},
	pick_reeds_50 = {
		category="farm",
		name="割芦苇",
		desc="采集芦苇%s棵",
		need=50,
		reward=2*rate
	},
	pick_coffeebush_50 = {
		category="farm",
		name="采咖啡",
		desc="采集咖啡%s次",
		need=50,
		reward=3*rate
	},

	chop_100 = {
		category="farm",
		name="伐木工",
		desc="砍树%s棵",
		need=100,
		reward=2*rate
	},
	chop_1000 = {
		category="farm",
		name="光头强",
		desc="砍树%s棵",
		need=1000,
		reward=4*rate
	},
	mine_60 = {
		category="farm",
		name="矿工",
		desc="挖矿%s座",
		need=60,
		reward=1*rate
	},
	mine_500 = {
		category="farm",
		name="矿老板",
		desc="挖矿%s座",
		need=500,
		reward=3*rate
	},

	--烹饪
	cook_100 = {
		category="cook",
		name="大厨",
		desc="烹饪%s次",
		need=100,
		reward=2*rate
	},
	cook_888 = {
		category="cook",
		name="小当家",
		desc="烹饪%s次",
		need=888,
		reward=4*rate
	},
	cook_butterflymuffin_5 = {
		category="cook",
		name="蝴蝶松饼",
		desc="烹饪蝴蝶松饼%s次",
		need=5,
		reward=1*rate
	},
	cook_frogglebunwich_5 = {
		category="cook",
		name="蛙腿三明治",
		desc="烹饪蛙腿三明治%s次",
		need=5,
		reward=1*rate
	},
	cook_taffy_5 = {
		category="cook",
		name="太妃糖",
		desc="烹饪太妃糖%s次",
		need=5,
		reward=1*rate
	},
	cook_pumpkincookie_5 = {
		category="cook",
		name="南瓜饼干",
		desc="烹饪南瓜饼干%s次",
		need=5,
		reward=1*rate
	},
	cook_stuffedeggplant_5 = {
		category="cook",
		name="香酥茄盒",
		desc="烹饪香酥茄盒%s次",
		need=5,
		reward=1*rate
	},
	cook_fishsticks_5 = {
		category="cook",
		name="炸鱼条",
		desc="烹饪炸鱼条%s次",
		need=5,
		reward=1*rate
	},
	cook_honeynuggets_5 = {
		category="cook",
		name="甜蜜金砖",
		desc="烹饪甜蜜金砖%s次",
		need=5,
		reward=1*rate
	},
	cook_honeyham_5 = {
		category="cook",
		name="蜜汁火腿",
		desc="烹饪蜜汁火腿%s次",
		need=5,
		reward=1*rate
	},
	cook_dragonpie_5 = {
		category="cook",
		name="火龙果派",
		desc="烹饪火龙果派%s次",
		need=5,
		reward=1*rate
	},
	cook_kabobs_5 = {
		category="cook",
		name="烤肉串",
		desc="烹饪烤肉串%s次",
		need=5,
		reward=1*rate
	},
	cook_mandrakesoup_2 = {
		category="cook",
		name="曼德拉汤",
		desc="烹饪曼德拉汤%s次",
		need=2,
		reward=1*rate
	},
	cook_baconeggs_5 = {
		category="cook",
		name="培根煎蛋",
		desc="烹饪培根煎蛋%s次",
		need=5,
		reward=1*rate
	},
	cook_perogies_5 = {
		category="cook",
		name="饺子",
		desc="烹饪饺子%s次",
		need=5,
		reward=1*rate
	},
	cook_turkeydinner_5 = {
		category="cook",
		name="火鸡大餐",
		desc="烹饪火鸡大餐%s次",
		need=5,
		reward=1*rate
	},
	cook_jammypreserves_5 = {
		category="cook",
		name="果酱蜜饯",
		desc="烹饪果酱蜜饯%s次",
		need=5,
		reward=1*rate
	},
	cook_fruitmedley_5 = {
		category="cook",
		name="水果集锦",
		desc="烹饪水果集锦%s次",
		need=5,
		reward=1*rate
	},
	cook_fishtacos_5 = {
		category="cook",
		name="鱼肉玉米卷",
		desc="烹饪鱼肉玉米卷%s次",
		need=5,
		reward=1*rate
	},
	cook_waffles_5 = {
		category="cook",
		name="华夫饼",
		desc="烹饪华夫饼%s次",
		need=5,
		reward=1*rate
	},
	cook_unagi_10 = {
		category="cook",
		name="鳗鱼料理",
		desc="烹饪鳗鱼料理%s次",
		need=10,
		reward=3*rate
	},
	cook_flowersalad_10 = {
		category="cook",
		name="鲜花沙拉",
		desc="烹饪鲜花沙拉%s次",
		need=10,
		reward=3*rate
	},
	cook_icecream_5 = {
		category="cook",
		name="冰淇淋",
		desc="烹饪冰淇淋%s次",
		need=5,
		reward=1*rate
	},
	cook_watermelonicle_5 = {
		category="cook",
		name="西瓜冰",
		desc="烹饪西瓜冰%s次",
		need=5,
		reward=1*rate
	},
	cook_trailmix_5 = {
		category="cook",
		name="什锦干果",
		desc="烹饪什锦干果%s次",
		need=5,
		reward=1*rate
	},
	cook_hotchili_5 = {
		category="cook",
		name="辣椒酱",
		desc="烹饪辣椒酱%s次",
		need=5,
		reward=1*rate
	},
	cook_guacamole_10 = {
		category="cook",
		name="鳄梨酱",
		desc="烹饪鳄梨酱%s次",
		need=10,
		hide=true,
		reward=3*rate
	},
	cook_bananapop_5 = {
		category="cook",
		name="香蕉冰",
		desc="烹饪香蕉冰%s次",
		need=5,
		reward=1*rate
	},

	--制作部分
	build_30 = {
		category="build",
		name="瓦匠",
		desc="建造%s次",
		need=30,
		reward=1*rate
	},
	build_300 = {
		category="build",
		name="工艺师",
		desc="建造%s次",
		need=300,
		reward=3*rate
	},
	build_pumpkin_lantern = {
		category="build",
		name="南瓜灯",
		desc="建造南瓜灯%s个",
		need=5,
		reward=1*rate
	},
	build_armorruins = {
		category="build",
		name="远古盔甲",
		desc="制作远古盔甲%s个",
		need=5,
		reward=2*rate
	},
	build_ruinshat = {
		category="build",
		name="远古皇冠",
		desc="制作远古皇冠%s个",
		need=5,
		reward=2*rate
	},
	build_ruins_bat = {
		category="build",
		name="远古铥棒",
		desc="制作远古铥棒%s个",
		need=5,
		reward=2*rate
	},
	build_gunpowder = {
		category="build",
		name="火药",
		desc="制作火药%s份",
		need=30,
		reward=3*rate
	},
	build_healingsalve = {
		category="build",
		name="治疗药膏",
		desc="制作治疗药膏%s份",
		need=5,
		reward=1*rate
	},
	build_bandage = {
		category="build",
		name="蜂蜜药膏",
		desc="制作蜂蜜药膏%s份",
		need=10,
		reward=2*rate
	},
	build_blowdart_pipe = {
		category="build",
		name="吹箭",
		desc="制作吹箭%s份",
		need=30,
		reward=2*rate
	},
	build_blowdart_sleep = {
		category="build",
		name="睡眠吹箭",
		desc="制作睡眠吹箭%s份",
		need=20,
		reward=2*rate
	},
	build_blowdart_yellow = {
		category="build",
		name="电磁吹箭",
		desc="制作电磁吹箭%s份",
		need=20,
		reward=2*rate
	},
	build_blowdart_fire = {
		category="build",
		name="燃烧吹箭",
		desc="制作燃烧吹箭%s份",
		need=20,
		reward=2*rate
	},
	build_nightsword = {
		category="build",
		name="暗夜剑",
		desc="制作暗夜剑%s次",
		need=3,
		reward=1*rate
	},
	build_amulet = {
		category="build",
		name="生命护符",
		desc="制作生命护符%s次",
		need=5,
		reward=1*rate
	},
	build_panflute = {
		category="build",
		name="排箫",
		desc="制作排箫%s次",
		need=2,
		reward=1*rate
	},
	build_molehat = {
		category="build",
		name="鼹鼠帽",
		desc="制作鼹鼠帽%s次",
		need=5,
		reward=1*rate
	},
	build_lifeinjector = {
		category="build",
		name="强心针",
		desc="制作强心针%s次",
		need=5,
		reward=2*rate
	},
	build_batbat = {
		category="build",
		name="蝙蝠棍",
		desc="制作蝙蝠棍%s次",
		need=5,
		reward=1*rate
	},
	build_multitool_axe_pickaxe = {
		category="build",
		name="镐斧",
		desc="制作镐斧%s次",
		need=2,
		reward=1*rate
	},
	build_thulecite = {
		category="build",
		name="合成铥矿",
		desc="制作铥矿%s次",
		need=20,
		reward=1*rate
	},
	build_yellowstaff = {
		category="build",
		name="焕星法杖",
		desc="制作焕星法杖%s次",
		need=5,
		reward=2*rate
	},
	build_footballhat = {
		category="build",
		name="橄榄球头盔",
		desc="制作橄榄球头盔%s次",
		need=10,
		reward=1*rate
	},
	build_armorwood = {
		category="build",
		name="木头盔甲",
		desc="制作木头盔甲%s次",
		need=10,
		reward=1*rate
	},
	build_hambat = {
		category="build",
		name="火腿棒",
		desc="制作火腿棒%s次",
		need=5,
		reward=1*rate
	},
	build_glasscutter = {
		category="build",
		name="镜片刀",
		desc="制作镜片刀%s次",
		need=5,
		reward=2*rate
	},


	--交友与互动
	makefriend_pigman = {
		category="friend",
		name="猪人兄弟",
		desc="收买%s只猪人",
		need=10,
		reward=2*rate
	},
	makefriend_bunnyman = {
		category="friend",
		name="兔兔那么可爱",
		desc="收买%s只兔人",
		need=10,
		reward=2*rate
	},
	makefriend_catcoon = {
		category="friend",
		name="吸猫",
		desc="收买%s只小浣猫",
		need=10,
		reward=2*rate
	},
	makefriend_spider = {
		category="friend",
		name="我是女王",
		desc="收买%s只蜘蛛",
		need=20,
		reward=2*rate
	},
	makefriend_mandrake_active = {
		category="friend",
		name="森林之友",
		desc="收买%s棵曼德拉草",
		need=2,
		reward=1*rate
	},
	makefriend_smallbird = {
		category="friend",
		name="我当妈妈",
		desc="孵化%s只高脚鸟",
		need=1,
		reward=2*rate
	},
	makefriend_rocky = {
		category="friend",
		name="石虾守卫",
		desc="收买%s只石虾",
		need=5,
		reward=2*rate
	},

	--other
	collect_30 = {
		category="other",
		name="交易",
		desc="完成%s次猪王(鱼人王)收集任务",
		need=30,
		reward=3*rate
	},
	collect_300 = {
		category="other",
		name="供应链",
		desc="完成%s次猪王(鱼人王)收集任务",
		need=300,
		hide=true,
		reward=5*rate
	},
	strength_10 = {
		category="other",
		name="强化",
		desc="熔炼装备%s次",
		need=10,
		reward=3*rate
	},
	strength_100 = {
		category="other",
		name="锻造师",
		desc="熔炼装备%s次",
		need=100,
		hide=true,
		reward=5*rate
	},
	strength_level_10 = {
		category="other",
		name="高级武器",
		desc="熔炼装备等级到10级",
		need=1,
		reward=2*rate
	},
	strength_level_20 = {
		category="other",
		name="难得一见",
		desc="熔炼装备等级到20级",
		need=1,
		hide=true,
		reward=8*rate
	},
}

--按顺序排序
task_list = {
	'all',
	--风滚草部分
	'pick_one_tumbleweed',
	'pick_tumbleweed_88',
	'pick_tumbleweed_288',
	'pick_tumbleweed_888',
	'pick_tumbleweed_2888',
	'pick_tumbleweed_6666',
	'pick_tumbleweed_red_100',
	'pick_tumbleweed_yellow_60',
	'pick_tumbleweed_light_30',
	'pick_tumbleweed_green_120',
	'pick_tumbleweed_blue_60',
	'pick_tumbleweed_gift_50',

	--食物部分
	'eat_100',
	'eat_1888',
	'eat_type_20',
	'eat_type_40',
	'eat_special_10',
	'eat_prefared_200',
	'eat_hot_10',
	'eat_cold_10',

	--击杀部分
	'kill_100',
	'kill_1000',
	'kill_spider_100',
	'kill_hound_100',
	'kill_bee_100',
	'kill_mosquito_100',
	'kill_frog_100',
	'kill_koale_5',
	'kill_monkey_20',
	'kill_bunnyman_20',
	'kill_tallbird_50',
	'kill_worm_20',
	'kill_slurtle_20',
	'kill_rabbit_10',
	'kill_ghost_10',
	'kill_tentacle_50',
	'kill_terrorbeak_50',
	'kill_birchnutdrake_20',
	'kill_lightninggoat_20',
	'kill_catcoon_20',
	'kill_walrus_20',
	'kill_butterfly_20',
	'kill_bat_20',
	'kill_merm_30',
	'kill_penguin_10',
	'kill_perd_20',
	'kill_bird_20',
	'kill_pigman_20',
	'kill_krampus_30',
	'kill_moonpig_10',
	--boss
	'kill_spat',
	'kill_spiderqueen_10',
	'kill_warg_5',
	'kill_leif_5',
	'kill_moose',
	'kill_dragonfly',
	'kill_beager',
	'kill_deerclops',
	'kill_killshadow_3',
	'kill_stalker',
	'kill_stalker_atrium',
	'kill_klaus',
	'kill_antlion',
	'kill_minotaur',
	'kill_beequeen',
	'kill_toadstool',
	'kill_toadstool_dark',
	'kill_malbatross',
	'kill_crabking',

	--伤害部分
	'attack_30000',
	'attack_99999',
	'hurt_10000',
	'damage_1',
	'hurt_1',
	'damage_66',

	--种植收割部分
	'plant_100',
	'plant_1000',
	'pick_100',
	'pick_1000',
	'pick_cactus_50',
	'pick_mushroom_100',
	'pick_flower_cave_100',
	'pick_tallbirdnest_10',
	'pick_rock_avocado_bush_100',
	'pick_cave_banana_tree_50',
	'pick_wormlight_plant_40',
	'pick_reeds_50',
	'pick_coffeebush_50',

	'chop_100',
	'chop_1000',
	'mine_60',
	'mine_500',

	--烹饪
	'cook_100',
	'cook_888',
	'cook_butterflymuffin_5',
	'cook_frogglebunwich_5',
	'cook_taffy_5',
	'cook_pumpkincookie_5',
	'cook_stuffedeggplant_5',
	'cook_fishsticks_5',
	'cook_honeynuggets_5',
	'cook_honeyham_5',
	'cook_dragonpie_5',
	'cook_kabobs_5',
	'cook_mandrakesoup_2',
	'cook_baconeggs_5',
	'cook_perogies_5',
	'cook_turkeydinner_5',
	'cook_jammypreserves_5',
	'cook_fruitmedley_5',
	'cook_fishtacos_5',
	'cook_waffles_5',
	'cook_unagi_10',
	'cook_flowersalad_10',
	'cook_icecream_5',
	'cook_watermelonicle_5',
	'cook_trailmix_5',
	'cook_hotchili_5',
	'cook_bananapop_5',

	--制作部分
	'build_30',
	'build_300',
	'build_pumpkin_lantern',
	'build_armorruins',
	'build_ruinshat',
	'build_ruins_bat',
	'build_gunpowder',
	'build_healingsalve',
	'build_bandage',
	'build_blowdart_pipe',
	'build_blowdart_sleep',
	'build_blowdart_yellow',
	'build_blowdart_fire',
	'build_nightsword',
	'build_amulet',
	'build_panflute',
	'build_molehat',
	'build_lifeinjector',
	'build_batbat',
	'build_multitool_axe_pickaxe',
	'build_thulecite',
	'build_yellowstaff',
	'build_footballhat',
	'build_armorwood',
	'build_hambat',
	'build_glasscutter',


	--交友与互动
	'makefriend_pigman',
	'makefriend_bunnyman',
	'makefriend_catcoon',
	'makefriend_spider',
	'makefriend_mandrake_active',
	'makefriend_smallbird',
	'makefriend_rocky',

	'collect_30',
	'strength_10',
	'strength_level_10',
}