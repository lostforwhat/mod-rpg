--武器强化，先使用龙鳞火炉作为强化装置
local _G = GLOBAL
local require = _G.require
local Vector3 = _G.Vector3
local containers = require("containers")

local function DoStrengthen(player, inst)
    local container = inst.components.container
    local status = 0
    local weapon = container:GetItemInSlot(1)
    if weapon == nil or not weapon:HasTag("weapon")
      or weapon.components.weapon == nil or weapon.components.weaponlevel == nil then
        inst.components.talker:Say("请将需要熔炼的主武器放入第一格，熔炼材料放入后几格！")
        return
    end
    if weapon.components.stackable ~= nil then
        inst.components.talker:Say("装备不符合熔炼条件！")
        return
    end

    local items = {}
    for i = 2, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item ~= nil then
            if not item:HasTag("nonpotatable") and not item:HasTag("irreplaceable") then
                items[i] = item
                --container:RemoveItemBySlot(i)
                --item:Remove()
            else
                status = 2
                break
            end
        end
    end
    if status == 2 then
        inst.components.talker:Say("含有不合格的熔炼材料！")
        return
    end
    if _G.next(items) == nil then
        inst.components.talker:Say("请在2~4格放入熔炼材料！")
        return
    end
    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
    end
    
    local basedamage = type(weapon.components.weapon.damage) == "number" and weapon.components.weapon.damage or 34
    local baselevel = weapon.components.weaponlevel.level or 0
    local rate = 0
    for k, v in pairs(items) do
        if v:HasTag("weapon") then
            local damage = v.components.weapon.damage
            damage = type(damage) == "number" and damage or 34 --base spear

            if v.components.stackable ~= nil then
                local num = v.components.stackable:StackSize()
                rate = rate + 0.05 * num * math.pow(damage / basedamage, 2)
            else
                local level = v.components.weaponlevel.level or 0
                rate = rate + (level + 1) * math.pow(damage / basedamage, 2)
            end
        else
            local num = v.components.stackable and v.components.stackable:StackSize() or 1
            if string.sub(v.prefab, -3) == "gem" then
                rate = rate + num * .1
            elseif v:HasTag("molebait") then
                rate = rate + num * .01
            elseif v.components.armor ~= nil then
                local absorb_percent = v.components.armor.absorb_percent or 0
                rate = rate + .5 + (absorb_percent - .6) * 4
            else
                rate = rate + num * .001
            end
        end
        local it = container:RemoveItemBySlot(k)
        it:Remove()
    end
    local success = weapon.components.weaponlevel:DoStrengthen(player, math.clamp(rate / (1 + baselevel), 0, 1))
    inst.components.container:Close()
    if success then
        inst.components.talker:Say("恭喜熔炼成功！")
    else
        inst.components.talker:Say("熔炼失败！")
    end
end

local params = {
    dragonflyfurnace = {
        widget = {
            slotpos = {
                Vector3(0, 64 + 32 + 8 + 4, 0),
                Vector3(0, 32 + 4, 0),
                Vector3(0, -(32 + 4), 0),
                Vector3(0, -(64 + 32 + 8 + 4), 0),
            },
            animbank = "ui_cookpot_1x4",
            animbuild = "ui_cookpot_1x4",
            pos = Vector3(150, 0, 0),
            side_align_tip = 100,
            buttoninfo = {
                text = "熔炼",
                position = Vector3(0, -165, 0),
                fn = function(inst)
                    if _G.TheWorld.ismastersim then
                        DoStrengthen(inst.components.container.opener, inst)
                    else
                        SendModRPCToServer(_G.MOD_RPC.RPG_strengthen["strengthen"], inst)
                    end
                end
            }
        },
        type = "strengthen",
    }
}

local containers_widgetsetup_base = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
    local t = params[prefab or container.inst.prefab]
    if t ~= nil then
        for k, v in pairs(t) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
    else
        containers_widgetsetup_base(container, prefab, data, ...)
    end
end

AddModRPCHandler("RPG_strengthen", "strengthen", DoStrengthen)

containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.dragonflyfurnace.widget.slotpos ~= nil and #params.dragonflyfurnace.widget.slotpos or 0)

local function WidgetSetup(container)
    container:WidgetSetup("dragonflyfurnace")
end

local function InitWidget(inst)
    if inst.components.talker == nil then
        inst:AddComponent("talker")
    end
    inst.components.talker.fontsize = 35
    inst.components.talker.font = _G.TALKINGFONT
    inst.components.talker.colour = Vector3(.9, .1, .9)
    inst.components.talker.offset = Vector3(0, -500, 0)
    inst.components.talker:MakeChatter()

    if not _G.TheWorld.ismastersim then
        inst:DoTaskInTime(0, function()
            if inst.replica then
                if inst.replica.container then
                    WidgetSetup(inst.replica.container)
                end
            end
        end)
        return inst
    end
    if _G.TheWorld.ismastersim then
        if not inst.components.container then
            inst:AddComponent("container")
            WidgetSetup(inst.components.container)
        end
    end
end

AddPrefabPostInit("dragonflyfurnace", InitWidget)

--cover showme
require 'util'
local colour_tb = {
    '#76EEC6',
    '#B4EEB4',
    '#4EEE94',
    '#7FFF00',
    '#BBFFFF',
    '#8DEEEE',
    '#98F5FF',
    '#00FFFF',
    '#00BFFF',
    '#4169E1',
    '#0000FF',
    '#6A5ACD',
    '#FFC0CB',
    '#FF69B4',
    '#FF69B4',
    '#FF1493',
    '#FF00FF',
    '#FF0000',
    '#FFA500',
    '#FF7F00',
}
AddClassPostConstruct("widgets/hoverer",function(self)
    local OldSetString = self.text.SetString
    self.text.SetString = function(text, str)
        local target = _G.TheInput:GetHUDEntityUnderMouse()
        if target ~= nil then
            target = target.widget ~= nil and target.widget.parent ~= nil and target.widget.parent.item
        else
            target = _G.TheInput:GetWorldEntityUnderMouse()
        end
        if target ~= nil then
            --to do
            if target:HasTag("weapon") then
                local name = _G.STRINGS.NAMES[string.upper(target.prefab)]
                local st, ed, level = string.find(str, ""..name.."%s*+(%d+)")
                level = level ~= nil and _G.tonumber(level) or 1
                if level <= 20 then
                    local r,g,b = _G.HexToPercentColor(colour_tb[level or 1])
                    self.text:SetColour({r,g,b,1})
                else
                    local r,g,b = _G.HexToPercentColor('#FFFF00')
                    self.text:SetColour({r,g,b,1})
                end
            end
        end

        return OldSetString(text, str)
    end
end)