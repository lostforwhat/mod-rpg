GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})--全局变量

STRINGS.NAMES.KLAUS_SACK = "赃物袋"
STRINGS.RECIPE_DESC.KLAUS_SACK = "装满宝藏的袋子!"
STRINGS.NAMES.DEER_ANTLER1 = "鹿角"
STRINGS.RECIPE_DESC.DEER_ANTLER1 = "它竟然能打开神奇的袋子"
--赃物袋
AddRecipe("klaus_sack", 
{Ingredient("greenmooneye", 1),Ingredient("orangemooneye", 1),Ingredient("yellowmooneye", 1),}, 
RECIPETABS.MAGIC, TECH.MAGIC_THREE, "klaus_sack_placer",2.5,nil,nil,nil,
"images/inventoryimages/klaus_sack.xml", "klaus_sack.tex")

--鹿角
AddRecipe("deer_antler1", {Ingredient("houndstooth", 6),Ingredient("boneshard", 2),Ingredient("silk", 5)},
GLOBAL.RECIPETABS.REFINE, GLOBAL.TECH.MAGIC_TWO)