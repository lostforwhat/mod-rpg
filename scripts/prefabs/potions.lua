local assets =
{
    Asset("ANIM", "anim/potions.zip"),
    Asset("IMAGE", "images/inventoryimages/potion_blue.tex"),
    Asset("ATLAS", "images/inventoryimages/potion_blue.xml"),
    Asset("IMAGE", "images/inventoryimages/potion_green.tex"),
    Asset("ATLAS", "images/inventoryimages/potion_green.xml"),
    Asset("IMAGE", "images/inventoryimages/potion_luck.tex"),
    Asset("ATLAS", "images/inventoryimages/potion_luck.xml"),
    Asset("IMAGE", "images/inventoryimages/potion_red.tex"),
    Asset("ATLAS", "images/inventoryimages/potion_red.xml"),
}

local function create_light(eater, lightprefab)
    if eater.wormlight ~= nil then
        if eater.wormlight.prefab == lightprefab then
            eater.wormlight.components.spell.lifetime = 0
            eater.wormlight.components.spell.duration = TUNING.WORMLIGHT_DURATION * 8
            eater.wormlight.components.spell:ResumeSpell()
            return
        else
            eater.wormlight.components.spell:OnFinish()
        end
    end

    local light = SpawnPrefab(lightprefab)
    light.components.spell:SetTarget(eater)
    if light:IsValid() then
        if light.components.spell.target == nil then
            light:Remove()
        else
        	light.components.spell.duration = TUNING.WORMLIGHT_DURATION * 8
            light.components.spell:StartSpell()
        end
    end
end

local function dobackperish(player)
    if player == nil or player.components.inventory == nil then return end
    local percent = math.random()
    percent = math.clamp(percent, 0, 0.5)
    for k,v in pairs(player.components.inventory.itemslots) do
        if v and v.components.perishable then
            v.components.perishable:ReducePercent(-percent)
        end
    end
    for k,v in pairs(player.components.inventory.equipslots) do
        if v and v.components.perishable then
            v.components.perishable:ReducePercent(-percent)
        end
    end
    for k,v in pairs(player.components.inventory.opencontainers) do
        if k and k:HasTag("backpack") and k.components.container then
            for i,j in pairs(k.components.container.slots) do
                if j and j.components.perishable then
                    j.components.perishable:ReducePercent(-percent)
                end
            end
        end
    end
end

local function takeglommerfuel(player)
	local glommer = c_find("glommer", 10, player)
	if glommer then
		local x,y,z = glommer.Transform:GetWorldPosition()
		local fuel = SpawnPrefab("glommerfuel")
		fuel.components.stackable:SetStackSize(math.random(5))
		glommer.sg:GoToState("goo", fuel)
	end
end

local potions_type = {
	blue = {
		health = 1,
		sanity = 10,
		hunger = 1,
		fn = function(inst, eater)
			if eater and eater.components.locomotor and eater:HasTag("player") then
				eater.components.debuffable:AddDebuff("buff_waterwalk", "buff_waterwalk")
			end
		end
	},
	green = {
		health = -5,
		sanity = 20,
		hunger = 10,
		fn = function(inst, eater)
			if eater ~= nil and eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
		        not (eater.components.health ~= nil and eater.components.health:IsDead()) and
		        not eater:HasTag("playerghost") then
		        eater.components.debuffable:AddDebuff("buff_taunt", "buff_taunt")
		        dobackperish(eater)
		    end
		end
	},
	luck = {
		health = 40,
		sanity = 5,
		hunger = 10,
		fn = function(inst, eater)
			if eater and eater.components.luck then
				eater.components.luck:DoDelta(GetRandomWithVariance(5, 10))
			end
			create_light(eater, "wormlight_light")
			if eater:HasTag("potionbuilder") then
				takeglommerfuel(eater)
			end
		end
	},
	red = {
		health = 100,
		sanity = 5,
		hunger = 1,
		fn = function(inst, eater)
			if eater ~= nil and eater.components.debuffable ~= nil and eater.components.debuffable:IsEnabled() and
		        not (eater.components.health ~= nil and eater.components.health:IsDead()) and
		        not eater:HasTag("playerghost") then
		        eater.components.debuffable:AddDebuff("buff_super_attack", "buff_super_attack")
		    end
		end
	}
}

local function MakePotion(type)
	local function fn()
		local inst = CreateEntity()
	    inst.entity:AddTransform()
	    inst.entity:AddAnimState()
	    inst.entity:AddNetwork()
	    MakeInventoryPhysics(inst)
	    
	    -- Set animation info
	    inst.AnimState:SetBuild("potions")
	    inst.AnimState:SetBank("potions")
	    inst.AnimState:PlayAnimation("potion_"..type)
	    inst.Transform:SetScale(2, 2, 1)

	    --inst:AddTag("irreplaceable")
	    if type == "luck" then
	    	inst.entity:AddLight()
	    	inst.Light:SetFalloff(0.7)
		    inst.Light:SetIntensity(.5)
		    inst.Light:SetRadius(2)
		    inst.Light:SetColour(225/255, 231/255, 25/255)
		    inst.Light:Enable(true)

		    inst:AddTag("lightbattery")
	    end

	    inst:AddTag("meat")
	    inst:AddTag("preparedfood")
	    --MakeInventoryFloatable(inst, "small", 0.05, {1.2, 0.75, 1.2})
	    inst.entity:SetPristine()

	    if not TheWorld.ismastersim then
	        return inst
	    end

	    inst:AddComponent("edible")
	    inst.components.edible.healthvalue = potions_type[type].health or 0 -- Amount to heal
	    inst.components.edible.hungervalue =  potions_type[type].hunger or 0 -- Amount to fill belly
	    inst.components.edible.sanityvalue = potions_type[type].sanity or 0 -- Amount to help Sanity
	    inst.components.edible.foodtype = "GOODIES"
	    inst.components.edible:SetOnEatenFn(potions_type[type].fn) 

	  	inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	    inst:AddComponent("inspectable")

	    inst:AddComponent("inventoryitem")
	    inst.components.inventoryitem.atlasname = "images/inventoryimages/potion_"..type..".xml" -- here's the atlas for our tex

	    --inst.OnSave = OnSave
	    --inst.OnLoad = OnLoad

	    return inst
	end

	return Prefab("potion_"..type, fn, assets)
end

return MakePotion("blue"),
MakePotion("green"),
MakePotion("luck"),
MakePotion("red")