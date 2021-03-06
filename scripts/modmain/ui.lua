local _G = GLOBAL

--添加modUI
--if _G.TheNet:GetIsClient() then
local PlayerStatus = require('widgets/playerstatus')
local PlayerDetail = require('widgets/playerdetail')
local ShopDetail = require('widgets/shopdetail')
local EmailDetail = require('widgets/emaildetail')
local TaskScreen = require('screens/taskscreen')
local ReceiveDialog = require('widgets/receivedialog')
local SkillShortCutKey = require('widgets/skillshortcutkey')
local HelpDetail = require('widgets/helpdetail')
local function AddPlayerStatus(self)
	self.player_status = self.top_root:AddChild(PlayerStatus(self.owner))
	self.player_status:SetHAnchor(_G.ANCHOR_LEFT)
    self.player_status:SetVAnchor(_G.ANCHOR_TOP)
    self.player_status:MoveToFront()

    --快捷键换称号
	_G.TheInput:AddKeyUpHandler(_G.KEY_L, function() 
		--print("---------")
		if self.owner and self.owner.HUD and self.owner.HUD:HasInputFocus() then return end
		SendModRPCToServer(MOD_RPC["RPG_titles"]["change"])
	end)
end
AddClassPostConstruct("widgets/controls", AddPlayerStatus)
local function AddDialog(self)
	self.receivedialog = self.topright_root:AddChild(ReceiveDialog(self.owner))
	self.receivedialog:SetPosition(-200, -400)
	self.receivedialog:SetClickable(true)
	self.receivedialog.OnMouseButton = function(inst, button, down, x, y)
		if button == _G.MOUSEBUTTON_LEFT then
			if down then
				self.receivedialog.dragging = true
				local mousepos = _G.TheInput:GetScreenPosition()
				self.receivedialog.dragPosDiff = self.receivedialog:GetPosition() - mousepos
			else
				self.receivedialog.dragging = false
			end
		end	
	end
	_G.TheInput:AddMoveHandler(function(x,y)
		if self.receivedialog.dragging then
			local offset = self.receivedialog.dragPosDiff or {0, 0, 0}
			local pos
			if type(x) == "number" then
				pos = _G.Vector3(x, y, 1) + offset
			else
				pos = x + offset
			end
			self.receivedialog:SetPosition(pos:Get())
		end
	end)
end
AddClassPostConstruct("widgets/controls", AddDialog)

local function AddSkillShortCutKey(self)
	self.skillskey = self.bottom_root:AddChild(SkillShortCutKey(self.owner))
	self.skillskey:SetPosition(0, 100)
end
AddClassPostConstruct("widgets/controls", AddSkillShortCutKey)

AddClassPostConstruct("screens/playerhud", function(self)
    self.ShowTaskScreen = function(_)
        
        self.taskscreen = TaskScreen(self.owner)
        self:OpenScreenUnderPause(self.taskscreen)
        return self.taskscreen
    end

    self.CloseTaskScreen = function(_)
        if self.taskscreen then
            self.taskscreen:Close()
            self.taskscreen = nil
        end
    end

    self.CloseDefaultPlayerInfo = function(_)
    	if self.playeravatarpopup ~= nil and
	        self.playeravatarpopup.started and
	        self.playeravatarpopup.inst:IsValid() then
	        self.playeravatarpopup:Close()
	    end
	end

    self.ShowPlayerDetail = function(_)
    	if self.playerdetail == nil then
    		self:CloseDefaultPlayerInfo()
    		self.playerdetail = self.controls.right_root:AddChild(PlayerDetail(self.owner))
    	end
	end
	self.ClosePlayerDetail = function(_) 
		if self.playerdetail then
			self.playerdetail:Close()
			self.playerdetail = nil
		end
	end

	local OldTogglePlayerAvatarPopup = self.TogglePlayerAvatarPopup
	self.TogglePlayerAvatarPopup = function(...)
		self:ClosePlayerDetail()
		OldTogglePlayerAvatarPopup(...)
	end

	self.ShowShopDetail = function(_)
		if self.shopdetail == nil then
			self:CloseEmailDetail()
			self.shopdetail = self.controls.topleft_root:AddChild(ShopDetail(self.owner))
		end
	end
	self.CloseShopDetail = function(_) 
		if self.shopdetail then
			self.shopdetail:Close()
			self.shopdetail = nil
		end
	end

	self.ShowEmailDetail = function(_)
		if self.emaildetail == nil then
			self:CloseShopDetail()
			self.emaildetail = self.controls.topleft_root:AddChild(EmailDetail(self.owner))
		end
	end
	self.CloseEmailDetail = function(_)
		if self.emaildetail then
			self.emaildetail:Close()
			self.emaildetail = nil
		end
	end

	self.ShowHelpDetail = function(_)
		if self.helpdetail == nil then
			self.helpdetail = self.controls.top_root:AddChild(HelpDetail(self.owner))
		end
	end
	self.CloseHelpDetail = function(_)
		if self.helpdetail then
			self.helpdetail:Close()
			self.helpdetail = nil
		end
	end

	self.inst:DoTaskInTime(.1, function() 
		if self.owner.Network:GetPlayerAge() <= 1 then
            self:ShowHelpDetail()
        end
	end)

	--修改esc按键关闭窗口
	local OldOnControl = self.OnControl
	self.OnControl = function(_, control, down) 
		if not down and control == _G.CONTROL_CANCEL then
			self:ClosePlayerDetail()
			self:CloseShopDetail()
			self:CloseEmailDetail()
		end
		return OldOnControl(self, control, down)
	end
end)
--end