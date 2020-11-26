require "modmain/task_constant"
local function GetTasksLike(...)
	local tasks = {}
	for k, v in pairs(task_list) do
		for _, like in pairs(...) do
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
		desc="",
		conditions={
			{
				condition="完成所有烹饪任务",
				fn=function(player)
					local tasks = {"cook_100", "cook_888"}
					return CheckTaskCompleted(player, tasks)
				end
			}
		},
		effect=function(player, equipped)

		end
	},
	{
		id="cleverhands",
		name="心灵手巧", 
		desc="",
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

		end
	},
	{
		id="killingheart",
		name="杀戮之心", 
		desc="暴击提升50%，暴击最大倍数+2",
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

		end
	},
	{
		id="lifeforever",
		name="生生不息",
		desc="",
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

		end
	},
	{
		id="leisurely",
		name="悠然自得", 
		desc="",
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
					return player.components.age.GetAgeInDays() >= 50
				end
			},
		},
		effect=function(player, equipped)

		end
	},
	{
		id="king",
		name="王者之巅", 
		desc="",
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
					return player.components.age.GetAgeInDays() >= 300
				end
			},
			{
				condition="人物等级大于80",
				fn=function(player)
					return player.components.level.level >= 80
				end
			},
		},
		effect=function(player, equipped)

		end
	},
	{
		id="vip",
		name="次元之客", 
		desc="",
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
	}
}