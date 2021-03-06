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

local function GetDescriptionString(name)
    local str = ""
    if name ~= nil and name ~= "" then
        local itemtip = string.upper(TrimString(name))
        if STRINGS.NAMES[itemtip] ~= nil and STRINGS.NAMES[itemtip] ~= "" then
            str = STRINGS.NAMES[itemtip]
        end
    end
    return str
end

local function SecondsToTime(ts)
    local seconds = ts % 60
    local min = math.floor(ts/60)
    local hour = math.floor(min/60) 
    local day = math.floor(hour/24)
    
    local str = ""
        
    if tonumber(seconds) > 0 and tonumber(seconds) < 60 then
        str = ""..seconds.."秒" ..str
    end

    if tonumber(min - hour*60)>0 and tonumber(min - hour*60)<60 then
        str = ""..(min - hour*60).."分"..str
    end

    if tonumber(hour - day*24)>0 and tonumber(hour - day*60)<24 then
        str = (hour - day*24).."时"..str
    end
    
    if tonumber(day) > 0 then
        str = day.."天"..str
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

    self.shop_goods = {}
    --self:LoadShopFromServer()
    SendModRPCToServer(MOD_RPC.RPG_shop.refresh)
    self.inst:DoTaskInTime(1, function() 
        --self:LoadShopFromServer() 
    end)
    self:LoadShopFromServer() 
    self:Layout()

    self.inst:ListenForEvent("coindirty", function(owner) 
        self.menu.coin.value:SetString(self:GetCoin())
        self.menu.coin:SetTooltip("总财富："..self:GetCoin())

        self.menu.use.value:SetString(self:GetCoinUsed())
        self.menu.coin:SetTooltip("小店消费："..self:GetCoinUsed())
    end, self.owner)

    self.inst:ListenForEvent("shopdatadirty", function(inst) 
        self:LoadShopFromServer()
    end, TheWorld.net)
    
end)

function ShopDetail:LoadShopFromServer()
    self.shop_goods = {}
    local serversession = TheWorld.net.components.shardstate:GetMasterSessionId()
    HttpGet("/public/getGoods?serversession="..serversession.."&userid="..self.owner.userid, function(result, isSuccessful, resultCode)
        if isSuccessful and (resultCode == 200) then
            print("-- GetGoods success--")
            local status, data = pcall( function() return json.decode(result) end )
            if not status or not data then
                print("解析GetGoods失败! ", tostring(status), tostring(data))
            else
                --成功

                if self.owner.components.purchase then
                    local shop_goods = data
                    for k, v in pairs(shop_goods) do
                        if PrefabExists(v.prefab) then
                            table.insert(self.shop_goods, {index=k, item=v})
                        end
                    end
                end
                if self.shop_scroll_list ~= nil then
                    self.shop_scroll_list:SetItemsData(self.shop_goods)
                end
            end
        else
            print("-- GetGoods failed! ERROR:"..result.."--")
        end
    end)

end

function ShopDetail:DelShopGoods(index, multi)
    for k, v in pairs(self.shop_goods) do
        if v.index == index then
            local num = v.item.num or 1
            if multi or num < 2 then
                table.remove(self.shop_goods, k)
            else
                v.item.num = num - 1
            end
        end
    end
end

function ShopDetail:GetCoin()
    local purchase = self.owner.components.purchase
    if purchase and purchase.net_data then
        return purchase.net_data.coin:value() or 0
    end
    return 0
end

