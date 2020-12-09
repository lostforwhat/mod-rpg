
local Diamond = Class(function(self, inst) 
    self.inst = inst

    self.value = 1
end,
nil,
{
    
})

function Diamond:Use(player)
	if player ~= nil and player:HasTag("player") and player.components.purchase ~= nil then
		local value = self.value
		if self.inst.components.stackable ~= nil then
			local num = self.inst.components.stackable:StackSize()
			value = self.value * num
		end
		player.components.purchase:CoinDoDelta(value)
		self.inst:Remove()
	end
end

return Diamond