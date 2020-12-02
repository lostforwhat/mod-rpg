local function CheckWorldId(worldid)
	if worldid == TheShard:GetShardId() then
		return false
	end
	local shards = Shard_GetConnectedShards()
	return shards[worldid] ~= nil
end

local Migrater = Class(function(self, inst) 
    self.inst = inst
end)

function Migrater:SetCheckFn(fn)
    self.checkfn = fn
end

function Migrater:StartMigrate(worldid)
	if CheckWorldId(worldid) and 
		(self.checkfn == nil or self.checkfn(self.inst)) then

		TheWorld:PushEvent("ms_playerdespawnandmigrate", { player = self.inst, portalid = 1, worldid = worldid })
	end
end

return Migrater