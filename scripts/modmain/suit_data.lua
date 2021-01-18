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

local function OnRegenSan(inst, data)
	local victim = data.victim
	if victim ~= nil and inst.components.sanity ~= nil and not inst:HasTag("playerghost")
        and not (victim:HasTag("wall") or victim:HasTag("balloon"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil then
        inst.components.sanity:DoDelta(10)
    end
end

local function FindEnts(prefab)
	local ents = {}
	for k,v in pairs(Ents) do
        if v.prefab == prefab and v:IsValid() 
        	and v.components.combat ~= nil 
        	and v.components.health ~= nil 
        	and not v.components.health:IsInvincible()
        	and not v.components.health:IsDead() then
            table.insert(ents, v)
        end
    end
    return ents
end

local function ApplyDisplay(inst)
	local dis = SpawnPrefab("display_effect")
	local rad = inst:GetPhysicsRadius(0)
	local x, y, z = inst.Transform:GetWorldPosition()
	dis.Transform:SetPosition(x, y + .5 * rad , z)
	dis:Display("量子纠缠", 30, {.8, .8, .1})
end

--量子套特效
local function OnKilledPrefab(inst, data)
	local victim = data.victim
	if victim ~= nil and inst.components.health ~= nil and not inst:HasTag("playerghost")
        and not (victim:HasTag("wall") or victim:HasTag("balloon")) 
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
        and math.random() < 0.1 then
        local ents = FindEnts(victim.prefab)
        if #ents > 0 then
        	local target = ents[math.random(#ents)]
        	target.components.health.currenthealth = 0.01
        	target.components.combat:GetAttacked(inst, 1)
        	ApplyDisplay(inst)
        end
    end
end

local function OnSchrodingerswordowner(inst, data)
	local target = data.target
	if target ~= nil then
		local percent = target.components.health ~= nil and target.components.health:GetPercent() or 0
	    if percent > 0 then
	        target.components.health:SetPercent(percent * .5)
	    end
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
			owner.components.health:ResetMax()
		end,
		onmismatch = function(owner) 
			owner.components.extrameta.extra_health:RemoveModifier("suit")
			owner.components.health:ResetMax()
		end,
		name = "萌新的祝福",
		desc = "【勇气】增加40生命值",
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
		desc = "【斗志】额外增加10%暴击几率",
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
		desc = "【斗志】额外增加12%暴击几率",
	},
	{
		prefabs = {"nightsword", "armor_sanity", "armorskeleton"},
		num = 2,
		onmatch = function(owner) 
			owner:WatchWorldState("isnight", WatchNight)
			WatchNight(owner)
			owner:ListenForEvent("killed", OnRegenSan)
		end,
		onmismatch = function(owner) 
			owner:StopWatchingWorldState("isnight", WatchNight)
			owner.components.combat.externaldamagemultipliers:RemoveModifier("suit")
			owner:RemoveEventCallback("killed", OnRegenSan)
		end,
		name = "暗夜掌控者",
		desc = "【黑暗】增加夜晚伤害30%,【摄魂】击杀恢复精神+10",
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
		desc = "【灵动】增加10%速度\n【野性】击杀回血+10",
	},
	{
		prefabs = {"ruinshat", "armorruins", "ruins_bat"},
		num = 3,
		onmatch = function(owner)
			owner.components.extrameta.extra_health:SetModifier("suit", 200)
			owner.components.health:ResetMax()
			owner.components.combat.externaldamagemultipliers:SetModifier("suit", 1.25)
		end,
		onmismatch = function(owner)
			owner.components.extrameta.extra_health:RemoveModifier("suit")
			owner.components.health:ResetMax()
			owner.components.combat.externaldamagemultipliers:RemoveModifier("suit")
		end,
		name = "远古的传说",
		desc = "【庇佑】增加200生命值\n【祝福】增加25%力量",
	},
	{
		prefabs = {"linghter_sword", "yellowamulet", "linghterhat", "armorlinghter"},
		num = 3,
		required_prefabs = {"linghter_sword"},
		onmatch = function(owner)
			owner.components.dodge:AddExtraChance("suit", 0.15)
		end,
		onmismatch = function(owner)
			owner.components.dodge:RemoveExtraChance("suit")
		end,
		name = "神圣之光",
		desc = "【光耀】增加15%闪避\n【圣光】提升装备激光束的效果",
	},
	{
		prefabs = {"space_sword", "timerhat", "armorforget"},
		num = 3,
		onmatch = function(owner)
			owner.components.locomotor:SetExternalSpeedMultiplier(owner, "suit", 1.25)
			owner:AddTag("suit_space")
		end,
		onmismatch = function(owner)
			owner.components.locomotor:RemoveExternalSpeedMultiplier(owner, "suit")
			owner:RemoveTag("suit_space")
		end,
		name = "时空奥秘",
		desc = "【洞悉万物】增加速度25%\n【穿透时空】可随意穿梭空间",
	},
	{
		prefabs = {"schrodingersword", "heisenberghat", "armordebroglie"},
		num = 3,
		onmatch = function(owner)
			owner:AddTag("suit_quantum")
			owner:ListenForEvent("killed", OnKilledPrefab)
			owner:ListenForEvent("schrodingerswordowner", OnSchrodingerswordowner)
		end,
		onmismatch = function(owner)
			owner:RemoveTag("suit_quantum")
			owner:RemoveEventCallback("killed", OnKilledPrefab)
			owner:RemoveEventCallback("schrodingerswordowner", OnSchrodingerswordowner)
		end,
		name = "量子理论",
		desc = "【坍塌】叠加态伤害自己时强制消减目标生命值\n【不确定性】每次攻击伤害波动±50%\n【量子纠缠】每次击杀目标都有10%概率使其同类直接死亡",
	},
}