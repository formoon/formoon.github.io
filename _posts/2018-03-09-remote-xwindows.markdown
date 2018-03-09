---
layout:         page
title:          在Mac上使用远程X11应用
subtitle:       XWindows vs Windows
card-image:     https://upload.wikimedia.org/wikipedia/commons/d/d4/X-Window-System.png
date:           2018-03-09
tags:           mac linux toSeven
post-card-type: image
---
![](https://upload.wikimedia.org/wikipedia/commons/d/d4/X-Window-System.png)
XWindows太老了，历史比Windows和Linux的开发时间都长，以至于很多人每天实际在用，但已经不知道它的存在。  
XWindows目前是Linux/类Unix系统上的标准显示配置，QT/GTK等架构也是基于XWindows的。所以通常也有很多人只关注占领桌面市场的Windows，对于败退在边缘的XWindows完全嗤之以鼻。  
其实只从GUI层面上来对比Windows和XWindows是不公平的。XWindows设计之初就是一个显示服务器的概念，在显示器服务器和应用之间，有一套[协议](http://blog.csdn.net/hxh129/article/details/7839963)来沟通彼此，是C/S的架构，这个协议可以序列化，从而显示的设备、跟应用运行的环境，可以不在同一台电脑之上。想想你熟悉的那些无线投影啥的，是啥时候才出现的吧。  

其实我个人也很久不用XWindows了。平常工作在Mac，但是最近机器学习的任务越来越多，Mac用起来就有点不顺手了。因为MacPro标准配置的opencl，远远比不上cuda在机器学习领域的支持广泛。恐怕如果Mac电脑不尽快做出改变，这一波风暴足以把很多依赖于Mac环境的开发人员驱逐到Linux甚至Windows的怀抱中去了。  
Windows的环境天然对NV系列显卡和CUDA的驱动支持很充分，所以也有很多程序员使用Windows环境做开发。但很多开源系统在Windows环境的编译甚至移植实在太艰苦了，一个应用中很大的精力都在折腾这些事情，完全不能集注到应用本身。  
所以我用的方法是另外找一台电脑安装NV显卡，然后运行Linux，虽然CUDA和CUDNN安装麻烦了一点点，但后续的工作就都很顺畅了。  
接下来就需要XWindows闪亮出厂了。当然可以另外接一套显示和键盘，但那样要占空间的...虽然显示器、键盘、鼠标不贵，但空间贵啊。再有就是远程桌面，不过那种分割的感觉，用起来会增加许多额外的麻烦。所以很多人忘记很多年的远程XWindows，可以出来嘚瑟一下了 :)  

macOS虽然也是类Unix，但从很早开始就不使用XWindows作为显示系统了，所以现在想在Mac上使用XWindows,需要先安装另外一个Apple发起的开源项目：[XQuartz](https://www.xquartz.org)。除了去官网下载安装包，在有Homebrew的系统上安装更简单：`brew cask install xquartz`，安装后是个app应用，可以在LaunchPad启动。所有XWindows的应用，都应当先启动xquartz应用，然后在其中的终端中（一定注意不是macOS原有的终端）再启动XWindows应用。  
接着是将远程的linux服务器上的运行结果，在本地的XQuartz中显示。正常情况下，如果本机Mac及远程的Linux在一个局网，或者双方能直接ping通那就简单了，只需要设置一个环境参数`DISPLAY`。如果linux用的是bash外壳，其设置方法为：`export DISPLAY=mac电脑IP地址:0.0`，冒号后面数字的意思是：第0个设备的第0个屏幕。  
如果两台电脑不在一个网段，就需要ssh大神的配合，首先查看`/etc/ssh/sshd_config`中的设置，是否打开了以下两项：  
```
X11Forwarding yes
X11DisplayOffset 10
```
这两项通常在安装sshd的时候都是默认屏蔽的。打开之后，还要设置DISPLAY环境变量为：`export DISPLAY=localhost:10.0`，其中localhost表示直接将显示数据发送到本地，位置10跟上面sshd的设置配套，表示由本地的sshd转发到远端的客户端去显示。  
最后还有一项，在mac使用ssh连接远端的服务器的时候，首先要确保是在XQuartz的终端中执行ssh命令，然后ssh命令中需要增加`-X`或者`-Y`参数，表示接受远端的XWindows转发数据。示例：`ssh -Y john@123.123.123.123`。  
连通之后，可以在远端运行一下xeyes、xclock、xlogo这样的基本应用来测试一下，看能否在本地桌面上显示出来。题头图的右上角两个应用分别是xlogo和xclock的样子。  
最后给一个在我的电脑跑起来的样子：  
![](http://p1avd6u2z.bkt.clouddn.com/201803/09/dnn_face_reg.png)
看起来跟在本地运行没有什么两样 :)  


  
