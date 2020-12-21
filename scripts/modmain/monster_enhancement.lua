local _G = GLOBAL
local assert = assert or _G.assert
local IsServer = _G.TheNet:GetIsServer()
local difficulty_level = TUNING.level

--强度，0-4 超过范围报错
local DEGREE = difficulty_level
assert(DEGREE >= 0 and DEGREE <= 4, "MOD DEGREE out of range: "..tostring(DEGREE))

--怪物强化都写这里
local health_degree = DEGREE * 0.5 + 1
local damage_degree = DEGREE * 0.4 + 1
local period_degree = 1 - DEGREE * 0.2
local range_degree = 1 + DEGREE * 0.2
local speed_degree = 1 + DEGREE * 0.2

--春鸭
TUNING.MOOSE_HEALTH = TUNING.MOOSE_HEALTH * health_degree
TUNING.MOOSE_DAMAGE = TUNING.MOOSE_DAMAGE * damage_degree
TUNING.MOOSE_ATTACK_PERIOD = TUNING.MOOSE_ATTACK_PERIOD * period_degree
TUNING.MOOSE_ATTACK_RANGE = TUNING.MOOSE_ATTACK_RANGE * range_degree
TUNING.MOOSE_WALK_SPEED = TUNING.MOOSE_WALK_SPEED * speed_degree
TUNING.MOOSE_RUN_SPEED = TUNING.MOOSE_RUN_SPEED * speed_degree
--冬鹿
TUNING.DEERCLOPS_HEALTH = TUNING.DEERCLOPS_HEALTH * health_degree
TUNING.DEERCLOPS_DAMAGE = TUNING.DEERCLOPS_DAMAGE * damage_degree
TUNING.DEERCLOPS_DAMAGE_PLAYER_PERCENT = TUNING.DEERCLOPS_DAMAGE_PLAYER_PERCENT
TUNING.DEERCLOPS_ATTACK_PERIOD = TUNING.DEERCLOPS_ATTACK_PERIOD * period_degree
TUNING.DEERCLOPS_ATTACK_RANGE = TUNING.DEERCLOPS_ATTACK_RANGE * range_degree
TUNING.DEERCLOPS_AOE_RANGE = TUNING.DEERCLOPS_AOE_RANGE * range_degree
TUNING.DEERCLOPS_AOE_SCALE = TUNING.DEERCLOPS_AOE_SCALE * range_degree
--秋熊
TUNING.BEARGER_HEALTH = TUNING.BEARGER_HEALTH * health_degree
TUNING.BEARGER_DAMAGE = TUNING.BEARGER_DAMAGE * damage_degree
TUNING.BEARGER_ATTACK_PERIOD = TUNING.BEARGER_ATTACK_PERIOD * period_degree
TUNING.BEARGER_MELEE_RANGE = TUNING.BEARGER_MELEE_RANGE * range_degree
TUNING.BEARGER_ATTACK_RANGE = TUNING.BEARGER_ATTACK_RANGE * range_degree
TUNING.BEARGER_CALM_WALK_SPEED = TUNING.BEARGER_CALM_WALK_SPEED * speed_degree
TUNING.BEARGER_ANGRY_WALK_SPEED = TUNING.BEARGER_ANGRY_WALK_SPEED * speed_degree
TUNING.BEARGER_RUN_SPEED = TUNING.BEARGER_RUN_SPEED * speed_degree
--夏蝇
TUNING.DRAGONFLY_HEALTH = TUNING.DRAGONFLY_HEALTH * health_degree
TUNING.DRAGONFLY_DAMAGE = TUNING.DRAGONFLY_DAMAGE * damage_degree
TUNING.DRAGONFLY_ATTACK_PERIOD = TUNING.DRAGONFLY_ATTACK_PERIOD * period_degree
TUNING.DRAGONFLY_ATTACK_RANGE = TUNING.DRAGONFLY_ATTACK_RANGE * range_degree
TUNING.DRAGONFLY_HIT_RANGE = TUNING.DRAGONFLY_HIT_RANGE * range_degree
TUNING.DRAGONFLY_SPEED = TUNING.DRAGONFLY_SPEED * speed_degree

