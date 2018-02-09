---
layout:         page
title:          GreenPlum无法远程访问解决
subtitle:       关闭Centos防火墙
card-image:     http://img.zgxue.com/ospic/uploads/space/2013/0603/182019_jOyF_141159.png
date:           2018-02-08
tags:           linux
post-card-type: image
---
通常GreenPlum都是安装在Centos上，结果安装完发现远程无法连接，在本地是可以正常访问的。  
测试是否可以连接可以使用psql工具：  
```bash
psql -h 192.168.1.200 -p 5432 -d dw_oems -U gpadmin -W   
	#默认密码一般也是gpadmin或者admin
```
如果不能连接，可以先使用netstat测试一下：   
```bash
#列出当前主机所有tcp监听端口
netstat -ntl
#列出的主机中，如果是：
127.0.0.1:5432 	
#则表示gp仅设置了本地访问，需要修改配置文件：postgresql.conf
#如果列出来是：
0.0.0.0:5432
#这样的形式，表示gp数据库已经允许远程访问。
#需要考虑主机的配置问题，通常是防火墙的限制。
```
比较简单的方式可以直接关闭centos的防火墙：  
```bash
#关闭centos防火墙
systemctl stop firewalld.service
#禁止centos防火墙
systemctl disable firewalld.service
#查看防火墙状态
firewall-cmd --state 
#（关闭后显示notrunning，开启后显示running）
```
关闭防火墙后，远程访问gp数据库正常了。  
