---
layout:         page
title:          5分钟搭建一个quic服务器
subtitle:       mac电脑很好用
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1515588532278&di=a9905d0faf61dacb7d47a66af3e4f892&imgtype=0&src=http%3A%2F%2Fwww.qingpingshan.com%2Fuploads%2Fallimg%2F161114%2F21005054D-0.png
date:           2018-01-10
tags:           mac
post-card-type: image
---
副标题是不是好气人啊:)  
其实没有歧视linux的意思，在Mac上的确5分钟可以搭建一个quic服务器。在Linux环境配置略微麻烦，10分钟也够了，五十步跟百步的区别。  
QUIC协议不多解释了，网上搜有很多解释，你需要记住的只有一个字：“快”。  
使用Chromium的quic插件编译一个服务器端很啰嗦，因为它自己以及很多的依赖包都是被墙掉的，根本下不来。  
另外一个golang的实现caddy则在github上，还是比较亲民的。  
我的Mac上常备golang，所以golang的安装就省了，直接开始安装caddy:
```bash
go get github.com/mholt/caddy/caddy
cd $GOPATH/src/github.com/mholt/caddy/caddy
#直接按照官方文档运行go run build.go有问题，因为其中引用了github/caddyserver包不存在，使用：
go build
#可以直接编译出caddy主文件。
#移到可执行目录
sudo mv caddy /usr/local/bin
#到自己的网站目录
cd ~/wwwroot
caddy
```
至此caddy运行起来了，网络就算慢点，5分钟也够了。  

测试访问：  
当前似乎只有chrome支持quic协议，打开chrome,在地址栏输入：chrome://flags，在出来的设置界面中，将原来默认为Default的“试验性QUIC协议”设置为Enable，随后会自动重启Chrome。  
重启完成后，在Chrome访问`http://127.0.0.1:2015/`网站就出来了。

参考链接：  
[caddy官网](https://github.com/mholt/caddy)  
[前卫一下：给你的网站开启 QUIC](https://www.bennythink.com/quic.html)  
