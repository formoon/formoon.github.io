---
layout:         page
title:          华为ARM服务器上手体验
subtitle:       不吹不黑，用实际应用来看看TaiShan的表现
card-image:		http://files.17study.com.cn/201912/hw/huawei-kunpeng920.jpeg
date:           2019-12-10
tags:           html
post-card-type: image
---
![](http://files.17study.com.cn/201912/hw/huawei-kunpeng920.jpeg)  
#### 背景
中美贸易冲突以来，相信最大的感受，并不是我对你加多少关税，而是我有，可我不卖给你。“禁售”成了市场经济中最大的竞争力。  
相信也是因为这个原因，华为“备胎转正”的鲲鹏系列芯片，一经推出，就吸引了业界的眼球。  
经过漫长的等待，基于鲲鹏920，代表高端计算能力的华为服务器已经开始大量出货。  
今天偶然发现，华为云上正在进行“鲲鹏弹性云服务器”免费试用活动，于是迅速的申请了一台尝鲜。  
![](http://files.17study.com.cn/201912/hw/huawei-event.png)  

#### 基本环境
最基本的试用套餐中，包括一台1核、1G内存、1M带宽的弹性服务器；一个100G的云硬盘还有一个动态的公网IP。个人用户可以免费试用15天。  
![](http://files.17study.com.cn/201912/hw/huawei-order.png)  

服务器可选多种操作系统，华为推荐的是自有的欧拉操作系统(EulerOS)。这是华为基于CentOS定制的版本，包含了多种服务器场景的优化，对于ARM64芯片也有更好的支持。其它还有10余种选择，都是Linux类的各种发型版本。  
严重依赖Windows系列的---你现在可以退散了，除了Windows操作系统当前还绑定在X86系列CPU之上，微软系列也属禁售之列。  
作为试用，首先要“玩”起来方便，我选择了Ubuntu18.04系统。  
![](http://files.17study.com.cn/201912/hw/huawei-panel.png)  

跟常见的云端系统一样，购买完成，服务器会快速的自己完成配置、启动。华为云提供了基于浏览器的终端界面： ![](http://files.17study.com.cn/201912/hw/huawei-console.png)  

一开始只有一个root账号，利用浏览器的终端，新建一个日常使用的账号，升级各项更新和补丁，重启，可以直接在远程使用ssh登陆到动态公网IP了。  
整个过程流畅、稳定，第一印象跟通常使用的服务器并没有什么不同。如果不使用uname检查内核，完全感觉不到是一台ARM服务器。  
```js
$ uname -a
Linux ecs-kc1-small-1-linux-20191209185931 4.15.0-72-generic #81-Ubuntu SMP Tue Nov 26 12:21:09 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux
```



