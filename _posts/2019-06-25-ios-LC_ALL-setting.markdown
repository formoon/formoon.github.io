---
layout:         page
title:          正确设置越狱版ios的终端编码
subtitle:       命令行中文的处理
card-image:		http://115.182.41.123/files/201906/ios-utf8/iphone.png
date:           2019-06-25
tags:           html
post-card-type: image
---
![](http://115.182.41.123/files/201906/ios-utf8/iphone.png)  
本文是针对越狱版iPhone手机的，手机没有越狱就别看了，看了也没办法用。  

越狱版的iPhone当然是为了跟电脑一样做各种有趣的事情的。  
但通常越狱的iPhone在命令行都无法处理中文，比如你的播放器里面的中文歌曲名，列出来全部是乱码的样子。类似下面的图：  
![](http://115.182.41.123/files/201906/ios-utf8/distort.png)  

输入中文也做不到，在终端窗口输入中文，只会收到一串的警告音，什么也输入不上去或者同样是一串乱码显示。  
这样很多强大的命令行工具也不能用了，比如find/grep。  

设置命令行的编码方式是无法成功的，默认情况下命令行只支持"C"的编码方式，也就是CP-1252。这种方式只支持ASCII字符。  
经过一段研究，发现是ios终端默认没有安装编码文件，这也是理所当然，不越狱，标准的iOS要编码文件干啥用，GUI界面都是使用自己的规则处理编码。  
这个编码文件可以直接在macOS电脑上拷贝，iOS跟macOS的编码文件是通用的。通常我是用en_US.UTF-8编码，这种编码对中西文的支持都比较完善。  
编码文件路径在`/usr/share/locale/en_US.UTF-8/`文件夹，完整拷贝出来。保存到iOS上相同的路径。  
直接用scp拷贝应当算最方便的：  
```bash
ssh root@xx.xx.xx.xx     #连接到iPhone
mkdir -p /usr/share/locale
cd /usr/share/locale
# 下面的用户名、IP请替换成macOS对应的用户名和IP地址
scp -r username@xx.xx.xx.xx:/usr/share/locale/en_US.UTF-8 .
echo "export LC_ALL='en_US.UTF-8'" >> ~/.profile

# 下面退出ssh, 重新连接iPhone就成功了，这是为了让修改之后的.profile设置生效
```
此时终端已经能够友好的处理中文了：  
![](http://115.182.41.123/files/201906/ios-utf8/chs.png)  

