local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"


local PlayerInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerInfo")
    self.owner = owner

    self.wereness = nil
    
end)



return PlayerInfo
