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
local PlayerAvatarPortrait = require "widgets/redux/playeravatarportrait"
local EquipSlot = require("equipslotutil")

local PlayerDetail = Class(Widget, function(self, owner)
    Widget._ctor(self, "PlayerDetail")

    self.owner = owner
    
    self.targetmovetime = TheInput:ControllerAttached() and .5 or .75
    self.started = false
    self.settled = false
    
    self.proot = self:AddChild(Widget("ROOT"))
    self.proot:SetPosition(335, 0)

    self:Layout()
    
    self.scrolldir = true
end)

function PlayerDetail:SetPlayerData()
    self.content:KillAllChildren()
    self.vertical_line = self.content:AddChild(Image("images/ui.xml", "line_vertical_5.tex"))
    self.vertical_line:SetScale(.5, .72)
    self.vertical_line:SetPosition(0, 0)

    SendModRPCToServer(MOD_RPC.RPG_meta.update, true)

    local meta_data = {
        {
            name = "生命值",
            widget_fn = function(self, width, height) 
                            local str_format = "%d/%d (+%d)"
                            local text = Text(BODYTEXTFONT, 25)
                            local max = self.owner.replica.health:Max()
                            local current = self.owner.replica.health:GetCurrent()
                            local extra = self.owner.components.extrameta._net_health:value()
                            text:SetString(string.format(str_format, current, max, extra))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("healthdirty", function(inst) 
                                --text:SetString(string.format("%.1f",inst._parent.replica.health:Max()))
                                max = inst._parent.replica.health:Max()
                                current = inst._parent.replica.health:GetCurrent()
                                extra = inst._parent.components.extrameta._net_health:value()
                                text:SetString(string.format(str_format, current, max, extra))
                            end, self.owner.player_classified)
                            return text
                        end
        },
        {
            name = "精神值",
            widget_fn = function(self, width, height) 
                            local str_format = "%d/%d (+%d)"
                            local text = Text(BODYTEXTFONT, 25)
                            local max = self.owner.replica.sanity:Max()
                            local current = self.owner.replica.sanity:GetCurrent()
                            local extra = self.owner.components.extrameta._net_sanity:value()
                            text:SetString(string.format(str_format, current, max, extra))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("sanitydirty", function(inst) 
                                max = inst._parent.replica.sanity:Max()
                                current = inst._parent.replica.sanity:GetCurrent()
                                extra = inst._parent.components.extrameta._net_sanity:value()
                                text:SetString(string.format(str_format, current, max, extra))
                            end, self.owner.player_classified)
                            return text
                        end
        },
        {
            name = "饥饿值",
            widget_fn = function(self, width, height) 
                            local str_format = "%d/%d (+%d)"
                            local text = Text(BODYTEXTFONT, 25)
                            local max = self.owner.replica.hunger:Max()
                            local current = self.owner.replica.hunger:GetCurrent()
                            local extra = self.owner.components.extrameta._net_hunger:value()
                            text:SetString(string.format(str_format, current, max, extra))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("hungerdirty", function(inst) 
                                max = inst._parent.replica.hunger:Max()
                                current = inst._parent.replica.hunger:GetCurrent()
                                extra = inst._parent.components.extrameta._net_hunger:value()
                                text:SetString(string.format(str_format, current, max, extra))
                            end, self.owner.player_classified)
                            return text
                        end
        },
        {
            name = "伤害",
            widget_fn = function(self, width, height) 
                            local str_format = "%.2f (%d%%) (+%.2f)"
                            local text = Text(BODYTEXTFONT, 25)
                            local damagemultiplier = self.owner.components.extrameta:GetDamageMultiplier()
                            local damage = self.owner.components.extrameta:GetDamage()
                            local extradamage = self.owner.components.extradamage:GetCommonExtraDamage()
                            text:SetString(string.format(str_format, damage, damagemultiplier*100, extradamage))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("extradamagedirty", function(inst) 
                                damagemultiplier = inst.components.extrameta:GetDamageMultiplier()
                                damage = inst.components.extrameta:GetDamage()
                                extradamage = inst.components.extradamage:GetCommonExtraDamage()
                                text:SetString(string.format(str_format, damage, damagemultiplier*100, extradamage))
                            end, self.owner)
                            return text
                        end
        },
        {
            name = "暴击",
            widget_fn = function(self, width, height) 
                            local str_format = "%d%% (%d~%d倍)"
                            local text = Text(BODYTEXTFONT, 25)
                            local chance = self.owner.components.crit:GetRealChance()
                            local min_hit = self.owner.components.crit:GetMinHit()
                            local max_hit = self.owner.components.crit:GetMaxHit()
                            text:SetString(string.format(str_format, math.floor(chance * 100 + 0.5), (min_hit + 1), max_hit + 1))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("critdirty", function(inst) 
                                chance = inst.components.crit:GetRealChance()
                                min_hit = inst.components.crit:GetMinHit()
                                max_hit = inst.components.crit:GetMaxHit()
                                text:SetString(string.format(str_format, math.floor(chance * 100 + 0.5), (min_hit + 1), max_hit + 1))
                            end, self.owner)
                            return text
                        end
        },
        {
            name = "闪避",
            widget_fn = function(self, width, height) 
                            local str_format = "%d%% (+%d%%)"
                            local text = Text(BODYTEXTFONT, 25)
                            local chance = self.owner.components.dodge:GetFinalChance()
                            local extra_chance = self.owner.components.dodge:GetExtraChance()
                            text:SetString(string.format(str_format, math.floor(chance * 100 + 0.5), math.floor(extra_chance * 100 + 0.5)))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("dodgedirty", function(inst) 
                                chance = inst.components.dodge:GetFinalChance()
                                extra_chance = inst.components.dodge:GetExtraChance()
                                text:SetString(string.format(str_format, math.floor(chance * 100 + 0.5), math.floor(extra_chance * 100 + 0.5)))
                            end, self.owner)
                            return text
                        end
        },
        {
            name = "护甲",
            widget_fn = function(self, width, height) 
                            local text = Text(BODYTEXTFONT, 25)
                            local absorb = self.owner.components.extrameta:GetAbsorb()
                            local invincible = self.owner.components.extrameta:IsInvincible()
                            text:SetString(invincible and "无敌的" or (math.floor(absorb * 100 + 0.5).."%"))
                            text:SetColour(unpack(invincible and {1, 0, 0, 1} or {1, 1, 1, 1}))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("extraabsorbdirty", function(inst) 
                                absorb = inst.components.extrameta:GetAbsorb()
                                invincible = inst.components.extrameta:IsInvincible()
                                text:SetString(invincible and "无敌的" or (math.floor(absorb * 100 + 0.5).."%"))
                                text:SetColour(unpack(invincible and {1, 0, 0, 1} or {1, 1, 1, 1}))
                            end, self.owner)
                            return text
                        end
        },
        {
            name = "荆棘",
            widget_fn = function(self, width, height) 
                            local text = Text(BODYTEXTFONT, 25)
                            local percent, common = self.owner.components.attackback:Get()
                            text:SetString(percent.."% + "..math.floor(common))
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("attackbackdirty", function(inst) 
                                percent, common = inst.components.attackback:Get()
                                text:SetString(percent.."% + "..math.floor(common))
                            end, self.owner)
                            return text
                        end
        },
        {
            name = "速度",
            widget_fn = function(self, width, height) 
                            local text = Text(BODYTEXTFONT, 25)
                            local speed = self.owner.components.extrameta:GetSpeed()
                            text:SetString(speed)
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("extraspeeddirty", function(inst) 
                                speed = inst.components.extrameta:GetSpeed()
                                text:SetString(speed)
                            end, self.owner)
                            return text
                        end
        },
        {
            name = "生命偷取",
            widget_fn = function(self, width, height) 
                            local text = Text(BODYTEXTFONT, 25)
                            local percent = self.owner.components.lifesteal:GetFinalPercent()
                            text:SetString((percent).."%")
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("lifestealdirty", function(inst) 
                                percent = inst.components.lifesteal:GetFinalPercent()
                                text:SetString(percent.."%")
                            end, self.owner)
                            return text
                        end
        },
        {
            name = "幸运",
            widget_fn = function(self, width, height) 
                            local text = Text(BODYTEXTFONT, 25)
                            local luck = self.owner.components.luck:GetLuck()
                            text:SetString(luck)
                            text:SetVAlign(ANCHOR_MIDDLE)
                            text:SetHAlign(ANCHOR_LEFT)
                            text:SetRegionSize(width, height*0.9)
                            text.inst:ListenForEvent("luckdirty", function(inst) 
                                luck = inst.components.luck:GetLuck()
                                text:SetString(luck)
                            end, self.owner)
                            return text
                        end
        },
    }

    self.names = {}
    self.values = {}
    self.horizontal_line = {}
    local max_line = #meta_data
    local height_line = math.ceil(480/max_line)
    for k=1, max_line do
        self.horizontal_line[k] = self.content:AddChild(Image("images/ui.xml", "line_horizontal_6.tex"))
        self.horizontal_line[k]:SetScale(1.05, .25)
        self.horizontal_line[k]:SetPosition(7, 240 - height_line * k)

        self.names[k] = self.content:AddChild(Text(TALKINGFONT, 30))
        self.names[k]:SetVAlign(ANCHOR_MIDDLE)
        self.names[k]:SetHAlign(ANCHOR_RIGHT)
        self.names[k]:SetPosition(-95, 240 - height_line * (k - 0.5), 0)
        self.names[k]:SetString(meta_data[k].name)
        self.names[k]:SetRegionSize(160, height_line*0.9)

        self.values[k] = self.content:AddChild(meta_data[k].widget_fn(self, 160, height_line))
        self.values[k]:SetPosition(95, 240 - height_line * (k - 0.5), 0)
    end 
    
