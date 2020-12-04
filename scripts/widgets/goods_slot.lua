local ItemSlot = require "widgets/itemslot"
local Text = require "widgets/text"

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


local GoodsSlot = Class(ItemSlot, function(self, owner, prefab, num, use_left, value)

	ItemSlot._ctor(self, "images/hud.xml", "inv_slot.tex", owner)
	self.owner = owner

	self.clickfn = nil

	self.label_num = self:AddChild(Text(NUMBERFONT, 22, "", {1, 0, 1, 1}))
	self.label_num:SetPosition(20, -20)

	self.label_use = self:AddChild(Text(NUMBERFONT, 22, "", {0, 1, 1, 1}))
	self.label_use:SetPosition(20, 20)

	self.label_value = self:AddChild(Text(NUMBERFONT, 22, "", {0, 1, 1, 1}))
	self.label_value:SetPosition(-20, 20)

	self:SetMeta({
		prefab = prefab,
		num = num,
		use_left = use_left,
		value = value
	})
end)

function GoodsSlot:OnControl(control, down)
	if self._base.OnControl(self, control, down) then return true end

	if down then
		if control == CONTROL_ACCEPT then
			self:Click(false)
		elseif control == CONTROL_SECONDARY then
			self:Click(true)
		end
		return true
	end
end

function GoodsSlot:SetClick(fn)
	self.clickfn = fn
end

function GoodsSlot:Click(stack_mod)
	if self.clickfn ~= nil and self.clickfn(stack_mod) then
		TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
	end
end

function GoodsSlot:SetMeta(meta)
	self.prefab = meta.prefab
	self.num = meta.num or 1
	self.use_left = meta.use_left or 1
	self.value = meta.value

	if self.num > 1 then
		self.label_num:SetString("x "..self.num)
	else
		self.label_num:SetString("")
    end

    if self.use_left < 1 then
    	self.label_use:SetString((self.use_left*100).."%")
	else
		self.label_use:SetString("")
    end

    if self.value ~= nil then
    	self.label_value:SetString("-"..self.value)
	else
		self.label_value:SetString("")
    end
end

function GoodsSlot:UpdateTooltip()
	local str = GetDescriptionString(self.prefab)
	if self.value ~= nil then
		str = str.."\n 价格："..self.value
	end
	if self.num > 0 then
		str = str.."\n 数量："..self.num
	end
	if self.use_left < 1 then
		str = str.."\n 耐久："..(self.use_left*100).."%"
	end
	self:SetTooltip(str)
end

function GoodsSlot:OnGainFocus()
	self:UpdateTooltip()
end

function GoodsSlot:SetTile(...)
	self._base.SetTile(self, ...)
	self.label_value:MoveToFront()
	self.label_use:MoveToFront()
	self.label_num:MoveToFront()
end

return GoodsSlot
