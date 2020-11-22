local Prayable = Class(function(self, inst) 
    self.inst = inst
    self.prayfn = nil
end)

function Prayable:SetPrayFn(fn)
    self.prayfn = fn
end

function Prayable:StartPray(inst, prayers)
	if self.prayfn~=nil then
		if self.prayfn(self.inst, prayers) then
			if inst.components.stackable ~= nil then
				inst.components.stackable:Get():Remove()
			else
				inst:Remove()
			end
			return true
		end
	end
end

return Prayable