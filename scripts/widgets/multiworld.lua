local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"


local MultiWorld = Class(Widget, function(self)
    Widget._ctor(self, "MultiWorld")
    --self.owner = owner

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0, 0)

    self.current = self.root:AddChild(ImageButton("minimap/minimap_data.xml", "sign.png"))
    self.current.text = self.root:AddChild(Text(TALKINGFONT, 28, "", {0, 1, 0, 1}))
    self.current:SetOnClick(function() self:ToggleInfo() end)
    self.current.inst:ListenForEvent("worldsharddatadirty", function() 
        self:SetCurrentWorld()
    end, TheWorld.net)
    self.current:SetHoverText("世界",{ size = 9, offset_x = 10, offset_y = 20, colour = {1,1,1,1}})
    self.current.text:MoveToFront()
    self:SetCurrentWorld()
    --local w, h = self.info:GetSize()
    self.info_out_pos = Vector3(0, 0, 0)
    self.info_in_pos = Vector3(0, 0, 0)
    
    --self:Hide()
end)

function MultiWorld:SetCurrentWorld()
    local worldId = TheShard:GetShardId()
    local sharddata = TheWorld.net.components.sharddata:Get() or {}
    local data = sharddata[worldId]
    if data ~= nil then
        self.current.text:SetString(data.players.."/"..data.maxplayers)
    end
end

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
    for _id, data in pairs(sharddata) do
        
    end
end

return MultiWorld
