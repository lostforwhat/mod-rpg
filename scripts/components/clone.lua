local function defaultclonefn(cloner)
	local x, y, z = cloner.Transform:GetWorldPosition()
	local cloned = SpawnPrefab(cloner.prefab)
	cloned.Transform:SetPosition(x, y, z)
end

local function GetAbigailNum(player)
	if player == nil then return 0 end
	local followers = player.components.leader.followers
	local num = 0
    for k,v in pairs(followers) do
        if k.prefab == "abigail_clone" then
            num = num + 1
        end
    end
    return num
end

local function AbigailClone(inst, data)
	if inst.components.clone ~= nil then
		inst.components.clone:AbigailClone(data)
	end
end


local Clone = Class(function(self, inst) 
    self.inst = inst
    self.maxclone = 4
    self.chance = 0.1
    self.clonefn = nil
    self:Init()
end)

function Clone:SetCloneFn(fn)
    self.clonefn = fn
end

function Clone:AbigailClone(data)
	if math.random() < self.chance then
    	local x, y, z = inst.Transform:GetWorldPosition()
		local player = inst._playerlink
		if player.abigail_clone == nil or GetAbigailNum(player) < self.maxclone then
			local cloned = SpawnPrefab("abigail_clone")

			cloned.Transform:SetPosition(x, y, z)
			cloned:LinkToPlayer(player)
			cloned:BecomeAggressive()
			cloned.components.combat:SuggestTarget(data.attacker or nil)
			cloned:DoTaskInTime(120, function(cloned) 
				if cloned:IsValid() then cloned:Remove() end
			end)
		end
    end
end

--clonefn
function Clone:StartClone()
	if self.clonefn ~= nil then
		inst:ListenForEvent("attacked", self.clonefn)
	end
end

function Clone:Init()
	if inst.prefab == "abigail" then
		self:SetCloneFn(AbigailClone)
		self:StartClone()
	end
end

function Clone:OnRemoveFromEntity()
	if inst.prefab == "abigail" then
		self.inst:RemoveEventCallback("onhitother", self.clonefn)
	end
end

return Clone