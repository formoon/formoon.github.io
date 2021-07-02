---
layout:         page
title:          在越狱的iPhone上安装自开发环境
subtitle:       iOS版的xcode
card-image:		https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201808/jailbreak.jpg
date:           2018-08-16
tags:           linux
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201808/jailbreak.jpg)
自开发跟自编译意思一样，后者表示一个开发语言的开发能力成熟度；前者则表示一个开发平台的开发能力成熟度。  
iPhone跟iPad面世这么多年，一直无法摆脱“娱乐”工具的宿命。Apple曾经希望通过iPad Pro为平台增添“生产力工具”的特征，但看起来成效不大。  
而竞争对手的Surface Pro，虽然娱乐性不足，但没有人否认Surface Pro是一个优良的生产力工具。  
在实用上，iPad跟Surface在于对文化创意类“生产力”的支持都不错。但是在其它方面，特别是软件开发之类的支持，iOS差的实在太多。  
如果你有一台尚可越狱的iOS设备，那么通过社区的支持，这种情况可以有所缓解。虽然依然离“生产力”的要求差的比较远，但一些必要的基础性工作已经有很高的可用度了。  

#### 越狱
第一步首先要将设备越狱，自从苹果加速关闭老版本软件的升级认证以来，想找到一台可以越狱的iOS设备已经越来越难了。目前看一些老型号的32位cpu产品因为已经被限制升级到高版本的iOS，反而成为了一个越狱的机会。比如手头有一款老的iPad3代，最高只能安装iOS9.3.5，很容易找到对应的越狱程序。  
iOS的越狱，不同的软件版本有不同的开发团队，这些黑客团队极具个人特色的风格，使得难以出现一款软件把这些工具集成到一起，完成自动化的越狱。所以不同版本的设备，都要在网上搜索不同的可行越狱方案，然后完成越狱过程。  
以9.3.5为例，大致越狱过程如下：  
1. 在开发者官网<https://phoenixpwn.com/>下载越狱工具，越狱工具是IPA文件，安装完成后是一个app，从而有机会执行，完成越狱。  
2. 因为iOS设备只能运行从AppStore下载的软件。所以想安装这个IPA，目前只有一个办法，就是使用合法的开发者账号对这个IPA重新签名，让iOS设备可以执行这个App。这个过程可以由[Cydia Impactor](http://www.cydiaimpactor.com/)工具自动完成，请下载时根据你的电脑，下载对应操作系统的版本。  
3. 因为签名时还需要生成新的AppID，所以开发者账号还需要有admin权限，这对很多人都是一个不大不小的障碍。如果这一点无法解决的话，还可以考虑使用一些第三方工具，比如zJailbrewk、Xabsi，这些工具是收费的。原理是使用了企业签名预先签名好了自己的安装程序和Phoenixpwn越狱程序，从而无需每个越狱者都具备自己具有开发者账号。安装这些第三方工具可以用要越狱的iOS设备浏览网页<https://pangu8.com/93.html>，从其中选择对应的软件，企业版的签名允许直接在浏览器中安装对应的应用。  
4. 不管是个人签名还是企业签名，都需要在iOS设备的设置->通用->设备管理中，选择信任相应的签名，Phoenix app才可以执行起来，不然一启动就直接被iOS杀死了。  
5. Phonenix第一次运行起来，点击按钮：Prepare For Jailbreak。通常系统会重启，以后再次执行，同样的位置，按钮的名称会变为：Kickstart Jailbreak。在越狱的过程中，会询问越狱使用的破解位置偏移，直接选用providers offset 选项即可（上面的选项）。这个越狱是非完美越狱，也就是每次设备重启后，都需要重新执行Phonenix App，然后使用“Kickstart Jailbreak”再次激活越狱。
6. 越狱成功率比较低，经常重启后仍然在未越狱状态，这时候就需要重新执行上面的过程，通常可能需要重复2、3次。另外一个就是如果使用个人开发者签名的话，那签名都是有时间限制的，如果过期，要使用Cydia Impactor重新安装Phonenix。  

#### 安装openssh-server
越狱只是拿到了系统根目录读写的权限，想要通过越狱把iOS设备当做一台电脑来使用，还需要安装各项应用软件，最重要的就是openssh-server，这样才可以通过ssh连接，得到iOS设备的命令行。  
在越狱完成后，设备桌面上会有Cydia的程序图标。Cydia相当于一个apt的图形界面控制台，apt是从debian和ubuntu的Linux引入的软件包管理器，可以安装、更新、卸载各种系统所需的软件包。因为各项软件包都是在安装过程中从互联网直接下载的，所以运行Cydia之前，要保证设备联网正常。  
第一次执行Cydia会比较慢，启动完成后，点击下方最右侧的放大镜图标，在搜索列表中输入openssh。单击搜索结果，然后选择屏幕右上角的“安装”按钮。如果网速没有问题的话，一般几分钟就能完成安装。  
同样的搜索框，再次输入apt，在搜索的结果中选取APT 0.7 Strict软件包，同样点击“安装”，这个是命令行版本的apt应用。有了命令行，很多软件的安装使用命令行的apt安装会更快捷方便。  
APT安装完成后退出Cydia应用，在WIFI设置中查看一下当前的IP地址，保证你的电脑跟iOS设备在同一个网段。如果是Linux/macOS设备，可以直接使用ssh连接iOS设备。如果是Windows设备，推荐安装putty或者xshell之类的ssh终端。  
剩下就可以跟连接一台电脑一样访问iOS设备了，比如：  
```bash
ssh root@192.168.1.101  
```
iOS设备的root默认密码是`alpine`，请尽快使用ssh登录并使用passwd命令修改掉默认密码，不然会很容易被别人控制。  

#### 安装常用工具和开发工具
iOS是一个精简的bsd unix系统，很多常用的命令行工具比如ifconfig/ping都被删去了，我们可以使用apt工具来安装：  
```bash
#更新软件源
apt-get update
#安装常用的命令行工具
apt-get install coreutils coreutils-bin vim inetutils network-cmds adv-cmds wget
#安装iFile文件管理器（App）
apt-get install eu.heinelt.ifile
#安装开发常用工具
apt-get install git make tcpdump 
```
随后，如果你是64位cpu,可以直接安装集成的工具包：  
```bash
apt-get install org.coolstar.iostoolchain
```
如果是你32位的cpu,但iOS版本在9.0（不含9.0）以下，也可以直接使用上面的语句安装完整开发工具包。但如果是32位cpu,软件版本又在9.0以上，则需要换用另外一套编译工具：  
```bash
apt-get install org.coolstar.llvm-clang32 org.coolstar.ld64 ldid
```
上面的org.coolstar.ld64实际是32位/64位cpu通用的。  

#### 解决系统分区过小的问题
iOS越狱后稍微操作经常就会在iOS设备屏幕上出现“存储空间已满”的警告信息，你如果到设置中查看，设备又远远没有占满。  
其实这个信息指的是系统空间已经被占满的意思。也就是unix系统的/根目录。通常这个目录都是iOS的固件部分，空间是确定的。但因为越狱后，又额外的安装了很多程序，所以这个空间就不足了。  
比较简单的处理方法是把类似语言包之类，在启动过程中不需要的库移到用户分区去，从而保证根目录的空间容量：  
```bash
mv /System/Library/LinguisticData /var/mobile
ln -s /var/mobile/LinguisticData/ /System/Library/
```

#### 安装iOS SDK
虽然现在iOS已经升级到了iOS12.x,但因为社区工具链的限制，经过多次试验，感觉还是iOS 8.1的SDK最好用。我从老版本的Xcode中导出了一套，放在这里：<https://pan.baidu.com/s/1fsDs8Al1DnPUwLBGCEO_3Q>，下载密码：y23e。下载完成后，可以使用scp把sdk拷贝到iOS设备上，比如：  
```bash
scp ios.tar.bz2 root@192.168.1.101:~/
```
随后在iOS的ssh命令行执行：  
```bash
mkdir -p /var/stash/Developer/SDKs/  
cd /var/stash/Developer/SDKs/  
tar xjvf ~/ios.tar.bz2
```
此时iOS已经具备了最基本的开发能力了，我们写一个最简单的hello world来测试一下。  
首先使用vim编辑一个程序文件，比如test.c:
```bash
cd ~
vim test.c
```
内容为:  
```c
#include<stdio.h>

int main(int argc, char **argv){
	printf("hello ios!\n");
}
```
编译程序：  
```bash 
clang -o test test.c -I /var/stash/Developer/SDKs/iPhoneOS8.1.sdk/usr/include/ -L /var/stash/Developer/SDKs/iPhoneOS8.1.sdk/usr/lib/ -L /var/stash/Developer/SDKs/iPhoneOS8.1.sdk/usr/lib/system/ 
```
因为SDK所在路径的原因，编译命令比较长，正式使用的时候可以写入到编译脚本或者Makefile。  
这时候直接运行输出的结果会报错：  
```bash
./test
Killed: 9
```
这同样是因为签名机制的原因，需要为我们编译的程序签名后再执行，就一切正常了：  
```bash
ldid -S test
./test
hello ios!
```
#### 安装iOS的ssh终端
现在已经可以在iOS设备上进行开发了，但事情还没有完。我们刚才所有的操作，都是在电脑的键盘、屏幕的配合下完成的所有操作，这远远算不上"自开发"。  
可以使用的方法之一是在iOS中安装ssh终端程序，从而在iOS设备上直接操作自己的命令行。终端程序推荐一个免费又好用的Termius，请自行在AppStore搜索下载。  
但在设置的时候你会发现，Termius根本无法连接上自己。原因是自iOS8之后，系统已经禁止App直接连接设备的1024号以下的端口了。
我们可以设置openssh的sshd服务增加一个监听端口，操作方法如下：  
1. 新建一个自启动服务文件：  
```bash
vim /Library/LaunchDaemons/com.openssh.sshd2.plist
```
内容为：  
	```xml
	<?xml version="1.0" encoding="UTF-8"?>
	<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
	<plist version="1.0">

	<dict>
	    <key>Label</key>
	    <string>com.openssh.sshd2</string>

	    <key>Program</key>
	    <string>/usr/libexec/sshd-keygen-wrapper</string>

	    <key>ProgramArguments</key>
	    <array>
	        <string>/usr/sbin/sshd</string>
	        <string>-i</string>
	    </array>

	    <key>SessionCreate</key>
	    <true/>

	    <key>Sockets</key>
	    <dict>
	        <key>Listeners</key>
	        <dict>
	            <key>SockServiceName</key>
	            <string>ssh2</string>
	        </dict>
	    </dict>

	    <key>StandardErrorPath</key>
	    <string>/dev/null</string>

	    <key>inetdCompatibility</key>
	    <dict>
	        <key>Wait</key>
	        <false/>
	    </dict>
	</dict>
	</plist>
	```
2. 编辑/etc/services文件，在文件最后增加以下两行：  
```bash
ssh2              10022/udp     # SSH Remote Login Protocol
ssh2              10022/tcp     # SSH Remote Login Protocol
```
重启后，再次激活越狱，可以在Termius中设置ssh连接到本机的10022端口了。  

#### 使用iOS的IDE
命令行工具对很多新手来讲使用起来难度还是不低的，我们还有另外一个选择。ios开发社区工程师lufinkey推出了一个集成的开发工具miniCode，能让程序员像操作电脑一样在ios开发简单的试验工程。miniCode的项目页面在：<https://github.com/lufinkey/miniCode>  
如果你使用apt-get直接安装了iostoolchain，那简单了，直接一行代码就能安装上miniCode:  
```bash
apt-get install com.brokenphysics.minicode
```
但如果在刚才的安装中，你不得不手工选择安装了32位的编译器，那这次还是要手工安装minicode，因为手工安装的32位编译器无法满足minicode的依赖包要求：
```bash
wget http://apt.thebigboss.org/repofiles/cydia/debs2.0/minicode_1.03.5.deb
dpkg -i --force-all minicode_1.03.5.deb
```
类似上面安装的iFile，minicode也是一个越狱环境运行的GUI程序，我们在命令行安装的GUI程序通常需要重启才能在iOS桌面看到，为了加快速度，我们可以只重启iOS的外壳SpringBoard:  
```bash
su -c uicache mobile
killall SpringBoard
```
![](https://i0.wp.com/ioshacker.com/wp-content/uploads/2014/06/miniCode-cydia.jpg?w=620&ssl=1)
![](https://i0.wp.com/ioshacker.com/wp-content/uploads/2014/06/miniCode-cydia.jpg?w=620&ssl=1)
![](https://i0.wp.com/ioshacker.com/wp-content/uploads/2014/06/minicode-tweak.jpg?w=320&ssl=1)


#### 参考资料
[miniCode brings Xcode to your iPhone and iPad](https://ioshacker.com/cydia/minicode-brings-xcode-iphone-ipad)  



