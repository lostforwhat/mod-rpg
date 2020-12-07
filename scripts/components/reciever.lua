local function onpos(self, pos)
	if pos ~= nil then
		self.net_data.x:set(pos.x)
		self.net_data.z:set(pos.z)
	end
end

local function onrecieving(self, recieving)
	self.net_data.recieving:set(recieving)
end

local function oncaller(self, caller)
	self.net_data.caller:set(caller)
end

local function ontime_left(self, time_left)
	self.net_data.time_left:set(time_left)
end

--这是个拼写错误，懒得纠正了
local Reciever = Class(function(self, inst) 
    self.inst = inst

    self.net_data = {
    	x = net_byte(inst.GUID, "reciever.x", "recieverposdirty"),
    	z = net_byte(inst.GUID, "reciever.z", "recieverposdirty"),
    	recieving = net_bool(inst.GUID, "reciever.recieving", "recievingdirty"),
    	caller = net_entity(inst.GUID, "reciever.caller"),
    	time_left = net_byte(inst.GUID, "reciever.time_left", "recievertime_leftdirty"),
    }

    self.caller = nil
    self.pos = nil
    self.recieving = false
    self.time_left = 0
end,
nil,
{
	pos = onpos,
	recieving = onrecieving,
	caller = oncaller,
	time_left = ontime_left,
})

function Reciever:CanRecieved()
	return not self.recieving and not self.inst:HasTag("playerghost")
end

function Reciever:RecievedCall(pos, caller)
	local reciever = self.inst
	if reciever~=nil and reciever:HasTag("player") and not self.recieving then
		if self.inst.components.talker ~= nil then
			self.inst.components.talker:Say("有人在呼唤！")
		end
		self.caller = caller
		self.pos = pos
		self.recieving = true
		self.time_left = 20
		reciever:StartUpdatingComponent(self)
	end
end

function Reciever:OnUpdate(dt)
	self.time_left = self.time_left - dt
	if self.time_left <= 0 then
		self.recieving = false
		self.inst:StopUpdatingComponent(self)
	end
end

--server only
function Reciever:Accept()
	if self.recieving and self.pos ~= nil then
		if not self.inst:HasTag("playerghost") then
			self.inst.Transform:SetPosition(self.pos:Get())
			self.recieving = false
			self.inst:StopUpdatingComponent(self)
		end
	else
		if self.inst.components.talker ~= nil then
			self.inst.components.talker:Say("啊！已经不知道位置了!")
		end
	end
end

function Reciever:Refuse()
	if self.inst.components.talker ~= nil then
		self.inst.components.talker:Say("我不想去呢!")
	end
	self.recieving = false
	self.inst:StopUpdatingComponent(self)
end

return Reciever