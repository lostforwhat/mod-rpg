--预计装备列表
--[[
	功能型武器：
	凝光剑，霜寒之矛，庖丁菜刀，
]]
suit_data = {
	{
		prefabs = {"footballhat", "armorwood", "hambat"},
		num = 3,
		required_prefabs = {"footballhat", "armorwood", "hambat"},
		onmatch = function(owner) end,
		onmismatch = function(owner) end
	},
	{
		prefabs = {"nightsword", "armor_sanity"},
		num = 2,

	}
}