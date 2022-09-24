GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--全局变量

TUNING.BIRD_PERISH_TIME = 12000;
TUNING.MULTITOOL_AXE_PICKAXE_USES = 1000;

STRINGS.NAMES.GREENGEM = "绿宝石"
STRINGS.NAMES.BUTTER = "黄油"

AddRecipe("greengem", {Ingredient("orangegem", 1),Ingredient("bluegem", 1),Ingredient("green_cap", 12)},
GLOBAL.RECIPETABS.REFINE, GLOBAL.TECH.MAGIC_TWO
)

AddRecipe("butter", {Ingredient("honeycomb", 1),Ingredient("royal_jelly", 1),Ingredient("honey", 12)},
	GLOBAL.RECIPETABS.REFINE, GLOBAL.TECH.MAGIC_TWO
)