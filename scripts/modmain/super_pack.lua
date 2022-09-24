local require = GLOBAL.require
local Vector3 = GLOBAL.Vector3
local TUNING = GLOBAL.TUNING
local IsServer = GLOBAL.TheNet:GetIsServer()
local TheInput = GLOBAL.TheInput 
local ThePlayer = GLOBAL.ThePlayer
local net_entity = GLOBAL.net_entity

                        
local containers = require("containers")
containers.MAXITEMSLOTS = 50
local INCREASEBACKPACKSIZES_BACKPACK = GetModConfigData("INCREASEBACKPACKSIZES_BACKPACK") 
local INCREASEBACKPACKSIZES_PIGGYBACK = GetModConfigData("INCREASEBACKPACKSIZES_PIGGYBACK")  
local INCREASEBACKPACKSIZES_KRAMPUSSACK = GetModConfigData("INCREASEBACKPACKSIZES_KRAMPUSSACK") 

  local function addItemSlotNetvarsInContainer(inst)
     if(#inst._itemspool < containers.MAXITEMSLOTS) then
        for i = #inst._itemspool+1, containers.MAXITEMSLOTS do
            table.insert(inst._itemspool, net_entity(inst.GUID, "container._items["..tostring(i).."]", "items["..tostring(i).."]dirty"))
        end
     end
  end
  AddPrefabPostInit("container_classified", addItemSlotNetvarsInContainer)


  local widgetsetup_Base = containers.widgetsetup or function() return true end
  function containers.widgetsetup(container, prefab, data, ...)

    local updated = false
    local tempPrefab = prefab or container.inst.prefab
    local result = widgetsetup_Base(container, prefab, data, ...)
   
    if((tempPrefab == "backpack" or tempPrefab == "icepack") and INCREASEBACKPACKSIZES_BACKPACK ~= 8) then
        container.widget.slotpos = {}
        
      if INCREASEBACKPACKSIZES_BACKPACK == 20 then
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 330, 0))
            table.insert(container.widget.slotpos, Vector3(-162 + 65, -65 * y + 330, 0))
        end
        
      elseif INCREASEBACKPACKSIZES_BACKPACK == 30 then 
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-195, -65 * y + 330, 0))
            table.insert(container.widget.slotpos, Vector3(-195 + 65, -65 * y + 330, 0))
            table.insert(container.widget.slotpos, Vector3(-195 + 130, -65 * y + 330, 0))
        end
        
      elseif INCREASEBACKPACKSIZES_BACKPACK == 40 then
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-260, -y*65 + 330 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +65, -y*65 + 330 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +130, -y*65 + 330 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +195, -y*65 + 330 ,0))
        end
        
      elseif INCREASEBACKPACKSIZES_BACKPACK == 50 then
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-300, -y*65 + 330 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +65, -y*65 + 330 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +130, -y*65 + 330 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +195, -y*65 + 330 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +260, -y*65 + 330 ,0))
        end
      end
      updated = true
      
    elseif(tempPrefab == "piggyback" and INCREASEBACKPACKSIZES_PIGGYBACK ~= 12) then
        container.widget.slotpos = {}
      if INCREASEBACKPACKSIZES_PIGGYBACK == 20 then 
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 297, 0))
            table.insert(container.widget.slotpos, Vector3(-162 + 65, -65 * y + 297, 0))
        end 
      elseif INCREASEBACKPACKSIZES_PIGGYBACK == 30 then 
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-195, -65 * y + 297, 0))
            table.insert(container.widget.slotpos, Vector3(-195 + 65, -65 * y + 297, 0))
            table.insert(container.widget.slotpos, Vector3(-195 + 130, -65 * y + 297, 0))
        end
      elseif INCREASEBACKPACKSIZES_PIGGYBACK == 40 then 
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-260, -y*65 + 297 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +65, -y*65 + 297 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +130, -y*65 + 297 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +195, -y*65 + 297 ,0))
        end
      elseif INCREASEBACKPACKSIZES_PIGGYBACK == 50 then 
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-300, -y*65 + 297 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +65, -y*65 + 297 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +130, -y*65 + 297 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +195, -y*65 + 297 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +260, -y*65 + 297 ,0))
        end
      end
      updated = true      
    elseif(tempPrefab == "krampus_sack" and INCREASEBACKPACKSIZES_KRAMPUSSACK ~= 14) then
        container.widget.slotpos = {}
      if INCREASEBACKPACKSIZES_KRAMPUSSACK == 20 then 
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-162, -65 * y + 413, 0))
            table.insert(container.widget.slotpos, Vector3(-162 + 65, -65 * y + 413, 0))
        end  
      elseif INCREASEBACKPACKSIZES_KRAMPUSSACK == 30 then
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-195, -65 * y + 413, 0))
            table.insert(container.widget.slotpos, Vector3(-195 + 65, -65 * y + 413, 0))
            table.insert(container.widget.slotpos, Vector3(-195 + 130, -65 * y + 413, 0))
        end
      elseif INCREASEBACKPACKSIZES_KRAMPUSSACK == 40 then
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-260, -y*65 + 413 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +65, -y*65 + 413 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +130, -y*65 + 413 ,0))
            table.insert(container.widget.slotpos, Vector3(-260 +195, -y*65 + 413 ,0))
        end
      elseif INCREASEBACKPACKSIZES_KRAMPUSSACK == 50 then
        container.widget.animbank = "ui_krampusbag_2x10"
        container.widget.animbuild = "ui_krampusbag_2x10"     
        for y = 0, 9 do
            table.insert(container.widget.slotpos, Vector3(-300, -y*65 + 413 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +65, -y*65 + 413 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +130, -y*65 + 413 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +195, -y*65 + 413 ,0))
            table.insert(container.widget.slotpos, Vector3(-300 +260, -y*65 + 413 ,0))
        end
      end
      updated = true        
      end 
  
    if updated then
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)

    end
   return result
  end