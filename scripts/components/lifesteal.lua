local MAX_PERCENT = 100

local function onpercent(self, percent)

end

local LifeSteal = Class(function(self, inst) 
    self.inst = inst
    self.default = 0
    self.percent = 0
    self.max_percent = MAX_PERCENT
    self.extra_percent = 0
    --self.extra_source_map = nil
end,
nil,
{
	percent = onpercent
})

function LifeSteal:OnSave()
	return {
		percent = self.percent
	}
end

function LifeSteal:SetPercent(val)
    if val > 0 and val < MAX_PERCENT then
        self.percent = val
    end
end

function LifeSteal:GetPercent()
    return self.percent or 0
end

function LifeSteal:AddExtraPercent(source, val)
    if self.extra_source_map == nil then
        self.extra_source_map = {}
    end
    self.extra_source_map[source] = val
    self.extra_percent = 0
    for k, v in pairs(self.extra_source_map) do
        if k and v then
            self.extra_percent = self.extra_percent + v
        end
    end
end

function LifeSteal:RemoveExtraPercent(source)
    if self.extra_source_map ~= nil and self.extra_source_map[source] then
        self.extra_source_map[source] = nil
        self.extra_percent = 0
        for k, v in pairs(self.extra_source_map) do
            if k and v then
                self.extra_percent = self.extra_percent + v
            end
        end
    end
end

function LifeSteal:GetFinalPercent()
    return self.percent + self.extra_percent
end

function LifeSteal:Effect(damage)
    local lifestealnum = damage * self:GetFinalPercent()
    if lifestealnum > 0 and self.inst.components.health ~= nil and
        not self.inst.components.health:IsDead() and not self.inst:HasTag("playerghost") then
        self.inst.components.health:DoDelta(lifestealnum, false, "lifesteal")
    end
end


function LifeSteal:OnRemoveFromEntity()
    
end

return LifeSteal