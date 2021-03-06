local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local Help = Class(Widget, function(self, owner)
    Widget._ctor(self, "Help")
    self.owner = owner

    self.button = self:AddChild(ImageButton("images/hud/help.xml", "help.tex"))
    self.button:SetHoverText("帮助",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,0,1,1}})
    self.button:SetOnClick(function() self:ToggleHelpDetail() end)


    self.inst:ListenForEvent("clocktick", function()
        if self.shown and self.owner.Network:GetPlayerAge() > 10 then
            self:Hide()
        end
    end, TheWorld)

    self.inst:ListenForEvent("_showhelp", function() 
        self.owner.HUD:ShowHelpDetail()
    end, self.owner)

    if self.owner.Network:GetPlayerAge() < 10 then
        self:Show()
    else
        self:Hide()
    end
end)


function Help:ToggleHelpDetail()
    if self.owner.HUD.helpdetail ~= nil then
        self.owner.HUD:CloseHelpDetail()
    else
        self.owner.HUD:ShowHelpDetail()
    end
end


return Help
