local _G = GLOBAL
env.ACTIONS = GLOBAL.ACTIONS
env.ActionHandler = GLOBAL.ActionHandler

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