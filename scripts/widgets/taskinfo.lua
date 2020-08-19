local Widget = require "widgets/widget"


local TaskInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "TaskInfo")
    self.owner = owner

    self.wereness = nil
    
end)



return TaskInfo
