local Packer =  Class(function(self, inst)
	self.inst = inst
	self.canpackfn = nil
	self.package = nil
end)

function Packer:HasPackage()
	return self.package ~= nil
end

function Packer:SetCanPackFn(fn)
	self.canpackfn = fn
end

function Packer:CanPack(target)
	return target
		and target:IsValid()
		and not target:IsInLimbo()
		and not target:HasTag("player")
		and self.inst:IsValid()
		and (not target.components or not target.components.packer)
		and not target.components.teleporter
		and not self:HasPackage()
		and (not self.canpackfn or self.canpackfn(target, self.inst))
end

local function get_name(target, raw_name)
	local name = raw_name or target:GetDisplayName() or (target.components.named and target.components.named.name)
	if not name or name == "MISSING NAME" then
		name = STRINGS.TUM.UNKNOWN_PACKAGE
	end

	local adj = target:GetAdjective()
	if adj then
		name = adj.." "..name
	end
	
	if target.components.stackable then
		local size = target.components.stackable:StackSize()
		if size > 1 then
			name = name.." x"..tostring(size)
		end
	end
	return name
end

function Packer:Pack(target)
	if not self:CanPack(target) then
		--print("cant pack")
		return false
	end
	self.package = {
		prefab = target.prefab,
		name = STRINGS.NAMES.PACKAGED.."["..get_name(target).."]",
	}
	pcall(function() 
		self.package.data, self.package.refs = target:GetPersistData()
	end)
	target:Remove()
	self.inst.components.named:SetName(self.package.name)
	return true
end


function Packer:Unpack(pos)
	if not self.package or 
		not self.package.prefab then
		return 
	end

	local target = SpawnPrefab(self.package.prefab)
	if target then
		target.Transform:SetPosition(pos:Get())

		local newents = {}
		if self.package.refs ~= nil then
			for _, guid in ipairs(self.package.refs) do
				newents[guid] = {entity = Ents[guid]}
			end
		end

	if target.components.leader then
		target.components.leader.LoadPostPass= function(newents, savedata)
			if savedata and savedata.followers then
				for k,v in pairs(savedata.followers) do
					local targ = newents[v]
					if targ and targ.entity and targ.entity.components.follower then
						self:AddFollower(targ.entity)
					end
				end
			end
		end
	end
	pcall(function() 
		target:SetPersistData(self.package.data, newents)
		target:LoadPostPass(newents, self.package.data)
	end)

	target.Transform:SetPosition(pos:Get())
	self.package = nil
	return true
	end
end

function Packer:GetName()
	return self.package and self.package.name
end

function Packer:OnSave()
	if self.package then
		return {package = self.package}, self.package.refs
	end
end

function Packer:OnLoad(data)
	if data and data.package then
		self.package = data.package
	end
end

return Packer