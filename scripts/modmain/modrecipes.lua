local _G = GLOBAL
local FOODTYPE = _G.FOODTYPE
local TECH = _G.TECH
local RECIPETABS = _G.RECIPETABS

--添加烹饪配方
AddIngredientValues({"coffeebean"}, {fruit=.5}, true)
AddIngredientValues({"coffeebean_cooked"}, {fruit=.5, coffeebean=1}, true)
local coffeeRecipe = {
		test = function(cooker, names, tags) return tags.coffeebean and (tags.coffeebean >= 4 or (tags.coffeebean>=3 and tags.dairy)) end,
		priority = 30,
		foodtype = FOODTYPE.GOODIES,
		cooktime = 1,
        --potlevel = "high",
        --floater = {"med", nil, 0.65},
        name = "coffee",
        weight = 1,
        overridebuild = "coffee"
	}
AddCookerRecipe("cookpot", coffeeRecipe)
AddCookerRecipe("portablecookpot", coffeeRecipe)


--添加制作配方
--wickerbottom
AddRecipe("book_treat", 
    {Ingredient("papyrus", 2), Ingredient("spidergland", 5), Ingredient("charcoal", 2)}, 
    _G.CUSTOM_RECIPETABS.BOOKS, 
    TECH.NONE, 
    nil, 
    nil, 
    nil, 
    nil, 
    "newbookbuilder", 
    "images/book_treat.xml"
)

AddRecipe("book_kill", 
    {Ingredient("papyrus", 5), Ingredient("livinglog", 2), Ingredient("purplegem", 4)}, 
    _G.CUSTOM_RECIPETABS.BOOKS, 
    TECH.NONE, 
    nil, 
    nil, 
    nil, 
    nil, 
    "newbookbuilder", 
    "images/book_kill.xml"
)

AddRecipe("book_season", 
    {Ingredient("papyrus", 8), Ingredient("opalpreciousgem", 1), Ingredient("greengem", 4)}, 
    _G.CUSTOM_RECIPETABS.BOOKS, 
    TECH.NONE, 
    nil, 
    nil, 
    nil, 
    nil, 
    "newbookbuilder", 
    "images/book_season.xml"
)

--willson
AddRecipe("potion_luck", {Ingredient("wormlight",2),Ingredient("butter",1),Ingredient("cave_banana",3)},
	RECIPETABS.MAGIC, 
	TECH.NONE, 
	nil, 
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	"potionbuilder", -- builder_tag
	"images/inventoryimages/potion_luck.xml"
)

AddRecipe("potion_blue", {Ingredient("bluegem",2),Ingredient("stinger",8),Ingredient("petals",3)}, 
	RECIPETABS.MAGIC, 
	TECH.NONE, 
	nil, 
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	"potionbuilder", -- builder_tag
	"images/inventoryimages/potion_blue.xml"
)

AddRecipe("potion_green", {Ingredient("green_cap",5),Ingredient("nightmarefuel",5),Ingredient("rottenegg",4)},
	RECIPETABS.MAGIC, 
	TECH.NONE, 
	nil, 
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	"potionbuilder", -- builder_tag
	"images/inventoryimages/potion_green.xml"
)

AddRecipe("potion_red", {Ingredient("glommerfuel",1),Ingredient("petals_evil",5),Ingredient("mosquitosack",3)},
	RECIPETABS.MAGIC, 
	TECH.NONE, 
	nil, 
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	"potionbuilder", -- builder_tag
	"images/inventoryimages/potion_red.xml"
)

--号角
AddRecipe("callerhorn", {Ingredient("horn",2),Ingredient("minotaurhorn",1)},
    RECIPETABS.MAGIC, 
    TECH.NONE, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    "vip", -- builder_tag
    "images/inventoryimages/callerhorn.xml"
)

AddRecipe("linghter_sword", {Ingredient("yellowgem", 20), Ingredient("nightstick",1), Ingredient("moonglass", 10)},
    RECIPETABS.WAR, 
    TECH.SCIENCE_TWO, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/linghter_sword.xml"
)

AddRecipe("linghterhat", {Ingredient("yellowgem", 20), Ingredient("moonrocknugget",10), Ingredient("moonglass", 10)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/linghterhat.xml"
)

AddRecipe("armorlinghter", {Ingredient("yellowgem", 20), Ingredient("moonrocknugget",10), Ingredient("moonglass", 10)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/armorlinghter.xml"
)

AddRecipe("space_sword", {Ingredient("orangegem", 20), Ingredient("orangestaff",1)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/space_sword.xml"
)

AddRecipe("timerhat", {Ingredient("orangegem", 20), Ingredient("ash",30), Ingredient("moonglass", 10)},
    RECIPETABS.WAR, 
    TECH.SCIENCE_TWO, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/timerhat.xml"
)

AddRecipe("armorforget", {Ingredient("orangegem", 20), Ingredient("ash",30), Ingredient("moonglass", 10)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/armorforget.xml"
)

AddRecipe("schrodingersword", {Ingredient("opalpreciousgem", 5), Ingredient("thulecite",20)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/schrodingersword.xml"
)

AddRecipe("heisenberghat", {Ingredient("opalpreciousgem", 3), Ingredient("nightmarefuel", 40)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/heisenberghat.xml"
)

AddRecipe("armordebroglie", {Ingredient("opalpreciousgem", 1), Ingredient("nightmarefuel", 25)},
    RECIPETABS.WAR, 
    TECH.SCIENCE_TWO, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/armordebroglie.xml"
)

--解构可用
AddRecipe("skillbook_1", 
    {Ingredient("skillbookpage", 3, 'images/inventoryimages/skillbookpage.xml')}, 
    _G.CUSTOM_RECIPETABS.BOOKS, 
    TECH.LOST
)

AddRecipe("skillbook_2", 
    {Ingredient("skillbookpage", 8, 'images/inventoryimages/skillbookpage.xml')}, 
    _G.CUSTOM_RECIPETABS.BOOKS, 
    TECH.LOST
)

AddRecipe("skillbook_3", 
    {Ingredient("skillbookpage", 12, 'images/inventoryimages/skillbookpage.xml')}, 
    nil, 
    TECH.LOST
)
AddRecipe("skillbook_4", 
    {Ingredient("skillbookpage", 16, 'images/inventoryimages/skillbookpage.xml')}, 
    nil, 
    TECH.LOST
)
AddRecipe("skillbook", 
    {Ingredient("skillbookpage", 9, 'images/inventoryimages/skillbookpage.xml')}, 
    nil, 
    TECH.LOST
)

AddRecipe("package_staff", 
    {Ingredient("opalpreciousgem", 3), Ingredient("greengem", 9), Ingredient("thulecite",5)}, 
    nil, 
    TECH.LOST
)