TUNING.DRAGONFLY_FIRE_ATTACK_PERIOD = TUNING.DRAGONFLY_FIRE_ATTACK_PERIOD * period_degree
TUNING.DRAGONFLY_FIRE_DAMAGE = TUNING.DRAGONFLY_FIRE_DAMAGE * damage_degree
TUNING.DRAGONFLY_FIRE_HIT_RANGE = TUNING.DRAGONFLY_FIRE_HIT_RANGE * range_degree
TUNING.DRAGONFLY_FIRE_SPEED = TUNING.DRAGONFLY_FIRE_SPEED * speed_degree
--犀牛
TUNING.MINOTAUR_DAMAGE = TUNING.MINOTAUR_DAMAGE * damage_degree
TUNING.MINOTAUR_HEALTH = TUNING.MINOTAUR_HEALTH * health_degree
TUNING.MINOTAUR_ATTACK_PERIOD = TUNING.MINOTAUR_ATTACK_PERIOD * period_degree
TUNING.MINOTAUR_WALK_SPEED = TUNING.MINOTAUR_WALK_SPEED * speed_degree
TUNING.MINOTAUR_RUN_SPEED = TUNING.MINOTAUR_RUN_SPEED * speed_degree
TUNING.MINOTAUR_TARGET_DIST = TUNING.MINOTAUR_TARGET_DIST * range_degree
--蜂王
TUNING.BEEQUEEN_HEALTH = TUNING.BEEQUEEN_HEALTH * health_degree
TUNING.BEEQUEEN_DAMAGE = TUNING.BEEQUEEN_DAMAGE * damage_degree
TUNING.BEEQUEEN_ATTACK_PERIOD = TUNING.BEEQUEEN_ATTACK_PERIOD * period_degree
TUNING.BEEQUEEN_ATTACK_RANGE = TUNING.BEEQUEEN_ATTACK_RANGE * range_degree
TUNING.BEEQUEEN_HIT_RANGE = TUNING.BEEQUEEN_HIT_RANGE * range_degree
TUNING.BEEQUEEN_SPEED = TUNING.BEEQUEEN_SPEED * speed_degree
--klaus
TUNING.KLAUS_HEALTH = TUNING.KLAUS_HEALTH * health_degree
TUNING.KLAUS_HEALTH_REGEN = TUNING.KLAUS_HEALTH_REGEN * 2 --per second (only when not in combat)
--TUNING.KLAUS_HEALTH_REZ = .5
TUNING.KLAUS_DAMAGE = TUNING.KLAUS_DAMAGE * damage_degree
TUNING.KLAUS_ATTACK_PERIOD = TUNING.KLAUS_ATTACK_PERIOD * period_degree
TUNING.KLAUS_ATTACK_RANGE = TUNING.KLAUS_ATTACK_RANGE * range_degree
TUNING.KLAUS_HIT_RANGE = TUNING.KLAUS_HIT_RANGE * range_degree
TUNING.KLAUS_SPEED = TUNING.KLAUS_SPEED * speed_degree
--骨架
TUNING.STALKER_HEALTH = TUNING.STALKER_HEALTH * health_degree
TUNING.STALKER_DAMAGE = TUNING.STALKER_DAMAGE * damage_degree
TUNING.STALKER_ATTACK_PERIOD = TUNING.STALKER_ATTACK_PERIOD * period_degree
TUNING.STALKER_ATTACK_RANGE = TUNING.STALKER_ATTACK_RANGE * range_degree
TUNING.STALKER_HIT_RANGE = TUNING.STALKER_HIT_RANGE * range_degree
TUNING.STALKER_AOE_RANGE = TUNING.STALKER_AOE_RANGE * range_degree
TUNING.STALKER_AOE_SCALE = .8
TUNING.STALKER_SPEED = TUNING.STALKER_SPEED * speed_degree
--影织者
TUNING.STALKER_ATRIUM_HEALTH = TUNING.STALKER_ATRIUM_HEALTH * health_degree
TUNING.STALKER_ATRIUM_PHASE2_HEALTH = TUNING.STALKER_ATRIUM_PHASE2_HEALTH * health_degree
TUNING.STALKER_ATRIUM_ATTACK_PERIOD = TUNING.STALKER_ATRIUM_ATTACK_PERIOD * period_degree
--蘑菇蛤
TUNING.TOADSTOOL_HEALTH = TUNING.TOADSTOOL_HEALTH * health_degree
TUNING.TOADSTOOL_ATTACK_RANGE = TUNING.TOADSTOOL_ATTACK_RANGE * range_degree
TUNING.TOADSTOOL_EPICSCARE_RANGE = TUNING.TOADSTOOL_EPICSCARE_RANGE * range_degree
TUNING.TOADSTOOL_DAMAGE_LVL[0] = 100 * damage_degree
TUNING.TOADSTOOL_DAMAGE_LVL[1] = 120 * damage_degree
TUNING.TOADSTOOL_DAMAGE_LVL[2] = 150 * damage_degree
TUNING.TOADSTOOL_DAMAGE_LVL[3] = 250 * damage_degree
--[[TUNING.TOADSTOOL_SPEED_LVL =
{
    [0] = .6,
    [1] = .8,
    [2] = 1.2,
    [3] = 3.2,
}
TUNING.TOADSTOOL_DAMAGE_LVL =
{
    [0] = 100,
    [1] = 120,
    [2] = 150,
    [3] = 250,
}
TUNING.TOADSTOOL_ATTACK_PERIOD_LVL =
{
    [0] = 3.5,
    [1] = 3,
    [2] = 2.5,
    [3] = 2,
}
--]]

