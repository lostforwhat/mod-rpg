local _G = GLOBAL
env.ACTIONS = GLOBAL.ACTIONS
env.ActionHandler = GLOBAL.ActionHandler

--[[
添加新动作
]]
--祈祷动作
AddAction("PRAY",_G.STRINGS.TUM.PRAY,function(act)
    if act.doer ~= nil and act.invobject ~= nil and act.invobject.components.prayable ~= nil then
        act.invobject.components.prayable:StartPray(act.invobject,act.doer)
        return true
    end
end)
AddComponentAction("INVENTORY", "prayable", function(inst,doer,actions,right)
    if doer:HasTag("player") then
        table.insert(actions, ACTIONS.PRAY)
    end
end)

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.PRAY, "give"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.PRAY,"give"))

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

AddStategraphActionHandler("wilson",ActionHandler(ACTIONS.CALL, "play_horn"))
AddStategraphActionHandler("wilson_client",ActionHandler(ACTIONS.CALL,"play_horn"))



--[[
以下代码修改原action，添加mod需要的逻辑，注册event等
并非新增action
]]

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

        if act.doer:HasTag("cookmaster") > 0 then
            local fn = stewer.task.fn
            stewer.task:Cancel()
            fn(act.target, stewer)
        end
        act.doer:PushEvent("docook", {product=stewer.product})
    end
end