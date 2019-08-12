---
layout:         page
title:          MySQL数据库文件的移动
subtitle:       数据库文件移动和权限设置
card-image:		https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1440923339,67641147&fm=26&gp=0.jpg
date:           2019-08-12
tags:           html
post-card-type: image
---
![](https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=1440923339,67641147&fm=26&gp=0.jpg)  
新型数据库层出不穷，MySQL一幅日薄西山的样子。其实还有很多人或者偏爱、或者使用以前遗留的系统，仍然生活在MySQL的世界。  
我也是有很久不用了，这个很久超过十年。  
不过前几天有个朋友让我帮忙为他们升级服务器，才发现，老革命居然碰到个新问题。  

因为是个用了很久的系统，所以不考虑变更数据库系统了。只是把当前数据库迁移到新的设备上，这应当是很简单的事情。按理说，数据文件大点，拷贝要时间，也超不过20分钟搞定，接下来小酒、撸串才是正理。  
```bash
$ sudo su
# service mysql stop
# cd /var/lib
// 注意下面的mysql是当前的数据文件路径，/media/data是挂载的新存储阵列
// 使用-a选项，是已经考虑了要把文件的权限属性一起拷贝，免得拷贝完成再设置权限
# cp -Ra mysql /media/data/
// 老文件先不删除，保留备份防止意外
# mv mysql mysql-bak
// 偷个懒，直接建一个链接，免得要修改mysql启动脚本和设置文件
# ln -s /media/data/mysql/ .
# service mysql start
```
回车键按下，系统提示：  
```bash
start: Job failed to start
```
赤裸裸打脸:(  
查看日志文件：/var/log/mysql/error.log，得到一些错误信息：  
```bash
190811 10:24:24  InnoDB: Operating system error number 13 in a file operation.
InnoDB: The error means mysqld does not have the access rights to
InnoDB: the directory.
InnoDB: File name ./ibdata1
InnoDB: File operation call: 'open'.
InnoDB: Cannot continue operation.
```
饶是之前就考虑了文件权限问题，拷贝之后，仍然出现了权限错误。  
老的文件夹尚未删除，逐个对比了文件的权限，未发现问题。  
在网上搜索了一下资料，发现大家不约而同的采用`mv`命令来移动数据文件夹，也是为了避免出现权限问题。而这里我为了保存备份，采用了`cp -Ra`。  
这给出了一点线索，当前服务器Linux的版本，都已经默认了更高的安全设置。在Centos是SELinux，在Ubuntu是AppArmor。  
这里说起来只是一句话，当时在现场，是做了很多无用功才在查看服务器启动脚本中想到了这个问题，时间浪费不少。  
找到原因，解决不难，这台服务器使用了Ubuntu，对维护人员比较友好，只要编辑AppArmor的配置文件就好：  
```bash
# vi /etc/apparmor.d/usr.sbin.mysqld
// 将以下4行：
  /var/lib/mysql/ r,
  /var/lib/mysql/** rwk,
  /var/lib/mysql-files/ r,
  /var/lib/mysql-files/** rwk,
// 修改为：
  /media/data/mysql/ r,
  /media/data/mysql/** rwk,
  /media/data/mysql-files/ r,
  /media/data/mysql-files/** rwk,
// 改的时候根据你的数据路径，调整上面4行的设置
// 此外考虑到/var/lib/mysql这个路径也可能会有测试需要，所以原始的4行保留，额外增加4行也可，不差那一点点运算

// 编辑完成存盘，接着更新配置和重启AppArmor服务：
# apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
# service apparmor reload
```
接着再一次启动mysql服务：  
```bash
# service mysql start
```
一切正常了。  

如果使用了Centos，则要更改SELinux的额外权限设置，可参考下面链接中介绍的两个方法操作。  

参考文献：[How to Move MySQL Data Directory to New Location on CentOS and Ubuntu](https://www.thegeekstuff.com/2016/05/move-mysql-directory/)  

