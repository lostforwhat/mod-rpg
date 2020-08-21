local Widget = require "widgets/widget"


local TitleInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "TitleInfo")
    self.owner = owner

    self.wereness = nil
    
end)



return TitleInfo
