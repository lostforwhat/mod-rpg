local MAX_DAMAGE = 10

local Revenge = Class(function(self, inst) 
    self.inst = inst
    self.damage_percent = 0
    self.max_damage = MAX_DAMAGE
    self.revenge_data = {}
    self.last_attacker = nil
end,
nil,
{
    
})

function Revenge:SetPercent(percent)
    self.damage_percent = percent
end

function Revenge:GetDamageUp(attacker)
    if attacker ~= nil then
        local hit = self.revenge_data[attacker] or 0
        return math.min(hit * self.damage_percent * 0.01, self.max_damage)
    end
    return 0
end

function Revenge:Onattcked(attacker)
    if attacker ~= nil and self.damage_percent > 0 then
        if self.revenge_data[attacker] == nil then
            self.revenge_data[attacker] = 1
        else
            self.revenge_data[attacker] = self.revenge_data[attacker] + 1
        end
        self.last_attacker = attacker
        self:Check()
    end
end

function Revenge:Check()
    for k,v in pairs(self.revenge_data) do
        if k == nil or not k:IsValid() or k == self.last_attacker or not k:IsNear(self.inst, 30) then
            self.revenge_data[k] = nil
        end
    end
end


function Revenge:OnRemoveFromEntity()
    
end

function Revenge:OnSave()
    return {
        
    }
end

function Revenge:OnLoad(data)
    if data ~= nil then
        
    end
end


return Revenge