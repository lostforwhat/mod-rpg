--npc任务组件
local NpcTask = Class(function(self, inst) 
    self.inst = inst

    self.current_task = nil
end,
nil,
{
    
})

function NpcTask:PushTask()
	if self.current_task == nil then
		
	end
end

return NpcTask