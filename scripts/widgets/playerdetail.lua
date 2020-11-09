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
local EquipSlot = require("equipslotutil")

local PlayerDetail = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerDetail")

    self.owner = owner
    
    self.targetmovetime = TheInput:ControllerAttached() and .5 or .75
    self.started = false
    self.settled = false
    
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetPosition(335, 0)

    self:Layout()
    
end)

function PlayerDetail:SetPlayerData()
    local options = {
        { text = "个人信息", data = 1 },
        { text = "称号", data = 2 }
    }
    self.top_nav = self.proot:AddChild(TEMPLATES.LabelSpinner("", options, 0, 160, 50, 20, NEWFONT, 30, -10))
    self.top_nav:SetPosition(0, 268)
    self.top_nav.spinner:SetTextColour(1,0.4,0.35,1)
    self.top_nav.spinner:SetOnChangedFn(function(selected, old) 
        if selected == 1 then
            self.top_nav.spinner:SetTextColour(1,0.4,0.35,1)
        else
            self.top_nav.spinner:SetTextColour(0.5,0.35,0.18,1)
        end
    end)
    


end

function PlayerDetail:Layout()
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(130, 540, .6, .6, 39, -25))
    self.frame:SetPosition(0, 20)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.frame_bg:SetScale(.51, .74)
    self.frame_bg:SetPosition(5, 7)


    local w, h = self.frame_bg:GetSize()

    self.out_pos = Vector3(.5 * w, 0, 0)
    self.in_pos = Vector3(-.95 * w, 0, 0)

    self:MoveTo(self.out_pos, self.in_pos, .33, function()  end)

    self:SetPlayerData()

    self.close_button = self.proot:AddChild(TEMPLATES.SmallButton(STRINGS.UI.PLAYER_AVATAR.CLOSE, 26, .5, function() 
        self.owner.HUD:ClosePlayerDetail()
    end))
    self.close_button:SetPosition(0, -269)
end

function PlayerDetail:Close()
    self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
end

return PlayerDetail