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

function Rejectdeath:OnSave()
    return {
        cd_time = self.cd_time or 0
    }
end

function Rejectdeath:OnLoad(data)
    if data ~= nil then
        self.cd_time = data.cd_time or 0
        if self.cd_time > 0 then
            self.inst:StartUpdatingComponent(self)
        end
    end
end

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
        for k=1, 10 do
            inst:DoTaskInTime(k*.5, function(inst) 
                local maxhealth = inst.components.health.maxhealth or 0
                inst.components.health:DoDelta(maxhealth * 0.05, nil, nil, true)
            end)
        end
    end
end

function Rejectdeath:OnUpdate(dt)
    local inst = self.inst
    if self.task_time > 0 then
        self.task_time = self.task_time - dt
        if inst._fx ~= nil then
            local t = self.task_time * 0.2
            inst._fx.AnimState:SetMultColour(t, t, t, t)
        end
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