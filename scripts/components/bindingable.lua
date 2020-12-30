
local Bindingable = Class(function(self, inst) 
    self.inst = inst

    self.binding_data = {}
    self.keys = {}
end,
nil,
{
    
})

function Bindingable:SortKey()
	self.keys = {}
	for k, v in pairs(self.binding_data) do
		table.insert(self.keys, k)
	end
	table.sort(self.keys, function(a,b) return a>b end)
end

function Bindingable:AddData(num, prefab)
	if self.binding_data[num] == nil then
		self.binding_data[num] = {prefab}
	else
		table.insert(self.binding_data[num], prefab)
	end
	self:SortKey()
end

function Bindingable:SetData(data)
	self.binding_data = data
	self:SortKey()
end

function Bindingable:GetProduct(num)
	for _, v in pairs(self.keys) do
		if num >= v then
			local data = self.binding_data[v]
			if data ~= nil and #data > 0 then
				return data[math.random(#data)], v
			end
		end
	end
end

function Bindingable:Binding(player)
	if player ~= nil and player:HasTag("player") then

		local num = 1
		if self.inst.components.stackable ~= nil then
			num = self.inst.components.stackable:StackSize()
		end

		local product, need = self:GetProduct(num)
		if product ~= nil then
			local item = SpwanPrefab(product)

			if num > need then
				self.inst.components.stackable:SetStackSize(num - need)
			else
				self.inst:Remove()
			end
			return true
		end
		--self.inst:Remove()
	end
end

return Bindingable