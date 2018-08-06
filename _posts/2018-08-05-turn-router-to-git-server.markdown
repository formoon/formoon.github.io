---
layout:         page
title:          把路由器改装成git服务器
subtitle:       OpenWRT环境的GIT服务器搭建
card-image:		https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1697833489,2364702298&fm=27&gp=0.jpg
date:           2018-08-05
tags:           linux
post-card-type: image
---
![](https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1697833489,2364702298&fm=27&gp=0.jpg)
在单位中，通常都标配了git服务器用来管理代码。  
对于家庭或者小办公室，这种方式有点不经济。当然如果是开源项目就简单了，刚刚被微软收购的github是理想选择。但如果没有打算开源，我今天的话题可能对你有用。  
我就属于喜欢在家中干活的那一类，以前常年开着一台电脑做下载，最近改了这个坏习惯。但是没有了长期开机的设备，也就没有了git server。  
趁着周末，把一台老的路由器改了改，当成git server来用，感觉效果爆棚，不能不安利给大家。  

#### 硬件
* 一台能够安装OpenWRT（或者Linux系统的）路由器，我用的是一台老设备，Netgear WND3700V1。  
* 视你日常工作量大小，准备一个空间足够的U盘，最好是高速的，当然这个高速是指能匹配路由器USB口的标准就足够。  

#### 系统软件
成文时，OpenWRT的版本是18.06.0，其它版本应当也可以，OpenWRT挺早就支持git软件包了。下载地址在：<http://downloads.openwrt.org/>。也可能是我的问题，但至少看起来，这样一个纯技术网站，不翻墙已经下载不到了。  
因为各家路由设备的硬件复杂性，虽然都是同样的OpenWRT，不同的路由器仍然要下载自己硬件对应的版本。如果之前没有安装过OpenWRT的话，建议你在<https://openwrt.org/toh/views/toh_fwdownload>查询OpenWRT支持的设备列表，确认自己应当使用的版本。  
OpenWRT的安装这里不讲，请参考官方相关文档。通常都是在自己路由器的管理界面使用软件更新功能，选择下载的固件文件，上传随后升级。  
接着请根据自己家里网络的情况，配置上网设置各项目，保证基本路由功能工作正常。  
#### 管理路由器
OpenWRT18.06.0的默认管理方式是使用ssh，方法：ssh root@[IP地址]。根据路由器的FLASH大小，比较小的FLASH是默认没有WEB GUI界面的，比如我用的这台。所幸大多情况下使用命令行配置路由器效率更高，而且有些工作是使用GUI界面做不到的。  
OpenWRT的默认账户用户名是root，没有密码，正常情况下第一次登陆会要求你修改密码。在一个连接公网的环境中，请尽早登陆修改密码。  

#### 配置镜像源
> 如果你不用翻墙就能访问官方的源服务器的话，请跳过这一节内容。  

OpenWRT使用opkg工具来管理扩展包。因为前面所说的原因，需要配置使用镜像源来保证所需软件包的安装。  
中间碰到一个小麻烦是国外的镜像服务器，基本都使用了https协议，OpenWRT不能直接支持。国内的镜像大多倒是http协议，但镜像中又缺乏一些驱动包，无法驱动U盘。  
所以如果找不到更好的完整源的话，只好把变更源这样一件小事分成两步来做。  
opkg的源配置文件路径为：/etc/opkg/distfeeds.conf，首先做一个备份，然后你可以使用你喜欢的编辑工具修改，我通常都是vi。   
把distfeeds.conf文件的内容修改为：  
```bash
src/gz openwrt_core http://openwrt.proxy.ustclug.org/releases/18.06.0/targets/ar71xx/generic/packages
src/gz openwrt_kmods https://downloads.lede-project.urown.net/snapshots/targets/ar71xx/generic/kmods/4.9.117-1-e017c397f3c6ba06dc921b136a63fb36
src/gz openwrt_base http://openwrt.proxy.ustclug.org/releases/18.06.0/packages/mips_24kc/base
src/gz openwrt_luci http://openwrt.proxy.ustclug.org/releases/18.06.0/packages/mips_24kc/luci
src/gz openwrt_packages http://openwrt.proxy.ustclug.org/releases/18.06.0/packages/mips_24kc/packages
src/gz openwrt_routing http://openwrt.proxy.ustclug.org/releases/18.06.0/packages/mips_24kc/routing
src/gz openwrt_telephony http://openwrt.proxy.ustclug.org/releases/18.06.0/packages/mips_24kc/telephony
```
这里面使用了两个源，分别是：http://openwrt.proxy.ustclug.org和https://downloads.lede-project.urown.net。  
接着在OpenWRT命令使用`opkg update`命令，只要网络没有问题，可以完成源目录包的更新，当然在https的那个源会报错，先不用管。  
> 通常的情况下，每次进行包安装工作之前进行一次`opkg update`就够了，这是下载软件源中的所有目录索引到本地。路由器关机、或者云端的源内容发生了变化才需要重新执行。  

随后安装https协议所需的软件包：  
```bash 
opkg install libustream-openssl  ca-bundle ca-certificates 
```
接着再做一次`opkg update`，这一次，应当所有的源都可以拿到目录包了。  
如果你有更好的http源，配置https访问这一步可以省略。  

至此，opkg包管理工具算配置完成。喜欢使用GUI界面的话，这时候可以使用下面命令安装：  
```bash
opkg update
opkg install luci
```  

