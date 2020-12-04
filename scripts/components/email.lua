require "utils/utils"

local function SpawnItem(prefab, use_left)
	local item = SpawnPrefab(prefab)
	if item.components.inventoryitem == nil then --不能放物品栏
		local real_item = item
		item = SpawnPrefab("package_ball")
		item.components.packer:Pack(real_item)
	end
	if use_left < 1 then
		if item.components.perishable ~= nil then
			item.components.perishable:SetPercent(use_left)
		end
		if item.components.finiteuses ~= nil then
			item.components.finiteuses:SetPercent(use_left)
		end
	end
	return item
end

local function GiveItem(inst, item)
	if inst.components.inventory ~= nil then
		inst.components.inventory:GiveItem(item)
	else
		item.Transform:SetPosition(inst:GetPosition():Get())
	end
end

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
	
	--[[self.list = {
		{
			_id = "1",
			title = "无标题",
			content = "恭喜您获得奖励！",
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
			time = tostring(os.date())
		},
		{
			_id = "2",
			title = "感谢支持",
			content = "感谢您支持本mod，祝您游戏愉快！",
			prefabs = {

			},
			sender = "system",
			time = tostring(os.date())
		},
		{
			_id = "3",
			title = "感谢支持",
			content = "感谢您支持本mod，祝您游戏愉快！",
			prefabs = {

			},
			sender = "system",
			time = tostring(os.date())
		},
		{
			_id = "3",
			title = "感谢支持",
			content = "感谢您支持本mod，祝您游戏愉快！",
			prefabs = {

			},
			sender = "system",
			time = tostring(os.date())
		}
	}]]
	

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

function Email:AddEmail(email)
	if email ~= nil and self:GetEmailForId(email._id) == nil then
		table.insert(self.list, email)
		self.net_data.list:set(Table2String(self.list))
		self.has = true
	end
end

function Email:AddEmails(emails)
	if emails ~= nil and next(emails) ~= nil then
		for _, email in pairs(emails) do
			if self:GetEmailForId(email._id) == nil then
				table.insert(self.list, email)
			end
		end
		if #self.list > 0 then
			self.has = true
			self.net_data.list:set(Table2String(self.list))
		end
	end
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

function Email:GetEmailForId(id, remove)
	if #self.list == 0 then return nil end 
	local temp = {}
	local target
	for k,v in pairs(self.list) do
		if v._id == id then
			if not remove then
				return v
			end
			target = v
		else
			table.insert(temp, v)
		end
	end
	if target ~= nil then
		self.list = temp
		if #self.list == 0 then
			self.has = false
		end
	end
	return target
end

--接收附件并删除邮件
function Email:ReceivedEmail(id)
	if TheWorld.ismastersim then
		local inst = self.inst
		local email = self:GetEmailForId(id, true)
		if email ~= nil and email.prefabs ~= nil and next(email.prefabs) ~= nil then
			for _, v in pairs(email.prefabs) do
				local prefab = v.prefab
				local num = v.num or 1
				local use_left = v.use_left or 1
				if PrefabExists(prefab) then
					local item = SpawnItem(prefab, use_left)
					--可否堆叠
					if num > 1 and
						item.components.stackable ~= nil and 
						item.components.stackable.maxsize >= num then
						item.components.stackable:SetStackSize(num)
						GiveItem(inst, item)
					else
						while(num > 0) do
							GiveItem(inst, item)
							num = num - 1
						end
					end
				end
			end
		end
	else
		SendModRPCToServer(MOD_RPC.RPG_email.received, id)
	end
end

--只接受附件，不删除邮件
function Email:ReceivedPrefabs(id)

end

function Email:GetEmailsFromServer()
	if TheWorld.ismastersim then
		local serversession = TheWorld.net.components.shardstate:GetMasterSessionId()
	    HttpGet("/public/getEmail?serversession="..serversession.."&userid="..self.inst.userid, function(result, isSuccessful, resultCode)
	    	if isSuccessful and (resultCode == 200) then
				print("-- getEmail success--")
				local status, data = pcall( function() return json.decode(result) end )
				if not status or not data then
			 		print("解析getEmail失败! ", tostring(status), tostring(data))
				else
					--成功
					self:AddEmails(data)
				end
			else
				print("-- getEmail failed! ERROR:"..result.."--")
			end
		end)
	end
end

return Email