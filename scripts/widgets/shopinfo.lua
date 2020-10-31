local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Button = require "widgets/button"
local TEMPLATES = require "widgets/redux/templates"

local ShopInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "ShopInfo")
    self.owner = owner

    self.root = self:AddChild(Button())
    self.root:SetHoverText("商店",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.root:SetOnClick(function() self:OpenShop() end)

    self.image = self.root:AddChild(Image("images/hud.xml", "tab_refine.tex"))
    self.image:SetPosition(0, 0)
    self.image:SetScale(0.67)
    self.image:MoveToBack()
    
    self.text = self.root:AddChild(Text(BODYTEXTFONT, 35))
    self.text:SetPosition(10, 0)
    self.text:SetColour(0,1,1,1)
    self.text:SetString(self:GetCoin())

    self.inst:ListenForEvent("coindirty", function(owner) 
    	self.text:SetString(self:GetCoin()) 
    end, self.owner)

end)

function ShopInfo:GetCoin()
	local taskdata = self.owner.components.taskdata
	if taskdata and taskdata.net_data then
		return taskdata.net_data.coin:value() or 0
	end
	return 0
end

function ShopInfo:OpenShop()

end

return ShopInfo
