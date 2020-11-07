local onchangefn = {}
if task_data then
	for k, v in pairs(task_data) do
		onchangefn[k] = function(self, val)
			self.net_data[k]:set(val)
		end
	end
end

onchangefn.coin = function(self, val)
	self.net_data.coin:set(val)
end

local TaskData = Class(function(self, inst) 
    self.inst = inst
    --网络数据，客主机需要并保存
    self.net_data = {
    	coin = net_shortint(inst.GUID, "coin", "coindirty")
    }
    self:Init()
    self.coin = 0

    --主机数据，需保存
    self.tumbleweednum = 0
    self.eat_types = {}
    self.shadowboss_killed = {}

    --主机临时数据，无需保存
    self.killed_temp = {} --临时存储击杀数据，防止重复击杀判定

end,
nil,
onchangefn)

function TaskData:Init()
	if task_data then
		local inst = self.inst
		for k, v in pairs(task_data) do
			local need = v.need or 1
			if need < 255 then 
				self.net_data[k] = net_byte(inst.GUID, k)
			elseif need < 32767 then
				self.net_data[k] = net_shortint(inst.GUID, k)
			else
				self.net_data[k] = net_int(inst.GUID, k)
			end
			self[k] = 0
		end
	end
	self:AllCompletedCheck()
end

function TaskData:OnSave()
	local data = {}
	if task_data then
		for k, v in pairs(task_data) do
			data[k] = self[k] or 0
		end
	end
	data.coin = self.coin or 0
	data.tumbleweednum = self.tumbleweednum or 0
	data.eat_types = self.eat_types or {}
	data.shadowboss_killed = self.shadowboss_killed or {}
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

function TaskData:AddMulti(taskname, num)
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
        self[taskname] = self[taskname] + num
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
	local reward = task_info.reward or 1
	local desc = task_info.desc
	local need = task_info.need or 1
	SpawnPrefab("seffc").entity:SetParent(inst.entity)

	local desc_str = string.format(desc, " "..need.." ")
	local annouce_str = string.format("%s %s 完成任务【%s】 奖励 %d", inst:GetDisplayName(), desc_str, task_text, reward) 
	TheNet:Announce(annouce_str, inst.entity)

	self:CoinDoDelta(task_info.reward or 1)
	inst:DoTaskInTime(.3,function() 
		self:AllCompletedCheck()
        inst:PushEvent("taskcompleted", {taskname=taskname})
    end) 
end

function TaskData:AllCompletedCheck()
	if self.all ~= 1 then
		for k,v in pairs(task_data) do
			if k ~= "all" and not v.hide then
				local need = v.need or 1
				if self[k] < need then
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
        	local need = v.need or 1
            if self[k] < need then
                self[k] = need
            end
        end
    end
	--...
	self:AllCompletedCheck()
end

function TaskData:CoinDoDelta(value)
	self.coin = self.coin + value
	if self.coin < 0 then self.coin = 0 end --防止数据异常
end

return TaskData