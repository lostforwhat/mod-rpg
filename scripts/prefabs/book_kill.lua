local assets =
{
    Asset("ANIM", "anim/new_books.zip"),
    Asset("IMAGE", "images/book_kill.tex"),
    Asset("ATLAS", "images/book_kill.xml"),
}

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function Onread(inst, reader)
    reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    
    local max_rad = 8
    if reader.prefab ~= "wickerbottom" then
        max_rad = 5
    end
    local pt = owner:GetPosition()
    for k=1, max_rad do 
        local n = 2*k + 2
        for j=1, n do
            local offset = FindWalkableOffset(pt, j * 2 * PI, k, 3, false, true, NoHoles)
            if offset ~= nil then
                local tentacle = SpawnPrefab("shadowtentacle_player")
                if tentacle ~= nil then
                    tentacle:SetOwner(reader)
                    tentacle.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
                end
            end
        end
    end
    if inst.SoundEmitter ~= nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_1")
        inst.SoundEmitter:PlaySound("dontstarve/common/shadowTentacleAttack_2")
    end

    if reader.prefab ~= "wickerbottom" and reader.components.talker then 
        reader.components.talker:Say(STRINGS.TALKER_BOOK_KILL_COMMON) 
    end
    return true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("new_books")
    inst.AnimState:SetBuild("new_books")
    inst.AnimState:PlayAnimation("book_kill")
    inst.Transform:SetScale(2, 2, 1)

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------------------

    inst:AddComponent("inspectable")
    inst:AddComponent("book")
    inst.components.book.onread = Onread

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "book_kill"
    inst.components.inventoryitem.atlasname = "images/book_kill.xml"

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(5)
    inst.components.finiteuses:SetUses(5)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
    MakeHauntableLaunch(inst)

    return inst
end


return Prefab("book_kill", fn, assets)
