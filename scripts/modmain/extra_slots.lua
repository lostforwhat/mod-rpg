--添加额外装备栏
local _G = GLOBAL
local IsServer = _G.TheNet:GetIsServer()

require "utils/utils"

local ExistInTable = _G.ExistInTable

table.insert(Assets, Asset("IMAGE", "images/slots/back.tex"))
table.insert(Assets, Asset("ATLAS", "images/slots/back.xml"))
table.insert(Assets, Asset("IMAGE", "images/slots/neck.tex"))
table.insert(Assets, Asset("ATLAS", "images/slots/neck.xml"))

_G.EQUIPSLOTS.BACK = "back"
_G.EQUIPSLOTS.NECK = "neck"


AddComponentPostInit("inventory", function(self, inst)
    local original_Equip = self.Equip
    function self:Equip(item, old_to_active)
        if original_Equip(self, item, old_to_active) and item and item.components and item.components.equippable then
            local eslot = item.components.equippable.equipslot
            if self.equipslots[eslot] ~= item then
                if eslot == _G.EQUIPSLOTS.BACK and item.components.container ~= nil then
                    self.inst:PushEvent("setoverflow", { overflow = item })
                end
            end
            return true
        else
            return
        end
    end

    self.GetOverflowContainer = function()
        if self.ignoreoverflow then
            return
        end
        local item = self:GetEquippedItem(_G.EQUIPSLOTS.BACK)
        return item ~= nil and item.components.container or nil
    end
end)

AddClassPostConstruct("widgets/inventorybar", function(self, owner)
    local Old_Refresh_base = self.Refresh
    local Old_Rebuild_base = self.Rebuild

    function self:LoadExtraSlots(self)
        self.bg:SetScale(1.35,1,1.25)
        self.bgcover:SetScale(1.35,1,1.25)

        if self.addextraslots == nil then
            self.addextraslots = 1

            self:AddEquipSlot(_G.EQUIPSLOTS.BACK, "images/slots/back.xml", "back.tex")
            self:AddEquipSlot(_G.EQUIPSLOTS.NECK, "images/slots/neck.xml", "neck.tex")

            if self.inspectcontrol then
                local W = 68
                local SEP = 12
                local INTERSEP = 28
                local inventory = self.owner.replica.inventory
                local num_slots = inventory:GetNumSlots()
                local num_equip = #self.equipslotinfo
                local num_buttons = self.controller_build and 0 or 1
                local num_slotintersep = math.ceil(num_slots / 5)
                local num_equipintersep = num_buttons > 0 and 1 or 0
                local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP
            	self.inspectcontrol.icon:SetPosition(-4, 6)
            	self.inspectcontrol:SetPosition((total_w - W) * .5 + 3, -6, 0)
            end
        end
    end

    function self:Refresh()
        Old_Refresh_base(self)
        self:LoadExtraSlots(self)
    end

    function self:Rebuild()
        Old_Rebuild_base(self)
        self:LoadExtraSlots(self)
    end
end)

AddPrefabPostInit("inventory_classified", function(inst)
    local function GetOverflowContainer(inst)
        local item = inst.GetEquippedItem(inst, _G.EQUIPSLOTS.BACK)
        return item ~= nil and item.replica.container or nil
    end

    local function Count(item)
        return item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
    end

    local function Has(inst, prefab, amount)
        local count =
            inst._activeitem ~= nil and
            inst._activeitem.prefab == prefab and
            Count(inst._activeitem) or 0

        if inst._itemspreview ~= nil then
            for i, v in ipairs(inst._items) do
                local item = inst._itemspreview[i]
                if item ~= nil and item.prefab == prefab then
                    count = count + Count(item)
                end
            end
        else
            for i, v in ipairs(inst._items) do
                local item = v:value()
                if item ~= nil and item ~= inst._activeitem and item.prefab == prefab then
                    count = count + Count(item)
                end
            end
        end

        local overflow = GetOverflowContainer(inst)
        if overflow ~= nil then
            local overflowhas, overflowcount = overflow:Has(prefab, amount)
            count = count + overflowcount
        end

        return count >= amount, count
    end

    if not IsServer then
        inst.GetOverflowContainer = GetOverflowContainer
        inst.Has = Has
    end
end)

AddStategraphPostInit("wilson", function(self)
    for key,value in pairs(self.states) do
        if value.name == 'amulet_rebirth' then
            local original_amulet_rebirth_onexit = self.states[key].onexit


            self.states[key].onexit = function(inst)
                local item = inst.components.inventory:GetEquippedItem(_G.EQUIPSLOTS.NECK)
                if item and item.prefab == "amulet" then
                    item = inst.components.inventory:RemoveItem(item)
                    if item then
                        item:Remove()
                        item.persists = false
                    end
                end
                original_amulet_rebirth_onexit(inst)
            end
        end
    end
end)

local amulets = {
    "amulet", "blueamulet", "purpleamulet", "orangeamulet", "greenamulet", "yellowamulet"
}

local backpacks = {
    "backpack", "krampus_sack", "piggyback", "icepack"
}

local function backpackpostinit(inst)
    if IsServer then
        inst.components.equippable.equipslot = _G.EQUIPSLOTS.BACK or _G.EQUIPSLOTS.BODY
    end
end

local function amuletpostinit(inst)
    if IsServer then
        inst.components.equippable.equipslot = _G.EQUIPSLOTS.NECK or _G.EQUIPSLOTS.BODY
    end
end

AddPrefabPostInitAny(function(inst) 
    if not IsServer then return end
    if ExistInTable(amulets, inst.prefab) then
        inst.components.equippable.equipslot = _G.EQUIPSLOTS.NECK or _G.EQUIPSLOTS.BODY
    elseif ExistInTable(backpacks, inst.prefab) or inst:HasTag("backpack") then
        inst.components.equippable.equipslot = _G.EQUIPSLOTS.BACK or _G.EQUIPSLOTS.BODY
    end
end)


AddPrefabPostInit("amulet", amuletpostinit)
AddPrefabPostInit("blueamulet", amuletpostinit)
AddPrefabPostInit("purpleamulet", amuletpostinit)
AddPrefabPostInit("orangeamulet", amuletpostinit)
AddPrefabPostInit("greenamulet", amuletpostinit)
AddPrefabPostInit("yellowamulet", amuletpostinit)

AddPrefabPostInit("backpack", backpackpostinit)
AddPrefabPostInit("krampus_sack", backpackpostinit)
AddPrefabPostInit("piggyback", backpackpostinit)
AddPrefabPostInit("icepack", backpackpostinit)