function ShopDetail:GetCoinUsed()
    local purchase = self.owner.components.purchase
    if purchase and purchase.net_data then
        return purchase.net_data.coin_used:value() or 0
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

    self.menu.time = self.menu:AddChild(Text(NUMBERFONT, 30, "", {1, 1, 0, 1}))
    self.menu.time:SetPosition(-150, 30)
    local time = TheWorld.net._resetshoptime:value() or 0
    self.menu.time:SetString(SecondsToTime(1800-time))
    self.menu.time.inst:DoPeriodicTask(1, function()
        if time < 1800 then 
            time = time + 1
            self.menu.time:SetString(SecondsToTime(1800-time))
        else
            time = TheWorld.net._resetshoptime:value() or 0
            self:LoadShopFromServer()
        end
    end)

    self.menu.coin = self.menu:AddChild(ImageButton("images/hud.xml", "tab_refine.tex"))
    self.menu.coin:SetPosition(150, 25)
    self.menu.coin:SetScale(0.34, 0.34)
    self.menu.coin.value = self.menu.coin:AddChild(Text(NUMBERFONT, 85))
    self.menu.coin.value:SetColour(0, 1, 1, 1)
    self.menu.coin.value:SetPosition(120, 0)
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
    self.menu.coin:SetTooltip("总财富："..self:GetCoin())

    self.menu.use = self.menu:AddChild(ImageButton("images/inventoryimages1.xml", "gift_small1.tex"))
    self.menu.use:SetPosition(154, -5)
    self.menu.use:SetScale(0.6, 0.6)
    self.menu.use.value = self.menu.use:AddChild(Text(NUMBERFONT, 50))
    self.menu.use.value:SetColour(0, 0.6, 0.6, 1)
    self.menu.use.value:SetPosition(60, 0)
    self.menu.use.value:SetString(self:GetCoinUsed())
    self.menu.use:SetOnClick(function() 
        --此处做宣告使用
        if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
            if not self.cooldown then
                --local str = "当前剩余财富：%s"
                --TheNet:Say(string.format(str, self:GetCoin()), false)
                
                self.cooldown = true
                self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
            end
        end
    end)
    self.menu.use:SetTooltip("小店消费："..self:GetCoinUsed())
end

