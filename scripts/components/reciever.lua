local function onpos(self, pos)
	self.net_data.x:set(pos.x)
	self.net_data.z:set(pos.z)
end

local function onrecieving(self, recieving)
	self.net_data.recieving:set(recieving)
end

local Reciever = Class(function(self, inst) 
    self.inst = inst

    self.net_data = {
    	x = net_byte(inst.GUID, "reciever.x", "recieverposdirty"),
    	z = net_byte(inst.GUID, "reciever.z", "recieverposdirty"),
    	recieving = net_bool(inst.GUID, "reciever.recieving", "recievingdirty")
    }

    self.pos = nil
    self.recieving = false
end,
nil,
{
	pos = onpos,
	recieving = onrecieving
})

function Reciever:CanRecieved()
	return not self.recieving and not self.inst:HasTag("playerghost")
end

function Reciever:RecievedCall(pos, caller)
	local reciever = self.inst
	if reciever~=nil and reciever:HasTag("player") then
		
	end
end

return Reciever