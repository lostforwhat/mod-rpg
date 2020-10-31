local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local PlayerInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerInfo")
    self.owner = owner

    local image_name = "avatar_"..self.owner.prefab..".tex"
    local atlas_name = "images/avatars.xml"
    self.button = self:AddChild(ImageButton(atlas_name, image_name))
    self.button:SetHoverText("个人",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.button:SetOnClick(function() self:ShowInfo() end)

    self.text = self:AddChild(Text(TALKINGFONT, 28))
    self.text:SetPosition(0, -85, 0)

    self.wereness = nil
    
end)

function PlayerInfo:ShowInfo()

    self.owner.HUD:InspectSelf()
end


return PlayerInfo
