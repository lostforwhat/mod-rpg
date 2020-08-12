
local Caller = Class(function(self, inst) 
    self.inst = inst
end)


function Caller:CallStart(player)
	if player~=nil and player:HasTag("player") then
		
		
		
	end
end

function Caller:CallEnd()
	if self.inst.components.finiteuses ~= nil then
		self.inst.components.finiteuses:Use(1)
	else
		self.inst:Remove()
	end
end

return Caller