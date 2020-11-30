require "modmain/task_constant"
require "modmain/loot_table"

local function GetTasksLike(...)
	local tasks = {}
	for k, v in pairs(task_list) do
		for _, like in pairs({...}) do
			if string.find(v, like) ~= nil then
				table.insert(tasks, v)
				break
			end
		end
	end
	return tasks
end

local function CheckTaskCompleted(player, tasks)
	for k, v in pairs(tasks) do
		if player.components.taskdata[v] == 0 then
			return false
		end
	end
	return true
end

local function CheckTaskCompletedNum(player, tasks)
	local num = 0
	for k, v in pairs(tasks) do
		if player.components.taskdata[v] > 0 then
			num = num + 1
		end
	end
	return num
end

--称号数据

titles_data = {
	{
		id="foodexpert",
		name="美食专家", 
		desc="【盛宴】吃饱时获得20%力量\n",
		conditions={
			{
				condition="完成所有烹饪任务",
				fn=function(player)
					local tasks = {"cook_100", "cook_888"}
					return CheckTaskCompleted(player, tasks)
				end
			},
			{
				condition="完成5个吃东西任务",
				fn=function(player)
					local tasks = GetTasksLike("eat_")
					return CheckTaskCompletedNum(player, tasks) >= 5
				end
			}
		},
		effect=function(player, equipped, titles_fx)
			if equipped then
				titles_fx:ListenForEvent("hungerdelta", function(owner, data)
					local percent = data.newpercent or 0
					if percent >= 0.8 then
						player.components.combat.externaldamagemultipliers:SetModifier("foodexpert", 1.2)
					else
						player.components.combat.externaldamagemultipliers:RemoveModifier("foodexpert")
					end
				end, player)
			else
				player.components.combat.externaldamagemultipliers:RemoveModifier("foodexpert")
			end
			--[[if equipped then
				player.components.combat.externaldamagemultipliers:SetModifier("foodexpert", 1.2)
			else
				player.components.combat.externaldamagemultipliers:RemoveModifier("foodexpert")
			end]]
		end
	},
	{
		id="cleverhands",
		name="心灵手巧", 
		desc="【投机】采集风滚草10%多1份物品\n【洞悉】击杀有5%概率多倍掉落",
		conditions={
			{
				condition="完成所有建造任务",
				fn=function(player)
					local tasks = GetTasksLike("build_")
					return CheckTaskCompleted(player, tasks)
				end
			},
			{
				condition="完成全部伤害要求任务",
				fn=function(player)
					local tasks = GetTasksLike("damage_", "hurt_")
					return CheckTaskCompleted(player, tasks)
				end
			},
			{
				condition="完成全部交友任务",
				fn=function(player)
					local tasks = GetTasksLike("makefriend_")
					return CheckTaskCompleted(player, tasks)
				end
			},
		},
		effect=function(player, equipped)
			if equipped then
				player:AddTag("cleverhands")
			else
				player:RemoveTag("cleverhands")
			end
		end
	},
	{
		id="killingheart",
		name="杀戮之心", 
		desc="【杀戮】暴击提升50%，暴击最大倍数+2",
		conditions={
			{
				condition="完成20个击杀任务",
				fn=function(player)
					local tasks = GetTasksLike("kill_")
					return CheckTaskCompletedNum(player, tasks) >= 20
				end
			},
			{
				condition="完成隐藏任务【暴怒的克劳斯】",
				fn=function(player)
					return player.components.taskdata.kill_klaus_rage > 0
				end
			},
		},
		effect=function(player, equipped)
			if equipped then
				local max_hit = player.components.crit.max_hit
				player.components.crit:SetMaxHit(max_hit + 2)
				player.components.crit:AddMultipliers("killingheart", 1.5)
			else
				local max_hit = player.components.crit.max_hit
				player.components.crit:SetMaxHit(max_hit - 2)
				player.components.crit:RemoveMultipliers("killingheart")
			end
		end
	},
	{
		id="lifeforever",
		name="生生不息",
		desc="【生机】击杀怪物恢复自身2%目标最大值\n【神佑】受伤害时有15%几率转移到附近单位",
		conditions={
			{
				condition="完成全部种植任务",
				fn=function(player)
					local tasks = GetTasksLike("plant_")
					return CheckTaskCompleted(player, tasks)
				end
			},
			{
				condition="人物等级大于40",
				fn=function(player)
					return player.components.level.level >= 40
				end
			},
		},
		effect=function(player, equipped)
			if equipped then
				player:AddTag("lifeforever")
			else
				player:RemoveTag("lifeforever")
			end
		end
	},
	{
		id="leisurely",
		name="悠然自得", 
		desc="【悠然】经验值获取提升10%\n【随缘】每次攻击造成伤害在1~真实伤害*3之间波动",
		conditions={
			{
				condition="完成砍树、挖矿、采集任务20个",
				fn=function(player)
					local tasks = GetTasksLike("chop_", "mine_", "pick_")
					return CheckTaskCompleted(player, tasks)
				end
			},
			{
				condition="生存天数大于50",
				fn=function(player)
					return player.components.age:GetAgeInDays() >= 50
				end
			},
		},
		effect=function(player, equipped)
			if equipped then
				player:AddTag("leisurely")
			else
				player:RemoveTag("leisurely")
			end
		end
	},
	{
		id="king",
		name="王者之巅", 
		desc="【蔑视】秒杀血量低于自己的单位\n【王者】全属性提升,每天发放一次物资",
		conditions={
			{
				condition="完成所有成就任务",
				fn=function(player)
					return player.components.taskdata.all > 0
				end
			},
			{
				condition="生存天数大于300",
				fn=function(player)
					return player.components.age:GetAgeInDays() >= 300
				end
			},
			{
				condition="人物等级大于80",
				fn=function(player)
					return player.components.level.level >= 80
				end
			},
		},
		effect=function(player, equipped, titles_fx)
			if equipped then
				titles_fx:WatchWorldState("cycles", function() 
					local types = {"new_loot", "new_loot", "new_loot", "good_loot", "luck_loot"}
					local items = deepcopy(loot_table[types[math.random(#types)]])
					local prefab = items[math.random(#items)]
					if PrefabExists(item) then
						local item = SpawnPrefab(item)
						if item.components.inventory == nil then
							local pack_item = SpawnPrefab("package_ball")
							pack_item.components.packer:Pack(item)
							return pack_item
						end
						player.components.inventory:GiveItem(item)
					end
				end)
				player:AddTag("titles_king")
				player.components.extrameta.extra_health:SetModifier("king", 50)
				player.components.extrameta.extra_hunger:SetModifier("king", 50)
				player.components.extrameta.extra_sanity:SetModifier("king", 50)
			else
				player:RemoveTag("titles_king")
				player.components.extrameta.extra_health:RemoveModifier("king")
				player.components.extrameta.extra_hunger:RemoveModifier("king")
				player.components.extrameta.extra_sanity:RemoveModifier("king")
			end
		end
	},
	{
		id="vip",
		name="次元之客", 
		desc="【特权】即使不佩戴(*)也生效\n【精通】*经验获取提升40%\n【魔手】*采集风滚草多获得物品\n【附魔】*部分新物品提升使用范围\n【更多】...",
		conditions={
			{
				condition="获得尊贵的客人凭证",
				fn=function(player)
					return player.components.vip.level > 0
				end
			},
		},
		effect=function(player, equipped)

		end
	},
	{
		id="fly",
		name="天外飞仙",
		desc="**",
		hide=true,
		conditions={
			{
				condition="*获取来源不明*",
				fn=function(player)
					return player.components.titles.special
				end
			},
		},
		postinit=function(inst) end,
		effect=function(player, equipped)

		end
	}
}