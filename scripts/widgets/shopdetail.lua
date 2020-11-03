local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local TEMPLATES = require "widgets/templates"
local TEMPLATES2 = require "widgets/redux/templates"
local EquipSlot = require("equipslotutil")

local DEFAULT_ATLAS = "images/inventoryimages.xml"

function GetDescriptionString(name)

    local str = ""

    if name ~= nil and name ~= "" then
        local itemtip = string.upper(TrimString( name ))
        if STRINGS.NAMES[itemtip] ~= nil and STRINGS.NAMES[itemtip] ~= "" then
            str = STRINGS.NAMES[itemtip]
        end
    end

    return str
end

local ShopDetail = Class(Widget, function(self, owner)
    Widget._ctor(self, "ShopDetail")

    self.owner = owner
    
    self.targetmovetime = TheInput:ControllerAttached() and .5 or .75
    self.started = false
    self.settled = false
    
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetPosition(335, 0)

    self:Layout()
    
end)

function ShopDetail:GetCoin()
    local taskdata = self.owner.components.taskdata
    if taskdata and taskdata.net_data then
        return taskdata.net_data.coin:value() or 0
    end
    return 0
end

function ShopDetail:LoadMenus()
    self.menu = self.frame:AddChild(Widget("Menu"))
    self.menu:SetPosition(0, 240)

    self.menu.title = self.menu:AddChild(Text(BODYTEXTFONT, 48))
    self.menu.title:SetPosition(0, 15)
    self.menu.title:SetVAlign(ANCHOR_MIDDLE)
    self.menu.title:SetHAlign(ANCHOR_MIDDLE)
    --self.menu.title:SetColour(1, 1, 1, 1)
    self.menu.title:SetString("交易小店")
    self.menu.title:SetRegionSize(150, 60)

    self.menu.coin = self.menu:AddChild(ImageButton("images/hud.xml", "tab_refine.tex"))
    self.menu.coin:SetPosition(150, 25)
    self.menu.coin:SetScale(0.34, 0.34)
    self.menu.coin.value = self.menu.coin:AddChild(Text(TALKINGFONT, 55))
    self.menu.coin.value:SetColour(0, 1, 1, 1)
    self.menu.coin.value:SetPosition(100, 0)
    self.menu.coin.value:SetString(self:GetCoin())
    self.menu.coin:SetOnClick(function() 
        --此处做宣告使用
        if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
            if not self.cooldown then
                local str = "当前剩余财富：%s"
                TheNet:Say(string.format(str, self:GetCoin()), false)
                
                self.cooldown = true
                self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
            end
        end
    end)
end

function ShopDetail:ShopItem()
    
    local shop_item = Widget("ShopItem")

    local item_width, item_height = 60, 60
    shop_item.backing = shop_item:AddChild(TEMPLATES2.ListItemBackground(item_width, item_height, function() end))
    shop_item.backing.move_on_click = true

    shop_item.num = shop_item:AddChild(Text(TALKINGFONT, 15))
    shop_item.num:SetPosition(0, -18)
    shop_item.num:SetColour(1, 0, 1, 1)
    shop_item.num:SetHAlign(ANCHOR_RIGHT)
    shop_item.value = shop_item:AddChild(Text(TALKINGFONT, 15))
    shop_item.value:SetColour(0, 1, 1, 1)
    shop_item.value:SetPosition(0, 18)
    shop_item.value:SetHAlign(ANCHOR_LEFT)

    shop_item.SetInfo = function(_, data)
        if shop_item.image then
            shop_item.image:Kill()
            shop_item.image = nil
        end
        local item = data.item
        local name = tostring(item.prefab)
        local atlas = softresolvefilepath("images/inventoryimages/"..name..".xml") 
            or softresolvefilepath("images/"..name..".xml") or DEFAULT_ATLAS
        local image = name .. ".tex"

        shop_item.image = shop_item:AddChild(Image(atlas, image, "chesspiece_anchor_sketch.tex"))
        shop_item.image:SetScale(0.7, 0.7)

        local value = item.value or 1
        local num = item.num or 1
        local use_left = item.use_left or 1
        shop_item:SetTooltip(GetDescriptionString(name).."\n 价格："..value.."\n 数量："..num.."\n 耐久："..(use_left*100).."%")

        shop_item.value:SetString("-"..(item.value or 1))
        shop_item.num:SetString("x "..(item.num or 1))
        shop_item.value:SetRegionSize(55, 18)
        shop_item.num:SetRegionSize(55, 18)
        shop_item.value:MoveToFront()
        shop_item.num:MoveToFront()

        shop_item.backing:SetOnClick(function()
            --此处做宣告使用
            if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
                if not self.cooldown then
                    local str = ""
                    --TheNet:Say(string.format(str, info.name, current, need), false)
                    
                    self.cooldown = true
                    self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
                end
            end
        end)
    end

    shop_item.OnGainFocus = function(_) 

    end

    shop_item.focus_forward = shop_item.backing
    return shop_item
