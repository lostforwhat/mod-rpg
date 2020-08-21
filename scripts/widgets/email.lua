local Widget = require "widgets/widget"


local Email = Class(Widget, function(self, owner)
    Widget._ctor(self, "Email")
    self.owner = owner

    self.button = self:AddChild(ImageButton("images/hud/email.xml", "email.tex"))
    self.button:SetHoverText("邮件",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.button:SetOnClick(function() self:DoRecievedEmail() end)

    self.text = self:AddChild(Text(TALKINGFONT, 28))
    self.text:SetPosition(0, -85, 0)
   	self:OnShow()

    self.inst:ListenForEvent("continuefrompause", function()
        if self.shown then
            self:OnShow()
        end
    end, TheWorld)
    
end)

function Email:DoRecievedEmail()

end

function Email:OnShow()

end


return Email
