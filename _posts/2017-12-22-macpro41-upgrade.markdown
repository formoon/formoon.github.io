---
layout:         page
title:          MacPro4,1升级到MacPro5,1
subtitle:       MacPro4,1 firmware patch and upgrade 
card-image:     https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/macpro.jpg
date:           2017-12-22
tags:           mac
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/macpro.jpg)

收了一台老MacPro,2009年版本，准确型号是“MacPro4,1”。机器很好，美中不足的是，太老了。硬件还好说，很多部件都可以单独采购升级，特别是有了淘宝，几乎只要有的东西，都可以买到。软件就麻烦了，macOS sierra已经不支持，更别说high sierra。  
而如果不能用最新的系统，对于研发人员来讲，MacPro的价值将大大降低，因为从开发系统到测试环境，都是非常严格的版本相关的。比如对于iPhone这类产品，Apple更是发布新版本后几个小时，老版本的验证服务器就会关闭从而强制用户升级。  
经过仔细的研究资料，发现苹果的"MacPro4,1"版本硬件跟“MacPro5,1”版本硬件区别很小，网上也有了对应工具用于将前者升级到后者版本。不过因为这款机器太老，很多相关的工具、脚本的下载、使用都有了很多问题，这里把文件下载存储到国内服务器上，然后给个总结如下：  
首先下载升级工具：<https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/22/MacPro2009-2010FirmwareTool.zip>  
解压缩后是个可执行.app文件,尝试运行，按照屏幕提示操作即可，根据网上的评论，大多情况下可以顺利完成升级。也有一些会中间出现长时间锁死或者报错5570失败，很可惜啊我是后者。  
一般的出现错误的原因都是因为时间太长，需要下载的固件包已经无法下载；又或者是http协议当前在苹果内部已经废弃；当然也不排除是“大防火墙”的问题了，碰到这种情况可以如下操作：
* 到苹果官方网站下载两个补丁包，地址分别为：<http://support.apple.com/downloads/DL989/en_US/MacProEFIUpdate.dmg>和<http://support.apple.com/downloads/DL1321/en_US/MacProEFIUpdate.dmg>，特别注意，两个文件名完全相同，但是不同的版本，前者是1.4，后者是1.5，下载后保存的时候不要搞混。
* 如果你已经有一台web服务器是最好的，但是如果你没有，可以考虑在本地临时设置一台web服务器，比如使用python内置的SimpleHTTPServer。下面假设我们在本地设置一台web服务器。
* 首先确定一个工作目录，在其下根据上面URL的方式设置两个文件夹：`mkdir -P downloads/DL989/en_US/`及`mkdir -P downloads/DL1321/en_US/`,将刚才下载的两个文件，对应分别放入目录，再次强调，因为文件名是相同的，别放错。
* 修改本地hosts文件，把support.apple.com网址指向127.0.0.1。看到这里你会不会说“咦？刚才下载的时候命名网址可以访问啊？”，不过可惜啊，这个升级工具它下载不下来，猜测的原因一开始就说过了。
* 在当前文件夹执行：`sudo python -m SimpleHTTPServer 80`，这是在80端口启动了web服务,使用sudo的原因是80端口只能使用root权限启动。接着，再次执行升级工具试试，至少在我这里，可以顺利的将系统升级了。
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/22/macpro.jpg)（升级成功的对比）

系统升级后，再安装macos sierra及high sierra就都不会有问题了。而且在新版本系统安装的时候，检测到固件的版本会比较老，会自动为你升级MacPro5,1的新固件，新固件工作起来一切正常。

除了升级软件，硬件可能会出现的问题主要是两个：  
* 原有的蓝牙模块功率非常小，而且是老版本的蓝牙协议，同当前的很多蓝牙键盘、鼠标已经不兼容，建议在淘宝买一个usb的蓝牙适配器，找的时候搜索Mac电脑免驱动可以用的。
* MacPro4,1的风扇电路设计可能同MacPro5,1有所不同，系统的自动调速似乎工作总是不正常，推荐用一个第三方软件“Macs Fan Control”，根据使用情况人工干预风扇的转速，在平常的时候，可以关小一些大幅的降低噪音。



资料参考：<http://forum.netkas.org/index.php/topic,852.0.html>
