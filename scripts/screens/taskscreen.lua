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
    self.black.OnMouseButton = function() self:OnCancel() end

    self.taskspanel = self.root:AddChild(TEMPLATES.RectangleWindow(650, 550))
    self.taskspanel:SetPosition(0, 25)

    self.current = self.taskspanel:AddChild(Text(BODYTEXTFONT, 35))
    self.current:SetPosition(0, 250, 0)
    self.current:SetRegionSize(650, 50)
    self.current:SetHAlign(ANCHOR_MIDDLE)

    self.cancelbutton = self.taskspanel:AddChild(
                            TEMPLATES.StandardButton(
                                function() self:OnCancel() end, "关闭",
                                {120, 40}))
    self.cancelbutton:SetPosition(0, -250)

    self:LoadTasks()
    self:Show()
    self.default_focus = self.tasks_scroll_list
    self.isopen = true
end)

function TaskScreen:TaskItem()
	local task = Widget("taskitem")

    local item_width, item_height = 130, 90
    task.backing = task:AddChild(TEMPLATES.ListItemBackground(item_width, item_height, function() end))
    task.backing.move_on_click = true

    task.name = task:AddChild(Text(BODYTEXTFONT, 35))
    task.name:SetVAlign(ANCHOR_MIDDLE)
    task.name:SetHAlign(ANCHOR_LEFT)
    task.name:SetPosition(0, 25, 0)
    task.name:SetRegionSize(130, 50)


    task.SetInfo = function(_, info)
        if info.name and info.name ~= "" then
            task.name:SetString(info.name)
            task.name:SetColour(1, 1, 1, 1)
        else
            task.name:SetString("Unknow")
            task.name:SetColour(1, 1, 0, 0.6)
        end

		task.backing:SetOnClick(function()
            
        end)
    end

    task.focus_forward = task.backing
    return task
end

function TaskScreen:LoadTasks()
	local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)

        widget:SetOnGainFocus(function()
            self.tasks_scroll_list:OnWidgetFocus(widget)
        end)

        widget.taskitem = widget:AddChild(self:TaskItem())
        local taskitem = widget.taskitem

        widget.focus_forward = taskitem

        return widget
    end

	local function ApplyDataToWidget(context, widget, data, index)
		widget.data = data
        widget.taskitem:Hide()
        if not data then
            widget.focus_forward = nil
            return
        end

        widget.focus_forward = widget.taskitem
        widget.taskitem:Show()

        local taskitem = widget.taskitem

        taskitem:SetInfo(data.task)
	end

	self.task_widgets = {}
	if task_data then
		for k, v in pairs(task_data) do
			local num = #self.task_widgets + 1
			--print(num)
			table.insert(self.task_widgets, {index=num, task=v})
		end
	end

	if not self.tasks_scroll_list then
		self.tasks_scroll_list = self.taskspanel:AddChild(
                                     TEMPLATES.ScrollingGrid(self.task_widgets, {
                context = {},
                widget_width = 130,
                widget_height = 90,
                num_visible_rows = 5,
                num_columns = 5,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 10,
                scrollbar_height_offset = -60,
                peek_percent = 0, -- may init with few clientmods, but have many servermods.
                allow_bottom_empty_row = true -- it's hidden anyway
            }))

        self.tasks_scroll_list:SetPosition(0, 0)

        self.tasks_scroll_list:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)
        self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.tasks_scroll_list)
	end
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