end

function PlayerDetail:SetSkillData()
    self.content:KillAllChildren()
    self.skills_scroll_list = nil

    self.desc = self.content:AddChild(Widget("desc"))
    self.desc:SetPosition(0, -165)
    self.desc.backing = self.desc:AddChild(TEMPLATES2.ListItemBackground(330, 130))
    self.desc.backing:SetClickable(false)
    self.desc.text = self.desc:AddChild(Text(NUMBERFONT, 26, "", {0, 1, 0, 1}))
    self.desc.text:SetRegionSize(300, 110)
    self.desc.text:SetHAlign(ANCHOR_LEFT)
    self.desc.text:SetVAlign(ANCHOR_TOP)
    self.desc.btn = self.desc:AddChild(TEMPLATES2.StandardButton(nil, "升级", {60, 40}))
    self.desc.btn:SetPosition(120, 35)
    self.desc.btn:Disable()
    self.desc.btn:Hide()

    self.skills = self.content:AddChild(Widget("skills"))
    self.skills:SetPosition(0, 65)
    self:LoadSkills()
end

function PlayerDetail:RefreshDesc()
    local item = self.desc.data
    if item then
        local cost = item.cost or 0
        local max_level = item.max_level or 1
        local level = item.level_fn and item:level_fn(self.owner) or 0
        if cost > 0 then
            if level >= max_level then
                self.desc.btn:Disable()
                self.desc.btn:SetOnClick(nil)
                self.desc.btn:SetText("已满级")
            else
                self.desc.btn:SetOnClick(function() 
                    if item.levelup_fn then
                        item:levelup_fn(self.owner)
                    end
                end)
                self.desc.btn:Enable()
                self.desc.btn:SetText("升级")
            end
            self.desc.btn:Show()
        else
            self.desc.btn:Disable()
            self.desc.btn:Hide()
            self.desc.btn:SetOnClick(nil)
        end
        local str = item.desc_fn and item:desc_fn(self.owner) or item.name..""
        self.desc.text:SetMultilineTruncatedString(str, 5, 300, 20, "", false)
    end
