--套装组件

local MAX_SLOTS = 5

local function OnEquipSlot(inst, data)
	if inst.components.suit then
		inst.components.suit:OnEquipSlot(data)
	end
end

local function OnUnEquipSlot(inst, data)
    if inst.components.suit then
        inst.components.suit:OnUnEquipSlot(data)
    end
end

--装备套装属性
local Suit = Class(function(self, inst) 
    self.inst = inst
    self.current_hat = nil
    self.current_armor = nil
    self.current_weapon = nil
    self.current_neck = nil
    self.current_backpack = nil
    --self.current_weapon2 = nil

    self.inst:ListenForEvent("equip", OnEquipSlot)
    self.inst:ListenForEvent("unequip", OnUnEquipSlot)
end)

function Suit:OnEquipSlot(data)
	local item = data.item
	local eslot = data.eslot

end

function Suit:OnUnEquipSlot(data)
    local item = data.item
    local eslot = data.eslot

end

function Suit:Calc(force)
	if self.inst.components.inventory == nil then return end
	--是否强制重新计算
	force = force == true
	if force then
		self.current_hat = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        self.current_armor = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
        self.current_weapon = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        self.current_neck = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK)
        self.current_backpack = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BACK)
        --self.current_weapon2 = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS2)
	end


end

function Suit:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("equip", OnEquipSlot)
    self.inst:RemoveEventCallback("unequip", OnUnEquipSlot)
end

return Suit