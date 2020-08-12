
local Migrater = Class(function(self, inst) 
    self.inst = inst
end)

function Migrater:SetFn(fn)
    self.fn = fn
end

function Migrater:StartMigrate(player)
	if player~=nil and player:HasTag("player") then
		
		
		if self.inst.components.stackable ~= nil then
			self.inst.components.stackable:Get():Remove()
		else
			self.inst:Remove()
		end
	end
end

return Migrater