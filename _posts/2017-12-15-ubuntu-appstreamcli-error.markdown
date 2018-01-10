---
layout:         post
title:          Ubuntu16.04LTS appstreamcli报错的处理
subtitle:       
card-image:     
date:           2017-12-15
tags:           linux
post-card-type: article
---
某台机重装两次ubuntu16.04 LTS版本都有开机报错，但一闪而过难以看清，后来尝试`apt update`,在下载完更新索引之后报错,从而确定了报错信息：  
```bash
Problem executing scripts APT::Update::Post-Invoke-Success 'if /usr/bin/test -w /var/cache/app-info -a -e /usr/bin/appstreamcli; then appstreamcli refresh > /dev/null; fi'
```
尝试强制重新安装appstreamcli之后故障消失，但不知道造成的原因是什么：
```bash
#先停止当前的运行
sudo pkill -KILL appstreamcli
#下载主程序和库的软件包
wget -P /tmp https://launchpad.net/ubuntu/+archive/primary/+files/appstream_0.9.4-1ubuntu1_amd64.deb https://launchpad.net/ubuntu/+archive/primary/+files/libappstream3_0.9.4-1ubuntu1_amd64.deb

#安装
sudo dpkg -i /tmp/appstream_0.9.4-1ubuntu1_amd64.deb /tmp/libappstream3_0.9.4-1ubuntu1_amd64.deb
```

之后再运行一次apt的升级操作，因为appstream肯定有了新的升级包。之后就可以正常使用了。  

参考：<https://askubuntu.com/questions/774986/appstreamcli-hanging-with-100-cpu-usage-during-update>
------------------------------
补充：  
1. 用同一个U盘装过很多台Linux,都没有出现过类似现象。    
2. 本台电脑日常偶尔还会出现其它的异常情况。  
3. 经过一段时间之后，这台电脑频繁崩溃，经过仔细检测，都是硬盘文件损坏。  
4. 最终判断硬盘有较为隐性的故障，更换硬盘后各种异常都消失了。  


