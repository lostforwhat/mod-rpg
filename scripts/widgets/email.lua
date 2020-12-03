local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local Email = Class(Widget, function(self, owner)
    Widget._ctor(self, "Email")
    self.owner = owner

    self.button = self:AddChild(ImageButton("images/hud/email.xml", "email.tex"))
    self.button:SetHoverText("邮件",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.button:SetOnClick(function() self:ToggleEmailDetail() end)

    self.text = self:AddChild(Text(TALKINGFONT, 28))
    self.text:SetPosition(0, -85, 0)
   	--self:OnShow()

    self.inst:ListenForEvent("continuefrompause", function()
        if self.shown then
            --self:OnShow()
        end
    end, TheWorld)

    self:Hide()
    self:CheckEmail()
    
end)

function Email:CheckEmail()
    self.inst:ListenForEvent("hasemaildirty", function() 
        if self.owner.components.email:HasEmail() then
            self:Show()
        else
            self:Hide()
        end
    end, self.owner)
end

function Email:ToggleEmailDetail()
    if self.owner.HUD.emaildetail ~= nil then
        self.owner.HUD:CloseEmailDetail()
    else
        self.owner.HUD:ShowEmailDetail()
    end
end


return Email
