local MAX_LEVEL = 99 --理论无上限,实际应该20级左右达到上限

local function onlevel(self, level)
	if self.inst.components.weapon ~= nil then
		self.inst.components.weapon:RecalcDamage()
	end
	if self.inst.components.named ~= nil and level > 0 then
		self.inst.components.named:SetName(STRINGS.NAMES[string.upper(self.inst.prefab)].." +"..level)
	end	
end

local WeaponLevel = Class(function(self, inst) 
    self.inst = inst
    
    self.level = 0
end,
nil,
{
	level = onlevel
})

function WeaponLevel:OnSave()
	return {
		level = self.level
	}
end

function WeaponLevel:OnLoad(data)
	if data ~= nil then
		self.level = data.level or 0 
	end
end

function WeaponLevel:AddLevel(amount)
	local oldlevel = self.level
	if type(amount) ~= "number" then
		amount = 1
	end
	if self.level < MAX_LEVEL then
		self.level = self.level + math.floor(amount)
	end
	self.inst:PushEvent("weaponlevelup", {oldlevel = oldlevel, newlevel = self.level})
end

function WeaponLevel:DoStrengthen(doer, rate, protect) --基础几率
	local player_luck = doer.components.luck and doer.components.luck:GetLuck() or 0

	local baselevel = self.level or 0
	local real_rate = 0
	if baselevel >= 19 then
		real_rate = math.min(.1, rate * .1) --限制高等级
	elseif baselevel >= 9 then
		real_rate = (.68 - baselevel*.02)
	else
		real_rate = (1 - baselevel*.04) * rate
	end
	if math.random() < real_rate * (1 + player_luck * .005) then
		self:AddLevel(1)
		doer:PushEvent("weaponstrengthen", {weapon = self.inst, level = self.level})

		if self.level >= 10 then 
			local str = "恭喜 "..doer:GetDisplayName().." 熔炼 ".. self.inst:GetDisplayName().." 成功!"
			TheNet:Announce(str, doer.entity)
		end
		
		self:Fixed(1)
		return true
	elseif baselevel > 10 and not protect and not doer:HasTag("weaponprotect") and not TheWorld:HasTag("weaponprotect") then
		self:AddLevel(-1)
	end
	self:Fixed(rate)
	return false
end

function WeaponLevel:Fixed(percent)
	if self.inst.components.finiteuses ~= nil then
		local current = self.inst.components.finiteuses:GetPercent()
		self.inst.components.finiteuses:SetPercent(math.min(current + percent, 1))
	elseif self.inst.components.perishable ~= nil then
		local current = self.inst.components.perishable:GetPercent()
		self.inst.components.perishable:SetPercent(math.min(current + percent, 1))
	end
end

return WeaponLevel
