local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local TaskInfo = Class(Widget, function(self, owner)
    Widget._ctor(self, "TaskInfo")
    self.owner = owner

    self.button = self:AddChild(ImageButton("images/inventoryimages1.xml", "chesspiece_anchor_sketch.tex"))
    self.button:SetHoverText("任务",{ size = 9, offset_x = 40, offset_y = -45, colour = {1,1,1,1}})
    self.button:SetOnClick(function() self:ShowInfo() end)

    self.text = self:AddChild(Text(TALKINGFONT, 28))
    self.text:SetPosition(0, -85, 0)

    self.wereness = nil
    
end)

function TaskInfo:ShowInfo()
	if self.owner and self.owner.HUD then
		self.owner.HUD:ShowTaskScreen(self.inst)
	end
end

return TaskInfo
