--Stealth 隐身能力组件,主客机同时需要
local CD_TIME = 25
local TASK_TIME = 5

local function onlevel(self, level)
	self.net_data.level:set(level)
end

local function oncd_time(self, val)
	self.net_data.cd_time:set(val)
end

local function onenabled(self, val)
	self.net_data.enabled:set(val)
end

local function OnAttackOther(inst, data)
	if inst.components.stealth ~= nil then
		inst.components.stealth:End()
	end
end

local Stealth = Class(function(self, inst) 
    self.inst = inst
    self.net_data = {
    	level = net_byte(inst.GUID, "stealth.level"),
    	cd_time = net_float(inst.GUID, "stealth.cd_time", "stealthdirty"),
    	enabled = net_bool(inst.GUID, "stealth.enabled", "stealthdirty")
    }

    self.level = 1

    self.cd_time = 0
    self.task_time = 0
    self.effect = false
    self.enabled = false

    self.handle_key = KEY_R
    self:ClientInit()
end,
nil,
{
	level = onlevel,
	cd_time = oncd_time,
	enabled = onenabled
})

function Stealth:ClientInit()
	--if not TheWorld.ismastersim then
		TheInput:AddKeyUpHandler(self.handle_key, function() 
			if not self.inst:HasTag("player") or self.inst:HasTag("playerghost") or
				(self.inst and self.inst.HUD and self.inst.HUD.IsChatInputScreenOpen()) then return end
			if not self.net_data.enabled:value() or self.net_data.cd_time:value() > 0 then return end
			SendModRPCToServer(MOD_RPC.RPG_skill.stealth)
		end)
	--end
end

function Stealth:Enabled(enabled)
	self.enabled = enabled == true
end

function Stealth:Effect()
	local inst = self.inst
	if inst:HasTag("playerghost") or (inst.components.freezable and inst.components.freezable:IsFrozen()) then
		return
	end
	if not inst:HasTag("player") then
		inst:Hide()
	end
	inst:AddTag("shadow")
	if inst.SoundEmitter ~= nil then
    	inst.SoundEmitter:PlaySound("dontstarve/common/staffteleport")
   	end
   	if inst.components.colourtweener == nil then
   		inst:AddComponent("colourtweener")
   	end
   	inst.components.colourtweener:StartTween({0.3,0.3,0.3,1}, 0)
   	local x, y, z = inst.Transform:GetWorldPosition()
   	local ents = TheSim:FindEntities(x,y,z, 30, nil,nil, {"monster","animal","flying","crazy","epic"})
    for k,v in pairs(ents) do
        if v.components.combat and v.components.combat:TargetIs(inst) then
            v.components.combat:DropTarget()
        end
    end
    if inst.components.crit ~= nil then
    	inst.components.crit.next_must_crit = true
    end
    self.cd_time = CD_TIME
    self.task_time = TASK_TIME + self.level
    self.effect = true
    inst:StartUpdatingComponent(self)
    inst:ListenForEvent("onattackother", OnAttackOther)
end

function Stealth:End()
	local inst = self.inst
	inst:Show()
    inst:RemoveTag("shadow")
    inst.components.colourtweener:StartTween({1,1,1,1}, 0)
    if inst.components.crit ~= nil then
    	inst.components.crit.next_must_crit = false
    end
    self.task_time = 0
    inst:RemoveEventCallback("onattackother", OnAttackOther)
end

function Stealth:OnUpdate(dt)
	local inst = self.inst
    if self.task_time > 0 then
        self.task_time = self.task_time - dt
        
    else
        if self.effect then
            self:End()
        end
    end
    if self.cd_time > 0 then
        self.cd_time = self.cd_time - dt
    else
    	self.cd_time = 0
        inst:StopUpdatingComponent(self)
    end
end

function Stealth:OnSave()
	return {
		cd_time = self.cd_time or 0,
		enabled = self.enabled or false
	}
end

function Stealth:OnLoad(data)
	if data ~= nil then
		self.cd_time = data.cd_time or 0
		self.enabled = data.enabled or false
	end
end

return Stealth