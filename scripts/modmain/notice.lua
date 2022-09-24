local interval = GetModConfigData("interval")
local send_rule = GetModConfigData("send_rule")
announce = {
	"本服有商店/任务/称号/成就/武器升级，让风滚草玩法更有乐趣",
	"彩色风滚草交流QQ群：384301246",
	"商店的财富值做基础任务及猪王任务都可以获得",
	"左上角点击可以查看面板更多内容（攻击力,暴击等）,请记得多翻页,快速复活在左下角,点击即可复活",
	"禁止使用空间权杖将地下物品打包到地上(地下池塘及远古科技除外),否则会造成服务器崩溃问题,发现一律拉入服务器黑名单",
	"地上世界禁止打包原始猪王、月台及沙漠池塘类似的唯一资源,会影响到游戏体验,不管世界有没有人",
	"猪王、月台等更多资源风滚草都可以开出，加油开风滚草吧",
	"自己的武器可放入龙鳞火炉进行熔炼(第一格放要升级的武器)，提高武器伤害(理论无上限)",
	"如有彩色附魔，需要击杀附魔怪物及boss获得附魔属性，最好的是彩色及紫色属性(可询问服内其他玩家)",
	"本服有自动清理，请不要长期挂机或死亡下线，你的物品可能会全被清理掉",
	"蓝图玩法需要击杀各种怪物获取，有多的蓝图还请能留给其他玩家",
	"按U键输入#add 玩家数字 给权限  #del 玩家数字 收权限!",
	"合作才是游戏的乐趣所在哦,请多多照顾新手,远离熊孩子,营造良好饥荒环境！",
	"按Tab键在玩家列表左边查看相应玩家数字，建议有玩家正在进出房间时不要收给权限！",
}
local n = 1
AddSimPostInit(function(inst)
	if GLOBAL.TheNet and GLOBAL.TheNet:GetIsServer() then
		GLOBAL.TheWorld:DoPeriodicTask(interval, function(inst)
		if send_rule == 1 then
			local temp_n = n % (#announce)
			if temp_n == 0 then
				if not GLOBAL.TheWorld:HasTag("cave") then 
					GLOBAL.TheNet:Announce(announce[(#announce)])
				end
			else
				if not GLOBAL.TheWorld:HasTag("cave") then 
					GLOBAL.TheNet:Announce(announce[n % (#announce)])
				end
			end 
			n = n + 1
		else
			if not GLOBAL.TheWorld:HasTag("cave") then 
				GLOBAL.TheNet:Announce(announce[math.random(#announce)])
			end 			
		end
			
		end)
	end
end)