#### 安装U盘并设置自动加载
如果只是当做私有云盘使用，U盘的格式可以随意。但如果打算用作git仓库以及用以弥补路由器可怜的FLASH存储，则必须使用Linux专有格式，比如EXT4。所以准备用在路由器上的U盘你要提前做好备份，因为后面的安装会重新格式化U盘。  
首先是安装加载U盘所需的各项驱动和相关支持工具：  
```bash
#假设你已经做过opkg udpate
opkg install block-mount e2fsprogs kmod-fs-ext4 kmod-usb3 kmod-usb2 kmod-usb-storage 
```
随后使用ext4格式，重新初始化U盘：  
```bash
#注意这一步会清掉U盘上现有的所有内容
mkfs.ext4 /dev/sda1
```
接着将U盘设置为路由器启动后自动加载：  
```bash
block detect > /etc/config/fstab 
uci set fstab.@mount[0].enabled='1' && uci set fstab.@global[0].check_fs='1' && uci commit 
/sbin/block mount && service fstab enable
```
这时候可以使用mount命令检查一下U盘是否加载成功（不需要重启），如果输出信息中，通常是在最后一行，如果有类似下面信息表示U盘加载成功了：
```bash
/dev/sda1 on /mnt/sda1 type ext4 (rw,relatime,data=ordered)
```
在我实验的时候，有一个U盘无论如何无法自动加载成功，猜测同U盘型号或者具体硬件及OpenWRT版本的支持有关系。就不去深究原因了，碰到这种情况可以使用启动脚本的方式解决，首先执行一次`mkdir /mnt/sda1`，然后在/etc/rc.local文件最后一行增加：  
```bash
mount /dev/sda1 /mnt/sda1
```
以后重启将会自动加载U盘。  

#### 安装git工具包
这一步对于新款路由器实在不是事儿，使用opkg一条命令就搞定：  
```bash
opkg install git
```
对于我这款老路由器来讲是个大麻烦，因为这款WND3700这款路由器只有4M的FLASH,相当于硬盘的存储空间。而git软件包压缩之后是4.3M,完全盛不下。  
这时候刚才安装的EXT4格式的U盘就起作用了，我使用手工安装的方式把git安装到U盘上，这样多大的软件包都不算问题了。  
首先下载git软件包:
```bash
cd /mnt/sda1/
wget http://openwrt.proxy.ustclug.org/releases/18.06.0/packages/mips_24kc/packages/git_2.16.3-1_mips_24kc.ipk
```
注意下载路径是跟你所使用的路由器版本有关的，比如上面的下载地址表示OpernWRT18.06.0版本，跑在mips_24kc的芯片上。根据这些信息，你要寻找自己路由器可用的软件包，平常这件事情是由opkg帮你做的。  
下载完成后，手工解压取出文件：  
```bash
tar xzvf git_2.16.3-1_mips_24kc.ipk
#上面的解压完成通常会出来3个文件，我们只使用其中的data.tar.gz文件。
mkdir ipks
cd ipks
tar xzvf ../data.tar.gz
cd ..
# 删除3个解压出的临时文件
rm control.tar.gz data.tar.gz  debian-binary
```
所有的文件都保存在/mnt/sda1/ipks/usr路径下，我们还需要手工完成安装，才能够运行：  
```bash 
ln -s /mnt/sda1/ipks/usr/bin/git /usr/bin/
ln -s /mnt/sda1/ipks/usr/bin/git-receive-pack /usr/bin/
ln -s /mnt/sda1/ipks/usr/bin/git-upload-archive /usr/bin/
ln -s /mnt/sda1/ipks/usr/bin/git-shell /usr/bin/
ln -s /mnt/sda1/ipks/usr/bin/git-upload-pack /usr/bin/
ln -s /mnt/sda1/ipks/usr/lib/git-core/ /usr/lib/
ln -s /mnt/sda1/ipks/usr/share/git-core/ /usr/share/
```
此时git已经可以使用了。接下来我们建立工作目录：  
```bash
mkdir /mnt/sda1/prjs
ln -s /mnt/sda1/prjs/ /
```
/prjs目录是我们的主要存储目录。因为路由器只有一个root账号，也就不用考虑额外的权限问题。  
今后所有的git仓库，都可以在/prjs路径下另外建目录来保存。我们来建立一个测试仓库来验证工作是否正常：  
```bash
mkdir /prjs/test
cd /prjs/test
git init --bare
```
好了，至此路由器上的所有准备都已经完成。今后增加新的git仓库，使用新的仓库名称，重复上面最后一个建立test仓库的操作就可以。  

#### 测试路由器上的git仓库
回到我们的工作电脑上，随意建立一个工作目录，测试路由器上的git仓库是否工作正常，下面假设我们路由器的IP地址为192.168.1.1，请修改成自己路由器的正确地址。  
```bash
mkdir testgit
cd testgit
git init .
echo "test information" > abc.txt
echo "测试信息" > abc1.txt
git add .
git commit -m "something new"
git remote add origin root@192.168.1.1:/prjs/test/
git push --set-upstream origin master
```
最后的git push执行后，需要输入路由器root账号密码，随后如果显示类似下面信息，就表示成功了：  
```bash
Counting objects: 2, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 231 bytes | 231.00 KiB/s, done.
Total 2 (delta 0), reused 0 (delta 0)
To root@192.168.1.1:/prjs/test/
   570db28..5ab2627  master -> master
```

#### 自动验证
如果不希望每次git push都输入路由器密码，可以把自己电脑的公钥存储到路由器备案，以后就不需要输入密码了，首先拷贝公钥到路由器：  
```bash
scp ~/.ssh/id_rsa.pub root@192.168.1.1:~/
```
接着在路由器上执行：  
```bash
cat id_rsa.pub >> /etc/dropbear/authorized_keys
```
可以使用ssh来测试是否生效，ssh root@192.168.1.1之后，如果不再要求输入密码直接登录了路由器，表示自动验证生效了。  

   