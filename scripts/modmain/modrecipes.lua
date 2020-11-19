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
	"images/potions/potion_luck.xml"
)

AddRecipe("potion_blue", {Ingredient("bluegem",2),Ingredient("stinger",8),Ingredient("petals",3)}, 
	RECIPETABS.MAGIC, 
	TECH.NONE, 
	nil, 
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	"potionbuilder", -- builder_tag
	"images/potions/potion_blue.xml"
)

AddRecipe("potion_green", {Ingredient("green_cap",5),Ingredient("nightmarefuel",5),Ingredient("rottenegg",4)},
	RECIPETABS.MAGIC, 
	TECH.NONE, 
	nil, 
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	"potionbuilder", -- builder_tag
	"images/potions/potion_green.xml"
)

AddRecipe("potion_red", {Ingredient("glommerfuel",1),Ingredient("petals_evil",5),Ingredient("mosquitosack",3)},
	RECIPETABS.MAGIC, 
	TECH.NONE, 
	nil, 
	nil, -- min_spacing
	nil, -- nounlock
	nil, -- numtogive
	"potionbuilder", -- builder_tag
	"images/potions/potion_red.xml"
)
