require "modmain/skill_constant"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local skills_key = {
    "resurrect",
    "rejectdeath",
    "stealth",
}

local SkillShortCutKey = Class(Widget, function(self, owner)
    Widget._ctor(self, "SkillShortCutKey")
    self.owner = owner

    self.root = self:AddChild(Widget("skillroot"))

    self.skills = {}
    self.inst:ListenForEvent("_skillsupdate", function() self:UpdateSkills() end, self.owner.player_skills_classified)
    self.inst:ListenForEvent("_skillsupdatecd", function() self:UpdateSkillsCd() end, self.owner.player_skills_classified)
end)

--[[function SkillShortCutKey:UpdateTooltips()
    local controller_id = TheInput:GetControllerID()
    --local key = tostring(TheInput:GetLocalizedControl(controller_id, handle_key))
end]]

function SkillShortCutKey:UpdateSkillsCd()
    local skills = self.owner.player_skills_classified:GetSkills()

end

function SkillShortCutKey:UpdateSkills()
    --包含快捷键的技能组件
    --self.inst:DoTaskInTime(0.1, function() 
        self.skills = self.owner.player_skills_classified:GetSkills()
        self:ReLayout()
    --end)
end

function SkillShortCutKey:ReLayout()
    local controller_id = TheInput:GetControllerID()

    self.skill_btns = {}

    local width, height = 32, 32
    local offset = 10
    for _, v in pairs(skills_key) do
        if self.skills[v] ~= nil and self.skills[v].level > 0 then
            local name = STRINGS.NAMES.SKILLS[v] or "none"
            local level = self.skills[v].level
            local cd = self.skills[v].cd
            local handle_key = self.skills[v].key

            --有快捷键时，获取快捷键
            if handle_key ~= nil then
                local key = tostring(TheInput:GetLocalizedControl(controller_id, handle_key))
                if key ~= nil then
                    name = name.."("..key..")"
                end
            end

            local atlas = "images/skills/"..v..".xml"
            local tex = v..".tex"
            local btn = self.root:AddChild(ImageButton(atlas, tex))
            btn:SetPosition((#self.skill_btns - 10) * (width + offset), 0)
            btn:SetScale(0.5, 0.5)
            btn:SetTooltip(name.."\n Lv"..level.."\n".."cd:"..cd)
            btn.cd = btn:AddChild(Text(NUMBERFONT, 40, cd))
            --table.insert(self.skill_btns, btn)
            self.skill_btns[v] = btn
        end
    end
end

return SkillShortCutKey