end

function PlayerDetail:LoadSkills()
    local item_width, item_height = 80, 60
    local function SkillItem(index)
        local skill_item = Widget("SkillItem-"..index)

        skill_item.backing = skill_item:AddChild(TEMPLATES2.ListItemBackground(item_width, item_height, function() end))
        skill_item.backing.move_on_click = true
        local item_backing = skill_item.backing

        skill_item.title = item_backing:AddChild(Text(NEWFONT, 24, "", {1, 1, 0, 1}))
        skill_item.title:SetPosition(0, 15)
        skill_item.title:SetHAlign(ANCHOR_LEFT)
        skill_item.title:SetRegionSize(70, 30)
        skill_item.level = item_backing:AddChild(Text(NUMBERFONT, 20, "", {1, 1, 0, 1}))
        skill_item.level:SetPosition(0, -15)
        skill_item.level:SetHAlign(ANCHOR_RIGHT)
        skill_item.level:SetRegionSize(70, 30)

        skill_item.SetInfo = function(_, data)
            if skill_item.coin then
                skill_item.coin:Kill()
                skill_item.coin = nil
            end

            local item = data.skill
            local id = item.id
            local name = item.name or ""
            local max_level = item.max_level or 1
            local level = item.level_fn and item:level_fn(self.owner) or 0
            local cost = item.cost or 0

            --skill_item.title:SetMultilineTruncatedString(item.name, 2, 70, 4, "...", false)
            skill_item.title:SetString(item.name)
            local level_str = "Lv "..(level>=max_level and "MAX" or level)
            skill_item.level:SetString(level_str)

            if level >= max_level then
                skill_item.title:SetColour({1, 0.8, 0.1, 1})
                skill_item.level:SetColour({1, 0.8, 0.1, 1})
            elseif level > 0 then
                skill_item.title:SetColour({0, 1, 0, 1})
                skill_item.level:SetColour({0, 1, 0, 1})
            else
                skill_item.title:SetColour({1, 1, 0, 1})
                skill_item.level:SetColour({1, 1, 0, 1})
            end

            if cost > 0 then
                skill_item.coin = skill_item.backing:AddChild(Image("images/hud.xml", "tab_refine.tex"))
                skill_item.coin:SetScale(0.16)
                skill_item.coin:SetPosition(-32, -15)
                skill_item.coin.value = skill_item.coin:AddChild(Text(NUMBERFONT, 120, "", {1, 0, 0, 1}))
                skill_item.coin.value:SetPosition(90, 0)
                skill_item.coin.value:SetString(-cost)
            else
                if (type(item.exclusive) == "table" and table.contains(item.exclusive, self.owner.prefab)) or
                    (type(item.exclusive) == "string" and item.exclusive == self.owner.prefab) then
                    local image_name = "avatar_"..self.owner.prefab..".tex"
                    local atlas_name = "images/avatars/avatar_"..self.owner.prefab..".xml"
                    if softresolvefilepath(atlas_name) == nil then
                        atlas_name = "images/avatars.xml"
                    end
                    skill_item.coin = skill_item.backing:AddChild(Image(atlas_name, image_name))
                    skill_item.coin:SetPosition(-28, -15)
                    skill_item.coin:SetScale(0.3)
                end
            end
            if skill_item.coin == nil then
                skill_item.coin = self:AddChild(Widget("ForEvent"))
                skill_item.coin:Hide()
            end

            --skill_item:SetClickable(true) --没卵用
            skill_item.backing:SetOnClick(function()
                --此处做宣告使用
                if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
                    if not self.cooldown then
                        TheNet:Say(name..":"..level_str, false)
                        
                        self.cooldown = true
                        self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
                    end
                end
                --local str = item.desc_fn and item:desc_fn(self.owner) or name..""
                --self.desc.text:SetMultilineTruncatedString(str, 5, 300, 15, "", false)
                self.desc.data = item
                self:RefreshDesc()
                
            end)
            skill_item.coin.inst:ListenForEvent(id.."skilldirty", function(owner) 
                skill_item:SetInfo(data)
                if self.desc.data and self.desc.data.id == id then
                    self:RefreshDesc()
                end
            end, self.owner)
        end

        skill_item.focus_forward = skill_item.backing
        return skill_item
    end
    local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)

        widget:SetOnGainFocus(function()
            self.skills_scroll_list:OnWidgetFocus(widget)
        end)

        widget.item = widget:AddChild(SkillItem(index))
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

    self.skills_data = {}
    if skill_constant then
        for k, v in pairs(skill_constant) do
            if v.id then
                if v.exclusive == nil or
                    (type(v.exclusive) == "table" and table.contains(v.exclusive, self.owner.prefab)) or
                    (type(v.exclusive) == "string" and v.exclusive == self.owner.prefab) then
                    if not v.hide or (v.level_fn and v:level_fn(self.owner) > 0) then
                        table.insert(self.skills_data, {index=v.id, skill=v})
                    end
                end
            end
        end
    end

    if not self.skills_scroll_list then
        self.skills_scroll_list = self.skills:AddChild(
                                     TEMPLATES2.ScrollingGrid(self.skills_data, {
                context = {},
                widget_width = item_width,
                widget_height = item_height,
                num_visible_rows = 5,
                num_columns = 4,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 15,
                scrollbar_height_offset = -10,
                peek_percent = 0, -- may init with few clientmods, but have many servermods.
                allow_bottom_empty_row = true -- it's hidden anyway
            }))

        self.skills_scroll_list:SetPosition(0, 0)

        self.skills_scroll_list:SetFocusChangeDir(MOVE_DOWN, self.close_button)
        self.close_button:SetFocusChangeDir(MOVE_UP, self.skills_scroll_list)
    end
