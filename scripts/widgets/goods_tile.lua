local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local DEFAULT_ATLAS = "images/inventoryimages1.xml"
local DEFAULT_ATLAS2 = "images/inventoryimages2.xml"

local function GetDescriptionString(name)
    local str = ""
    if name ~= nil and name ~= "" then
        local itemtip = string.upper(TrimString( name ))
        if STRINGS.NAMES[itemtip] ~= nil and STRINGS.NAMES[itemtip] ~= "" then
            str = STRINGS.NAMES[itemtip]
        end
    end
    return str
end

local GoodsTile = Class(Widget, function(self, name)
	Widget._ctor(self, "GoodsTile")
	self.name = name
	local atlas = softresolvefilepath("images/inventoryimages/"..name..".xml") 
        or softresolvefilepath("images/"..name..".xml") or DEFAULT_ATLAS
    local image = name .. ".tex"
    atlas = TheSim:AtlasContains(atlas, image) and atlas or (TheSim:AtlasContains(DEFAULT_ATLAS2, image) and DEFAULT_ATLAS2)

	self.image = self:AddChild(Image(atlas, image, "chesspiece_anchor_sketch.tex"))

end)

--[[
function GoodsTile:OnControl(control, down)
	self:UpdateTooltip()
	return false
end

function GoodsTile:UpdateTooltip()
	local str = GetDescriptionString(self.name)
	self:SetTooltip(str)
end

function GoodsTile:OnGainFocus()
	self:UpdateTooltip()
end
]]

return GoodsTile
