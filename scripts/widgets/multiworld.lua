local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local MultiWorld = Class(Widget, function(self, owner)
    Widget._ctor(self, "MultiWorld")
    self.owner = owner

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0, 0)

    self.current = self.root:AddChild(ImageButton("images/achiv_clear.xml", "achiv_clear.tex"))
    self.current.text = self.current:AddChild(Text(TALKINGFONT, 28, "", {0, 1, 0, 1}))
    self.current:SetOnClick(function() self:ToggleInfo() end)

    self.info_out_pos = Vector3(.5 * w, 0, 0)
    self.info_in_pos = Vector3(-.95 * w, 0, 0)
    
    self:Hide()
end)

function MultiWorld:ToggleInfo()
    if self.info ~= nil then
        self.info:MoveTo(self.info_in_pos, self.info_out_pos, .33, function() self:CloseInfo() end)
    else
        self:ShowInfo()
    end
end

function MultiWorld:CloseInfo()
    self.info:Kill()
    self.info = nil
end

function MultiWorld:ShowInfo()
    self.info = self.root:AddChild(Widget("Info"))
    self.info.inst:ListenForEvent("worldsharddatadirty", function() 
        self:SetWorldList()
    end, TheWorld.net)
    self:SetWorldList()
    self.info:MoveTo(self.info_out_pos, self.info_in_pos, .33, function() end)
end

function MultiWorld:SetWorldList()
    local sharddata = TheWorld.net.components.sharddata:Get() or {}
    for k, v in pairs(sharddata) do
        
    end
end

return MultiWorld
