require "modmain/loot_table"

local function IsValidVictim(victim)
    return victim ~= nil
        and not ((victim:HasTag("prey") and not victim:HasTag("hostile")) or
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
	        local v = self.itemslots[k]
	        if v ~= nil then
	        	table.insert(items, v)
	        end
	    end
	    item = items[math.random(#items)]
	    item = target.components.inventory:DropItem(item)
    end
    --否则随机获得一个物品
    if item == nil and self.inst:HasTag("player") and not target:HasTag("player") then
    	item = self:RandomItem(target)
    else
    	return
    end
    --如果攻击者有物品栏，则物品归属攻击者
    if self.inst.components.inventory ~= nil then
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
	local types = {"new_loot", "new_loot", "new_loot", "good_loot", "luck_loot"}
	local items = deepcopy(loot_table[types[math.random(#self.level)]])
	local prefab = items[math.random(#items)]
	if PrefabExists(item) then
		local item = SpawnPrefab(item)
		if item.components.inventory == nil then
			local pack_item = SpawnPrefab("package_ball")
			pack_item.components.packer:Pack(item)
			return pack_item
		end
		return item
	end
	return nil
end

function Stealer:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("onhitother", OnHitohter)
end

return Stealer