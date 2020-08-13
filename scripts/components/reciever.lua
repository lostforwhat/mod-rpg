local Reciever = Class(function(self, inst) 
    self.inst = inst
    self.pos = nil
    self.recieving = false
end)

function Reciever:CanRecieved()
	return not self.recieving
end

function Reciever:RecievedCall(pos, caller)
	local reciever = self.inst
	if reciever~=nil and reciever:HasTag("player") then
		
	end
end

return Reciever