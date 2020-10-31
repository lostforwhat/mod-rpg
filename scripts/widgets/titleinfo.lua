local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local TitleInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "TitleInfo")
    self.owner = owner

    self.button = self:AddChild(ImageButton("images/inventoryimages.xml", "hivehat.tex"))
    self.button:SetHoverText("称号",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.button:SetOnClick(function() self:OpenTitle() end)

end)

function TitleInfo:OpenTitle()

end

return TitleInfo
