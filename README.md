# mod-rpg
##风滚草模式+rpg玩法
##3.0版本改动(新) *初版(test版)*
1. 修改任务系统
2. 新增技能书
3. 新增网络商店（后期开放玩家交易及跨服交易)
4. 详细人物属性面板及技能属性面板
5. 修改专属技能及天赋（专属升级跟随人物等级）

|人物|天赋|技能|
|:--:|:--|:--|
|威尔逊|无|魔法实验|
|薇洛|无|伯尼之怒|
|温蒂|无|灵魂分裂|
|wx78|A处理器|电场保护|
|维斯|无|气球替身|
|薇格弗得|无|战技|
|沃尔夫冈|无|横扫千军|
|沃利|无|鲜血记忆|
|沃姆伍德|光合作用|撒豆成兵|
|麦斯威尔|无|精神护体|
|薇诺娜|无|飞石术|
|韦伯|蜘蛛体质|无|
|沃尔特|无|连续射击|
|沃托克斯|灵魂掌控|魔力跃击|
|沃特|无|如鱼得水|
|薇克波顿|无|禁忌之书|
|伍迪|无|露西飞斧|

6. 人物自带初始属性
   1. 大力士自带1%暴击 
   2. 机器人自带1%反伤 
   3. 女武神自带1%吸血 
   4. 女工自带1%闪避
   5. 厨子自带0.5额外攻击距离
   6. 温蒂自带1%移速 
   7. 火女自带1%移速 
   8. 恶魔自带1%移速 
   9. 威屌自带1%移速 
   10. 小丑自带1%闪避 
   11. 奶奶自带技能书制作 
   12. 植物人自带1%反伤 
   13. 鱼人自带1%闪避 
   14. 沃尔特弹弓子弹扩容到199 
   15. 老麦自带2额外伤害
   16. 韦伯自带1%伤害
   17. 伍迪自带1%额外护甲
7. 死亡惩罚 降低经验值(等级)

<!--
待完成：
1. 武器添加等级
2. 称号调整 √
3. 商店对接网站 √
4. 怪物安装技能 √  活动 存档等

5. 人形怪物
6. 多世界 √
7. 清理 √
8. 邮箱 √
9. 技能快捷键  自带复活 √
10. 收集任务 √
11. 调整价格 √
-->

<br/>
<!--
3.0版本改动(旧)<br/>
1.大改成就系统模式，修改为主线任务及支线任务模式 <br/>
2.修改技能获取方式，同时允许怪物拥有技能 <br/>
3.新增大量技能（天赋等） <br/>
4.新增部分装备（可能会和技能有重复功能） <br/>
5.新增装备套装属性 <br/>
6.交易系统*(延迟开发)* <br/>
7.称号系统微调 <br/>
a.组件改造，考虑技能使用组件监听事件还是直接组件相互注入 <br/>
b.网络变量使用replica + classify <br/>
<br>
天赋:<br/>
1.概率平衡： 概率事件达到基准值后一定会触发 <br/>
2.精打细算： 消耗品使用减少 <br/>
3.
<br>
其他创意记录： <br/>
1.天气控制仪，控制下雨 <br/>
2.骑行扫把（御剑飞行，考虑可行性） <br/>
3.牛角制作号角，代替call指令 <br/>
4.次元制作黑洞，代替跳转世界  <br/>
5.添加背景音乐 <br/>
6.角色互动，羁绊等(暂不考虑)<br/> 
7. 蜘蛛人带多把武器（先测试可行性） <br/>
8. 掉落改为概率，风滚草出货改为概率，都不是必出 <br/>
7.烹饪加入 酒（醉生梦死） <br/>
8.加入限制技能(或者道具)，永久只能使用多少次 <br/>
9.添加唯一一只无敌的蜗牛 <br/>
10.修改死亡惩罚，死亡等级-1 <br/>
11.加入风滚草探测，探测后物品锁定 <br/>
<br>
角色自带天赋（同时专属也改为角色自带）： <br/>
1.大力士自带1%暴击 <br/>
2.机器人自带1%反伤 <br/>
3.女武神自带1%吸血 <br/>
4.女工自带10%快速采集 <br/>
5.厨子自带10%快速烹饪 <br/>
6.温蒂自带1%移速 <br/>
7.火女自带1%移速 <br/>
8.恶魔自带1%移速 <br/>
9.威屌自带1%移速 <br/>
10.小丑自带1%闪避 <br/>
11.奶奶自带技能制作 <br/>
12.植物人自带1%回血 <br/>
13.鱼人自带1%闪避 <br/>
14.沃尔特自带1射程 <br/>
15.老麦自带1%精神护体 <br/>
<br>
<br>

<br>
球状光虫,撒豆成兵
c_announce("服务器即将更新mod！")

!!! 差一个继承
!!! 差一个恢复存档人物
!!  差 护符增加新属性 （寒冰护符的保鲜等）
TheWorld:DoPeriodicTask(610, function() if #TheNet:GetClientTable() >= 10 then x_openholiday() end end)
TheNet:SystemMessage("##MODRPG#1#holiday6:1")
TheNet:SystemMessage("##MODRPG#1#holiday5:2")
TheNet:SystemMessage("##MODRPG#1#holiday8:3")
TheNet:SystemMessage("##MODRPG#1#holiday8:4")
TheNet:SystemMessage("##MODRPG#1#holiday5:5")
TheNet:SystemMessage("##MODRPG#1#holiday5:6")
TheNet:SystemMessage("##MODRPG#1#holiday5:7")
TheNet:SystemMessage("##MODRPG#1#holiday7:8")
TheWorld:DoTaskInTime(600, function() if #TheNet:GetClientTable() >= 5 then x_openholiday(5,9999) end end)
-->