end

function PlayerDetail:GetLevel()
    return self.owner.components.level and self.owner.components.level.net_data
        and self.owner.components.level.net_data.level:value() or 1
end

function PlayerDetail:GetXp()
    local xp = 0 
    local needxp = 0
    if self.owner.components.level then
        xp = self.owner.components.level.net_data.xp:value() or 0
        needxp = self.owner.components.level:GetLevelUpNeedXp() or 0
    end
    return xp, needxp
end

local function Divide(a, b)
    return a / b
end

function PlayerDetail:LoadTitles()
    local item_width, item_height = 320, 160
    local function TitlesItem(index)
        local titles_item = Widget("TitlesItem-"..index)

        titles_item.backing = titles_item:AddChild(TEMPLATES2.ListItemBackground_Static(item_width, item_height))
        titles_item.backing.move_on_click = true
        local item_backing = titles_item.backing

        titles_item.conditions = item_backing:AddChild(Text(BODYTEXTFONT, 24, "", {1, 0.9, 0.55, 1}))
        titles_item.conditions:SetPosition(-20, 0)
        titles_item.conditions:SetRegionSize(240, 150)
        titles_item.conditions:SetHAlign(ANCHOR_LEFT)
        titles_item.conditions:SetVAlign(ANCHOR_MIDDLE)
        titles_item.SetInfo = function(_, data)
            if titles_item.image ~= nil then
                titles_item.image:Kill()
                titles_item.image = nil
            end
            if titles_item.btn ~= nil then
                titles_item.btn:Kill()
                titles_item.btn = nil
            end
            if titles_item.vip ~= nil then
                titles_item.vip:Kill()
                titles_item.vip = nil
            end

            local item = data.title
            local name = item.id
            local conditions = item.conditions

            local player_conditions = self.owner.components.titles.net_data[name]:value() or {}
            local player_equip = self.owner.components.titles.net_data.equip:value() or ""
            local condition_str = ""
            local get = true
            for k, v in pairs(conditions) do
                condition_str = condition_str.."【需】"..v.condition..(player_conditions[k] ~= nil and player_conditions[k] > 0 and "【完成】" or "").."\n"
                get = player_conditions[k] ~= nil and player_conditions[k] > 0 and get or false
            end
            condition_str = condition_str..item.desc
            titles_item.conditions:SetMultilineTruncatedString(condition_str, 7, 240, 18, "", false)
            titles_item.conditions:SetColour(get and {0, 1, 0, 1} or {1,0.9,0.55,1})

            local atlas_name = "images/titles/"..name..".xml"
            local tex_name = name..".tex"
            titles_item.image = item_backing:AddChild(Image(atlas_name, tex_name))
            titles_item.image:SetPosition(0, 0)
            if get then
                titles_item.image:SetTint(1, 1, 1, 1)
                titles_item.btn = item_backing:AddChild(TEMPLATES2.LabelCheckbox(function(w)
                    w.checked = not w.checked
                    if w.checked then
                        SendModRPCToServer(MOD_RPC.RPG_titles.equip, name)
                    else
                        SendModRPCToServer(MOD_RPC.RPG_titles.unequip, name)
                    end
                    w:Refresh()
                end, player_equip == name, "佩戴"))
                titles_item.btn:SetPosition(90, 55)
                titles_item.btn.inst:ListenForEvent("titlesequipdirty", function(owner) 
                    titles_item.btn.checked = self.owner.components.titles.net_data.equip:value() == name
                    titles_item.btn:Refresh()
                end, self.owner)
            else
                titles_item.image:SetTint(0.7, 0.7, 0.7, 0.7)
            end
            if name == "vip" then
                titles_item.vip = item_backing:AddChild(TEMPLATES2.StandardButton(function() 
                    SendModRPCToServer(MOD_RPC.RPG_vip.refresh)
                    VisitURL("http://vip.tumbleweedofall.xyz:8008?userid="..self.owner.userid)
                end, "获取", {60, 40}))
                titles_item.vip:SetPosition(110, -55)
                if get then
                    titles_item.vip:SetText("升级")
                end
            end
            titles_item.conditions:MoveToFront()
            --titles_item.image:MoveToBack()

            --[[titles_item.backing:SetOnClick(function()
                --此处做宣告使用
                if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
                    if not self.cooldown then
                        --TheNet:Say(name..":"..level_str, false)
                        
                        self.cooldown = true
                        self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
                    end
                end
                --local str = item.desc_fn and item:desc_fn(self.owner) or name..""
                --self.desc.text:SetMultilineTruncatedString(str, 5, 300, 15, "", false)

            end)]]

            titles_item.image.inst:ListenForEvent("titles"..name.."dirty", function(owner) 
                titles_item:SetInfo(data)
            end, self.owner)
        end

        titles_item.focus_forward = titles_item.backing
        return titles_item
    end
    local function ScrollWidgetsCtor(context, index)
        local widget = Widget("widget-" .. index)

        widget:SetOnGainFocus(function()
            self.titles_scroll_list:OnWidgetFocus(widget)
        end)

        widget.item = widget:AddChild(TitlesItem(index))
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

    self.titles_data = {}
    if titles_data then
        for k, v in pairs(titles_data) do
            if v.id and (not v.hide or self.owner.components.titles:CheckTitles(v.id)) then
                if v.exclusive == nil or
                    (type(v.exclusive) == "table" and table.contains(v.exclusive, self.owner.prefab)) or
                    (type(v.exclusive) == "string" and v.exclusive == self.owner.prefab) then
                    table.insert(self.titles_data, {index=v.id, title=v})
                end
            end
        end
    end

    if not self.titles_scroll_list then
        self.titles_scroll_list = self.titles:AddChild(
                                     TEMPLATES2.ScrollingGrid(self.titles_data, {
                context = {},
                widget_width = item_width,
                widget_height = item_height,
                num_visible_rows = 3,
                num_columns = 1,
                item_ctor_fn = ScrollWidgetsCtor,
                apply_fn = ApplyDataToWidget,
                scrollbar_offset = 15,
                scrollbar_height_offset = -10,
                peek_percent = 0, -- may init with few clientmods, but have many servermods.
                allow_bottom_empty_row = true -- it's hidden anyway
            }))

        self.titles_scroll_list:SetPosition(0, 0)

        --self.titles_scroll_list:SetFocusChangeDir(MOVE_DOWN, self.close_button)
        --self.close_button:SetFocusChangeDir(MOVE_UP, self.titles_scroll_list)
    end
