require "utils/utils"

local function OnHandleQuestQueryResponce(self, inst, result, isSuccessful, resultCode)
	if isSuccessful and string.len(result) > 1 and resultCode == 200 then 
		local status, data = pcall( function() return json.decode(result) end )
		if not status or not data then
	 		print("再次解析vip列表失败" .. tostring(inst.userid) .."! ", tostring(status), tostring(data))
		else
			if data[inst.userid] and data[inst.userid] > 0 then
				self.level = data[inst.userid]
			end
		end
	else
		print("获取vip列表失败,code:"..tostring(resultCode))
		
	end
end

local function tryAgainVip(self, inst)
	local url = "https://raw.githubusercontent.com/lostforwhat/dst/master/vip.json"
	HttpGet( url, 
		function(result, isSuccessful, resultCode) 
			OnHandleQuestQueryResponce(self, inst, result, isSuccessful, resultCode)
		end)
end

local function onlevel(self, level)
	if level > 0 then
		self.inst:AddTag("vip")
	else
		self.inst:RemoveTag("vip")
	end
	self.net_data.level:set(level)
end

--player vip 组件

local Vip = Class(function(self, inst) 
	self.inst = inst

	self.net_data = {
		level = net_shortint(inst.GUID, "vip.level", "vipdirty")
	}

	self.level = 0

	if TheWorld.ismastersim and self.inst:HasTag("player") then
		self.inst:DoTaskInTime(.4, function() self:Get() end)
		--self:Get()
	end
end,
nil,
{
	level = onlevel,
})

function Vip:Get()
	local inst = self.inst
	local userid = inst.userid or ""
	local displayname = inst:GetDisplayName() or ""
	print("userid:"..userid)
	HttpGet("/public/getVip?userid="..userid.."&displayname="..displayname, 
		function(result, isSuccessful, resultCode) 
			if isSuccessful and string.len(result) > 1 and resultCode == 200 then 
				local status, data = pcall( function() return json.decode(result) end )
				if not status or not data then
			 		print("解析vip列表失败" .. tostring(inst.userid) .."! ", tostring(status), tostring(data))
				else
					if data.userid == inst.userid and data.level > 0 then
						print("------"..inst:GetDisplayName().."获得vip------")
						self.level = data.level
					end
				end
			else
				print("获取vip列表失败,将从github获取数据,code:"..tostring(resultCode)..result)
				tryAgainVip(self, inst)
			end
	end)
end

return Vip