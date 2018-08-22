---
layout:         page
title:          小经验：macOS上VPN无效的处理
subtitle:       调整路由优先级
card-image:		http://img.mp.sohu.com/q_mini,c_zoom,w_640/upload/20170730/f355b2b2ee184957b4bf782bc056ea21.jpg
date:           2018-08-22
tags:           mac
post-card-type: image
---
![](http://img.mp.sohu.com/q_mini,c_zoom,w_640/upload/20170730/f355b2b2ee184957b4bf782bc056ea21.jpg)
首先声明哈，VPN是一种很规范的应用方式，在很多企业应用中都必不可少，我这里可不是教你翻墙的意思。  
某日到一个客户公司去办事，客户的公司上网控制非常严格，上外网都需要拨号到给定的VPN才允许。但在我的苹果本上设置正常、拨号正常、各项网络测试也正常，仍然上不了外网。  
打开终端，命令行使用netstat -r查看，得到类似如下信息：  
```bash
macbookpro13 ~> netstat -r
Routing tables

Internet:
Destination        Gateway            Flags        Refs      Use   Netif Expire
default            10.98.23.254       UGScI           7        0     en0
default            link#19            UCS           127        0    ppp0
...
```
可以看到，默认路由有两条，上面的一条是wifi连接的，第二条ppp0就是VPN拨号得到的。所有的上网通讯，优先是使用第一条路由，并没有经过第二条VPN的通道，所以仍然无法上网。  
在macOS上调整VPN路由的优先级不能使用常规的路由控制命令，而是如下操作：  
* 打开mac系统设置，选择网络设置
* 网络设置中，左下角网络连接管理处，选择+、-号之后的齿轮，在其中选择设置服务顺序（set service order)
* 把刚刚建立的VPN连接拖到列表的最顶上，然后点OK按钮
* 网络设置中点击APPLY按钮
之后看一看路由状态，VPN的路由已经被提到最上面了。上网当然也就正常了。  

参考文献：  
<https://interworks.com/blog/jpoehls/2012/04/18/cant-access-network-resources-over-vpn-connection-mac-os-x/>
