---
layout:         page
title:          被Docker/VMWare宠坏的孩子们，还记得QEMU吗？
subtitle:       用QEMU构建真正的异构CPU环境
card-image:     https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=46233978,3905979695&fm=27&gp=0.jpg
date:           2017-12-28
tags:           mac linux
post-card-type: image
---
![](https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=46233978,3905979695&fm=27&gp=0.jpg)
这是一个云端的年代，这是一个虚拟化的年代。当我们幸福的置身其中的时候，也不得不痛苦的怀疑自己的感官和思想，真和假，虚和实，谁又能分得清。  
时至今日，几乎没有一台服务器不是用虚拟化的方式管理和维护了。每个人的电脑上，VMware虚机或者Docker组成的诸多大大小小、错综复杂的微服务容器已经充斥生活。还有人记得QEMU吗？  
QEMU是虚机鼻祖式的应用，正是从QEMU开始，虚拟化、云服务才一日紧似一日的迅猛发展，直至一统江湖。  
其实在今天，真正还在使用QEMU的用户已经比较少了，如果不是Android模拟器还在勉强的撑着门面，跌破1%的占有率恐怕也不会令人奇怪。最差也会是运行QEMU-KVM虚拟环境吧。  
主要的区别，QEMU是一个应用程序，运行在用户空间，采用纯软件模拟的方式来仿真CPU出来，在虚拟环境中运行虚拟操作系统；而QEMU-KVM的KVM部分，或者Docker/VMWare等其它虚机系统，会有一部分运行在内核层，特别是提供真实的CPU执行能力，当然其它硬件层的访问，也会有非常大的提速。对于真正使用虚拟环境的用户，毋庸置疑会选择后者。所以OpenStack年代，很多用户都是将QEMU-KVM当做主力单元。    
但是QEMU的这种特性也会有一个其它虚拟化所不具有的优点，就是可以虚拟真正的异构CPU环境。比如我们使用的Android模拟器，内核就是QEMU,提供了一个真实的ARM环境（当然现在也有很多x86的Andoid及x86的Android模拟器）来运行Android环境及调试应用程序，很多人评论Android模拟器运行效果慢，不如mac上面iPhone模拟器快速精致。究其根本原因，就是因为Android的模拟器是跑在ARM真实的模拟环境下，软件的每个字节都要被QEMU从ARM翻译到主机的x86代码，然后再执行，所以尽管有这样那样的缺点，模拟结果的可靠性却是iPhone模拟器所不能媲美的。  

