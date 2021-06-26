local function CheckShard(worldid)
	local shards = Shard_GetConnectedShards()
	for k, v in pairs(shards) do
		if tonumber(k) == tonumber(worldid) then
			return true
		end
	end
end

local function CheckWorldId(worldid)
	if tonumber(worldid) == tonumber(TheShard:GetShardId()) then
		return false
	end
	
	return tonumber(worldid) == 1 or CheckShard(worldid)
end

local Migrater = Class(function(self, inst) 
    self.inst = inst
end)

function Migrater:SetCheckFn(fn)
    self.checkfn = fn
end

function Migrater:StartMigrate(worldid)
	--worldid = tonumber(worldid)
	if self.inst:IsValid() and not self.inst:HasTag("playerghost") and CheckWorldId(worldid) and 
		(self.checkfn == nil or self.checkfn(self.inst)) then
		--self.inst.sg:GoToState("migrate")
		if self.inst:HasTag("player") then
			self.inst.components.health:SetInvincible(true)
		end
		TheWorld:DoTaskInTime(0, function()
			print("Activating portal[0] to "..(worldid or "<nil>"))
			TheWorld:PushEvent("ms_playerdespawnandmigrate", { player = self.inst, portalid = 0, worldid = worldid })
		end)
	end
end

return Migrater