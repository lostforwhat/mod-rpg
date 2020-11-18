require "utils/utils"

local function onhas(self, val)
	self.net_data.has:set(val)
end

local function onlist(self, val)
	self.net_data.list:set(Table2String(val))
end

local Email = Class(function(self, inst) 
    self.inst = inst

    self.net_data = {
    	list = net_string(inst.GUID, "email.list", "emaildirty"),
    	has = net_bool(inst.GUID, "email.has", "hasemaildirty")
    }
    --eg. self.list
	--[[
	self.list = {
		{
			title = "title",
			content = "content",
			prefabs = {
				{
					prefab = "achiv_clear",
					num = 2,
				},
				{
					prefab = "spear",
					use_left = 0.5
				}
			},
			sender = "system",
			time = tostring(os.data())
		},
		{
			title = "title",
			content = "content",
			prefabs = {

			},
			sender = "system",
			time = tostring(os.data())
		}
	}
	]]

    self.list = {}
    self.has = false
end,
nil,
{
	has = onhas,
	list = onlist
})

function Email:OnLoad(data)
	if data then
		self.list = data.list or {}
		self.has = data.has or false
	end
end

function Email:OnSave()
	return {
		list = self.list,
		has = self.has
	}
end

function Email:HasEmail()
	if TheWorld.ismastersim then
		return self.has or false
	else
		return self.net_data.has:value() or false
	end
end

function Email:GetEmail()
	if TheWorld.ismastersim then
		return self.list or {}
	else
		return String2Table(self.net_data.list:value()) or {}
	end
end

function Email:RecievedEmail()


end

return Email