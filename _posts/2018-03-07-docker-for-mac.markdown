---
layout:         page
title:          Docker for mac上使用Kubernetes
subtitle:       手工在Docker for mac上安装Kubernetes
card-image:     http://www.fgkj.cc/uploads/allimg/180322/1-1P3220SQJM.jpg
date:           2018-03-07
tags:           mac
post-card-type: image
---
![](http://www.fgkj.cc/uploads/allimg/180322/1-1P3220SQJM.jpg)
本文成文较早，当前已经有更好的解决办法，请参考：
https://github.com/AliyunContainerService/k8s-for-docker-desktop

(此下为原文)

---

通常开发都是使用单机版的Docker环境，不太操心Docker集群的事情。  
而在这种单机环境下，命令行操作Docker觉得很好用了，如果碰到解决不了的问题，还有脚本，如果说有什么事是一个脚本解决不了的。。。那就是两个。。。 :)  
久而久之，很多事情都习惯了用Docker的角度去思考，比如服务发现、负载均衡，直接使用Docker的端口映射配合HAPROXY感觉就足够了。然后在这方面的知识也就固化在了这个点，再也没有更新。  
而实际上Kubernetes大概每三个月发出一个新版本的速度，快速的成长着。以至于感觉，还是迁到Kubernetes吧，比如看起来Kubernetes内置的service/dns/proxy配合做负载均衡，虽然也有一些诟病，但还是比自己原来的方式好用很多啊。至少即便是写脚本，也不希望用了别人一个成熟脚本，还要自己改来改去。  

Docker for Mac的Edge版本直接包含内置的Kubernetes。不过第一次安装就碰到了麻烦，在设置中开启Kubernetes支持之后，命令行工具kubectl很快就安装成功，但是Kubernetes一直停留在安装界面，看不到动作和进展。  
查了查，发现又卡在了Docker映像文件的下载，Kubernetes毕竟是Google开发的工具，所以放在了Google自己的仓库中，域名是gcr.io，在国内完全无法访问。  
因为Docker默认使用https协议，所以通常的翻墙代理直接就返回了TLS签名错误，仍然不能下载。手头又没有好用的VPN。  
好在网上有人早做过了类似的准备。搜到一个centos下安装同样1.92版本的Kubernetes的记录（<https://my.oschina.net/binges/blog/1615955>）。  
其中Kubernetes使用的几个映像，原作者已经下载并导出tar文件，放置到了百度云上，下载地址：<https://pan.baidu.com/s/1dzQyiq>,密码：dyvi。其中还共享有一些centos用的Kubernetes软件包，请忽略，在Mac上不需要。  
把这些文件放入一个文件夹：  
```bash
    etcd-amd64.tar
    k8s-dns-dnsmasq-nanny-amd64.tar
    k8s-dns-kube-dns-amd64.tar
    k8s-dns-sidecar-amd64.tar
    kube-apiserver-amd64.tar
    kube-controller-manager-amd64.tar
    kube-proxy-amd64.tar
    kube-scheduler-amd64.tar
    pause-amd64.tar
```
随后执行一行脚本就可以全部导入了：  
```
for i in `ls`;do docker load < $i ;done
```
导入完成后可以使用`docker images`查看：  
```bash
docker images
REPOSITORY                                               TAG                 IMAGE ID            CREATED             SIZE
gcr.io/google_containers/kube-proxy-amd64                v1.9.2              e6754bb0a529        12 days ago         109.1 MB
gcr.io/google_containers/kube-controller-manager-amd64   v1.9.2              769d889083b6        12 days ago         137.8 MB
gcr.io/google_containers/kube-apiserver-amd64            v1.9.2              7109112be2c7        12 days ago         210.4 MB
gcr.io/google_containers/kube-scheduler-amd64            v1.9.2              2bf081517538        12 days ago         62.71 MB
gcr.io/google_containers/etcd-amd64                      3.1.11              59d36f27cceb        8 weeks ago         193.9 MB
gcr.io/google_containers/k8s-dns-sidecar-amd64           1.14.7              db76ee297b85        3 months ago        42.03 MB
gcr.io/google_containers/k8s-dns-kube-dns-amd64          1.14.7              5d049a8c4eec        3 months ago        50.27 MB
gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64     1.14.7              5feec37454f4        3 months ago        40.95 MB
gcr.io/google_containers/pause-amd64                     3.0                 99e59f495ffa        21 months ago       746.9 kB
```
这些映像都是带版本号标签的，如果打算换用自己习惯的加速器或者国内镜像使用docker pull下载，记得要加上标签，不然因为latest标签，会报找不到映像。  
这些映像有了之后，重启一下Docker for Mac，你会看到Docker起来之后稍等片刻，Kubernetes也跟着起来了。  
