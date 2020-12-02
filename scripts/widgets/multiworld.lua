require 'util'

local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local Text = require "widgets/text"
local TEMPLATES2 = require "widgets/redux/templates"

local function GetLength(tab)
    local count = 0
    if type( tab ) ~= "table" then
        return 0
    end
    for k, v in pairs( tab ) do
        count = count + 1
    end
    return count
end

local TIMEOUT = 5

local MultiWorld = Class(Widget, function(self)
    Widget._ctor(self, "MultiWorld")
    --self.owner = owner

    self.root = self:AddChild(Widget("ROOT"))
    self.root:SetPosition(0, 0)

    self.current = self.root:AddChild(ImageButton("minimap/minimap_data.xml", "sign.png"))
    self.current.text = self.root:AddChild(Text(NUMBERFONT, 28, "", {0, 1, 0, .7}))
    self.current:SetOnClick(function() self:ToggleInfo() end)
    self.current.inst:ListenForEvent("worldsharddatadirty", function() 
        self:SetCurrentWorld()
    end, TheWorld.net)
    self.worldId = TheWorld.net.components.sharddata:GetId() or 0
    self.current:SetHoverText("世界"..self.worldId,{ size = 9, offset_x = 10, offset_y = 30, colour = {1,1,1,1}})
    self.current:SetOnGainFocus(function() 
        self.current.text:SetColour({0, 1, 0, .7})
    end)
    self.current:SetOnLoseFocus(function()
        self.current.text:SetColour({0, 1, 0, .7})
    end)
    self:SetCurrentWorld()
    --local w, h = self.info:GetSize()
    self.info_out_pos = Vector3(0, 0, 0)
    self.info_in_pos = Vector3(0, 0, 0)
    
    self.timeout = TIMEOUT
    --self:Hide()
end)

function MultiWorld:SetCurrentWorld()
    local sharddata = TheWorld.net.components.sharddata:Get() or {}
    local data = sharddata[self.worldId]
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
    self:StopUpdating()
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
    self.timeout = TIMEOUT
    self:StartUpdating()
end

function MultiWorld:SetWorldList()
    local btn_width, btn_height = 80, 60
    local offset = 10
    local sharddata = TheWorld.net.components.sharddata:Get() or {}
    local total = GetLength(sharddata)
    self.worldlist = {}

    local panel_width, panel_height = (btn_width + offset) * total - offset, btn_height
    self.worldpanel = self.info:AddChild(TEMPLATES2.RectangleWindow(panel_width, panel_height))
    
    local index = 1
    for _id, data in orderedPairs(sharddata) do
        --if _id ~= TheShard:GetShardId() then -- 客户端无法获取shardid
            local str = (data.name or ("世界".._id)).."\n"..(data.players or 0).."/"..(data.maxplayers or 0)
            self.worldlist[_id] = self.worldpanel:AddChild(TEMPLATES2.StandardButton(function() 
                SendModRPCToServer(MOD_RPC.RPG_worldpicker.migrate, _id)
            end, str, {btn_width, btn_height}))
            self.worldlist[_id]:SetPosition(btn_width * 0.5 - panel_width * 0.5 + (btn_width + offset) * (index - 1), 0)
            index = index + 1
        --end
    end

    self.info_out_pos = Vector3(panel_width * 0.5 + 200, 80, 0)
    self.info_in_pos = Vector3(-panel_width * .8, 80, 0)
end

function MultiWorld:OnUpdate(dt)
    if self.focus then
        self.timeout = TIMEOUT
    else
        self.timeout = self.timeout - dt
    end
    if self.timeout <= 0 then
        self:CloseInfo()
    end
end

return MultiWorld
