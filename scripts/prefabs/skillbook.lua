require "modmain/skill_constant"

local assets =
{
    Asset("ANIM", "anim/skillbook.zip"),
    Asset("IMAGE", "images/inventoryimages/skillbook.tex"),
    Asset("ATLAS", "images/inventoryimages/skillbook.xml"),
}

local function OnPray(inst, prayer)
    if prayer and not prayer:HasTag("playerghost") then 
        if inst.skill ~= nil and prayer.components.skilldata ~= nil then
            return prayer.components.skilldata:LevelUp(inst.skill, true)
        end
    end
end

local function onload(inst, data)
    if data ~= nil and data.skill ~= nil then
        inst.skill = data.skill
    end
end

local function onsave(inst, data)
    data.skill = inst.skill
end

local function OnHaunt(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        
        return true
    end
    return false
end

local function fn(grade)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("skillbook")
    inst.AnimState:SetBuild("skillbook")
    inst.AnimState:PlayAnimation("idle")
    inst.Transform:SetScale(0.8, 0.8, 1)

    inst:AddTag("skillbook")

    inst:AddTag("_named")

    if grade ~= nil then
        inst:SetPrefabName("skillbook_"..grade)
    else
        inst:SetPrefabName("skillbook")
    end
    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------------------
    inst:RemoveTag("_named")

    inst:AddComponent("inspectable")
    inst:AddComponent("prayable")
    inst.components.prayable:SetPrayFn(OnPray)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "skillbook"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/skillbook.xml"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    inst:AddComponent("named")
    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
    MakeHauntableLaunch(inst)
    AddHauntableCustomReaction(inst, OnHaunt, true, false, true)

    inst.OnLoad = onload
    inst.OnSave = onsave
    return inst
end


local function MakeAnySkillBook()
    local inst = fn()
    if not TheWorld.ismastersim then
        return inst
    end
    
    local skills = {}
    if skill_constant then
        for k, v in pairs(skill_constant) do
            if v.exclusive == nil and not v.nobook then
                table.insert(skills, v.id)
            end
        end
    end 
    inst.skill = (#skills > 0 and skills[math.random(#skills)]) or "unknown"
    inst.components.named:SetName(STRINGS.NAMES.SKILLS[string.upper(inst.skill)].." "..STRINGS.NAMES.SKILLBOOK)
    return inst
end

local function MakeSkillbookGrade(grade)
    return function()
        local inst = fn(grade)
        if not TheWorld.ismastersim then
            return inst
        end
        
        local skills = {}
        if skill_constant then
            for k, v in pairs(skill_constant) do
                if v.exclusive == nil and not v.nobook and v.grade == grade then
                    table.insert(skills, v.id)
                end
            end
        end 
        inst.skill = (#skills > 0 and skills[math.random(#skills)]) or "unknown"
        inst.components.named:SetName(STRINGS.NAMES.SKILLS[string.upper(inst.skill)].." "..STRINGS.NAMES.SKILLBOOK)
        return inst
    end
end

local function MakeSkillbook(skill)
    return function()
        local inst = fn()
        if not TheWorld.ismastersim then
            return inst
        end
        
        inst.skill = skill.id or "unknown"
        inst.components.named:SetName(STRINGS.NAMES.SKILLS[string.upper(inst.skill)].." "..STRINGS.NAMES.SKILLBOOK)
        return inst
    end
end

local prefabs = {}
table.insert(prefabs, Prefab("skillbook", MakeAnySkillBook, assets))

local grades = {}
if skill_constant then
    for k, v in pairs(skill_constant) do
        if v.exclusive == nil and not v.nobook then
            if v.grade ~= nil and not table.contains(grades, v.grade) then
                table.insert(grades, v.grade)
                table.insert(prefabs, Prefab("skillbook_"..v.grade, MakeSkillbookGrade(v.grade), assets))
            end
            table.insert(prefabs, Prefab(string.lower(v.id or "NONAME").."_skillbook", MakeSkillbook(v), assets))
        end
    end
end
grades = nil

return unpack(prefabs)