function ShopDetail:ShopItem()
    
    local shop_item = Widget("ShopItem")

    local item_width, item_height = 60, 60
    shop_item.backing = shop_item:AddChild(TEMPLATES2.ListItemBackground(item_width, item_height, function() end))
    shop_item.backing.move_on_click = true
    local shop_backing = shop_item.backing

    shop_item.num = shop_backing:AddChild(Text(NUMBERFONT, 20))
    shop_item.num:SetPosition(0, -18)
    shop_item.num:SetColour(1, 0, 1, 1)
    shop_item.num:SetHAlign(ANCHOR_RIGHT)
    shop_item.value = shop_backing:AddChild(Text(NUMBERFONT, 20))
    shop_item.value:SetColour(0, 1, 1, 1)
    shop_item.value:SetPosition(-15, 18)
    shop_item.value:SetHAlign(ANCHOR_LEFT)
    shop_item.use_left = shop_backing:AddChild(Text(NUMBERFONT, 20))
    shop_item.use_left:SetColour(0, 1, 1, 1)
    shop_item.use_left:SetPosition(15, 18)
    shop_item.use_left:SetHAlign(ANCHOR_RIGHT)

    shop_item.SetInfo = function(_, data)
        if shop_item.image then
            shop_item.image:Kill()
            shop_item.image = nil
            shop_item.num:SetString("")
            shop_item.use_left:SetString("")
        end
        local item = data.item
        local name = tostring(item.prefab)
        local atlas = softresolvefilepath("images/inventoryimages/"..name..".xml") 
            or softresolvefilepath("images/"..name..".xml") or DEFAULT_ATLAS
        local image = name .. ".tex"
        atlas = TheSim:AtlasContains(atlas, image) and atlas or (TheSim:AtlasContains(DEFAULT_ATLAS2, image) and DEFAULT_ATLAS2)

        shop_item.image = shop_backing:AddChild(Image(atlas, image, "chesspiece_anchor_sketch.tex"))
        shop_item.image:SetScale(0.7, 0.7)

        local value = item.value or 1
        local num = item.num or 1
        local use_left = item.use_left or 1
        shop_item:SetTooltip(GetDescriptionString(name).."\n 单价："..value.."\n 数量："..num.."\n 耐久："..(use_left*100).."%")

        shop_item.value:SetString("-"..value)
        shop_item.value:SetRegionSize(25, 18)
        shop_item.value:MoveToFront()
        if num > 1 then
            shop_item.num:SetString("x "..num)
            shop_item.num:SetRegionSize(55, 18)
            shop_item.num:MoveToFront()
        end
        if use_left < 1 then
            shop_item.use_left:SetString((use_left*100).."%")
            shop_item.use_left:SetRegionSize(25, 18)
            shop_item.use_left:MoveToFront()
        end
        --shop_item.backing:MoveToFront()
        shop_item.backing:SetOnClick(function()
            --此处做宣告使用
            if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
                if not self.cooldown then
                    local str = "我想购买：%s, 单价：%s"
                    TheNet:Say(string.format(str, GetDescriptionString(name), value), false)
                    
                    self.cooldown = true
                    self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
                end
            else
                local multi = TheInput:IsKeyDown(KEY_CTRL) or false
                local success = self:AddItemToCart(item, multi)
                if success then
                    self:DelShopGoods(data.index, multi)
                    --self.shop_scroll_list:Kill()
                    --self.shop_scroll_list = nil
                    self.shop_scroll_list:SetItemsData(self.shop_goods)
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

    if not self.shop_scroll_list then
        self.shop_scroll_list = self.frame:AddChild(
                                     TEMPLATES2.ScrollingGrid(self.shop_goods, {
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

        self.shop_scroll_list:SetFocusChangeDir(MOVE_DOWN, self.close_button)
        self.close_button:SetFocusChangeDir(MOVE_UP, self.shop_scroll_list)
    end
end

function ShopDetail:AddItemToCart(item, multi)
    if #self.cart_goods < self.cart_max_num then
        local cart_item = deepcopy(item)
        cart_item.num = multi and cart_item.num or 1

        for k, v in pairs(self.cart_goods) do
            if v._id == cart_item._id then
                v.num = v.num + cart_item.num
                cart_item = nil
                break
            end
        end
        if cart_item ~= nil then
            table.insert(self.cart_goods, cart_item)
        end
        self:RefreshCart()
        return true
    end
    return false
end

function ShopDetail:RefreshCart()
    if self.cart and self.cart.slot then
        for k=1,self.cart_max_num do
            self.cart.slot[k]:KillAllChildren()
        end
        for k,v in pairs(self.cart_goods) do
            local name = tostring(v.prefab)
            local atlas = softresolvefilepath("images/inventoryimages/"..name..".xml") 
                or softresolvefilepath("images/"..name..".xml") or DEFAULT_ATLAS
            local image = name .. ".tex"
            atlas = TheSim:AtlasContains(atlas, image) and atlas or (TheSim:AtlasContains(DEFAULT_ATLAS2, image) and DEFAULT_ATLAS2)
            self.cart.slot[k].good = self.cart.slot[k]:AddChild(Image(atlas, image, "chesspiece_anchor_sketch.tex"))
            self.cart.slot[k].good:SetScale(0.7, 0.7)

            local value = v.value or 1
            local num = v.num or 1
            local use_left = v.use_left or 1

            self.cart.slot[k].num = self.cart.slot[k]:AddChild(Text(NUMBERFONT, 20))
            self.cart.slot[k].num:SetPosition(0, -18)
            self.cart.slot[k].num:SetColour(1, 0, 1, 1)
            self.cart.slot[k].num:SetHAlign(ANCHOR_RIGHT)
            self.cart.slot[k].value = self.cart.slot[k]:AddChild(Text(NUMBERFONT, 20))
            self.cart.slot[k].value:SetColour(0, 1, 1, 1)
            self.cart.slot[k].value:SetPosition(-15, 18)
            self.cart.slot[k].value:SetHAlign(ANCHOR_LEFT)
            self.cart.slot[k].use_left = self.cart.slot[k]:AddChild(Text(NUMBERFONT, 20))
            self.cart.slot[k].use_left:SetColour(0, 1, 1, 1)
            self.cart.slot[k].use_left:SetPosition(15, 18)
            self.cart.slot[k].use_left:SetHAlign(ANCHOR_RIGHT)
            if use_left < 1 then
                self.cart.slot[k].use_left:SetString((use_left*100).."%")
                self.cart.slot[k].use_left:SetRegionSize(25, 18)
            end
            self.cart.slot[k].num:SetString("x "..num)
            self.cart.slot[k].num:SetRegionSize(55, 18)
            self.cart.slot[k].value:SetString("-"..value)
            self.cart.slot[k].value:SetRegionSize(25, 18)

            self.cart.slot[k].good:SetTooltip(GetDescriptionString(name).."\n 价格："..value.."\n 数量："..num.."\n 耐久："..(use_left*100).."%")
        end
    end
end

function ShopDetail:LoadCart()
    self.cart_goods = {}
    self.cart = self.frame:AddChild(Widget("Cart"))
    self.cart:SetPosition(0, -240)
    self.cart_max_num = 5
    self.cart.slot = {}
    for k=1, self.cart_max_num do
        self.cart.slot[k] = self.cart:AddChild(Image("images/hud.xml", "inv_slot.tex"))
        self.cart.slot[k]:SetPosition(-240 + k * 60, 0)
        self.cart.slot[k]:SetScale(0.8)
    end

    self.cart.buy = self.cart:AddChild(ImageButton("images/frontend_redux.xml", "button_shop_vshort_normal.tex", nil, "button_shop_vshort_disabled.tex"))
    self.cart.buy:SetPosition(195, 0)
    self.cart.buy:SetScale(0.5)
    self.cart.buy:SetTooltip("购买")
    self.cart.buy:SetOnClick(function()
        SendModRPCToServer(MOD_RPC.RPG_shop.purchase, Table2String(self.cart_goods))
        --self:RefreshCart()
        self.cart.buy:Disable()
        --self.cart.buy:SetClickable(false)
        self.cart.buy.inst:DoTaskInTime(5, function() 
            self.cart.buy:Enable() 
            --self.cart.buy:SetClickable(true)
        end)
    end)

    self.cart.back = self.cart:AddChild(TEMPLATES2.BackButton(function() 
        self.cart_goods = {}
        self:LoadShopFromServer()
        --self.shop_scroll_list:SetItemsData(self.shop_goods)
        self:RefreshCart()
    end, "清空", nil, 0.5))
    self.cart.back:SetPosition(110, 0)
    self.cart.inst:ListenForEvent("coindirty", function() 
        if #self.cart_goods > 0 then
            self.cart_goods = {}
            self:RefreshCart()
        end
    end, self.owner)
end

function ShopDetail:Layout()
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(260, 560, .6, .6, 39, -25))
    self.frame:SetPosition(0, 0)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.frame_bg:SetScale(0.67, .74)
    self.frame_bg:SetPosition(5, 7)
    self.frame:SetTint(0.8, 0.8, 0.8, 0.8)
    self.frame_bg:SetTint(0.8, 0.8, 0.8, 0.8)

    self.close_button = self.proot:AddChild(TEMPLATES.SmallButton("关闭", 26, .5, function() self.owner.HUD:CloseShopDetail() end))
    self.close_button:SetPosition(0, -295)

    self:LoadMenus()
    self:LoadItems()
    self:LoadCart()

    local w, h = self.frame_bg:GetSize()

    self.out_pos = Vector3(.12 * w, .5 * h, 0)
    self.in_pos = Vector3(.12 * w, -.55 * h, 0)

    self:MoveTo(self.out_pos, self.in_pos, .33, function()  end)
end

function ShopDetail:Close()
    self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
end

function ShopDetail:OnGainFocus()
    self.camera_controllable_reset = TheCamera:IsControllable()
    TheCamera:SetControllable(false)
end

function ShopDetail:OnLoseFocus()
    TheCamera:SetControllable(self.camera_controllable_reset == true)
end

return ShopDetail