---
layout:         page
title:          resource fork, Finder information, or similar detritus not allowed
subtitle:       错误处理
card-image:     http://115.182.41.123/files/201801/swift.jpg
date:           2018-01-29
tags:           mac
post-card-type: image
---
Xcode编译swift项目报如题错误。  
1. 网上有介绍是使用photoshop等软件处理的图片附加了Xcode不识别的信息，可以在终端中查看，比如如下：  
```bash
$ ls -alF@ *
-rw-r--r--@ 1 andrew  staff  179578 Jan 29 10:07 hsk_slpah.png
	com.apple.FinderInfo	    32 
	com.apple.lastuseddate#PS	    16 
	com.apple.metadata:_kMDItemUserTags	    42 
```
上面列出的com.apple.FinderInfo信息就是。可以使用：`xattr -c resources/hsk_slpah.png`命令来删除。  
2. 也碰到过一个情况，有的时候报这个错误，有的时候报签名错误，各种方法尝试没有解决。后来到可执行文件生成目录中去看，有很多个同名的项目，虽然项目被系统自动增加了随机的目录名前缀，但因为使用Xcode很久，所以积累的废文件很多，把没用的项目全部删除重启Xcode就没问题了。  



