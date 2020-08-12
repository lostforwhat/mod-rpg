local Reciever = Class(function(self, inst) 
    self.inst = inst
    self.pos = nil
end)


function Reciever:RecievedCall(pos, caller)
	local reciever = self.inst
	if reciever~=nil and reciever:HasTag("player") then
		
	end
end

return Reciever