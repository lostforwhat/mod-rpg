local CD_TIME = 300
local TASK_TIME = 5

local function OnMinHealth(inst, data)
    if inst.components.rejectdeath then
        inst.components.rejectdeath:OnMinHealth()
    end
end

--回光返照
local Rejectdeath = Class(function(self, inst) 
    self.inst = inst
    self.level = 1

    self.cd_time = 0
    self.task_time = 0
    self.effect = false

    self.inst:ListenForEvent("minhealth", OnMinHealth)
end)

function Rejectdeath:OnMinHealth()
    if self.cd_time <= 0 then
        local inst = self.inst
        inst.components.health.currenthealth = 1
        inst.components.health:SetInvincible(true)
        if inst._fx ~= nil then
            inst._fx:kill_fx()
        end
        inst._fx = SpawnPrefab("forcefieldfx")
        inst._fx.entity:SetParent(inst.entity)
        inst._fx.Transform:SetPosition(0, 0.2, 0)
        if inst.SoundEmitter ~= nil then
            inst.SoundEmitter:PlaySound("dontstarve/common/lava_arena/spawn")
        end
        self.task_time = TASK_TIME
        self.cd_time = CD_TIME
        self.effect = true
        inst:StartUpdatingComponent(self)
    end
end

function Rejectdeath:OnUpdate(dt)
    local inst = self.inst
    if self.task_time > 0 then
        self.task_time = self.task_time - dt
        local maxhealth = inst.components.health.maxhealth or 0
        inst.components.health:DoDelta(maxhealth * 0.1)
    else
        if self.effect then
            if inst._fx ~= nil then
                inst._fx:kill_fx()
                inst._fx = nil
            end
            inst.components.health:SetInvincible(false)
            self.effect = false
        end
    end
    if self.cd_time > 0 then
        self.cd_time = self.cd_time - dt
    else
        inst:StopUpdatingComponent(self)
    end
end

function Rejectdeath:OnRemoveFromEntity()
    self.inst:RemoveEventCallback("minhealth", OnMinHealth)
end

return Rejectdeath