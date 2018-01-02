---
layout:         page
title:          如何看到微信小程序的源码
subtitle:       wechat mini-app 探究
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1514886948128&di=61563d84fbaa4cf1756261b74414628c&imgtype=0&src=http%3A%2F%2Fwww.aiyingli.com%2Fwp-content%2Fuploads%2F2017%2F01%2F1-51.png
date:           2018-01-02
tags:           HTML
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1514886948128&di=61563d84fbaa4cf1756261b74414628c&imgtype=0&src=http%3A%2F%2Fwww.aiyingli.com%2Fwp-content%2Fuploads%2F2017%2F01%2F1-51.png)
首先要说，按照中华人民共和国著作权法，逆向工程看别人源码是不合法的，所以请仅限于个人学习。  
另外一个角度来说，HTML/JS本身的开源特质，也是在鼓励大家互相交流、沟通和共同的进步。从这个角度上说，非技术限制所导致的人为对源码进行封装、隐藏网页源码，似乎也不那么令人信服。  

如题，这件事情要分为两步：  
1.拿到小程序软件包。有两种方法可以建议，一是使用抓包工具获取网络数据记录，所有的软件包应当是https://cdn-xxxx.xxx.xxx/nnnnn.wxapkg这样的URL形式从网上下载。后面的nnnn指的是数字，随后可以在桌面浏览器把这个文件下载下来。二是从手机的缓存中获取，相信开放平台诸如android会更容易，不过手头没有样机，所以我是用一个已越狱的iPhone操作：
```bash
#登陆到手机
ssh root@192.168.1.103
#进入应用沙盒目录
cd /var/mobile/Containers/Data/Application/
#搜索所有缓存的小程序包
find . -name "*wxapkg"
#或者建议在搜索的同时拷贝到桌面电脑
#桌面电脑在执行拷贝之前建立好保存的文件夹
find . -name "*wxapkg" -exec scp {} andrew@192.168.1.105:~/Downloads/wx/ \;
#请注意以上手机的ip地址、台机的ip地址都应当换成你自己的
```
至此将所有的wxapkg的小程序文件包拷贝到了桌面电脑。视你运行小程序的情况，一般近期的小程序都会在缓存中，你当前运行的小程序正常是肯定在的。

2.第二步就是将这个小程序文件包解压缩成正常的文件。
请使用如下解压缩工具：  
<https://github.com/Clarence-pan/unpack-wxapkg>  
此兄台使用了php语言写的解压缩脚本，请自行下载php源文件以及准备好php运行环境。  
在mac电脑上解压缩的方法是：`php unpack-wxapkg.php 14.wxapkg`，执行后会生成一个`14.wxapkg`开头的文件夹，其中就是解压之后的文件。  

一般来说，脚本js文件已经经过了压缩，阅读起来非常困难，推荐两个个在线工具。其一<https://tool.lu/html/>，将js文件所有内容拷贝至在线工具，然后使用美化功能，可以恢复到缩进排版的源码格式，这样可以便于你阅读学习。  
另外一个在线工具对于更深度的js编译压缩有较好的反编译解压缩效果，可以酌情使用：<http://jsbeautifier.org>  

本文已经写完的时候，在网上又看到另外一篇文章，介绍将解包的小程序运行起来。所需步骤是：
* 首先下载微信小程序开发工具：<https://mp.weixin.qq.com/debug/wxagame/dev/devtools/download.html?t=20171230>,注意运行这个工具你需要有开发者账号，这个账号注册是免费的。
* 运行开发工具，新建一个项目，选择项目文件夹、选择没有AppID的最后一个体验小游戏（如果你是打算运行一个小程序就选择小程序），小游戏、小程序的区别，一个入口是game.js,一个是app.js。最后一项注意不使用程序模板，默认是使用的，把该选项的勾选取消。
* 把解包的所有文件拷贝到刚刚建立的新项目文件夹。
* 如果是一个小游戏，则建立一个game.json,其中根据手机使用的方向填写内容，比如纵向正常使用，可以如下填写：
```json
{
  "deviceOrientation" : "portrait"
}
```
* 编译然后预览，就跑起来了。注意如果是小游戏，需要通过扫码传送到手机上进行预览和测试。

这一部分参考了如下链接：
<https://juejin.im/post/5a4b0fc7f265da431956a2b7>


