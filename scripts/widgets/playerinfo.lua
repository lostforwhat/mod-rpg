local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local PlayerInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerInfo")
    self.owner = owner

    self.button = self:AddChild(ImageButton("images/hud/levelbadge.xml", "levelbadge.tex"))
    self.button:SetHoverText("个人",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.button:SetOnClick(function() self:ShowInfo() end)

    self.text = self:AddChild(Text(TALKINGFONT, 28))
    self.text:SetPosition(0, -85, 0)

    self.wereness = nil
    
end)

function PlayerInfo:ShowInfo()

end


return PlayerInfo
