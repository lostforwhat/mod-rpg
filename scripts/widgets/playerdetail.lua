local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local TEMPLATES = require "widgets/templates"
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
end

function PlayerDetail:Close()
    self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
end

return PlayerDetail