end

function ShopDetail:LoadItems()
    --self.shoppanel = self.proot:AddChild(TEMPLATES2.RectangleWindow(260, 540))

    local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)

        widget:SetOnGainFocus(function()
            self.shop_scroll_list:OnWidgetFocus(widget)
        end)

        widget.item = widget:AddChild(self:ShopItem())
        local item = widget.item

        widget.focus_forward = item

        return widget
    end

    local function ApplyDataToWidget(context, widget, data, index)
        widget.data = data
        widget.item:Hide()
        if not data then
            widget.focus_forward = nil
            return
        end

        widget.focus_forward = widget.item
        widget.item:Show()

        local item = widget.item

        item:SetInfo(data)
    end

    self.shop_widgets = {}
    local shop_list = {{prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear"}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="spear", use_left=0.5}, {prefab="footballhat"}, {prefab="hivehat"}, {prefab="hivehat"},
                        {prefab="achiv_clear", num=5, value=20}
                        }
    if shop_list then
        for k, v in pairs(shop_list) do
            if PrefabExists(v.prefab) then
                table.insert(self.shop_widgets, {index=k, item=v})
            end
        end
    end

    if not self.shop_scroll_list then
        self.shop_scroll_list = self.frame:AddChild(
                                     TEMPLATES2.ScrollingGrid(self.shop_widgets, {
                context = {},
                widget_width = 60,
                widget_height = 60,
                num_visible_rows = 7,
                num_columns = 7,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 15,
                scrollbar_height_offset = -20,
                peek_percent = 0, -- may init with few clientmods, but have many servermods.
                allow_bottom_empty_row = true -- it's hidden anyway
            }))

        self.shop_scroll_list:SetPosition(0, 0)

        --self.shop_scroll_list:SetFocusChangeDir(MOVE_DOWN, self.cancelbutton)
        --self.cancelbutton:SetFocusChangeDir(MOVE_UP, self.shop_scroll_list)
    end
end

function ShopDetail:Layout()
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(260, 540, .6, .6, 39, -25))
    self.frame:SetPosition(0, 0)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.frame_bg:SetScale(0.67, .74)
    self.frame_bg:SetPosition(5, 7)
    self.frame:SetTint(0.8, 0.8, 0.8, 0.8)
    self.frame_bg:SetTint(0.8, 0.8, 0.8, 0.8)

    self:LoadMenus()
    self:LoadItems()

    local w, h = self.frame_bg:GetSize()

    self.out_pos = Vector3(.12 * w, .5 * h, 0)
    self.in_pos = Vector3(.12 * w, -.55 * h, 0)

    self:MoveTo(self.out_pos, self.in_pos, .33, function()  end)
end

function ShopDetail:Close()
    self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
end

function ShopDetail:OnGainFocus()
    --此处需要控制鼠标滑动不影响游戏缩放
    local controller = TheInput:ControllerAttached()
    TheInput:EnableMouse(not controller)
end

function ShopDetail:OnLoseFocus()
    TheInput:EnableMouse(true)
end

return ShopDetail