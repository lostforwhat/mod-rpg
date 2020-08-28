local DEFAULT_PERCENT = 0

local function OnCooldown(inst)
    inst._cdtask = nil
end

local function onchance(self, chance)

end

local function oncommon(self, common)

end

local AttackBack = Class(function(self, inst) 
    self.inst = inst
    self.percent = DEFAULT_PERCENT
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
    return self.percent or 0
end

function AttackBack:SetCommon(common)
    if common >= 0 then
        self.common = common
    end
end

function AttackBack:GetCommon()
    return self.common or 0
end


--每次被攻击执行这个函数，若返回true，则执行触发代码
function AttackBack:Effect(damage)
    local effect = self.percent > 0 or self.common > 0
    if effect and self.inst._cdtask == nil then
        --V2C: tiny CD to limit chain reactions
        inst._cdtask = inst:DoTaskInTime(.3, OnCooldown)

        local back_prefab = SpawnPrefab("bramblefx_armor")
        back_prefab.damage = damage * self.percent + self.common
        back_prefab:SetFXOwner(self.inst)
        return true
    end
    return false
end

function AttackBack:OnRemoveFromEntity()
    
end

function AttackBack:OnSave()
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
end


return AttackBack