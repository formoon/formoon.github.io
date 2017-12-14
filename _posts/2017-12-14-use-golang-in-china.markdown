---
layout:         page
title:          在国内使用golang的小技巧
subtitle:       下载资源包和查看文档
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1513241513463&di=cff690a53d3399411c18eaef837fb2e3&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dshijue1%252C0%252C0%252C294%252C40%2Fsign%3D12b608fb02fa513d45a7649d55043f8e%2F279759ee3d6d55fb31c2eb0167224f4a20a4dd95.jpg
date:           2017-12-14
tags:           golang 
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1513241513463&di=cff690a53d3399411c18eaef837fb2e3&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dshijue1%252C0%252C0%252C294%252C40%2Fsign%3D12b608fb02fa513d45a7649d55043f8e%2F279759ee3d6d55fb31c2eb0167224f4a20a4dd95.jpg)
(图文无关)

go是一种好语言，从业几十年，接触到go语言就有一种“众里寻他千百度，眸然回首，那人就在灯火阑珊处”的感觉。  
然而其实就是从最近开始，使用golang碰到两个大麻烦，每天几乎都有很多痛苦加身，一个麻烦是下载各种组件包，另一个麻烦是查阅文档手册，为什么是从最近开始就不解释了。这两个麻烦归根结底的根源其实是一个，都来自于我们那个伟大的防火墙。  
问题1，下载组件包，最大量的组件包都来自于官网golang.org,因为这个网站已经被墙，在国内已经无法访问，所以组件下载都会失败，不过golang.org是托管在github,所以还是有一种变通的办法：
```bash
#原有golang.org的下载，对应修改为github的下载，比如：
go get github.com/golang/mobile/cmd/gomobile
#下载完成后,在本地代码库中移动到正确的位置：
cd $GOPATH/src 
mv github.com/golang/mobile/ golang.org/x/
#这样就可以正常使用了。
```
网上还有另外一个方法是使用golang的第三方包管理工具glide,据说glide可以自动从镜像站下载需要的包，但是我用的比较少，没有详细的测试。  
glide安装方法很简单：  
```bash
go get github.com/Masterminds/glide
```
常用使用方法如下：  
```bash
glide create|init 初始化项目并创建glide.yaml文件.
glide get 获取单个包
　　--all-dependencies 会下载所有关联的依赖包
　　-s 删除所有版本控制，如.git
　　-v 删除嵌套的vendor
glide install 安装包
glide update|up 更新包
```
glide的官网地址是：<https://github.com/Masterminds/glide>，建议在官网查询详细文档。

问题2是查看手册问题，因为golang的升级速度很快，目前国内还没有比较完整、完善的文档可供查阅参考，大多数指引特别是最基本的参考手册也是在golang.org网站。这个痛苦其实至今没有太好的解决办法，我只能建议多用yahoo和bing来进行网上搜索，多查一些网站来获取所需的资料。

