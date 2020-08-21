local Widget = require "widgets/widget"


local ShopInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "ShopInfo")
    self.owner = owner

    self.wereness = nil
    
end)



return ShopInfo
