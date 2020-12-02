require "utils/utils"
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

local DEFAULT_ATLAS = "images/inventoryimages1.xml"
local DEFAULT_ATLAS2 = "images/inventoryimages2.xml"


local EmailDetail = Class(Widget, function(self, owner)
    Widget._ctor(self, "EmailDetail")

    self.owner = owner
    
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetPosition(335, 0)

    self:Layout()
    
end)



function EmailDetail:Layout()
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(260, 560, .6, .6, 39, -25))
    self.frame:SetPosition(0, 0)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.frame_bg:SetScale(0.67, .74)
    self.frame_bg:SetPosition(5, 7)
    self.frame:SetTint(0.8, 0.8, 0.8, 0.8)
    self.frame_bg:SetTint(0.8, 0.8, 0.8, 0.8)

    self.close_button = self.proot:AddChild(TEMPLATES.SmallButton("关闭", 26, .5, function() self.owner.HUD:CloseShopDetail() end))
    self.close_button:SetPosition(0, -295)

    self:LoadEmails()

    local w, h = self.frame_bg:GetSize()

    self.out_pos = Vector3(.12 * w, .5 * h, 0)
    self.in_pos = Vector3(.12 * w, -.55 * h, 0)

    self:MoveTo(self.out_pos, self.in_pos, .33, function()  end)
end

function EmailDetail:LoadEmails()
    local item_width, item_height = 420, 84

    local function BuildEmail()
        local email_item = Widget("EmailItem")

        email_item.backing = email_item:AddChild(TEMPLATES2.ListItemBackground(item_width, item_height, function() end))
        email_item.backing.move_on_click = true
        local backing = email_item.backing


        email_item.SetInfo = function(_, data)
            
        end

        shop_item.focus_forward = shop_item.backing
        return shop_item
    end

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
    self.emails = {}

    if not self.email_scroll_list then
        self.email_scroll_list = self.frame:AddChild(
                                     TEMPLATES2.ScrollingGrid(self.emails, {
                context = {},
                widget_width = item_width,
                widget_height = item_height,
                num_visible_rows = 5,
                num_columns = 1,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 15,
                scrollbar_height_offset = -20,
                peek_percent = 0, -- may init with few clientmods, but have many servermods.
                allow_bottom_empty_row = true -- it's hidden anyway
            }))

        self.email_scroll_list:SetPosition(0, 0)

        self.email_scroll_list:SetFocusChangeDir(MOVE_DOWN, self.close_button)
        self.close_button:SetFocusChangeDir(MOVE_UP, self.email_scroll_list)
    end
end

function EmailDetail:Close()
    self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
end

function EmailDetail:OnGainFocus()
    self.camera_controllable_reset = TheCamera:IsControllable()
    TheCamera:SetControllable(false)
end

function EmailDetail:OnLoseFocus()
    TheCamera:SetControllable(self.camera_controllable_reset == true)
end

return EmailDetail