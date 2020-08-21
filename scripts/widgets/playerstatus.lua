local Widget = require "widgets/widget"
local PlayerInfo = require "widgets/playerinfo"
local TaskInfo = require "widgets/taskinfo"
local TitleInfo = require "widgets/titleinfo"
local ShopInfo = require "widgets/shopinfo"



local PlayerStatus = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerStatus")
    self.owner = owner

    self.player_info = self:AddChild(PlayerInfo(owner))
    self.player_info:SetPosition(0, -40, 0)

    self.task_info = self:AddChild(TaskInfo(owner))
    self.task_info:SetPosition(40, -40, 0)

    self.title_info = self:AddChild(TitleInfo(owner))
    self.title_info:SetPosition(80, -40, 0)

    self.shop_info = self:AddChild(ShopInfo(owner))
    self.shop_info:SetPosition(120, -40, 0)

    
end)



return PlayerStatus
