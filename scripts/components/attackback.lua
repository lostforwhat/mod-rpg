local DEFAULT_PERCENT = 0

local function OnCooldown(inst)
    inst._cdtask = nil
end

local function onpercent(self, percent)
    self.net_data.percent:set(percent)
end

local function oncommon(self, common)
    self.net_data.common:set(common)
end

local AttackBack = Class(function(self, inst) 
    self.inst = inst

    self.net_data = {
        percent = net_byte(inst.GUID, "attackback.percent", "attackbackdirty"),
        common = net_shortint(inst.GUID, "attackback.common", "attackbackdirty")
    }

    self.percent = DEFAULT_PERCENT --0~100
    self.common = 0 --固定反伤值
end,
nil,
{
    percent = onpercent,
    common = oncommon
})

function AttackBack:SetPercent(percent)
    if percent >= 0 then
        self.percent = percent
    end
end

function AttackBack:GetPercent()
    return self.net_data.percent:value() or self.percent or 0
end

function AttackBack:SetCommon(common)
    if common >= 0 then
        self.common = common
    end
end


function AttackBack:GetCommon()
    return self.net_data.common:value() or self.common or 0
end


--每次被攻击执行这个函数，若返回true，则执行触发代码
function AttackBack:Effect(damage)
    local effect = self.percent > 0 or self.common > 0
    if effect and self.inst._cdtask == nil then
        --V2C: tiny CD to limit chain reactions
        self.inst._cdtask = self.inst:DoTaskInTime(.3, OnCooldown)

        local back_prefab = SpawnPrefab("bramblefx_armor")
        back_prefab.damage = damage * self.percent *0.01 + self.common
        back_prefab:SetFXOwner(self.inst)
        return true
    end
    return false
end

function AttackBack:Get()
    if TheWorld.ismastersim then
        return self.percent, self.common
    else
        return self.net_data.percent:value(), self.net_data.common:value()
    end
end

function AttackBack:OnRemoveFromEntity()
    
end

--[[function AttackBack:OnSave()
    return {
        percent = self.percent,
        common = self.common
    }
end

function AttackBack:OnLoad(data)
    if data ~= nil then
        self.percent = data.percent or DEFAULT_PERCENT
        self.common = data.common or 0
    end
end]]


return AttackBack