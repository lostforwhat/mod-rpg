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
		inst.angle = inst.angle or math.random() * 2 * PI --此代码其实不必
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

local function Display(inst, text, size, colour, offset)
	inst.Label:SetText(text)
	if size ~= nil then
		inst:SetFontSize(size)
	end
	if colour ~= nil then
		inst:SetColour(colour)
	end
	if offset ~= nil then
		inst:SetOffset(offset)
	end
	inst.time = DURATION
	inst.angle = math.random() * 2 * PI
	inst.disappear_task = inst:DoPeriodicTask(FRAMES, DelayDisappear)
end

local function Enable(inst, enable)
	inst.Label:Enable(enable == true)
end


local function fn() 
	local inst = CreateEntity() 
	inst.entity:AddTransform() 
	 
	inst.entity:AddLabel() 
	inst.Label:SetFont(NUMBERFONT) 
	inst.Label:SetFontSize(28) 
	inst.Label:SetColour(1, 1, 1) 
	inst.Label:SetText("") 
	inst.Label:Enable(true)

	inst.SetFontSize = SetFontSize
	inst.SetOffset = SetOffset 
	inst.Display = Display 
	inst.Enable = Enable
	
	inst:AddTag("FX") 
	inst.persists = false 

	--inst:DoPeriodicTask(FRAMES, DelayDisappear)
	inst:DoTaskInTime(DURATION, inst.Remove)

	return inst 
end

return Prefab("display_effect", fn)