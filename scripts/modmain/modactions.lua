local _G = GLOBAL
local TUNING = _G.TUNING
local ACTIONS = _G.ACTIONS
local ActionHandler = _G.ActionHandler
local State = _G.State
local FRAMES = _G.FRAMES
local TimeEvent = _G.TimeEvent
local EventHandler = _G.EventHandler

--[[
添加新动作
]]
--祈祷动作
AddAction("PRAY",_G.STRINGS.TUM.PRAY,function(act)
    if act.doer ~= nil and act.invobject ~= nil and act.invobject.components.prayable ~= nil then
        return act.invobject.components.prayable:StartPray(act.invobject,act.doer)
    end
end)
AddComponentAction("INVENTORY", "prayable", function(inst,doer,actions,right)
    if doer:HasTag("player") then
        table.insert(actions, ACTIONS.PRAY)
    end
end)

local function prayfn(inst, action)
    if action.invobject ~= nil and action.invobject:HasTag("skillbook") then
        return "dolongaction"
    end
    return "give"
end

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.PRAY, prayfn))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.PRAY, prayfn))

--召集
AddAction("CALL",_G.STRINGS.TUM.CALL,function(act)
    if act.doer ~= nil and act.invobject ~= nil and act.invobject.components.caller ~= nil then
        return act.invobject.components.caller:CallStart(act.doer)
    end
end)
AddComponentAction("INVENTORY", "caller", function(inst,doer,actions,right)
    if doer:HasTag("player") then
        table.insert(actions, ACTIONS.CALL)
    end
end)

_G.TOOLACTIONS["CALL"] = true

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.CALL, "play_horn"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.CALL, "play"))

--使用钻石
AddAction("USEDIAMOND", _G.STRINGS.TUM.USEDIAMOND, function(act)
    if act.doer ~= nil and act.invobject ~= nil and act.invobject.components.diamond ~= nil then
        act.invobject.components.diamond:Use(act.doer)
        return true
    end
end)
AddComponentAction("INVENTORY", "diamond", function(inst, doer, actions, right)
    if doer:HasTag("player") then
        table.insert(actions, ACTIONS.USEDIAMOND)
    end
end)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.USEDIAMOND, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.USEDIAMOND, "dolongaction"))

--task
AddAction("GETTASK", _G.STRINGS.TUM.GETTASK, function(act)
    if act.doer ~= nil and act.target ~= nil and act.target.components.npctask ~= nil and not act.target.components.npctask.tasking then
        act.target.components.npctask:Check(act.doer)
        return true
    end
end)
AddComponentAction("SCENE", "npctask", function(inst, doer, actions, right) 
    if right and inst:HasTag("npctask") and doer ~= nil and doer:HasTag("player") and not doer:HasTag("playerghost") then
        table.insert(actions, ACTIONS.GETTASK)
    end
end)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GETTASK, "give"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GETTASK, "give"))

--野蛮冲撞
AddAction("COLLIDE",_G.STRINGS.TUM.COLLIDE, function(act)
    local act_pos = act:GetActionPoint()
    if act.invobject ~= nil 
        and act.doer ~= nil
        and act.doer.sg ~= nil
        --and act.doer.sg.currentstate.name == "portal_jumpin_pre"
        and act_pos ~= nil
        and not act.doer:HasTag("playerghost")
        and act.doer:HasTag("wxrunhit")
        and act.doer.components.timer ~= nil 
        and not act.doer.components.timer:TimerExists("wxrunhit") then
        act.doer.sg:GoToState("wxrunhit", act_pos)
        act.doer.components.timer:StartTimer("wxrunhit", 10)
        return true
    end
end)

AddComponentAction("SCENE", "combat", function(inst, doer, actions, right) 
    if right and not doer.replica.rider:IsRiding() and doer:HasTag("wxrunhit")
        and inst.replica.combat ~= nil and inst.replica.combat:CanBeAttacked(doer)
        and doer.components.timer ~= nil 
        and not doer.components.timer:TimerExists("wxrunhit") then
        table.insert(actions, ACTIONS.COLLIDE)
    end
end)

--AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.COLLIDE, "wxrunhit"))
--AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.COLLIDE, "wxrunhit"))

