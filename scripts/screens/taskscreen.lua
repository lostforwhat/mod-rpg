local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local Text = require "widgets/text"

local TEMPLATES = require "widgets/redux/templates"
local ScrollableList = require "widgets/scrollablelist"

local DEFAULT_ATLAS = "images/inventoryimages1.xml"
local DEFAULT_ATLAS2 = "images/inventoryimages2.xml"

local categorys = {
    tumbleweed = "giftwrap",
    kill = "spear",
    killboss = "nightsword",
    eat = "meatballs",
    cook = "cookpot",
    build = "cutstone",
    friend = "mandrake",
    farm = "fast_farmplot",
}

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

    self.scalingroot = self:AddChild(Widget("taskwidgetscalingroot"))
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

    self.current = self.taskspanel:AddChild(Text(BODYTEXTFONT, 30))
    self.current:SetPosition(0, 250)
    self.current:SetRegionSize(250, 50)
    self.current:SetHAlign(ANCHOR_MIDDLE)
    self.current:SetColour(0.7, 0.7, 0.7, 1)
    self.title_str = "我的任务(%s/%s)"
    self.current:SetString(string.format(self.title_str, self:GetMyTask()))

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

function TaskScreen:GetMyTask()
	local total = 0
	local num = 0
	local taskdata = self.owner.components.taskdata
	for k, v in pairs(task_data) do
		if not v.hide then
			local current = taskdata.net_data[k]:value() or 0
			local need = v.need or 1
			if current >= need then
				num = num + 1
			end
			total = total + 1
		end
	end
	return num, total
end

local function GetAtlas(prefab)
    local name = tostring(prefab)
    local atlas = softresolvefilepath("images/inventoryimages/"..name..".xml")
        or softresolvefilepath("images/"..name..".xml") or DEFAULT_ATLAS
    local image = name .. ".tex"
    atlas = TheSim:AtlasContains(atlas, image) and atlas or (TheSim:AtlasContains(DEFAULT_ATLAS2, image) and DEFAULT_ATLAS2)
    return atlas, image
end

function TaskScreen:TaskItem()
    local taskdata = self.owner.components.taskdata
	local task = Widget("taskitem")

    local item_width, item_height = 160, 75
    task.backing = task:AddChild(TEMPLATES.ListItemBackground(item_width, item_height, function() end))
    task.backing.move_on_click = true

    task.name = task:AddChild(Text(BODYTEXTFONT, 32))
    task.name:SetVAlign(ANCHOR_MIDDLE)
    task.name:SetHAlign(ANCHOR_LEFT)
    task.name:SetPosition(-10, 20, 0)
    --task.name:SetRegionSize(120, 35)

    task.reward = task:AddChild(Text(BODYTEXTFONT, 30))
    task.reward:SetVAlign(ANCHOR_MIDDLE)
    task.reward:SetHAlign(ANCHOR_MIDDLE)
    task.reward:SetPosition(70, 20, 0)
    --task.reward:SetRegionSize(30, 20)

    task.desc = task:AddChild(Text(BODYTEXTFONT, 18))
    task.desc:SetVAlign(ANCHOR_MIDDLE)
    task.desc:SetHAlign(ANCHOR_LEFT)
    task.desc:SetPosition(0, -17.5, 0)

    task.SetInfo = function(_, data)
        if task.image ~= nil then
            task.image:Kill()
            task.image = nil
        end
        task.data = data
        local info = data.task
        local index = data.index
        --task.name:SetString(info.name)
        local category = info.category or ""
        if categorys[category] ~= nil then
            local atlas, image = GetAtlas(categorys[category])
            task.image = task:AddChild(Image(atlas, image, "chesspiece_anchor_sketch.tex"))
            --task.image:SetTint(.6, .6, .6, .6)
            task.image:MoveToBack()
            task.image:SetScale(0.4, 0.4)
            task.image:SetPosition(62, -16)
        end

        task.name:SetTruncatedString(info.name, 120, 100, "")
        local line = task.name:GetString()
		while #line < #info.name do
			task.name:SetSize(task.name:GetSize() - 1)
			task.name:SetTruncatedString(info.name, 120, 100, "")
			line = task.name:GetString()
		end
		task.name:SetRegionSize(120, 35)
        
        local current = taskdata.net_data[index]:value()
        local need = info.need or 1
        task.desc:SetMultilineTruncatedString(string.format(info.desc, " "..current.."/"..need.." "), 2, 140, 100, "", true)
        task.desc:SetRegionSize(140, 40)

        local reward = info.reward or 1
        task.reward:SetString(reward)
        task.reward:SetColour(1, 0.84, 0, 1)
        if current >= need then
            task.name:SetColour(0, 1, 0, 1)
            task.desc:SetColour(0, 1, 0, 1)
        else
            task.name:SetColour(1, 0.65, 0, 1)
            task.desc:SetColour(1, 0.94, 0.71, 1)
        end

		task.backing:SetOnClick(function()
            --此处做宣告使用
            if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
                if not self.cooldown then

                    local str = "任务：%s, 完成度：%s/%s"
                    TheNet:Say(string.format(str, info.name, current, need), false)
                    
                    self.cooldown = true
                    self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
                end
            end
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

        taskitem:SetInfo(data)
	end

	self.task_widgets = {}
	if task_data then
		for k, v in pairs(task_list) do
			--local num = #self.task_widgets + 1
			--print(num)
			if task_data[v] and not task_data[v].hide then
				table.insert(self.task_widgets, {index=v, task=task_data[v]})
			end
		end
	end

	if not self.tasks_scroll_list then
		self.tasks_scroll_list = self.taskspanel:AddChild(
                                     TEMPLATES.ScrollingGrid(self.task_widgets, {
                context = {},
                widget_width = 160,
                widget_height = 75,
                num_visible_rows = 6,
                num_columns = 4,
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