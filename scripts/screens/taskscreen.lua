local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local TEMPLATES = require "widgets/redux/templates"
local ScrollableList = require "widgets/scrollablelist"

local TaskScreen = Class(Screen, function(self, owner)
    Screen._ctor(self, "TaskScreen")

    self.owner = owner

    self.isopen = false

    --获取屏幕宽高
    self._sw, self.sh = TheSim:GetScreenSize()

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetPosition(0, 0, 0)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.scalingroot = self:AddChild(Widget("travelablewidgetscalingroot"))
    self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())

    self.inst:ListenForEvent("continuefrompause", function()
        if self.isopen then
            self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
        end
    end, TheWorld)
    self.inst:ListenForEvent("refreshhudsize", function(hud, scale)
        if self.isopen then 
        	self.scalingroot:SetScale(scale) 
        end
    end, owner.HUD.inst)

    self.root = self.scalingroot:AddChild(TEMPLATES.ScreenRoot("root"))

    -- secretly this thing is a modal Screen, it just LOOKS like a widget
    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0)
    --self.black.OnMouseButton = function() self:OnCancel() end

    self.destspanel = self.root:AddChild(TEMPLATES.RectangleWindow(650, 550))
    self.destspanel:SetPosition(0, 25)

    self.current = self.destspanel:AddChild(Text(BODYTEXTFONT, 35))
    self.current:SetPosition(0, 250, 0)
    self.current:SetRegionSize(650, 50)
    self.current:SetHAlign(ANCHOR_MIDDLE)

    self.cancelbutton = self.destspanel:AddChild(
                            TEMPLATES.StandardButton(
                                function() self:OnCancel() end, "关闭",
                                {120, 40}))
    self.cancelbutton:SetPosition(0, -250)

    --self:LoadTasks()
    self:Show()
    --self.default_focus = self.dests_scroll_list
    self.isopen = true
end)

function TaskScreen:LoadTasks()

end

function TaskScreen:OnControl(control, down)
    if TaskScreen._base.OnControl(self, control, down) then return true end

    if not down then
        if control == CONTROL_OPEN_DEBUG_CONSOLE then
            return true
        elseif control == CONTROL_CANCEL then
            self:OnCancel()
        end
    end
end

function TaskScreen:Close()
	if self.isopen then
		self.black:Kill()
		self.isopen = false
		self.inst:DoTaskInTime(.2, function() 
			TheFrontEnd:PopScreen(self)
		end)
	end
end

function TaskScreen:OnCancel()
	if self.isopen then
		self.owner.HUD:CloseTaskScreen()
	end
end

return TaskScreen