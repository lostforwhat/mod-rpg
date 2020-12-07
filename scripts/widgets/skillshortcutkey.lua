local Widget = require "widgets/widget"



local SkillShortCutKey = Class(Widget, function(self, owner)
    Widget._ctor(self, "SkillShortCutKey")
    self.owner = owner

    
end)



return SkillShortCutKey