--蚁狮
TUNING.ANTLION_HEALTH = TUNING.ANTLION_HEALTH * health_degree
TUNING.ANTLION_MAX_ATTACK_PERIOD = 4 * period_degree
TUNING.ANTLION_MIN_ATTACK_PERIOD = 2 * period_degree
TUNING.ANTLION_SPEED_UP = -.2
TUNING.ANTLION_SLOW_DOWN = .4
TUNING.ANTLION_CAST_RANGE = 15
TUNING.ANTLION_CAST_MAX_RANGE = 20
TUNING.ANTLION_WALL_CD = 20
TUNING.ANTLION_HIT_RECOVERY = 1
TUNING.ANTLION_EAT_HEALING = 200

TUNING.SHADOW_ROOK.HEALTH = {1000 * health_degree, 4000 * health_degree, 10000 * health_degree}
TUNING.SHADOW_ROOK.DAMAGE = {45 * damage_degree, 100 * damage_degree, 165 * damage_degree}
TUNING.SHADOW_ROOK.ATTACK_PERIOD = {6 * period_degree, 5.5 * period_degree, 5 * period_degree}

TUNING.SHADOW_KNIGHT.SPEED = {7 * speed_degree, 9 * speed_degree, 12 * speed_degree}
TUNING.SHADOW_KNIGHT.HEALTH = {900 * health_degree, 2700 * health_degree, 8100 * health_degree}
TUNING.SHADOW_KNIGHT.DAMAGE = {40 * damage_degree, 90 * damage_degree, 150 * damage_degree}
TUNING.SHADOW_KNIGHT.ATTACK_PERIOD = {3 * period_degree, 2.5 * period_degree, 2 * period_degree}

TUNING.SHADOW_BISHOP.ATTACK_RANGE = {4 * range_degree, 6 * range_degree, 8 * range_degree}
TUNING.SHADOW_BISHOP.HEALTH = {800 * health_degree, 2500 * health_degree, 7500 * health_degree}
TUNING.SHADOW_BISHOP.DAMAGE = {20 * damage_degree, 35 * damage_degree, 60 * damage_degree}
TUNING.SHADOW_BISHOP.ATTACK_PERIOD = {15 * period_degree, 14 * period_degree, 12 * period_degree}
--[[TUNING.SHADOW_ROOK =
{
    LEVELUP_SCALE = {1, 1.2, 1.6},
    SPEED = 7,                          -- levels are procedural
    HEALTH = {1000, 4000, 10000},
    DAMAGE = {45, 100, 165},
    ATTACK_PERIOD = {6, 5.5, 5},
    ATTACK_RANGE = 8,                   -- levels are procedural
    HIT_RANGE = 3.35,
    RETARGET_DIST = 15,
}

TUNING.SHADOW_KNIGHT =
{
    LEVELUP_SCALE = {1, 1.7, 2.5},
    SPEED = {7, 9, 12},
    HEALTH = {900, 2700, 8100},
    DAMAGE = {40, 90, 150},
    ATTACK_PERIOD = {3, 2.5, 2},
    ATTACK_RANGE = 2.3,                 -- levels are procedural
    ATTACK_RANGE_LONG = 4.5,            -- levels are procedural
    RETARGET_DIST = 15,
}

TUNING.SHADOW_BISHOP =
{
    LEVELUP_SCALE = {1, 1.6, 2.2},
    SPEED = 3,                          -- levels are procedural
    HEALTH = {800, 2500, 7500},
    DAMAGE = {20, 35, 60},
    ATTACK_PERIOD = {15, 14, 12},
    ATTACK_RANGE = {4, 6, 8},           -- levels are procedural
    HIT_RANGE = 1.75,
    ATTACK_TICK = .5,
    ATTACK_START_TICK = .2,
    RETARGET_DIST = 15,
}]]

--邪天翁
TUNING.MALBATROSS_HEALTH = 2500 * 2  * health_degree
TUNING.MALBATROSS_DAMAGE = 150  * damage_degree
--帝王蟹
TUNING.CRABKING_HEALTH = 20000 * health_degree
TUNING.CRABKING_CLAW_WALK_SPEED = 1
TUNING.CRABKING_CLAW_RUN_SPEED = 4
TUNING.CRABKING_DAMAGE = 150 * damage_degree
TUNING.CRABKING_DAMAGE_PLAYER_PERCENT = .5
TUNING.CRABKING_ATTACK_RANGE = 5
TUNING.CRABKING_AOE_RANGE = 3
TUNING.CRABKING_AOE_SCALE = 0.8
TUNING.CRABKING_ATTACK_PERIOD = 4


