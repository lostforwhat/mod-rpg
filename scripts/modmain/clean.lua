local _G = GLOBAL
local TheNet = _G.TheNet
--local TheWorld = _G.TheWorld
local TUNING = _G.TUNING
local tonumber = _G.tonumber

if TheNet:GetIsServer() or TheNet:IsDedicated() then

	AddSimPostInit(function() 
		print("--已加载草服清理工具--")

		local function getTime()
			return _G.os.date("%Y-%m-%d %H:%M:%S")
		end

		local function GetLength(tab)
		    local count = 0
		    if type( tab ) ~= "table" then
		        return 0
		    end
		    for k, v in pairs( tab ) do
		        count = count + 1
		    end
		    return count
		end

		local function playerNear(item)
			local x,y,z = item.Transform:GetWorldPosition()
			local ents = TheSim:FindEntities(x,y,z, 30, nil,nil, {"player"})
			return ents ~= nil and GetLength(ents) > 0
		end

		local function structureNear(item, num)
			if num == nil then num = 5 end
			local x,y,z = item.Transform:GetWorldPosition()
			local ents = TheSim:FindEntities(x,y,z, 20, nil,nil, {"structure", "wall", "chest", "evergreens"})
			return ents ~= nil and GetLength(ents) >= num
		end

		local function clean()
			print("--草服清理工具：开始清理--")
			local count = 0
			local clean_tab = {}
			for _, v in pairs(_G.Ents) do -- 所有物品
		        if v.prefab ~= nil and not v:HasTag("irreplaceable") then        
		            if v:IsInLimbo() or v:HasTag("INLIMBO") then --不可见
		            	if v.components.inventoryitem ~= nil then
			            	if v:HasTag("tumbleweeddropped") then
			            		if v._cleanfail then
			            			v._cleanfail = nil
			            			v:RemoveTag("tumbleweeddropped")
			            		else
				            		v._cleanfail = true
				            	end
			            	end
			            end
		            elseif v:HasTag("structure") then --建筑

		            elseif v.components.inventoryitem ~= nil then --可以捡起来的物品
		            	--主要清理这类
		            	if v:HasTag("tumbleweeddropped") then --直接删
		            		if not playerNear(v) then
		            			if clean_tab[v.prefab] == nil then
		            				clean_tab[v.prefab] = 1
		            			else
		            				clean_tab[v.prefab] = clean_tab[v.prefab] + 1
		            			end
			            		v:Remove()
			            		count = count + 1
			            	end
			            else
			            	if not v:HasTag("monstor") and v.components.health == nil
			            		and v.components.container == nil
			            		and not v:HasTag("backpack") and not v:HasTag("heavy")
			            		and not v:HasTag("irreplaceable") and not v:HasTag("flying")
			            		and not v:HasTag("canbait") and v.components.locomotor == nil then
				            	if not playerNear(v) and not structureNear(v, 3) then
				            		if v.components.stackable == nil or v.components.stackable:StackSize() < 10 then
				            			if _G.c_countprefabs(v.prefab, true) > 1 then
						            		--第一次打标记,第二次直接删
						            		if v._cleantag then
						            			if clean_tab[v.prefab] == nil then
						            				clean_tab[v.prefab] = 1
						            			else
						            				clean_tab[v.prefab] = clean_tab[v.prefab] + 1
						            			end
						            			v:Remove()
						            			count = count + 1
						            		else
						            			v._cleantag = true
						            		end
						            	end
					            	end
				            	end
				            end
		            	end

		            else -- 剩下的作物和生物之类的
		            	if v:HasTag("playerskeleton") or (v:HasTag("monstor") and v:HasTag("tumbleweeddropped")) then
		            		if _G.c_countprefabs(v.prefab, true) > 2 and not playerNear(v) then
			            		--第一次打标记,第二次直接删
			            		if v._cleantag then
			            			if clean_tab[v.prefab] == nil then
			            				clean_tab[v.prefab] = 1
			            			else
			            				clean_tab[v.prefab] = clean_tab[v.prefab] + 1
			            			end
			            			v:Remove()
			            			count = count + 1
			            		else
			            			v._cleantag = true
			            		end
			            	end
		            	end
		            end
		        end
		    end
		    print("--"..getTime().."清理完成,清理总数量:"..count.."--")
		    for k,v in pairs(clean_tab) do
		    	print("--[已清理]  "..k..":"..v)
		    end
		end

		--_G.clean_task = TheWorld:DoPeriodicTask(TUNING.TOTAL_DAY_TIME, clean)

		local function OnEntityDropLoot(world, data)
			local inst = data.inst
			local x,y,z = inst.Transform:GetWorldPosition()
			if x and y and z then
				local ents = TheSim:FindEntities(x,y,z, 5, nil,nil)
				if ents ~= nil then
					for k, v in pairs(ents) do
						if not v:IsInLimbo() and not v:HasTag("INLIMBO") and v.prefab ~= nil
							and v.components.locomotor == nil and not v:HasTag("canbait")
							and v.components and v.components.inventoryitem 
							and not v:HasTag("backpack") and not v:HasTag("heavy")
		            		and not v:HasTag("irreplaceable") and not v:HasTag("flying")
		            		and not v:HasTag("canbait") then
							v:AddTag("tumbleweeddropped")
						end
					end
				end
			end
		end

		local function IsMainWorld()
			return _G.TheWorld.ismastersim and _G.TheWorld.ismastershard
		end

		--为掉落物添加tag
		--TheWorld:ListenForEvent("entity_droploot", OnEntityDropLoot)
		local function delayclean(inst, delay)
			delay = type(delay)=="number" and delay or 10
			inst:DoTaskInTime(delay, clean)
		end

		local function task()
			--发布多世界驱动消息
	        local msg = _G.SHARD_KEY.."clean10"
	        TheNet:SystemMessage(msg)
	        TheNet:Announce("[草服清理工具]：10秒后开始清理地面，请保管好需要物品")
		end

		--注册消息驱动器
		_G.AddShardRule("clean", function(msg) 
			local param = string.sub(msg, 6)
			if param == nil or _G.tonumber(param) ~= nil then
				delayclean(_G.TheWorld, _G.tonumber(param))
			else
				if IsMainWorld() then
					if param == "start" then
						if TUNING.clean_task ~= nil then
							TheNet:SystemMessage("自动清理任务已存在")
							return
						end
						TUNING.clean_task = _G.TheWorld:DoPeriodicTask(2*TUNING.TOTAL_DAY_TIME, task, TUNING.TOTAL_DAY_TIME*.5)
					elseif param == "stop" then
						if TUNING.clean_task ~= nil then
							TUNING.clean_task:Cancel()
							TUNING.clean_task = nil
						end
					end
				end
			end
		end)

		--开始任务
		if IsMainWorld() then
	        TUNING.clean_task = _G.TheWorld:DoPeriodicTask(2*TUNING.TOTAL_DAY_TIME, task, TUNING.TOTAL_DAY_TIME*.5)
	    end
	    _G.TheWorld:ListenForEvent("entity_droploot", OnEntityDropLoot)

        
	end)

	--注册全局函数
	_G.x_clean = function()
		print("--草服清理工具：手动清理--")
		local msg = _G.SHARD_KEY.."clean0"
        TheNet:SystemMessage(msg)
	end

	_G.x_start = function(interval)
		local msg = _G.SHARD_KEY.."cleanstart"
        TheNet:SystemMessage(msg)
	end

	_G.x_stop = function()
		print("--草服清理工具：停止自动清理任务--")
		local msg = _G.SHARD_KEY.."cleanstop"
        TheNet:SystemMessage(msg)
	end

end