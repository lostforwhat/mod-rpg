local PI = GLOBAL.PI
local _G = GLOBAL
require("modmain/loot_table")
local loot_table = GLOBAL.loot_table

local function removetools(picker)
    if picker == nil or picker.components.inventory == nil then return end
    for k,v in pairs(picker.components.inventory.itemslots) do
        if v and (v.prefab=="multitool_axe_pickaxe"
            or v.prefab=="goldenpickaxe"
            or v.prefab=="pickaxe") then
            v:Remove()
        end
    end
    --装备栏
    for k,v in pairs(picker.components.inventory.equipslots) do
        if v and (v.prefab=="multitool_axe_pickaxe"
            or v.prefab=="goldenpickaxe"
            or v.prefab=="pickaxe") then
            v:Remove()
        end
    end
    --背包
    for k,v in pairs(picker.components.inventory.opencontainers) do
        if k and k:HasTag("backpack") and k.components.container then
            for i,j in pairs(k.components.container.slots) do
                if j and (j.prefab=="multitool_axe_pickaxe"
                    or j.prefab=="goldenpickaxe"
                    or j.prefab=="pickaxe") then
                    j:Remove()
                end
            end
        end
    end
end

local function removeweapon(picker)--破坏武器
    if picker == nil or picker.components.inventory == nil then return end
    for k,v in pairs(picker.components.inventory.equipslots) do
        if v --[[and (v.components.weapon or v:HasTag("weapon")
            or v.components.armor or v:HasTag("armor"))]]
            and v.components.finiteuses ~= nil then
            v.components.finiteuses:SetUses(1)
        else
            if math.random() < 0.3 and (v:HasTag("weapon") or v:HasTag("armor")) then
                v:Remove()
            end
        end
    end
end

local function doperish(picker)--腐烂陷阱
    if picker == nil or picker.components.inventory == nil then return end
    --old: 考虑到有可能有返鲜机制，允许100%腐烂
    --new: 考虑到武器有等级系统，装备栏最多腐烂当前一半
    local percent = math.random() * 2
    percent = math.clamp(percent, 0.5, 1)
    for k,v in pairs(picker.components.inventory.itemslots) do
        if v and v.components.perishable then
            local old = v.components.perishable:GetPercent()
            v.components.perishable:ReducePercent(percent)
        end
    end
    for k,v in pairs(picker.components.inventory.equipslots) do
        if v and v.components.perishable then
            local old = v.components.perishable:GetPercent()
            v.components.perishable:ReducePercent(old * .5)
        end
    end
    for k,v in pairs(picker.components.inventory.opencontainers) do
        if k and k:HasTag("backpack") and k.components.container then
            for i,j in pairs(k.components.container.slots) do
                if j and j.components.perishable then
                    local old = j.components.perishable:GetPercent()
                    j.components.perishable:ReducePercent(percent)
                end
            end
        end
    end
end

local function damned(picker)
    if picker == nil or picker.components.inventory == nil then return end

    for k,v in pairs(picker.components.inventory.equipslots) do
        if v and v.components.weaponlevel ~= nil then
            local old = v.components.weaponlevel.level or 0
            if old > 0 then
                v.components.weaponlevel:AddLevel(-1)
            else
                v:Remove()
            end
        end
    end
end

local function lightningTarget(picker)
    picker:StartThread(function()
        local x,y,z = picker.Transform:GetWorldPosition()
        local num = 10
        for k = 1, num do
            local r = math.random(1, 5)
            local angle = k * 2 * PI / num
            local pos = GLOBAL.Point(r*math.cos(angle)+x, y, r*math.sin(angle)+z)
            GLOBAL.TheWorld:PushEvent("ms_sendlightningstrike", pos)
            GLOBAL.Sleep(.2 + math.random())
        end
    end)
end

local function keepPickerStop(picker)
    if picker.components.freezable then
        picker.components.freezable:AddColdness(10, 3)
    end
end

