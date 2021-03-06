--召唤组件
local Caller = Class(function(self, inst) 
    self.inst = inst
end)


function Caller:CallStart(player)
	if not TheWorld.calling and
		player ~= nil and player:HasTag("player") then
		local pos = player:GetPosition()
		for k, v in pairs(AllPlayers) do
			if v and v.components.reciever ~= nil and v ~= player
				and v.components.reciever:CanRecieved() then
					v.components.reciever:RecievedCall(pos, player)
			end
		end
		if #AllPlayers > 0 then
			self:CallEnd()
			return true
		end
	end
end

function Caller:CallEnd()
	if self.inst.components.finiteuses ~= nil then
		self.inst.components.finiteuses:Use(1)
	end
	TheWorld.calling = true
	TheWorld:DoTaskInTime(20, function() 
		TheWorld.calling = nil
	end)
end

return Caller