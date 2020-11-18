local SourceModifierList = require("util/sourcemodifierlist")

local Extrameta = Class(function(self, inst) 
    self.inst = inst

    --self.damagemultiplier = 1
    self._net_damagemultiplier = net_float(inst.GUID, "extrameta.damagemultiplier", "extradamagedirty")
    self._net_damage = net_float(inst.GUID, "extrameta.damage", "extradamagedirty")

    self._net_absorb = net_float(inst.GUID, "extrameta.absorb", "extraabsorbdirty")
    self._net_invincible = net_bool(inst.GUID, "extrameta.invincible", "extraabsorbdirty")

    self._net_speed = net_float(inst.GUID, "extrameta.speed", "extraspeeddirty")

    self._net_hunger = net_shortint(inst.GUID, "extrameta.hunger", "extrahungerdirty")
    self._net_sanity = net_shortint(inst.GUID, "extrameta.sanity", "extrasanitydirty")
    self._net_health = net_shortint(inst.GUID, "extrameta.health", "extrahealthdirty")

    self.extra_health = SourceModifierList(self.inst, 0, SourceModifierList.additive)
    self.extra_sanity = SourceModifierList(self.inst, 0, SourceModifierList.additive)
    self.extra_hunger = SourceModifierList(self.inst, 0, SourceModifierList.additive)
    --self.extra_damage = SourceModifierList(self.inst) --额外伤害比较复杂，所以有单独组件
    --self.extra_speed = SourceModifierList(self.inst)

    self.inst:StartUpdatingComponent(self)
end)

function Extrameta:GetDamageMultiplier()
	if TheWorld.ismastersim then
		if self.inst.components.combat then
			local basemultiplier =  self.inst.components.combat.damagemultiplier or 1
			local externaldamagemultipliers = self.inst.components.combat.externaldamagemultipliers:Get() or 1
			return basemultiplier * externaldamagemultipliers
		end
	else
		return self._net_damagemultiplier:value() or 1
	end
end

function Extrameta:GetDamage()
	if TheWorld.ismastersim then
		if self.inst.components.combat then
			local weapon = self.inst.components.combat:GetWeapon()
			local basedamage = self.inst.components.combat.defaultdamage
			local basemultiplier = self.inst.components.combat.damagemultiplier or 1
			local bonus = 0
			if weapon ~= nil then
				if type(weapon.components.weapon.damage) ~= "function" then
					basedamage = weapon.components.weapon.damage
				end
			else
				if self.inst.components.rider ~= nil and self.inst.components.rider:IsRiding() then
		            local mount = self.inst.components.rider:GetMount()
		            if mount ~= nil and mount.components.combat ~= nil then
		                basedamage = mount.components.combat.defaultdamage
		                basemultiplier = mount.components.combat.damagemultiplier
		                externaldamagemultipliers = mount.components.combat.externaldamagemultipliers
		                bonus = mount.components.combat.damagebonus
		            end

		            local saddle = self.inst.components.rider:GetSaddle()
		            if saddle ~= nil and saddle.components.saddler ~= nil then
		                basedamage = basedamage + saddle.components.saddler:GetBonusDamage()
		            end
		        end
			end

			return basemultiplier
				* self.inst.components.combat.externaldamagemultipliers:Get() 
				* basedamage
				+ (bonus or 0)
		end
	else
		return self._net_damage:value() or 0
	end
end

function Extrameta:GetAbsorb()
	if TheWorld.ismastersim then
		--Defense
		local itemabsorb = 0
		local absorbmax = 0
		local inventory = self.inst.components.inventory
		if inventory then
			for k, v in pairs(inventory.equipslots) do
				if v.components.armor then
					if(itemabsorb < v.components.armor.absorb_percent) then
						itemabsorb = v.components.armor.absorb_percent
					end
				end
			end
		end
		if itemabsorb == 0 then
			absorbmax = 1*(self.inst.components.health.externalabsorbmodifiers:Get() 
				+ self.inst.components.health.playerabsorb 
				+ self.inst.components.health.absorb)
		else
			absorbmax = (self.inst.components.health.externalabsorbmodifiers:Get() 
				+ self.inst.components.health.playerabsorb 
				+ self.inst.components.health.absorb)
			absorbmax = 1*(itemabsorb + (1-itemabsorb)*absorbmax)
		end
		return absorbmax
	else
		return self._net_absorb:value() or 0
	end
end

function Extrameta:IsInvincible()
	if TheWorld.ismastersim then
		return self.inst.components.health:IsInvincible()
	else
		return self._net_invincible:value() or false
	end
end

function Extrameta:GetSpeed()
	if TheWorld.ismastersim then
		return self.inst.components.locomotor:GetRunSpeed()
	else
		return self._net_speed:value() or self.inst.components.locomotor:GetRunSpeed()
	end
end

--迫不得已使用这种消耗资源的方式，否则得大量修改combat及其replica
function Extrameta:OnUpdate(dt)
	if TheWorld.ismastersim then
		local damagemultiplier = self:GetDamageMultiplier()
		if self._net_damagemultiplier:value() ~= damagemultiplier then
			self._net_damagemultiplier:set(damagemultiplier)
		end
		local damage = self:GetDamage()
		if self._net_damage:value() ~= damage then
			self._net_damage:set(damage)
		end
		local absorb = self:GetAbsorb()
		if self._net_absorb:value() ~= absorb then
			self._net_absorb:set(absorb)
		end
		local speed = self:GetSpeed()
		if self._net_speed:value() ~= speed then
			self._net_speed:set(speed)
		end
		local invincible = self:IsInvincible()
		if self._net_invincible:value() ~= invincible then
			self._net_invincible:set(invincible)
		end
		if self._net_hunger:value() ~= self.extra_hunger:Get() then
			self._net_hunger:set(self.extra_hunger:Get())
			self.inst.components.hunger:ResetMax()
		end
		if self._net_sanity:value() ~= self.extra_sanity:Get() then
			self._net_sanity:set(self.extra_sanity:Get())
			self.inst.components.sanity:ResetMax()
		end
		if self._net_health:value() ~= self.extra_health:Get() then
			self._net_health:set(self.extra_health:Get())
			self.inst.components.health:ResetMax()
		end
	end
end


return Extrameta