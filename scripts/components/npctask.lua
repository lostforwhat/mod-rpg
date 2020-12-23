local pool = require('modmain/npc_task_pool')

local tasks = pool.tasks
local rewards = pool.rewards

local default_msg = "我需要 %s %d 份，帮我找来";
local msg_data = {
	"我需要 %d 份 %s，帮我找来",
	"我正在寻找 %d 个 %s，能帮我找到吗?",
	"嘿，你身上有 %d 个 %s 吗， 我用好东西和你交换!",
	"请帮我找 %d 个 %s",
	"我急需 %d 个 %s，请帮我找到",
	"就差 %d 个 %s 了，我会给你丰富的回报",
	"我可以将 %d 张 %s 装订成一本，如果你现在有的话",
}

local function RandomVaribleNum(num)
	if num <= 1 then
		return num
	end
	local offset = math.floor(num * .25)
	num = math.random(num-offset, num+offset)
	return num
end

local function GetStackSize(item)
    return item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
end

local function SpawnItem(prefab, use_left)
	local item = SpawnPrefab(prefab)
	if item.components.inventoryitem == nil then --不能放物品栏
		local real_item = item
		item = SpawnPrefab("package_ball")
		item.components.packer:Pack(real_item)
	end
	if use_left ~= nil and use_left < 1 then
		if item.components.perishable ~= nil then
			item.components.perishable:SetPercent(use_left)
		end
		if item.components.finiteuses ~= nil then
			item.components.finiteuses:SetPercent(use_left)
		end
	end
	return item
end

local function GiveItem(inst, item)
	if inst.components.inventory ~= nil then
		inst.components.inventory:GiveItem(item)
	else
		item.Transform:SetPosition(inst:GetPosition():Get())
	end
end

local function CheckSpawnedLoot(loot)
    if loot.components.inventoryitem ~= nil then
        loot.components.inventoryitem:TryToSink()
    else
        local lootx, looty, lootz = loot.Transform:GetWorldPosition()
        if ShouldEntitySink(loot, true) or TheWorld.Map:IsPointNearHole(Vector3(lootx, 0, lootz)) then
            SinkEntity(loot)
        end
    end
end

local function DropLoot(inst, loot)
   
    local x, y, z = inst.Transform:GetWorldPosition()
    if loot.Physics ~= nil then
        local angle = math.random() * 2 * PI
        loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))

        if inst.Physics ~= nil then
            local len = loot:GetPhysicsRadius(0) + inst:GetPhysicsRadius(0)
            x = x + math.cos(angle) * len
            z = z + math.sin(angle) * len
        end

        loot:DoTaskInTime(1, CheckSpawnedLoot)
    end
    loot.Transform:SetPosition(x, y, z)
    --loot:PushEvent("on_loot_dropped", {dropper = inst})

    return loot
end

--npc任务组件
local NpcTask = Class(function(self, inst) 
    self.inst = inst

    self.current_task = nil
    self.tasking = false
end)

function NpcTask:Check(player)
	self.tasking = true
	if self.current_task ~= nil then
		local prefab = self.current_task.prefab
		local num = self.current_task.num
		local total = 0
		local item_tbs = {}
		if player.components.inventory ~= nil then
			--物品栏
            for k, v in pairs(player.components.inventory.itemslots) do
                if v.prefab == prefab and not v:HasTag("irreplaceable") then
                    local n = GetStackSize(v)
                    total = total + n
                    table.insert(item_tbs, v)
                end
            end
            --背包
            for k, v in pairs(player.components.inventory.opencontainers) do
                if k and k:HasTag("backpack") and k.components.container then
                    for i,j in pairs(k.components.container.slots) do
                        if j.prefab == prefab and not j:HasTag("irreplaceable") then
                            local n = GetStackSize(j)
                            total = total + n
                            table.insert(item_tbs, j)
                        end
                    end
                end
            end
		end
		if total >= num then
			for _, item in pairs(item_tbs) do
				local size = GetStackSize(item)
				if num >= size then
					item:Remove()
					num = num - size
				else
					item.components.stackable:SetStackSize(size - num)
					num = 0
				end
				if num <= 0 then
					self:Complete(player)
					self.tasking = false
					return
				end
			end
		end
	end
	self:PushTask()
	self.inst:DoTaskInTime(3, function() 
		self.tasking = false
	end)
end

function NpcTask:Complete(player)
	local inst = self.inst
	if self.current_task ~= nil then
		local level = self.current_task.level or 1
		local reward_tb = rewards[level]

		--基础奖励，钻石,经验值
		if level > 4 then
			local diamond = SpawnPrefab("diamond")
			diamond.components.stackable:SetStackSize(level-4)
			GiveItem(player, diamond)
		else
			local potion = SpawnPrefab("potion_achiv")
			potion.components.stackable:SetStackSize(level)
			GiveItem(player, potion)
		end

		--物品奖励
		local reward = reward_tb[math.random(#reward_tb)]
		local prefab = reward.prefab
		local num = reward.num or 1

		if TheWorld:HasTag("pigking_task_double") then
			num = num * 2
		end
		for k=1, num do
			local item = SpawnItem(prefab)
			DropLoot(player, item)
		end

		if inst.components.talker ~= nil then
			inst.components.talker:Say("这是你的奖励！")
		end
		player.components.taskdata:AddCollectTask()
		player:PushEvent("completecollect", {level = level})
		self.current_task = nil
	end
end

function NpcTask:PushTask()
	local inst = self.inst
	if self.current_task == nil then
		self.current_task = self:GetRandomTask()
	end
	if inst.components.talker ~= nil then
		inst.components.talker:Say(self:GetTaskDescription())
	end
end

function NpcTask:GetTaskDescription()
	if self.current_task ~= nil then
		local prefab = self.current_task.prefab
		local num = self.current_task.num or 1
		local level = self.current_task.level or 1
		local str_fmt = msg_data[level] or default_msg
		return str_fmt:format(num, STRINGS.NAMES[string.upper(prefab)])
	end	
end

function NpcTask:GetRandomTask()
	local task = tasks[math.random(#tasks)]
	if task ~= nil then
		--task = deepcopy(task)
		local prefab = task.prefab
		local num = task.num or 1
		local level = task.level or 1
		if num > 1 then
			num = RandomVaribleNum(num)
		end
		return {
			prefab = prefab, 
			num = num, 
			level = level
		}
	end
end

return NpcTask