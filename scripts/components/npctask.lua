local pool = require('modmain/npc_task_pool')

local tasks = pool.tasks
local reward = pool.reward

local function RandomVaribleNum(num)
	if num <= 1 then
		return num
	end
	local offset = math.floor(num * .5)
	num = math.random(num-offset, num+offset)
end

--npc任务组件
local NpcTask = Class(function(self, inst) 
    self.inst = inst

    self.current_task = nil
end,
nil,
{
    
})

function NpcTask:PushTask()
	local inst = self.inst
	if self.current_task == nil then
		self.current_task = self:GetRandomTask()
		
		if inst.components.talker ~= nil then
			inst.components.talker:Say()
		end
	end
end

function NpcTask:GetRandomTask()
	local task = tasks[math.random(#tasks)]
	if task ~= nil then
		--task = deepcopy(task)
		local num = task.num or 1
		local level = task.level or 1
		if num > 1 then
			task.num = RandomVaribleNum(num)
		end
	end
	return task
end

return NpcTask