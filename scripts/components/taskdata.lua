local onchangefn = {}
if task_data then
	for k, v in pairs(task_data) do
		onchangefn[k] = function(self, val)
			self.net_data[k]:set(val)
		end
	end
end

local TaskData = Class(function(self, inst) 
    self.inst = inst
    self.tumbleweednum = 0

    self.net_data = {}
    self:Init()
end,
nil,
onchangefn)

function TaskData:Init()
	if task_data then
		local inst = self.inst
		for k, v in pairs(task_data) do
			local need = v.need
			if need < 255 then 
				self.net_data[k] = net_byte(inst.GUID, k)
			elseif need < 32767 then
				self.net_data[k] = net_shortint(inst.GUID, k)
			else
				self.net_data[k] = net_int(inst.GUID, k)
			end
			
		end
	end
end

function TaskData:OnSave()
	local data = {}
	if task_data then
		for k, v in pairs(task_data) do
			data[k] = self[k] or 0
		end
	end
	return data
end

function TaskData:OnLoad(data)
	for k, v in pairs(data) do
		self[k] = v or 0
	end	
end

function TaskData:AddOne(taskname)
	if self[taskname] ~= nil and task_data[taskname] ~= nil then
		local task_info = task_data[taskname]
		local task_text = task_info.name
		local reward = task_info.reward or 1
		local need = task_info.need or 1
		local hide = task_info.hide or false
        if self[taskname] >= need then 
            self[taskname] = need
            return
        end
        self[taskname] = self[taskname] + 1
        if self[taskname] >= need then
            self[taskname] = need
            self:Completed(taskname)
        end
    end
end

function TaskData:Completed(taskname)
	local inst = self.inst
	local task_info = task_data[taskname]
	if task_info == nil then return end --防止代码崩档 

	local task_text = task_info.name
	local reward = task_info.reward
	local desc = task_info.desc
	SpawnPrefab("seffc").entity:SetParent(inst.entity)

	local annouce_str = string.format("%s  完成任务【%s】 奖励%d", inst:GetDisplayName(), task_text, reward) 
	TheNet:Announce(annouce_str, inst.entity)

	inst:DoTaskInTime(.3,function() 
		self:AllCompletedCheck()
        inst:PushEvent("taskcompleted", {taskname=taskname})
    end) 
end

function TaskData:AllCompletedCheck()
	if self.all ~= 1 then
		for k,v in pairs(task_data) do
			if k ~= "all" and not v.hide then
				if self[k] < v.need then
					return false
				end
			end
		end
		self:AddOne('all')
		return true
	else
		return true
	end
end

--测试专用
function TaskData:GrantAll(pwd)
	--添加简单的参数防止误用
    if pwd==nil or pwd ~= "123456" then return end
	for k,v in pairs(task_data) do
        if k ~= "all" and not v.hide then
            if self[k] < v then
                self[k] = v
            end
        end
    end
	--...
end

return TaskData