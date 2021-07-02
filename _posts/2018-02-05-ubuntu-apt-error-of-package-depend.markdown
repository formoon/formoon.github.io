---
layout:         page
title:          Ubuntu16包依赖故障解决
subtitle:       APT包依赖故障
card-image:		https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201903/28/dependent-chain.jpeg
date:           2018-02-05
tags:           linux
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201903/28/dependent-chain.jpeg)  
Linux一个令人赞叹的优点就是浩如烟海的开源软件。  
工作中碰到的大多数问题，往往都能找到一个优秀的开源软件包来解决，从而节省了自己从头开发的时间和金钱。  
然而也带来了一个附加问题，大量依赖前人成果的后续开发，导致层层叠叠俨如梦魇的包依赖，很多初入门的Linux新手折戟于此。  

当前已经有很多的的包管理工具来简化这一切，比如Centos中的yum，又比如Ubuntu中的apt。都已经默认就安装在各自的操作系统中，随时可以调用。  

今天编译caffe的过程中，发现一些caffe的依赖包用apt无法安装了。比如`sudo apt install libhdf5-serial-dev`，报错依赖libhdf5-dev，然后libhd5-dev又依赖fortran，一直推导到最后到了gcc：
```bash
The following packages have unmet dependencies:
 libgfortran3 : Depends: gcc-5-base (= 5.3.1-14ubuntu2) but 5.4.0-6ubuntu1~16.04.6 is to be installed
E: Unable to correct problems, you have held broken packages.
```
错误信息的大意是需要gcc 5.3.1-14版本，在libgfortran3中要求了“=”这个版本，而不是通常的">"。但是当前系统中已经安装了gcc5.4.0-6版本。这样导致了一系列的依赖包都无法满足安装条件，从而安装失败。  
此类错误，有些可以用`sudo apt install -f`来解决，可惜大多的并不能。  

这时候还可以尝试一下新的`aptitude`包管理工具：  
```bash
sudo apt install aptitude
```
随后再使用aptitude来安装我们需要的软件包：  
```bash
sudo aptitude install libhdf5-serial-dev
```
运行后当然仍然会报告依赖错误，但多了几个选项可供选择。其中一个是“.”(小数点)，aptitude会自动检索出来包括gcc在内的几个包，版本过高，不满足安装需求，询问是否降级？选择Y之后，aptitude将会自动把对应的软件包都降级到需要的版本，从而完成libhdf5-serial-dev的安装。  
这个在apt管理中需要很复杂的手工操作，变得简单无比了。  

参考链接：  
<https://wiki.debian.org/Aptitude>