进入我们的正式话题，我们来尝试一下在mac电脑上，用QEMU搭建一个PowerPC环境来进行PowerPC的开发工作。首先执行`brew install qemu`安装qemu系统。qemu是开源软件，可以免费使用。  
随后下载PowerPC版本的linux系统光盘，各大linux品牌的网站上都应当有下载，个人偏好ubuntu/debian系列，ubuntu下载地址：<https://wiki.ubuntu.com/PowerPC>，其中ubuntu12有powerpc版本,debian同样也只有老版本有powerpc版本了，可以在台湾的镜像网站上下载会比较快：<http://ftp.tku.edu.tw>。  
在VMWare或者类似的商业软件中，有美观易用的GUI界面帮助用户建立虚机和进行配置，在QEMU中，我们就完全需要命令行手工操作了。不过这样的优点也是很显著的，就是我一再提到的，可以做成批处理或者实现自动化。这对于技术人员来讲可是很重要的整合手段。下面是建立PowerPC虚机的完整过程，仍旧用注释的形式逐行解释：  
```bash
#准备一个虚机工作目录
mkdir ~/qemuPowerPC
cd ~/qemuPowerPC

#建立一个虚拟硬盘文件，
#格式为qcow2,这是qemu支持最好的虚拟硬盘格式
#虚拟硬盘文件名为：debian-ppc.qcow2，容量为15G
qemu-img create -f qcow2 debian-ppc.qcow2 15G

#执行虚机系统并进行系统安装操作
# -m 512   虚拟内存大小，不指定默认是128
# -redir tcp:2222::22 网络端口重定向，这样安装完成后可以ssh -p 2222 127.0.0.1连接到虚机
# -boot d 从cdrom启动
# -cdrom 指定iso文件路径
# 最后是虚拟硬盘文件的路径名
qemu-system-ppc -m 512 -redir tcp:2222::22 -boot d -cdrom ~/Downloads/debian-server-powerpc.iso debian-ppc.qcow2

```
好了，屏幕上会弹出一个QEMU的窗口，显示debian安装界面，跟其它虚机一样，你可以一步步按照提示操作，安装操作系统，最后一定要记得安装openssh-server服务以便我们将来直接从命令行管理。安装完成后正常从菜单选择关机。至此，虚拟硬盘文件中，已经安装好了debian的操作系统。  
接着是做一个启动脚本，不然每次打这么长的命令行实在是太费劲了，通常在VMWare这样的系统中，关于内存配置、网络配置等信息，是保存在虚机配置文件中的。而在QEMU系统中，这些内容大多数都是采用命令行参数的方式实现。把下面脚本保存到一个文本文件，然后`chmod +x`设置可执行权限，以后每次直接运行，就可以启动虚机了。
```bash
#!/bin/sh

qemu-system-ppc -m 1G -device e1000,netdev=net0 -netdev user,hostfwd=tcp::2222-:22,id=net0 ~/qemuPowerPC/debian-ppc.qcow2 
```
下图就是一个安装好的展示画面，其中的uname命令中可以看到CPU类型是PowerPC类型：
![](http://blog.17study.com.cn/attachments/201712/28/debian.png)
在一个真实的CPU环境中工作，原来很多交叉编译繁复工作、本地依赖库及目标机依赖库的头痛问题都不用考虑了。这种顺畅，是除了golang这种天生自带交叉编译系统之外的开发人员梦寐以求的吧。  
qemu支持很多种cpu类型，每种cpu都有一个对应的启动程序，可以通过ls /usr/local/qemu*查看一下，比如我电脑上的最新版包括这些启动程序：  
```bash
ls /usr/local/bin/qemu*
/usr/local/bin/qemu-img                 /usr/local/bin/qemu-system-microblazeel /usr/local/bin/qemu-system-s390x
/usr/local/bin/qemu-io                  /usr/local/bin/qemu-system-mips         /usr/local/bin/qemu-system-sh4
/usr/local/bin/qemu-nbd                 /usr/local/bin/qemu-system-mips64       /usr/local/bin/qemu-system-sh4eb
/usr/local/bin/qemu-system-aarch64      /usr/local/bin/qemu-system-mips64el     /usr/local/bin/qemu-system-sparc
/usr/local/bin/qemu-system-alpha        /usr/local/bin/qemu-system-mipsel       /usr/local/bin/qemu-system-sparc64
/usr/local/bin/qemu-system-arm          /usr/local/bin/qemu-system-moxie        /usr/local/bin/qemu-system-tricore
/usr/local/bin/qemu-system-cris         /usr/local/bin/qemu-system-nios2        /usr/local/bin/qemu-system-unicore32
/usr/local/bin/qemu-system-i386         /usr/local/bin/qemu-system-or1k         /usr/local/bin/qemu-system-x86_64
/usr/local/bin/qemu-system-lm32         /usr/local/bin/qemu-system-ppc          /usr/local/bin/qemu-system-xtensa
/usr/local/bin/qemu-system-m68k         /usr/local/bin/qemu-system-ppc64        /usr/local/bin/qemu-system-xtensaeb
/usr/local/bin/qemu-system-microblaze   /usr/local/bin/qemu-system-ppcemb
``` 
QEMU还不仅可以做这些，一些底层的开发，比如内核的调试，用QEMU进行往往比一台真机更快速有效，其它的商业版虚拟软件也同样无法比拟。下面的命令行是用QEMU启动一个编译输出的内核：
```bash
qemu-system-x86_64 -kernel bzImage \
               -hda rootfs.ext2 \
               -boot c \
               -m 512 \
               -append "root=/dev/sda rw" \
                -localtime \
                -no-reboot \
                -name rtlinux \
                -net nic -net user \
                -redir tcp:2222::22 \
                -redir tcp:3333::3333
```
这个命令行要额外解释一下，网络、内存等其它很多参数略过不提，帮助页面写的很清楚。rootfs.ext2是一个ext2格式的根文件系统，其实就是一个磁盘映像，以前已经安装好了linux系统。bzImage是刚刚编译的新内核，这里使用这个新内核而不是硬盘中的kernel启动虚机系统，从而验证新编译内核的工作情况。后面的-append附加的启动参数，也是表示等内核启动后，根文件系统仍然使用原有的磁盘映像来进一步启动后续的各项服务。  
还有一种内核的编译模式是将一个根文件系统直接压缩打包到内核文件中，这种情况根文件系统一般只能只读了，在台式机中大多是用来进一步引导硬盘上的操作系统，在小规模的嵌入系统中，有些这就可以是完整的系统了，这种情况的启动更是容易：
```bash
qemu-system-x86_64 -kernel bzImage
```
有了这些功能，进行linux定制开发的时候简直是太方便了，比如我们制作一个最简单的hello world应用，代码如下：
```c
/*helloworld.c*/  
#include <stdio.h>    
  
void main()  
{  
    printf("Hello World - from QEMU environment\n");  
	//强制刷新输出，不然可能打印不出来  
    fflush(stdout);
	//锁死程序，不然也可能一闪而过  
    while(1);
} 
```
把程序静态编译，注意必须静态，不然基本内核起来，并不存在其它的链接库：
```bash
#以下工作要在Linux环境进行，因为我们是测试linux内核的启动
#静态编译
gcc -static -o helloworld helloworld.c  
#打包为rootfs
echo helloworld | cpio -o --format=newc > rootfs 

#　使用qemu启动  
qemu-system-x86_64   \  
     -kernel ./bzImage \  
     -initrd ./rootfs  \  
     -append "root=/dev/ram rdinit=/helloworld"  
```
运行结果的贴图就不放了，效果就是在kernel信息显示完成后，下面有一行“Hello World - from QEMU environment”。  
还可能更基础吗？当然是可以的，<https://github.com/lucasysfeng/lucasOS>，这是操作系统基本原理的一个教学实验项目，其中有自己直接操作显示缓存区，实现显示，来模拟一个操作系统内核启动过程的代码，代码很短，有兴趣可以去看看，最后的实践环节也是把编译的内核放到QEMU中去执行。  


最后说一说qemu虚机的日常维护，其实就是虚拟磁盘文件的维护，在VMWare中也有一个压缩硬盘未用空间的功能。类似的qemu可以用磁盘映像转换工具来达到类似的功能：
```bash
#-p 显示进度，-O是指定输出格式，-c启用压缩
qemu-img convert -p -c -O qcow2 debian-wheezy-powerpc.qcow2 shrinked.qcow2
```
这个工具本身是将各种磁盘映像文件进行格式转换，这里我们输入输出都是相同的格式，其实就是让工具将输入的磁盘重新输出成为一个新的文件，从而压缩了碎片空间，也就减小了整体映像文件尺寸。

QEMU官网链接：<https://www.qemu.org>