--其他生物，仅调整hp和attack
TUNING.SPAT_HEALTH = 800 * health_degree
TUNING.SPAT_MELEE_DAMAGE = 60 * damage_degree
--树精
TUNING.LEIF_HEALTH = 2000 * 1.5 * health_degree
TUNING.LEIF_DAMAGE = 150  * damage_degree
--蜘蛛
TUNING.SPIDER_HEALTH = 100 * health_degree
TUNING.SPIDER_DAMAGE = 20 * damage_degree
TUNING.SPIDER_WARRIOR_HEALTH = 200 * health_degree
TUNING.SPIDER_WARRIOR_DAMAGE = 20  * damage_degree
TUNING.SPIDER_HIDER_HEALTH = 150 * 1.5  * health_degree
TUNING.SPIDER_HIDER_DAMAGE = 20  * damage_degree
TUNING.SPIDER_SPITTER_HEALTH = 175 * 2  * health_degree
TUNING.SPIDER_SPITTER_DAMAGE_MELEE = 20 
TUNING.SPIDER_MOON_HEALTH = 250  * health_degree
TUNING.SPIDER_MOON_DAMAGE = 25  * damage_degree
--猎犬
TUNING.HOUND_HEALTH = 150  * health_degree
TUNING.HOUND_DAMAGE = 20  * damage_degree
TUNING.FIREHOUND_HEALTH = 100  * health_degree
TUNING.FIREHOUND_DAMAGE = 30  * damage_degree
TUNING.ICEHOUND_HEALTH = 100  * health_degree
TUNING.ICEHOUND_DAMAGE = 30  * damage_degree
--蠕虫
TUNING.WORM_DAMAGE = 75  * damage_degree
TUNING.WORM_HEALTH = 900  * health_degree
--触手
TUNING.TENTACLE_DAMAGE = 34  * damage_degree
TUNING.TENTACLE_HEALTH = 500  * health_degree
--鱼人
TUNING.MERM_DAMAGE = 30  * damage_degree
TUNING.MERM_HEALTH = 250 * 2  * health_degree
--高鸟
TUNING.TALLBIRD_HEALTH = 400 * 2  * health_degree
TUNING.TALLBIRD_DAMAGE = 50  * damage_degree
--青蛙
TUNING.FROG_HEALTH = 100  * health_degree
TUNING.FROG_DAMAGE = 10  * damage_degree
--海象
TUNING.WALRUS_DAMAGE = 33  * damage_degree
TUNING.WALRUS_HEALTH = 150 * 2  * health_degree
--缀食者
TUNING.SLURPER_HEALTH = 200  * health_degree
TUNING.SLURPER_DAMAGE = 30  * damage_degree
--企鹅
TUNING.PENGUIN_DAMAGE = 33 * damage_degree
TUNING.PENGUIN_HEALTH = 150  * health_degree
--发条骑士
TUNING.KNIGHT_DAMAGE = 40  * damage_degree
TUNING.KNIGHT_HEALTH = 300 * 3  * health_degree
--发条战车
TUNING.ROOK_DAMAGE = 45  * damage_degree
TUNING.ROOK_HEALTH = 300 * 3  * health_degree
--发条主教
TUNING.BISHOP_DAMAGE = 40  * damage_degree
TUNING.BISHOP_HEALTH = 300 * 3  * health_degree

--防止小鸭子被批量秒杀
TUNING.MOSSLING_HEALTH = 5000

--TUNING.ANTLION_SINKHOLE.UNEVENGROUND_RADIUS = 3


AddPrefabPostInitAny(function(inst) 
    if not IsServer then return end
    if inst:HasTag("epic") then --boss
    	--生命回复
    	if inst.components.health and inst.components.health.regen == nil then
    		local max_health = inst.components.health.maxhealth
    		inst.components.health:StartRegen(max_health * 0.005, 10)
    	end
    end
end)

--尝试给怪物添加组件
AddPrefabPostInitAny(function(inst) 
    if inst.prefab == "bat" or inst.prefab == "mosquito" then
       inst:AddComponent("lifesteal") 
       if IsServer then
            inst.components.lifesteal:SetPercent(50)
       end
    end
    if inst.prefab == "krampus" then
        inst:AddComponent("stealer")
        if IsServer then
            inst.components.stealer.chance = 0.1
        end
    end
    if inst.prefab == "merm" then
        inst:AddComponent("dodge")
        if IsServer then
            inst.components.dodge:SetChance(0.2)
        end
    end
end)