------根据actions 修改stategraph
AddStategraphState("wilson", State{
    name = "wxrunhit",
    tags = {"moving", "running", "wxrunhit"},
    onenter = function(inst, dest)
        local buffaction = inst:GetBufferedAction()
        local target = buffaction ~= nil and buffaction.target or nil
        inst.components.locomotor:Stop()
        if target ~= nil and target:IsValid() then
            inst:FacePoint(target:GetPosition())
        end
        inst.AnimState:SetBank("rook")
        inst.AnimState:SetBuild("rook_build")
        --inst.Transform:SetScale(0.6,0.6,0.6)
        inst.AnimState:PlayAnimation("atk", true)
        
        inst.components.locomotor.runspeed = 20
        --inst.components.locomotor:GoToPoint(dest, nil, true)
        print("test----------------")
        inst.sg:SetTimeout(2 * FRAMES)
    end,
    onupdate = function(inst)
        inst.components.locomotor:RunForward()
    end,
    timeline = {
        TimeEvent(0*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        TimeEvent(35*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        TimeEvent(70*FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },
    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,
    events = {
        EventHandler("onreachdestination", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
    },
    onexit = function(inst)
        inst.components.locomotor.runspeed = 6
        inst.AnimState:SetBank("wilson")
        inst.AnimState:SetBuild("wx78")
    end,
})

AddStategraphState("wilson_client", State{
    name = "wxrunhit",
    tags = {"moving", "running", "wxrunhit"},
    onenter = function(inst, dest)
        inst.components.locomotor:Stop()
        local target = buffaction ~= nil and buffaction.target or nil
        inst.components.locomotor:Stop()
        if target ~= nil and target:IsValid() then
            inst:FacePoint(target:GetPosition())
        end
        inst.sg:SetTimeout(2 * FRAMES)
        --inst.components.locomotor.runspeed = 60
        --inst.components.locomotor:GoToPoint(dest, nil, true)
    end,
    onupdate = function(inst)
        --inst.components.locomotor:RunForward()
    end,
    timeline = {
        
    },
    ontimeout = function(inst)
        inst.sg:GoToState("idle")
    end,
    events = {
        EventHandler("onreachdestination", function(inst)
            inst.sg:GoToState("idle")
        end),
        EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
    },
    onexit = function(inst)
        --inst.components.locomotor.runspeed = 6
    end,
})


--[[
以下代码修改原action，添加mod需要的逻辑，注册event等
并非新增action
]]

local function NewQuickAction(inst, action)
    if inst and inst:HasTag("pickmaster") then
        return "doshortaction"
    elseif action.target and action.target.components.pickable then
        if action.target.components.pickable.quickpick then
            return "doshortaction"
        else
            return "dolongaction"
        end
    else 
        return "dolongaction"
    end
end

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PICK, NewQuickAction))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.TAKEITEM, NewQuickAction))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.HARVEST, NewQuickAction))

--修改give逻辑
local GIVE = ACTIONS.GIVE
local old_give_fn = GIVE.fn
GIVE.fn = function(act, ...)

    --[[
    local trader = nil
    if act.target and act.target.components then
        trader = act.target.components.trader
    end
    ]]

    local result = old_give_fn(act)
    if act.doer and result and act.target and act.invobject and act.invobject.onlytask == nil then
        act.doer:PushEvent("givesomething", {item=act.invobject, target=act.target})
        act.invobject.onlytask = act.invobject:DoTaskInTime(0.35, function()  act.invobject.onlytask = nil end)
    end

    return result
end

--修改cook逻辑
local COOK = ACTIONS.COOK
local old_cook_fn = COOK.fn
COOK.fn = function(act, ...)
    local result = old_cook_fn(act)
    local stewer = act.target.components.stewer
    if result and stewer ~= nil then

        if act.doer:HasTag("cookmaster") then
            local fn = stewer.task.fn
            stewer.task:Cancel()
            fn(act.target, stewer)
        end
        act.doer:PushEvent("docook", {product=stewer.product})
    end
end

--修改施肥
local FERTILIZE = ACTIONS.FERTILIZE
local old_fertilize_fn = FERTILIZE.fn
FERTILIZE.fn = function(act, ...)
    if act.invobject ~= nil and act.invobject.components.fertilizer ~= nil then
        if act.target:HasTag("volcanic") == act.invobject:HasTag("volcanic") then
            return old_fertilize_fn(act, ...)
        end
    end
end
