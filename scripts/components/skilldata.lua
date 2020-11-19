local function onskill(owner, skillid)
	if owner.components.skilldata then
		if owner.components.skilldata.skills then
			local skill = owner.components.skilldata.skills[skillid]
			if skill then
				if skill.effect_fn then
					skill:effect_fn(owner)
				end
			end
		end
	end
end

local onchangefn = {}
if skill_constant then
	for k, v in pairs(skill_constant) do
		if v.id then
			onchangefn[v.id] = function(self, val)
				onskill(self.inst, v.id)
				self.net_data[v.id]:set(val)
			end
		end
	end
end

local SkillData = Class(function(self, inst) 
    self.inst = inst

    self.net_data = {

    }
    self.skills = {}
    self:Init()

    self.coin_used = 0
end,
nil,
onchangefn)

function SkillData:Init()
	if skill_constant then
		local inst = self.inst
		for k, v in pairs(skill_constant) do
			local id = v.id
			local max_level = v.max_level or 1
			if max_level < 255 then 
				self.net_data[id] = net_byte(inst.GUID, "skilldata."..id, id.."skilldirty")
			elseif max_level < 32767 then
				self.net_data[id] = net_shortint(inst.GUID, "skilldata."..id, id.."skilldirty")
			else
				self.net_data[id] = net_int(inst.GUID, "skilldata."..id, id.."skilldirty")
			end
			self[id] = 0
			if TheWorld.ismastersim then
				self.skills[id] = v
			end
		end
	end
end

function SkillData:GetLevel(id)
	if TheWorld.ismastersim then
		return self[id] or 0
	else
		return self.net_data[id]:value() or 0
	end
end

function SkillData:LevelUp(id, amount)
	if self[id] == nil or self.net_data[id] == nil then return end
	if TheWorld.ismastersim then
		if self.skills[id] then
			local skill = self.skills[id]
			local cost = skill.cost or 0
			local max_level = skill.max_level or 1
			if self[id] + amount > max_level then
				return
			end
			if self.inst.components.purchase then
				if self.inst.components.purchase.coin >= cost then
					self.inst.components.purchase:CoinDoDelta(-cost)
					self.coin_used = self.coin_used + cost
					self[id] = self[id] + math.floor(amount)
				end
			end
		end
	else
		--self.net_data[id]:set_local(self.net_data[id]:value() + math.floor(amount))
		SendModRPCToServer(MOD_RPC.RPG_skill.levelup, id, amount)
	end
end

function SkillData:SetLevel(id, level)
	if TheWorld.ismastersim then
		if self.skills[id] then
			local skill = self.skills[id]
			local max_level = skill.max_level or 1
			if level < 0 then
				level = 0
			end
			if level > max_level then
				level = max_level
			end
			self[id] = math.floor(level)
		end
	end
end

function SkillData:OnSave()
	local data = {}
	if skill_constant then
		for k, v in pairs(skill_constant) do
			if v.id then
				data[v.id] = self[v.id] or 0
			end
		end
	end
	data.coin_used = self.coin_used or 0
	return data
end

function SkillData:OnLoad(data)
	for k, v in pairs(data) do
		self[k] = v or 0
	end	
end

return SkillData