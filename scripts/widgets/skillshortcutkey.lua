--require "modmain/skill_constant"
require "modmain/suit_data"

local Widget = require "widgets/widget"
local Text = require "widgets/text"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"

local skills_key = {
    "resurrect",
    "rejectdeath",
    "stealth",
}

local skills_name = {
	resurrect = "复活",
    rejectdeath = "回光返照",
    stealth = "伪装",
}

local function GetLength(tab)
    local count = 0
    if type( tab ) ~= "table" then
        return 0
    end
    for k, v in pairs( tab ) do
        count = count + 1
    end
    return count
end

local SkillShortCutKey = Class(Widget, function(self, owner)
    Widget._ctor(self, "SkillShortCutKey")
    self.owner = owner

    self.root = self:AddChild(Widget("skillroot"))

    self.skills = {}

    self.inst:ListenForEvent("_skillsupdate", function() self:UpdateSkills() end, self.owner)
    self.inst:ListenForEvent("_skillsupdatecd", function() self:UpdateSkillsCd() end, self.owner)
    self.inst:DoTaskInTime(.1, function()
        self:InitKey()
        self:InitSuit()
    end)
end)

--[[function SkillShortCutKey:UpdateTooltips()
    local controller_id = TheInput:GetControllerID()
    --local key = tostring(TheInput:GetLocalizedControl(controller_id, handle_key))
end]]

function SkillShortCutKey:InitKey()
	self.skills = self.owner.player_classified:GetSkills()
	for k, v in pairs(self.skills) do
		if v ~= nil and v.key ~= nil then
			TheInput:AddKeyUpHandler(v.key, function() 
	            if not self.owner:HasTag("player") or 
	                self.owner:HasTag("playerghost") or
	                (self.owner and self.owner.HUD and 
	                   self.owner.HUD:HasInputFocus()) then return end
	            if self.skills[k].level <= 0 or self.skills[k].cd > 0 then return end
	            SendModRPCToServer(MOD_RPC.RPG_skill[k])
	        end)
		end
	end
end

function SkillShortCutKey:UpdateSkillsCd()
    local skills = self.owner.player_classified:GetSkills()
    for k, v in pairs(skills) do
    	if self.skill_btns ~= nil and self.skill_btns[k] ~= nil and self.skill_btns[k].cd ~= nil then
    		if v.cd ~= nil and v.cd > 0 then
    			self.skill_btns[k].cd:SetString(math.floor(v.cd))
    			self.skill_btns[k].cd:Show()
    		else
    			self.skill_btns[k].cd:Hide()
    		end
            local name = skills_name[k] or "no name"
            local level = v.level
            self.skill_btns[k]:SetTooltip(name.." Lv"..level.."\n".."cd:"..(v.cd > 0 and math.floor(v.cd) or "就绪"))
    	end
    end
end

function SkillShortCutKey:UpdateSkills()
    --包含快捷键的技能组件
    --self.inst:DoTaskInTime(0.1, function() 
        self.skills = self.owner.player_classified:GetSkills()
        self:ReLayout()
    --end)
end

function SkillShortCutKey:ReLayout()
    local controller_id = TheInput:GetControllerID()

    self.root:KillAllChildren()
    self.skill_btns = {}

    local width, height = 32, 32
    local offset = 10
    for _, v in pairs(skills_key) do
        if self.skills[v] ~= nil and self.skills[v].level > 0 then
            --local name = STRINGS.NAMES.SKILLS[v] or "none"
            local name = skills_name[v] or "no name"
            local level = self.skills[v].level
            local cd = math.floor(self.skills[v].cd)
            local handle_key = self.skills[v].key

            --有快捷键时，获取快捷键
            if handle_key ~= nil then
                --[[local key = tostring(TheInput:GetLocalizedControl(controller_id, handle_key))
                if key ~= nil then
                    name = name.."("..key..")"
                end]]
            end

            local atlas = "images/skills/"..v..".xml"
            local tex = v..".tex"
            local btn = self.root:AddChild(ImageButton(atlas, tex))
            btn:SetPosition((GetLength(self.skill_btns) - 12) * (width + offset), 0)
            btn:SetScale(0.5, 0.5)
            btn:SetTooltip(name.." Lv"..level.."\n".."cd:"..(cd > 0 and cd or "就绪"))
            btn.cd = btn:AddChild(Text(NUMBERFONT, 40, cd))
            if cd <= 0 then
            	btn.cd:Hide()
            else
            	btn.cd:Show()
            end

            btn:SetOnClick(function() 
            	if self.skills[v].level <= 0 or self.skills[v].cd > 0 or self.skills[v].passive then return end
	            SendModRPCToServer(MOD_RPC.RPG_skill[v])
            end)
            --table.insert(self.skill_btns, btn)
            self.skill_btns[v] = btn
        end
    end

end

function SkillShortCutKey:InitSuit()
    --suit
    self.suit = self.root:AddChild(ImageButton("images/skills/suit.xml", "suit.tex"))
    self.suit:SetPosition(-462, 42)
    self.suit:SetScale(.5, .5)
    self.suit:SetTooltipColour(0.1, 1, 0.2, 1)
    self.suit:Hide()

    self.suit.inst:ListenForEvent("_suitdirty", function() 
        self:UpdateSuit()
    end, self.owner)
end

function SkillShortCutKey:UpdateSuit()
    if self.owner.player_classified ~= nil and 
        self.owner.player_classified._suit:value() ~= nil and 
        self.owner.player_classified._suit:value() > 0 then

        local index = self.owner.player_classified._suit:value()
        local name = suit_data[index].name
        local desc = suit_data[index].desc
        self.suit:SetTooltip("套装:"..name.."\n"..desc)
        self.suit:Show()
    else
        self.suit:Hide()
    end
end

return SkillShortCutKey
