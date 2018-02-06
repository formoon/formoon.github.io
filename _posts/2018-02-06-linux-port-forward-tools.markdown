---
layout:         page
title:          rinetd:轻量级Linux端口转发工具
subtitle:       Ubuntu下rinetd快速安装配置
card-image:     https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=4028094089,3977303194&fm=27&gp=0.jpg
date:           2018-02-06
tags:           linux
post-card-type: image
---
新的微服务理念下，网络端口映射从来没有像今天一样被如此频繁的应用。  
在正式的生产环境中，HAPROXY或者NGNIX反向代理基本已经成为软件方案中事实上的工业标准，硬件路由器的NAT方式则是硬件方案中的普及应用。  
但是在开发环境中，这些通常的工具还是太重了，维护起来也有些麻烦。  
[rinetd](http://www.lenzg.net/rinetd/rinetd.html)是一个好选择，安装容易，配置简单，兼容性也还不错。我在使用中只发现过碰到上G的大文件直接sftp协议传输碰到一些兼容问题(猜测生产级的多用户、大规模并发性能不够），正常的日常应用基本没有问题。  
在Ubuntu上安装rinetd非常容易：  
```bash
sudo apt install rinetd
```
rinetd的配置文件位于`/etc/rinetd.conf`。一行典型的rinetd映射配置如下：  
```bash
# bindadress    bindport  connectaddress  connectport
0.0.0.0 20022 192.168.130.100 22
```  
如同上面英文部分的解释所描述的，用空格隔开的4个参数分别为：绑定到主机的地址、绑定端口、转发到的目标IP地址，目标端口。  
上面的例子实际就是把虚机或者容器中的192.168.130.100机器的22号ssh端口，映射到当前的Ubuntu主机上。  
其实目标地址不是虚机或者容器也是可以的。比如局网中，我们只有有限的外部IP地址，其它的设备只拥有内网地址，也一样可以用这个端口映射的方式，为外部提供服务。  
这个IP地址甚至可以在别的网段，只要当前这台主机能够访问到，端口代理就都能使用。  
这样的配置文件可以有多行，从而同时映射多个端口到本机，供外部访问。  
每次修改配置文件后，需要重启rinetd服务来使配置生效：  
```bash
service rinetd restart
```



