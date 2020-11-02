local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local PlayerInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerInfo")
    self.owner = owner

    local image_name = "avatar_"..self.owner.prefab..".tex"
    local atlas_name = "images/avatars/avatar_"..self.owner.prefab..".xml"
    if softresolvefilepath(atlas_name) == nil then
        atlas_name = "images/avatars.xml"
    end
    self.button = self:AddChild(ImageButton(atlas_name, image_name))
    self.button:SetHoverText("个人",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.button:SetOnClick(function() self:ShowInfo() end)

    self.text = self:AddChild(Text(TALKINGFONT, 28))
    self.text:SetPosition(1, -32)
    self.text:SetColour(0, 1, 1, 1)
    
    self.inst:ListenForEvent("leveldirty", function(owner) 
        self.text:SetString("LV "..self:GetLevel()) 
    end, self.owner)
end)

function PlayerInfo:ShowInfo()
    --此处展示个人信息
    if self.owner.HUD.playerdetail == nil then
        self.owner.HUD:ShowPlayerDetail()

    --self.owner.HUD:InspectSelf()
    else
        self.owner.HUD:ClosePlayerDetail()
    end
end

function PlayerInfo:GetLevel()
    return self.owner.components.level and self.owner.components.level.net_data
        and self.owner.components.level.net_data.level:value() or 1
end

return PlayerInfo
