local Widget = require "widgets/widget"
local PlayerInfo = require "widgets/playerinfo"
local TaskInfo = require "widgets/taskinfo"
local TitleInfo = require "widgets/titleinfo"
local ShopInfo = require "widgets/shopinfo"
local Email = require "widgets/email"



local PlayerStatus = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerStatus")
    self.owner = owner

    self.player_info = self:AddChild(PlayerInfo(owner))
    self.player_info:SetPosition(40, -40)
    self.player_info:SetScale(0.6,0.6)

    self.task_info = self:AddChild(TaskInfo(owner))
    self.task_info:SetPosition(80, -40)
    self.task_info:SetScale(0.6,0.6)

    --self.title_info = self:AddChild(TitleInfo(owner))
    --self.title_info:SetPosition(120, -40, 0)
    --self.title_info:SetScale(0.6,0.6,1)

    self.shop_info = self:AddChild(ShopInfo(owner))
    self.shop_info:SetPosition(120, -40)
    self.shop_info:SetScale(0.6,0.6)

    self.email = self:AddChild(Email(owner))
    self.email:SetPosition(170, -40)
    self.email:SetScale(0.5,0.5)
end)



return PlayerStatus
