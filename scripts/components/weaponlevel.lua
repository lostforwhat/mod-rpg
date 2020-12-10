local MAX_LEVEL = 10

local WeaponLevel = Class(function(self, inst) 
    self.inst = inst
    
    self.level = 0
end)

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
