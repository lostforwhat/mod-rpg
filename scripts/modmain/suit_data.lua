local function WatchNight(inst)
	if TheWorld.state.isnight then
        inst.components.combat.externaldamagemultipliers:SetModifier("suit", 1.3)
    else
        inst.components.combat.externaldamagemultipliers:RemoveModifier("suit")
    end
end

local function OnKilled(inst, data)
	local victim = data.victim
	if victim ~= nil and inst.components.health ~= nil and not inst:HasTag("playerghost")
        and not (victim:HasTag("wall") or victim:HasTag("balloon"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil then
        inst.components.health:DoDelta(10)
    end
end

--预计装备列表
--[[
	功能型武器：
	凝光剑，霜寒之矛，庖丁菜刀，
]]
suit_data = {
	{
		prefabs = {"armorgrass", "spear"},
		num = 2,
		required_prefabs = {"armorgrass", "spear"},
		onmatch = function(owner) 
			owner.components.extrameta.extra_health:SetModifier("suit", 40)
		end,
		onmismatch = function(owner) 
			owner.components.extrameta.extra_health:RemoveModifier("suit")
		end,
		name = "萌新的祝福",
		desc = "增加40生命值",
	},
	{
		prefabs = {"footballhat", "armorwood", "hambat"},
		num = 3,
		required_prefabs = {"footballhat", "armorwood", "hambat"},
		onmatch = function(owner) 
			owner.components.crit:AddExtraChance("suit", 0.1)
		end,
		onmismatch = function(owner) 
			owner.components.crit:RemoveExtraChance("suit")
		end,
		name = "格斗家",
		desc = "额外增加10%暴击几率",
	},
	{
		prefabs = {"wathgrithrhat", "spear_wathgrithr"},
		num = 2,
		onmatch = function(owner) 
			owner.components.crit:AddExtraChance("suit", 0.12)
		end,
		onmismatch = function(owner) 
			owner.components.crit:RemoveExtraChance("suit")
		end,
		name = "格斗专家",
		desc = "额外增加12%暴击几率",
	},
	{
		prefabs = {"nightsword", "armor_sanity"},
		num = 2,
		onmatch = function(owner) 
			owner:WatchWorldState("isnight", WatchNight)
			WatchNight(owner)
		end,
		onmismatch = function(owner) 
			owner:StopWatchingWorldState("isnight", WatchNight)
			owner.components.combat.externaldamagemultipliers:RemoveModifier("suit")
		end,
		name = "暗夜掌控者",
		desc = "增加夜晚伤害30%",
	},
	{
		prefabs = {"slurtlehat", "armorsnurtleshell", "tentaclespike"},
		num = 2,
		required_prefabs = {"tentaclespike"},
		onmatch = function(owner) 
			owner.components.locomotor:SetExternalSpeedMultiplier(owner, "suit", 1.1)
			owner:ListenForEvent("killed", OnKilled)
		end,
		onmismatch = function(owner) 
			owner.components.locomotor:RemoveExternalSpeedMultiplier(owner, "suit")
			owner:RemoveEventCallback("killed", OnKilled)
		end,
		name = "野人必备",
		desc = "增加10%速度，击杀回血+10",
	},
	{
		prefabs = {"ruinshat", "armorruins", "ruins_bat"},
		num = 3,
		onmatch = function(owner)
			owner.components.extrameta.extra_health:SetModifier("suit", 200)
			owner.components.combat.externaldamagemultipliers:SetModifier("suit", 1.3)
		end,
		onmismatch = function(owner)
			owner.components.extrameta.extra_health:RemoveModifier("suit")
			owner.components.combat.externaldamagemultipliers:RemoveModifier("suit")
		end,
		name = "远古的传说",
		desc = "增加200生命值，增加10%力量",
	},
	{
		prefabs = {"linghter_sword", "yellowamulet", "linghterhat", "armorlinghter"},
		num = 3,
		required_prefabs = {"linghter_sword"},
		onmatch = function(owner)
			owner.components.dodge:AddExtraChance("suit", 0.1)
		end,
		onmismatch = function(owner)
			owner.components.dodge:RemoveExtraChance("suit")
		end,
		name = "神圣之光",
		desc = "增加10%闪避",
	},
	{
		prefabs = {"space_sword", "timerhat", "armorlinghter"},
		num = 3,
		onmatch = function(owner)

		end,
		onmismatch = function(owner)

		end,
		name = "时空奥秘",
		desc = "",
	},
	{
		prefabs = {"schrodingersword", "heisenberghat", "armordebroglie"},
		num = 3,
		onmatch = function(owner)
			
		end,
		onmismatch = function(owner)

		end,
		name = "量子理论",
		desc = "",
	},
}