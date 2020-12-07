local Widget = require "widgets/widget"
local Text = require "widgets/text"
local ImageButton = require "widgets/imagebutton"
local Image = require "widgets/image"

local ReceiveDialog = Class(Widget, function(self, owner)
    Widget._ctor(self, "ReceiveDialog")

    self.owner = owner

    self.root = self:AddChild(Widget("root"))
    self.root:SetScale(.75)

    local bottom_buttons = {
    	{
            text = "前往",
            cb = function()
            	if not self.cd_time then
            		self.cd_time = true
            		SendModRPCToServer(MOD_RPC.RPG_Receive.received, true)  
            		self.inst:DoTaskInTime(2, function() self.cd_time = nil end)
            	end  
            end,
        },
        {
        	text = "拒绝",
        	cb = function()
				if not self.cd_time then
            		self.cd_time = true
            		SendModRPCToServer(MOD_RPC.RPG_Receive.received, false)  
            		self.inst:DoTaskInTime(2, function() self.cd_time = nil end)
            	end    
        	end,
        }
    }
    self.dialogroot = self.root:AddChild(TEMPLATES.CurlyWindow(240, 160, "召集", bottom_buttons, 10, ""))

    self:Hide()

    self.inst:ListenForEvent("recievingdirty", function() 
    	self:CheckDialog()
	end, self.owner)

	self.inst:ListenForEvent("recievertime_leftdirty", function()
		self:UpdateTimer()
	end)

    self.inst:ListenForEvent("continuefrompause", function()
        
    end, TheWorld)
end)

function ReceiveDialog:CheckDialog()
	local receiving = self.owner.components.reciever.net_data.recieving:value() or false
	if receiving then
		local caller = self.owner.components.reciever.net_data.caller:value()
		local title = (caller ~= nil and caller:GetDisplayName() or "似乎有人").." 请求协助，是否立即前往？"
		self.dialogroot.body:SetMultilineTruncatedString(title, 2, 260, 55, true)
		self:Show()
	else
		self:Hide()
	end
end

function ReceiveDialog:UpdateTimer()
	local time_left = self.owner.components.reciever.net_data.time_left:value() or 0
	if time_left > 0 then
		self.dialogroot.title:SetString("召集【"..time_left.."s】")
	else
		self:Hide()
	end
end

return ReceiveDialog