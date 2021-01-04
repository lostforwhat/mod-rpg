local DEFAULT_CD = 60
local USE_STEP = 5

local function onlevel(self, level)
	if self.inst.player_classified ~= nil then
        self.inst.player_classified:UpdateSkill("resurrect", {level=level})
    end
end

local function oncd_time(self, cd_time)
	if self.inst.player_classified ~= nil then
        self.inst.player_classified:UpdateSkillCd("resurrect", cd_time)
    end
end


--人物复活组件
local Resurrect = Class(function(self, inst) 
    self.inst = inst

    self.level = 0
    self.cd_time = 0
    self.use = 0
end,
nil,
{
	level = onlevel,
	cd_time = oncd_time,
})

function Resurrect:OnSave()
	return {
		cd_time = self.cd_time,
		use = self.use,
	}
end

function Resurrect:OnLoad(data)
	if data ~= nil and data.cd_time then
		self.cd_time = data.cd_time or 0
		if self.cd_time > 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end 
	if data ~= nil and data.use then
		self.use = data.use or 0
	end
end

function Resurrect:Effect()
	if self.level > 0 and self.cd_time <= 0 and self.inst:HasTag("playerghost") then
		self.inst:DoTaskInTime(0, function()
			self.inst:PushEvent("respawnfromghost")
			self.inst.rezsource = "复活"

			if self.inst.components.level ~= nil then
		        self.inst.components.level:ReduceXpOnDeath()
		    end
		end)

		self.use = self.use + 1
		self.cd_time = DEFAULT_CD + self.use * USE_STEP
		self.inst:StartUpdatingComponent(self)

		if self.inst.components.email ~= nil then
			if self.use == 1 then --初次复活给予提示
				local email = {
					_id = math.random(999999),
					title = "复活提示",
					content = "亲爱的玩家，这是您第一次使用一键复活，每次使用将延长使用CD并扣减经验值，建议必要的时候再使用该方式复活！",
					prefabs = {
						{
							prefab = "amulet",
							num = 1,
						}
					},
					sender = "system",
					time = tostring(os.date())
				}
				self.inst.components.email:AddEmail(email)
			end
			if self.use == 5 and --前期多次复活给予提示
				self.inst.components.age ~= nil and 
				self.inst.components.age:GetAgeInDays() <= 5 then
				local email = {
					_id = math.random(999999),
					title = "来自五年的关怀",
					content = "您短期内频繁使用一键复活，每次使用将延长使用CD并扣减经验值，建议必要的时候再使用该方式复活，考虑您目前的困境，系统给予您特殊的关怀！",
					prefabs = {
						{
							prefab = "amulet",
							num = 5,
						},
						{
							prefab = "potion_luck",
							num = 2,
						},
						{
							prefab = "meat_dried",
							num = 5,
						},
						{
							prefab = "cutgrass",
							num = 10,
						},
						{
							prefab = "twigs",
							num = 5,
						}
					},
					sender = "system",
					time = tostring(os.date())
				}
				self.inst.components.email:AddEmail(email)
			end
		end
	end
end

function Resurrect:OnUpdate(dt)
	self.cd_time = self.cd_time - dt
	if self.cd_time <= 0 then
		self.cd_time = 0
		self.inst:StopUpdatingComponent(self)
	end
end

return Resurrect