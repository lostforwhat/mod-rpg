local MAX_LEVEL = 99 --理论无上限,实际应该10级左右达到上限

local function onlevel(self, level)
	if self.inst.components.weapon ~= nil then
		self.inst.components.weapon:RecalcDamage()
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

--7,10,16,19,26,31
function WeaponLevel:DoStrengthen(doer)

end

return WeaponLevel
