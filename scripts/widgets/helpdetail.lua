require "utils/utils"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/templates"
local TEMPLATES2 = require "widgets/redux/templates"

local DEFAULT_TEXT = [[
新手指引:
1.左上角各图标可查看人物信息，任务完成状况，网络商店
2.右下角木牌可选择其他世界，需靠近大门或洞穴口
3.更换人物数据不保留，有需要的建议前期更换
4.猪王(鱼人王)可接取收集任务
5.龙鳞火炉可进行武器熔炼
6.此提示将在生存10天后关闭，可使用#help指令呼出
]]

local HelpDetail = Class(Widget, function(self, owner)
    Widget._ctor(self, "HelpDetail")

    self.owner = owner
    
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetPosition(0, 0)

    
    self:Layout()

    self.inst:ListenForEvent("helpdirty", function()
        
    end, self.owner)
    
end)



function HelpDetail:Layout()
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(260, 200, .6, .6, 39, -25))
    self.frame:SetPosition(0, 0)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_small.tex"))
    self.frame_bg:SetScale(.6, .52)
    self.frame_bg:SetPosition(5, 7)
    self.frame:SetTint(0.8, 0.8, 0.8, 0.8)
    self.frame_bg:SetTint(0.8, 0.8, 0.8, 0.8)

    self.close_button = self.proot:AddChild(TEMPLATES.SmallButton("关闭", 26, .5, function() self.owner.HUD:CloseHelpDetail() end))
    self.close_button:SetPosition(0, -120)

    self:SetContent()

    local w, h = self.frame_bg:GetSize()

    self.out_pos = Vector3(0, .5 * h, 0)
    self.in_pos = Vector3(0, -.55 * h, 0)

    self:MoveTo(self.out_pos, self.in_pos, .33, function()  end)
end

function HelpDetail:SetContent()
    self.text = self.frame_bg:AddChild(Text(BODYTEXTFONT, 45, "", {0.1, 0.9, 0.55, 1}))
    self.text:SetPosition(0, 10)
    self.text:SetRegionSize(700, 480)
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetVAlign(ANCHOR_MIDDLE)

    local str = TheWorld.net._help_text and TheWorld.net._help_text:value() or ""
    str = str ~= "" and str or DEFAULT_TEXT 
    self.text:SetMultilineTruncatedString(str, 7, 700, 28, "...", false)
end

function HelpDetail:Close()
    self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
end

function HelpDetail:OnGainFocus()
    self.camera_controllable_reset = TheCamera:IsControllable()
    TheCamera:SetControllable(false)
end

function HelpDetail:OnLoseFocus()
    TheCamera:SetControllable(self.camera_controllable_reset == true)
end

return HelpDetail