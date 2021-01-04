require "modmain/loot_table"

local function needNotice(goods)
    local notice_goods = notice_goods
    for i, v in ipairs(notice_goods) do
        if goods == v then 
            return true
        end
    end
    return false
end

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("stealed") and not victim:HasTag("hostile")) or
                victim:HasTag("veggie") or victim:HasTag("structure") or
                victim:HasTag("wall") or victim:HasTag("balloon") or
                victim:HasTag("groundspike") or victim:HasTag("smashable") or
                victim:HasTag("companion") or victim:HasTag("INLIMBO"))
        and victim.components.health ~= nil
        and victim.components.combat ~= nil
end

local function OnHitohter(inst, data)
    if inst.components.stealer then
        inst.components.stealer:OnHitohter(data.target)
    end
end

local function ApplyDisplay(inst)
    local dis = SpawnPrefab("display_effect")
    local rad = inst:GetPhysicsRadius(0)
    local x, y, z = inst.Transform:GetWorldPosition()
    dis.Transform:SetPosition(x, y + .5 * rad , z)
    dis:Display("偷窃", 32, {.1, .9, .2})
end

--偷窃
local Stealer = Class(function(self, inst) 
    self.inst = inst
    self.chance = 0
    self.level = 1

    self.inst:ListenForEvent("onhitother", OnHitohter)
end)

function Stealer:OnHitohter(target)
	if self.chance > 0 and IsValidVictim(target) and math.random() < self.chance then
        self:Effect(target)
    end
end

function Stealer:Effect(target)
	--如果有物品栏，从物品栏随机获取一个物品
	local item = nil
	if target.components.inventory ~= nil and target.components.inventory.maxslots > 0 then
		local maxslots = target.components.inventory.maxslots
		local items = {}
        for k = 1, maxslots do
	        local v = target.components.inventory.itemslots[k]
	        if v ~= nil then
	        	table.insert(items, v)
	        end
	    end
        if #items > 0 then
    	    item = items[math.random(#items)]
    	    item = target.components.inventory:DropItem(item)
        end
    end
    --然后随机获得一个掉落物，如果有的话
    if target.components.lootdropper ~= nil then
        local loots = target.components.lootdropper:GenerateLoot()
        if #loots > 0 then
            item = SpawnPrefab(loots[math.random(#loots)])
            item.Transform:SetPosition(target:GetPosition():Get())
        end
    end
    --否则随机获得一个物品
    if item == nil and self.inst:HasTag("player") and not target:HasTag("player") then
    	item = self:RandomItem(target)
        if not target:HasTag("epic") then
            target:AddTag("stealed") --防止薅羊毛
        end
        ApplyDisplay(self.inst)
    elseif item == nil then
    	return
    end
    --宣告贵重物品
    if item ~= nil and needNotice(item.prefab) then
        TheNet:Announce(self.inst:GetDisplayName().." 使用探云手，从 "..target:GetDisplayName().." 偷取了 "..item:GetDisplayName())
    end
    --如果攻击者有物品栏，则物品归属攻击者, 非玩家偷窃则有概率物品丢失
    if self.inst.components.inventory ~= nil and (self.inst:HasTag("player") or math.random() < .6) then
        self.inst.components.inventory:GiveItem(item)
    else
    	--否则销毁物品
    	if not item:HasTag("irreplaceable") then
	    	item:Remove()
	    end
    end
end

function Stealer:RandomItem(target)
	if loot_table == nil then return end
	local types = {"new_loot", "bad_loot", "new_loot", "new_loot", "good_loot", "luck_loot"}
	local items = deepcopy(loot_table[types[math.random(self.level + 1)]])
    local loot = items[math.random(#items)]

    local viplevel = self.inst.components.vip and self.inst.components.vip.level or 0
    while(loot.chance < .1 / (viplevel + 1)) do
        items = deepcopy(loot_table[types[math.random(self.level)]])
        loot = items[math.random(#items)]
    end

	local prefab = loot.item
	if prefab ~= nil and PrefabExists(prefab) then
		local item = SpawnPrefab(prefab)
		if item.components.inventoryitem == nil then
			local pack_item = SpawnPrefab("package_ball")
			pack_item.components.packer:Pack(item)
			return pack_item
		end
        item.Transform:SetPosition(target:GetPosition():Get())
		return item
	end
	return SpawnPrefab("ash")
end

function Stealer:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("onhitother", OnHitohter)
end

return Stealer