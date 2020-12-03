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
local GoodsSlot = require "widgets/goods_slot"
local GoodsTile = require "widgets/goods_tile"

local EmailDetail = Class(Widget, function(self, owner)
    Widget._ctor(self, "EmailDetail")

    self.owner = owner
    
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetPosition(335, 0)

    self.emails = {}
    self:GetEmailFromServer()
    self:Layout()

    self.inst:ListenForEvent("emaildirty", function()
        self:GetEmailFromServer()
    end, self.owner)
    
end)

function EmailDetail:GetEmailFromServer()
    self.emails = {}
    local emails = deepcopy(self.owner.components.email:GetEmail() or {})
    for k, v in pairs(emails) do
        if v ~= nil and next(v) ~= nil then --排除空数据
            table.insert(self.emails, {index=k, item=v})
        end
    end
    if self.email_scroll_list ~= nil then
        self.email_scroll_list:SetItemsData(self.emails)
    end
end

function EmailDetail:Layout()
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(260, 560, .6, .6, 39, -25))
    self.frame:SetPosition(0, 0)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.frame_bg:SetScale(0.67, .74)
    self.frame_bg:SetPosition(5, 7)
    self.frame:SetTint(0.8, 0.8, 0.8, 0.8)
    self.frame_bg:SetTint(0.8, 0.8, 0.8, 0.8)

    self.close_button = self.proot:AddChild(TEMPLATES.SmallButton("关闭", 26, .5, function() self.owner.HUD:CloseEmailDetail() end))
    self.close_button:SetPosition(0, -295)

    self:LoadEmails()

    local w, h = self.frame_bg:GetSize()

    self.out_pos = Vector3(.12 * w, .5 * h, 0)
    self.in_pos = Vector3(.12 * w, -.55 * h, 0)

    self:MoveTo(self.out_pos, self.in_pos, .33, function()  end)
end

function EmailDetail:LoadEmails()
    local item_width, item_height = 440, 140

    local function BuildEmail()
        local email_item = Widget("EmailItem")

        email_item.backing = email_item:AddChild(TEMPLATES2.ListItemBackground_Static(item_width, item_height))
        email_item.backing.move_on_click = true
        local backing = email_item.backing

        email_item.title = backing:AddChild(Text(NUMBERFONT, 28))
        email_item.title:SetPosition(0, 50)
        email_item.title:SetRegionSize(item_width * .9, 30)
        email_item.title:SetColour(0, 1, 0, 1)
        email_item.title:SetHAlign(ANCHOR_LEFT)

        email_item.content = backing:AddChild(Text(NUMBERFONT, 22))
        email_item.content:SetPosition(0, 10)
        email_item.content:SetRegionSize(item_width * .9, 40)
        email_item.content:SetHAlign(ANCHOR_LEFT)

        email_item.prefab = backing:AddChild(Widget("EmailPrefab"))
        email_item.prefab:SetPosition(0, -40)

        email_item.SetInfo = function(_, data)
            email_item.prefab:KillAllChildren()
            email_item.slot = nil
            if email_item.get ~= nil then
                email_item.get:Kill()
                email_item.get = nil
            end

            local item = data.item
            local id = item._id
            local title = item.title or ""
            local content = item.content or "无"
            local sender = item.sender or "system"
            local time = item.time or ""

            email_item.title:SetString("["..time.." "..sender.."] "..title)

            email_item.content:SetMultilineTruncatedString(content, 3, item_width * .9, 60, "", false)

            email_item.get = backing:AddChild(TEMPLATES2.StandardButton(function() 
                SendModRPCToServer(MOD_RPC.RPG_email.received, id)
            end, "接收", {50, 40}))
            email_item.get:SetPosition(180, 45)

            local prefabs = item.prefabs or {}
            local slot_max_num = #prefabs
            if slot_max_num > 0 then
                email_item.slot = {}
                for k=1, slot_max_num do
                    local name = prefabs[k].prefab
                    local num = prefabs[k].num or 1
                    local use_left = prefabs[k].use_left or 1
                    email_item.slot[k] = email_item.prefab:AddChild(GoodsSlot(self.owner, name, num, use_left))
                    email_item.slot[k]:SetTile(GoodsTile(name))
                    email_item.slot[k]:SetScale(0.6)
                    email_item.slot[k]:SetPosition(-198 + 21 + (k -1) * 42, 0)
                end
            end
        end

        email_item.focus_forward = email_item.backing
        return email_item
    end

    local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)

        widget:SetOnGainFocus(function()
            self.email_scroll_list:OnWidgetFocus(widget)
        end)

        widget.item = widget:AddChild(BuildEmail())
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

    if not self.email_scroll_list then
        self.email_scroll_list = self.frame:AddChild(
                                     TEMPLATES2.ScrollingGrid(self.emails, {
                context = {},
                widget_width = item_width,
                widget_height = item_height,
                num_visible_rows = 4,
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