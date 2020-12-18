require "modmain/suit_data"
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

    self.equip_slots = {}

    self.inst:ListenForEvent("equip", OnEquipSlot)
    self.inst:ListenForEvent("unequip", OnUnEquipSlot)

    self.inst:DoTaskInTime(0, function() 
        self:Calc(true)
    end)
end)

function Suit:OnEquipSlot(data)
	local item = data.item
	local eslot = data.eslot

    self:Calc(true)
end

function Suit:OnUnEquipSlot(data)
    local item = data.item
    local eslot = data.eslot

    self:Calc(true)
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

        self.equip_slots = {self.current_hat, self.current_armor, self.current_weapon, self.current_neck, self.current_backpack}
	end

    if suit_data then
        for _, v in pairs(suit_data) do
            local prefabs = v.prefabs
            local required_prefabs = v.required_prefabs
            local num = v.num or #prefabs
            local suit = 0
            local require_suit = 0
            for i, prefab in pairs(prefabs) do
                if self:HasEquip(prefab) then
                    suit = suit + 1
                    if required_prefabs ~= nil and table.contains(required_prefabs, prefab) then
                        require_suit = require_suit + 1
                    end
                end
            end

            if suit >= num and (required_prefabs == nil or require_suit >= #required_prefabs) then
                self:EffectSuit(v)
                return
            end
        end
    end
    self:EffectSuit(nil)
end

function Suit:EffectSuit(suit)
    if self.current_suit ~= nil and self.current_suit.onmismatch ~= nil then
        self.current_suit.onmismatch(self.inst)
    end
    self.current_suit = suit
    if self.current_suit ~= nil and self.current_suit.onmatch ~= nil then
        if self.inst.components.talker ~= nil then
            self.inst.components.talker:Say("已获得套装效果!")
        end
        self.current_suit.onmatch(suit)
    end
end

function Suit:HasEquip(prefab)
    for k, v in pairs(self.equip_slots) do
        if v ~= nil and v.prefab == prefab then
            return true
        end
    end
end

function Suit:OnRemoveFromEntity()
    self:EffectSuit(nil)
    self.inst:RemoveEventCallback("equip", OnEquipSlot)
    self.inst:RemoveEventCallback("unequip", OnUnEquipSlot)
end

return Suit