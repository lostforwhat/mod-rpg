require "utils/utils"

local skills = {
    resurrect = {
        level = 0,
        cd = 0,
    },
    rejectdeath = {
        level = 0,
        cd = 0,
    },
    stealth = {
        level = 0,
        cd = 0,
    },
}

local function UpdateSkill(inst, name, data)
    if inst._skills[name] ~= nil then
        for k, v in pairs(inst.skills[name]) do
            if data[k] ~= nil then
                inst.skills[name][k] = data.k
            end
        end
        inst._skills[name]:set(Table2String(inst.skills[name]))
        inst._skillsupdate:Push()
    end
end

local function UpdateSkillCd(inst, name, cd)
    if inst._skills[name] ~= nil then
        inst.skills[name].cd = cd
        inst._skills[name]:set(Table2String(inst.skills[name]))
        inst._skillsupdatecd:Push()
    end
end

local function OnSkillsUpdate(inst)
    for k, v in pairs(inst._skills) do
        inst.client_skills[k] = String2Table(v:value())
    end
end

local function GetSkills(inst)
    if TheWorld.ismastersim then
        return inst.skills
    else
        OnSkillsUpdate(inst)
        return inst.client_skills
    end
end

local function fn()
    local inst = CreateEntity()

    if TheWorld.ismastersim then
        inst.entity:AddTransform() -- So we can follow parent's sleep state
    end
    inst.entity:AddNetwork()
    inst.entity:Hide()
    inst:AddTag("CLASSIFIED")

    inst._skills = {
        resurrect = net_string(inst.GUID, "_skills.resurrect"),
        rejectdeath = net_string(inst.GUID, "_skills.rejectdeath"),
        stealth = net_string(inst.GUID, "_skills.stealth"),
    }
    inst._skillsupdate = net_event(inst.GUID, "_skillsupdate")
    inst._skillsupdatecd = net_event(inst.GUID, "_skillsupdatecd")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.client_skills = skills
        --inst:ListenForEvent("_skillsupdate", OnSkillsUpdate)
        --inst:ListenForEvent("_skillsupdatecd", OnSkillsUpdate)
        inst.GetSkills = GetSkills
        return inst
    end

    inst.skills = skills
    inst.UpdateSkill = UpdateSkill
    inst.UpdateSkillCd = UpdateSkillCd
    inst.GetSkills = GetSkills

    inst.persists = false

    return inst
end

return Prefab("player_skills_classified", fn)
