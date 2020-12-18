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

AddRecipe("skillbook_1", 
    {Ingredient("skillbookpage", 5, 'images/inventoryimages/skillbookpage.xml'), Ingredient("greengem", 1)}, 
    _G.CUSTOM_RECIPETABS.BOOKS, 
    TECH.NONE, 
    nil, 
    nil, 
    nil, 
    nil, 
    "newbookbuilder", 
    "images/inventoryimages/skillbook_1.xml"
)

AddRecipe("skillbook_2", 
    {Ingredient("skillbookpage", 20, 'images/inventoryimages/skillbookpage.xml'), Ingredient("greengem", 2)}, 
    _G.CUSTOM_RECIPETABS.BOOKS, 
    TECH.NONE, 
    nil, 
    nil, 
    nil, 
    nil, 
    "newbookbuilder", 
    "images/inventoryimages/skillbook_2.xml"
)

--解构可用
AddRecipe("skillbook_3", 
    {Ingredient("skillbookpage", 30, 'images/inventoryimages/skillbookpage.xml'), Ingredient("greengem", 3)}, 
    nil, 
    TECH.LOST
)
AddRecipe("skillbook_4", 
    {Ingredient("skillbookpage", 40, 'images/inventoryimages/skillbookpage.xml'), Ingredient("greengem", 4)}, 
    nil, 
    TECH.LOST
)
AddRecipe("skillbook", 
    {Ingredient("skillbookpage", 20, 'images/inventoryimages/skillbookpage.xml'), Ingredient("greengem", 2)}, 
    nil, 
    TECH.LOST
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

AddRecipe("linghter_sword", {Ingredient("yellowgem", 20),Ingredient("nightstick",1)},
    RECIPETABS.WAR, 
    TECH.SCIENCE_TWO, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    nil, -- builder_tag
    "images/inventoryimages/linghter_sword.xml"
)

AddRecipe("space_sword", {Ingredient("orangegem", 20), Ingredient("orangestaff",1)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    "noopen", -- builder_tag
    "images/inventoryimages/space_sword.xml"
)

AddRecipe("schrodingersword", {Ingredient("opalpreciousgem", 5), Ingredient("thulecite",20)},
    RECIPETABS.WAR, 
    TECH.LOST, 
    nil, 
    nil, -- min_spacing
    nil, -- nounlock
    nil, -- numtogive
    "noopen", -- builder_tag
    "images/inventoryimages/schrodingersword.xml"
)