--local FollowText = require "widgets/followtext"
local DURATION = 0.6

local prefabs = {}

local function SetFontSize(inst, size)
	inst.Label:SetFontSize(size)
end

local function SetColour(inst, r, g, b)
	if type(r) ~= "number" then
		inst.Label:SetColour(unpack(r))
		return
	end
	inst.Label:SetColour(r, g, b)
end

local function SetOffset(inst, x, y, z)
	if type(x) ~= "number" then
		inst.Label:SetWorldOffset(unpack(x))
		return
	end
	inst.Label:SetWorldOffset(x, y, z)
end

local function DelayDisappear(inst)
	if inst.time ~= nil and inst.time > 0 then
		local angle = inst.angle or math.random() * 2 * PI --此代码其实不必
		local pos = inst:GetPosition()
		local offset = Vector3(2 * FRAMES * math.cos(angle), 10 * FRAMES, 2 * FRAMES * math.sin(angle)) 
		inst.Transform:SetPosition((pos + offset):Get())

		inst.time = inst.time - FRAMES
	elseif inst.disappear_task ~= nil then
		inst.disappear_task:Cancel()
		inst:Remove()
	elseif inst ~= nil then
		inst:Remove()
	end
end

local function Enable(inst, enable)
	inst.Label:Enable(enable == true)
end

local function OnDisplay(inst)
	local text = inst._text:value()
	local size = inst._size:value()
	local r, g, b = inst._colour_r:value()/255, inst._colour_g:value()/255, inst._colour_b:value()/255
	inst.Label:SetText(text)
	inst:SetColour(r, g, b)
	inst:SetFontSize(size)
end

local function Display(inst, text, size, colour, offset)
	--inst.Label:SetText(text)
	if size ~= nil then
		--inst:SetFontSize(size)
		inst._size:set(size)
	end
	if colour ~= nil then
		--inst:SetColour(colour)
		local r, g, b = unpack(colour)
		inst._colour_r:set(r*255)
		inst._colour_g:set(g*255)
		inst._colour_b:set(b*255)
	end
	if offset ~= nil then
		--inst:SetOffset(offset)
	end

	inst._text:set(text)
	OnDisplay(inst)

	inst.time = DURATION
	inst.angle = math.random() * 2 * PI
	inst.disappear_task = inst:DoPeriodicTask(FRAMES, DelayDisappear)
end


local function fn() 
	local inst = CreateEntity() 
	inst.entity:AddTransform() 
	inst.entity:AddNetwork()
	 
	inst.entity:AddLabel() 
	inst.Label:SetFont(NUMBERFONT) 
	inst.Label:SetFontSize(28) 
	inst.Label:SetColour(1, 1, 1) 
	inst.Label:SetText("") 
	inst.Label:Enable(true)

	inst._text = net_string(inst.GUID, "display_effect._text", "display_effectdirty")
	inst._size = net_byte(inst.GUID, "display_effect._size")
	inst._colour_r = net_byte(inst.GUID, "display_effect._colour_r")
	inst._colour_g = net_byte(inst.GUID, "display_effect._colour_g")
	inst._colour_b = net_byte(inst.GUID, "display_effect._colour_b")
	inst._text:set_local("")
	inst._size:set_local(28)
	inst._colour_r:set_local(255)
	inst._colour_g:set_local(255)
	inst._colour_b:set_local(255)

	if TheWorld.ismastersim then
		
	else
		inst:ListenForEvent("display_effectdirty", OnDisplay)
	end

	inst.SetFontSize = SetFontSize
	inst.SetOffset = SetOffset 
	inst.Display = Display 
	inst.Enable = Enable
	inst.SetColour = SetColour
	
	inst:AddTag("FX") 
	inst.persists = false 

	--inst:DoPeriodicTask(FRAMES, DelayDisappear)
	inst:DoTaskInTime(DURATION, inst.Remove)

	return inst 
end

return Prefab("display_effect", fn)