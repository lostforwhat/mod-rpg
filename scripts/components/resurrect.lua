local DEFAULT_CD = 120
local USE_STEP = 5

local function onlevel(self, level)
	if self.inst.player_skills_classified ~= nil then
        self.inst.player_skills_classified:UpdateSkill("resurrect", {level=level})
    end
end

local function oncd_time(self, cd_time)
	if self.inst.player_skills_classified ~= nil then
        self.inst.player_skills_classified:UpdateSkill("resurrect", {cd=cd_time})
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
		cd_time = self.cd_time
	}
end

function Resurrect:OnLoad(data)
	if data ~= nil and data.cd_time then
		self.cd_time = data.cd_time or 0
		if self.cd_time > 0 then
			self.inst:StartUpdatingComponent(self)
		end
	end 
end

function Resurrect:Effect()
	if self.level > 0 and self.cd_time <= 0 and self.inst:HasTag("playerghost") then
		self.inst:DoTaskInTime(0, function()
			self.inst:PushEvent("respawnfromghost")
			self.inst.rezsource = "复活"
		end)

		self.use = self.use + 1
		self.cd_time = DEFAULT_CD + self.use * USE_STEP
		self.inst:StartUpdatingComponent(self)
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