local function AddWeapLevel(picker)
    if picker == nil or picker.components.inventory == nil then return end
    for k,v in pairs(picker.components.inventory.itemslots) do
        if v.components.weaponlevel ~= nil then
            v.components.weaponlevel:AddLevel(1)
        end
    end
    --装备栏
    for k,v in pairs(picker.components.inventory.equipslots) do
        if v.components.weaponlevel ~= nil then
            v.components.weaponlevel:AddLevel(1)
        end
    end
    --背包
    for k,v in pairs(picker.components.inventory.opencontainers) do
        if k and k:HasTag("backpack") and k.components.container then
            for i,j in pairs(k.components.container.slots) do
                if j.components.weaponlevel ~= nil then
                    j.components.weaponlevel:AddLevel(1)
                end
            end
        end
    end
end

local function spawnPlayerGift(picker)
    if picker == nil then return end
    local x,y,z = picker.Transform:GetWorldPosition()
    if picker.prefab == "wortox" then
        for k=1, 6 do
            local item = GLOBAL.SpawnPrefab("wortox_soul_spawn")
            local x_offset = math.random()*2-1
            local z_offset = math.random()*2-1
            item.Transform:SetPosition(x+x_offset, y, z+z_offset)
        end 
    end
    if picker.prefab == "wilson" then
        for k=1,10 do
            local item = GLOBAL.SpawnPrefab("glommerfuel")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "wendy" then
        for k=1,20 do
            local item = GLOBAL.SpawnPrefab("ghostflower")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "willow" then
        local item_tb = {"lighter", "bernie_active"}
        local item = GLOBAL.SpawnPrefab(item_tb[math.random(#item_tb)])
        picker.components.inventory:GiveItem(item)
    end
    if picker.prefab == "wickerbottom" then
        for k=1,16 do
            local item = GLOBAL.SpawnPrefab("papyrus")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "waxwell" then
        for k=1,20 do
            local item = GLOBAL.SpawnPrefab("nightmarefuel")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "webber" then
        for k=1,2 do
            local item = GLOBAL.SpawnPrefab("spiderhat")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "wes" then
        local item = GLOBAL.SpawnPrefab("bushhat")
        picker.components.inventory:GiveItem(item)
    end
    if picker.prefab == "winona" then
        for k=1,16 do
            local item = GLOBAL.SpawnPrefab("sewing_tape")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "woodie" then
        for k=1,5 do
            local item = GLOBAL.SpawnPrefab("monsterlasagna")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "wormwood" then
        for k=1,20 do
            local item = GLOBAL.SpawnPrefab("seeds")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "wurt" then
        for k=1,2 do
            local item = GLOBAL.SpawnPrefab("vegstinger_spice_chili")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "warly" then
        for k=1,10 do
            local item = GLOBAL.SpawnPrefab("spice_chili")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "wathgrithr" then
        for k=1,10 do
            local item = GLOBAL.SpawnPrefab("goldnugget")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "wolfgang" then
        for k=1,2 do
            local item = GLOBAL.SpawnPrefab("bonestew")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "wx78" then
        for k=1,2 do
            local item = GLOBAL.SpawnPrefab("gears")
            picker.components.inventory:GiveItem(item)
        end
    end
    if picker.prefab == "walter" then
        for k=1,20 do
            local item = GLOBAL.SpawnPrefab("rocks")
            picker.components.inventory:GiveItem(item)
        end
    end
end

local function needNotice(goods)
    local notice_goods = GLOBAL.notice_goods
    for i, v in ipairs(notice_goods) do
        if goods == v then 
            return true
        end
    end
    return false
end

local function spawnAtGround(name, x,y,z)
    if GLOBAL.TheWorld.Map:IsPassableAtPoint(x, y, z) then
        local item = GLOBAL.SpawnPrefab(name)
        if item then
            item.Transform:SetPosition(x, y, z)
            item:AddTag("tumbleweeddropped")
            return item
        end
    end
end

local function ApplyResistance(picker)
    local effect = _G.SpawnPrefab("display_effect")
    local rad = picker:GetPhysicsRadius(0)
    local x, y, z = picker.Transform:GetWorldPosition()
    effect.Transform:SetPosition(x, y + .5 * rad , z)
    effect:Display("陷阱抵抗", 30, {.6, .9, 1})
end

local function CanResistTrap(picker)
    local inventory = picker.components.inventory
    if inventory == nil then return false end
    for k,v in pairs(inventory.equipslots) do
        if v and v:HasTag("resistancetrap") then
            return true
        end
    end
end

local function doSpawnItem(it, target, picker)
    --添加多世界宣告支持
    local picker_name = picker and picker:GetDisplayName() or "???"
    local function resetNotice(...)
        local worldShardId = GLOBAL.TheShard:GetShardId()
        local serverName = ""
        if worldShardId ~= nil and worldShardId ~= "0" then
            serverName = "[" .. GLOBAL.STRINGS.TUM.WORLD .. worldShardId .. "] "
        end
        local msg = picker_name .. GLOBAL.STRINGS.TUM.PICKTUMBLEWEED
        for k ,v in pairs({...}) do
            msg = msg .. " " .. v
        end
        GLOBAL.TheNet:Announce(serverName .. msg)
    end
    local x, y, z = target.Transform:GetWorldPosition()
    if it.trap then
        if picker ~= nil then
            x, y, z = picker.Transform:GetWorldPosition()

            if CanResistTrap(picker) then
                picker:PushEvent("tumbleweedtrap")
                ApplyResistance(picker)
                return
            end
        end
        local name = it.item
        if name == "lightningstrike" then
            if GLOBAL.TheWorld:HasTag("cave") then
                -- There's a roof over your head, magic lightning can't strike!
                GLOBAL.TheWorld:PushEvent("ms_miniquake", { rad = 3, num = 5, duration = 1.5, target = picker })
                return
            end
            lightningTarget(picker)
            resetNotice(GLOBAL.STRINGS.TUM.LIGHTING)
        end
        if name == "rock_circle" then
            local num = 7
            --生成冰山/石头山
            local stone_type = "rock_flintless"
            if GLOBAL.TheWorld.state.iswinter then
                stone_type = "rock_ice"
            end
            for k=1,num do
                local angle = k * 2 * PI / num
                spawnAtGround(stone_type, 2*math.cos(angle)+x, y, 2*math.sin(angle)+z)
            end
            removetools(picker)
            resetNotice(GLOBAL.STRINGS.TUM.CIRCLE)
        end
        if name == "sanity_attack" then
            if picker ~= nil and picker.components.sanity ~= nil then
                local san = picker.components.sanity.current or 0
                picker.components.sanity:DoDelta(-san)
            end
            resetNotice(GLOBAL.STRINGS.TUM.SANITY)
        end
        if name == "perish_attack" then
            doperish(picker)
            resetNotice(GLOBAL.STRINGS.TUM.PERISH)
        end
        if name == "broken_attack" then
            removeweapon(picker)
            resetNotice(GLOBAL.STRINGS.TUM.BROKEN)
        end
        if name == "damned_attack" then
            damned(picker)
            resetNotice(GLOBAL.STRINGS.TUM.DAMNED)
        end
        if name == "tentacle_circle" then
            local num=7
            for k=1,num do
                local angle = k * 2 * PI / num
                --spawnAtGround("wall_stone", 2*math.cos(angle)+x, y, 2*math.sin(angle)+z)
                keepPickerStop(picker)
                spawnAtGround("tentacle", 3*math.cos(angle)+x, y, 3*math.sin(angle)+z)
            end
            resetNotice(GLOBAL.STRINGS.TUM.TENTACLE_TRAP)
        end
        if name == "boom_circle" then
            local num=10
            for k=1,num do
                local item = spawnAtGround("gunpowder", x,y,z)
                if item then
                    item.components.explosive:OnBurnt()
                end
            end
            resetNotice("BOOM!!!")
        end
        if name == "fire_circle" then
            local num = 8
            for k=1,num do
                local angle = k * 2 * PI / num
                local item = spawnAtGround("wall_hay", 2*math.cos(angle)+x, y, 2*math.sin(angle)+z)
                if item ~= nil then 
                    item.components.burnable:Ignite() 
                end
            end
            resetNotice(GLOBAL.STRINGS.TUM.FIRE_TRAP)
        end
        if name == "season_change" then
            local names = {"spring","summer","autumn","winter"}
            local index = math.random(#names)
            GLOBAL.TheWorld:PushEvent("ms_setseason", names[index])
            resetNotice(GLOBAL.STRINGS.TUM.SEASON_CHANGE)
        end
        if name == "shadow_boss" then
            local item = GLOBAL.SpawnPrefab("shadow_rook")
            item.Transform:SetPosition(x, y, z)
            local s1 = item:GetDisplayName()
            if picker ~= nil then
                item.components.combat:SuggestTarget(picker)
            end
            item = GLOBAL.SpawnPrefab("shadow_knight")
            item.Transform:SetPosition(x, y, z)
            local s2 = item:GetDisplayName()
            if picker ~= nil then
                item.components.combat:SuggestTarget(picker)
            end
            item = GLOBAL.SpawnPrefab("shadow_bishop")
            item.Transform:SetPosition(x, y, z)
            local s3 = item:GetDisplayName()
            if picker ~= nil then
                item.components.combat:SuggestTarget(picker)
            end
            resetNotice(s1, s2, s3)
        end
        if name == "ghost_circle" then
            local num = 6
            for k=1,num do
                local angle = k * 2 * PI / num
                local item = spawnAtGround("ghost", 2*math.cos(angle)+x, y, 2*math.sin(angle)+z)
                if picker ~= nil and item ~= nil then
                    item.components.combat:SuggestTarget(picker)
                end
            end
        end
        if name == "monster_circle" then
            local monster_tb = {"spider", "hound", "firehound", "icehound", "tallbird", "frog", "merm", "bat", "bee"}
            local monster = monster_tb[math.random(#monster_tb)]
            local num = 6
            for k=1,num do
                local angle = k * 2 * PI / num
                local item = spawnAtGround(monster, 2*math.cos(angle)+x, y, 2*math.sin(angle)+z)
                if picker ~= nil and item ~= nil then
                    item.components.combat:SuggestTarget(picker)
                end
            end
        end
        picker:PushEvent("tumbleweedtrap")
        return
    end
    if it.gift then
        local name = it.item
        if name == "tumbleweed_gift" then
            local tum = "tumbleweed"
            local chance = math.random()
            if chance < 0.2 then
                tum = "tumbleweed_3"
            end
            if chance < 0.05 then
                tum = "tumbleweed_4"
            end
            if chance < 0.01 then
                tum = "tumbleweed_5"
            end
            local num=math.random(3,10)
            for k=1,num do
                spawnAtGround(tum, x+math.random()-0.5,y,z +math.random()-0.5)
            end
        end
        if name == "hutch_gift" then
            local has_hq = type(GLOBAL.c_countprefabs)=="function" and GLOBAL.c_countprefabs("hutch_fishbowl", true) or 1
            if has_hq == 0 then
                spawnAtGround("hutch_fishbowl", x,y,z)
            end
        end
        if name == "pond_gift" then
            local names = {"pond","pond_cave","lava_pond"}
            local item = spawnAtGround(names[math.random(#names)], x,y,z)
            resetNotice(item:GetDisplayName())
            picker:PushEvent("tumbleweeddropped", {item = item})
        end
        if name == "plant_gift" then
            local names = {"flower","carrot_planted","cave_fern","red_mushroom","green_mushroom","blue_mushroom","reeds","cactus","lichen"}
            local num=math.random(7,15)
            --生成作物
            for k=1,num do
                local angle = k * 2 * PI / num
                spawnAtGround(names[math.random(#names)] ,5*math.cos(angle)+x, y, 5*math.sin(angle)+z)
            end
            resetNotice(GLOBAL.STRINGS.TUM.PLANT_GIFT)
        end
        if name == "cave_plant_gift" then
            local num=7
            --生成香蕉树
            local names = {"cave_banana_tree","mushtree_medium","mushtree_small","mushtree_tall"}
            local item = spawnAtGround(names[math.random(#names)], x,y,z)
            --生成荧光果草
            names = {"flower_cave_triple", "flower_cave_double", "flower_cave"}
            for k=1,num do
                local angle = k * 2 * PI / num
                local item2 = spawnAtGround(names[math.random(#names)], 2*math.cos(angle)+x, y, 2*math.sin(angle)+z)
                if item2 then item = item2 end
            end
            resetNotice(item:GetDisplayName())
        end
        if name == "bird_gift" then
            local names = {"crow", "robin", "canary", "puffin"}
            local item = nil
            if GLOBAL.TheWorld.state.iswinter then
                item = spawnAtGround("robin_winter", x,y,z)
            else
                item = spawnAtGround(names[math.random(#names)], x,y,z)
            end
            if item then item:PushEvent("gotosleep") end
        end
        if name == "resurrect_gift" then
            local item = spawnAtGround("resurrectionstone", x,y,z)
            resetNotice(item:GetDisplayName())
            picker:PushEvent("tumbleweeddropped", {item = item})
            local num = 4
            for k=1,num do
                local angle = k *2 *PI/num
                spawnAtGround("pighead", 3*math.cos(angle)+x, y, 3*math.sin(angle)+z)
            end
        end
        if name == "ancient_gift" then
            local item = spawnAtGround("ancient_altar", x,y,z)
            resetNotice(item:GetDisplayName())
            picker:PushEvent("tumbleweeddropped", {item = item})
        end
        if name == "cook_gift" then
            local item = spawnAtGround("icebox", x,y,z)
            local num = 6
            for k=1,num do
                local angle = k *2 *PI/num
                spawnAtGround("cookpot", 3*math.cos(angle)+x, y, 3*math.sin(angle)+z)
            end
            resetNotice(GLOBAL.STRINGS.TUM.COOKIE)
        end
        if name == "butterfly_gift" then
            for k=0,math.random(1,10) do
                spawnAtGround("butterfly", x+math.random()-0.5,y,z +math.random()-0.5)
            end
        end
        if name == "player_gift" then
            spawnPlayerGift(picker)
        end
        if name == "weaponlevel_gift" then
            AddWeapLevel(picker)
            resetNotice(GLOBAL.STRINGS.TUM.WEAPONLEVEL)
        end
        return 
    end
    local item = spawnAtGround(it.item, x,y,z)
    if it.aggro and item ~= nil and item.components.combat ~= nil and picker ~= nil then
        item.components.combat:SuggestTarget(picker)
    end
    
    if item ~= nil and needNotice(it.item) then
        local item_name = item:GetDisplayName() or "???"
        resetNotice(item_name)
        if item.components.inventoryitem ~= nil and item.components.combat == nil then
            picker:PushEvent("tumbleweeddropped", {item = item})
        end
    end
    --武器随机增加等级
    if item ~= nil and item:HasTag("weapon") and
        item.components.weaponlevel ~= nil then
        local max = math.random(1, 12)
        item.components.weaponlevel.level = math.random(0, max)
    end
    return item
end

--初始化
AddPrefabPostInit(
    "world",
    function(inst)
        if GLOBAL.TheWorld.ismastersim then --判断是不是主机

            inst:ListenForEvent("tumbleweedpicked", function(inst, data) 
                local possible_loot = {}
                local function insertLoot(loot, n)
                    for a,b in ipairs(loot) do
                        --print("old:"..b.chance)
                        local newchance = b.chance * n --重置chance
                        --print("new:"..b.chance)
                        if newchance > 0 then
                            table.insert(possible_loot, {chance=newchance, item=b.item, aggro=b.aggro, trap=b.trap, gift=b.gift})
                        end
                    end
                end

                local days = GLOBAL.TheWorld.state.cycles  --世界天数
                local target = data.target
                local picker = data.picker
                if picker == nil or not picker:HasTag("player") then
                    return
                end
                local x, y, z = target.Transform:GetWorldPosition()

                local playerage = picker.components.age:GetAgeInDays() or 0 --玩家天数
                local san = picker.components and picker.components.sanity and picker.components.sanity:GetPercent() or 0 --san值
                local luck = picker.components and picker.components.luck and picker.components.luck:GetLuck() or 1
                san = math.max(san, 0.05)

                local world_chance = math.floor(days*0.01 + playerage*0.04)
                if picker:HasTag("cleverhands") or playerage < 100 then
                    world_chance = math.floor(playerage*0.04)
                end

                local bad_chance = math.ceil(world_chance/san)
                local good_chance = math.ceil(luck*san)

                local level = target.level or 0
                if level == 0 then
                    insertLoot(loot_table.new_loot, 1)
                    insertLoot(loot_table.good_loot, good_chance)
                    insertLoot(loot_table.luck_loot, good_chance)
                    insertLoot(loot_table.bad_loot, bad_chance)
                    insertLoot(loot_table.monstor_loot, bad_chance)
                    insertLoot(loot_table.big_boss_loot, bad_chance)
                    insertLoot(loot_table.trap_loot, bad_chance)
                    insertLoot(loot_table.gift_loot, 1)
                elseif level == 1 then
                    insertLoot(loot_table.new_loot, 1)
                    insertLoot(loot_table.good_loot, 1)
                    insertLoot(loot_table.luck_loot, 1)
                    insertLoot(loot_table.gift_loot, 1)
                elseif level == 2 then
                    insertLoot(loot_table.good_loot, 2)
                    insertLoot(loot_table.luck_loot, 5)
                    insertLoot(loot_table.gift_loot, 1)
                elseif level == 3 then
                    possible_loot = loot_table.luck_loot
                elseif level == -1 then
                    insertLoot(loot_table.bad_loot, 1)
                    insertLoot(loot_table.monstor_loot, 1)
                    insertLoot(loot_table.big_boss_loot, 1)
                elseif level == -2 then
                    insertLoot(loot_table.monstor_loot, 1)
                    insertLoot(loot_table.big_boss_loot, 1)
                end

                local totalchance = 0
                for m, n in ipairs(possible_loot) do
                    totalchance = totalchance + n.chance
                    --print("name:"..n.item..",chance:"..n.chance)
                end

                local num_loots = 1
                if picker:HasTag("cleverhands") and math.random() < 0.1 then
                    num_loots = num_loots + 1
                end
                if picker.components.vip and picker.components.vip.level > 0 then
                    num_loots = num_loots + 1
                end
                if _G.TheWorld:HasTag("pick_tumbleweed_more") then
                    num_loots = num_loots + 2
                end
                --[[if TUNING.more_blueprint and level >=2 then
                    spawnAtGround("blueprint", x, y, z)
                    num_loots = num_loots - 1
                end]]

                local res_loot = {}
                while num_loots > 0 do
                    next_chance = math.random()*totalchance
                    --print("next_chance:"..next_chance)
                    next_loot = nil
                    for m, n in ipairs(possible_loot) do
                        next_chance = next_chance - n.chance
                        --print("n_chance:"..n.chance)
                        if next_chance <= 0 then
                            next_loot = n
                            break
                        end
                    end
                    if next_loot ~= nil then
                        table.insert(res_loot, next_loot)
                        num_loots = num_loots - 1
                    end
                end
                for k,v in pairs(res_loot) do
                    local item = doSpawnItem(v, target, picker)
                    if item == nil or item:HasTag("structure") then
                        break
                    end
                end

            end)
        end
    end
)

--api
GLOBAL.AddLoot = function(loot_tb, loot_type)
    if not loot_type or not loot_table[loot_type] then
        loot_type = "new_loot"
    end
    if loot_tb and loot_tb.item and loot_tb.chance then
        table.insert(loot_table[loot_type], loot_tb)
    end
end