end

function PlayerDetail:SetTitlesData()
    self.content:KillAllChildren()
    self.titles_scroll_list = nil

    self.titles = self.content:AddChild(Widget("titles"))
    self.titles:SetPosition(0, 0)
    
    SendModRPCToServer(MOD_RPC.RPG_titles.check)
    self:LoadTitles()
end

function PlayerDetail:Layout()
    self.frame = self.proot:AddChild(TEMPLATES.CurlyWindow(130, 540, .6, .6, 39, -25))
    self.frame:SetPosition(0, 20)

    self.frame_bg = self.frame:AddChild(Image("images/fepanel_fills.xml", "panel_fill_tall.tex"))
    self.frame_bg:SetScale(.51, .74)
    self.frame_bg:SetPosition(5, 7)


    local w, h = self.frame_bg:GetSize()

    self.out_pos = Vector3(.5 * w, 0, 0)
    self.in_pos = Vector3(-.95 * w, 0, 0)

    self:MoveTo(self.out_pos, self.in_pos, .33, function()  end)

    self.title = self.proot:AddChild(Text(TALKINGFONT, 30))
    self.title:SetPosition(-50, 282, 0)
    self.title:SetTruncatedString(self.owner:GetDisplayName(), 200, 35, true)

    self.level = self.proot:AddChild(Widget("Experience"))
    self.level:SetPosition(30, 250)
    self.level.text = self.level:AddChild(Text(NUMBERFONT, 25))
    self.level.text:SetPosition(125, 0)
    self.level.text:SetString("Lv "..self:GetLevel())
    self.level.text:SetColour(0, 1, 0, 1)
    self.level.text:SetVAlign(ANCHOR_MIDDLE)
    self.level.text:SetHAlign(ANCHOR_LEFT)
    self.level.text:SetRegionSize(40, 40)
    self.level.text.inst:ListenForEvent("leveldirty", function(inst) 
        self.level.text:SetString("Lv "..self:GetLevel())
    end, self.owner)
    self.level.xpbtn = self.level:AddChild(Button())
    self.level.xpbar = self.level.xpbtn:AddChild(TEMPLATES2.LargeScissorProgressBar())
    self.level.xpbar:SetScale(0.32, 0.6)
    self.level.xpbar.xp = self.level.xpbar:AddChild(Text(BODYTEXTFONT, 30))
    self.level.xpbar.xp:SetScale(2, 1)
    self.level.xpbar.xp:SetString(string.format("%d/%d", self:GetXp()))

    self.level.xpbar:SetPercent(Divide(self:GetXp()))
    self.level.xpbar.inst:ListenForEvent("xpdirty", function(inst) 
        self.level.xpbar.xp:SetString(string.format("%d/%d", self:GetXp()))
        self.level.xpbar:SetPercent(Divide(self:GetXp()))
    end, self.owner)
    self.level.xpbtn:SetOnClick(function() 
        --此处做宣告使用
        if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
            if not self.cooldown then
                local str = "我的等级：Lv%s （%d%%）"
                TheNet:Say(string.format(str, self:GetLevel(), 100*Divide(self:GetXp())), false)
                self.cooldown = true
                self.inst:DoTaskInTime(3, function() self.cooldown = nil end)
            end
        end
    end)
    
    self.puppet = self.proot:AddChild(PlayerAvatarPortrait())
    self.puppet:SetPosition(-120, 268)
    self.puppet:SetScale(0.5)
    local obj = TheNet:GetClientTableForUser(self.owner.userid)
    self.puppet:UpdatePlayerListing(nil, nil, self.owner.prefab, GetSkinsDataFromClientTableData(obj))

    self.content = self.proot:AddChild(Widget("content"))
    self.content:SetPosition(0, -10)

    local options = {
        { text = "个人信息", data = 1 },
        { text = "我的技能", data = 2 },
        { text = "我的称号", data = 3 }
    }
    self.top_nav = self.proot:AddChild(TEMPLATES.LabelSpinner("", options, 0, 160, 50, 20, NEWFONT, 30, -10))
    self.top_nav:SetPosition(100, 288)
    self.top_nav.spinner:SetTextColour(1,0.4,0.35,1)
    self.top_nav.spinner:SetOnChangedFn(function(selected, old) 
        if selected == 1 then
            self.top_nav.spinner:SetTextColour(1,0.4,0.35,1)
            self:SetPlayerData()
        elseif selected == 2 then
            self.top_nav.spinner:SetTextColour(0.5,0.35,0.18,1)
            self:SetSkillData()
        else
            self.top_nav.spinner:SetTextColour(0,0.78,1,1)
            self:SetTitlesData()
        end
    end)
    self:SetPlayerData()

    self.close_button = self.proot:AddChild(TEMPLATES.SmallButton(STRINGS.UI.PLAYER_AVATAR.CLOSE, 26, .5, function() 
        self.owner.HUD:ClosePlayerDetail()
    end))
    self.close_button:SetPosition(0, -269)
end

function PlayerDetail:Close()
    self:MoveTo(self.in_pos, self.out_pos, .33, function() self:Kill() end)
    SendModRPCToServer(MOD_RPC.RPG_meta.update, false)
end

function PlayerDetail:OnControl(control, down)
    if PlayerDetail._base.OnControl(self, control, down) then return true end
end

function PlayerDetail:OnGainFocus()
    self.camera_controllable_reset = TheCamera:IsControllable()
    TheCamera:SetControllable(false)
end

function PlayerDetail:OnLoseFocus()
    TheCamera:SetControllable(self.camera_controllable_reset == true)
end

return PlayerDetail