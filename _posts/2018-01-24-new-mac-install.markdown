---
layout:         page
title:          新麦装机两三事
subtitle:       特别是研发人员的MAC装机注意问题
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516767979953&di=b3bad354b2f4bb314d17684135fc434a&imgtype=0&src=http%3A%2F%2Fimage.kejixun.com%2F2017%2F0405%2F20170405094250332.jpg
date:           2018-01-24
tags:           toSeven
post-card-type: image
---
虽然是mac老司机，但每次装机总会碰到一些小问题需要临时上网搜索一下解决方案，所以留下些文字备忘一下：  
1. 研发用的新机最好选择语言用英文版，中文版通常的使用没问题，但很多的地方的翻译都不准确，而且有一些测试不充分的BUG。比如我曾经碰到过配置IP地址，多个IP地址之间应当是用英文分号分割，结果也变成了中文分号，新版本虽然修改了这个BUG，但类似小问题经常还是会有。  
2. Xcode优先安装，后面其它许多的开源软件都依赖Xcode的命令行。  
3. 正常情况下，Sierra和High Sierra已经不建议在Recovery状态关闭系统保护功能，原来依赖关闭系统文件权限，注入一些功能的软件，大多升级版本也已经不再需要写入系统文件区。所以我也建议不要再关闭系统文件保护功能，这样系统的安全性会好很多，即便出现可能的病毒，也不会导致系统基础崩溃。 
如果一定要关闭，重启时按⌘R键进入恢复模式，启动后打开终端程序，在其中使用如下命令关闭系统文件保护：  
```bash
csrutil disable
``` 
4. 因为3的原因，系统内置的python/ruby等，不要再跟以前一样升级，如果需要，另外安装一个新版本即可。  
5. 安装Homebrew,其它开源软件包，尽量统一使用Homebrew管理：  
```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
6. 通常即便不需要升级python,也还是要重新安装一个，因为python的一些扩展包你也可能碰到需要升级，这也是需要自己安装一份有读写权限的python。别心疼那几十M的空间。  
```bash
brew install python
```
另外注意，新版的brew,安装的python默认是python2.7，程序执行的时候命名为python2。总结一下就是：  
```bash
python		#系统内置的python2.7
pip			#系统没有自带，如果你自己安装了pip那对应的是系统的python
python2		#用brew自己安装的python2.7
pip2		#安装python的时候回自动安装pip
python3		#如果你另外安装了python3
pip3		#对应python3
```
7. 所以如果你想继续安装tensorflow，应当是使用你另外安装的pip2或者pip3来安装，系统内置的python因为扩展包版本不兼容又无法改写，实际无法安装tensorflow。  
```bash
pip2 install tensorflow
```
使用上面命令行安装的tensorflow，只有python2环境中才能引用，python3如果要使用，需要用pip3自行安装。  
8. python有些包的提示不是很完整，比如错误信息是scipy.misc包中找不到imread，实际上是因为包pillow包没有安装，应当使用`pip2 install pillow`安装。  
9. ruby / gem比python幸运，因为gem可以指定安装包安装的路径，这样即便系统的版本不满意，也不一定非要重新整个安装了。比如：  
```bash
sudo gem install jekyll bundler -n /usr/local/bin
#后面的-n参数就是指定安装路径
```
相对的更换源到国内网站你肯定忘不掉，因为下载包下不动你就想起来了：  
```bash
#前面要先删除原来的源，这里省略
gem sources --add https://gems.ruby-china.org/
```
10. 调试程序经常会碰到没有签名的应用需要运行，所以人为打开权限控制对于研发人员也是不得已了，虽然这样有了病毒传播的风险，但毕竟工作重要：  
```bash
sudo spctl --master-disable
```
11. 研发的一些特殊情况可能需要修改EFI分区，加载方式如下：  
```bash
#首先检查EFI分区设备名
diskutil list
#比如结果是：
/dev/disk0
 #: TYPE                     NAME          SIZE       IDENTIFIER
 0: GUID_partition_scheme                  *251.0 GB  disk0
 1: EFI                                    209.7 MB   disk0s1
 2: Apple_HFS                Macintosh HD  250.1 GB   disk0s2
 3: Apple_Boot               Recovery HD   650.0 MB   disk0s3
#建立一个加载点
mkdir /Volumes/efi
#挂载，注意设备名跟上面对应
sudo mount -t msdos /dev/disk0s1 /Volumes/efi
#后面就可以做自己的事情了
```
11. 有一些小工具想加到Finder工具栏中，是按住⌘键不松手，然后用鼠标拖动到Finder工具栏。  
12. Messager短信应用删除信息太麻烦，option+⌘+backspace可以无提示框直接删。  
13. 开机启动脚本，有以下几个路径可以放置开机启动脚本的引导配置文件，
```bash
#以.plist配置文件的方式
/Library/LaunchAgents/
/Library/LaunchDaemons/
/System/Library/LaunchAgents/
/System/Library/LaunchDaemons/
#以文件夹的方式，文件夹内放置配置文件.plist及相关脚本
/Library/StartupItems/
/System/Library/StartupItems/
```
LaunchDaemons是在系统引导时执行(boot)，LaunchAgents是在用户登录的时候执行（login)。  
/System/Library下的是macOS系统进程使用。/Library是所有用户使用。  
对应的，~/Library中的，上面没有列，一般用的少，是对应某一个用户的。  
通常用户自己设置的，需要开机就执行的一些进程一般是放在/Library/LaunchDaemons/之下，有2点需要注意：  
	 * 拥有者权限必须是root:wheel
	 * 权限644    
	 

先这些吧，想到再补充。  

#### 参考资料：
[了解LaunchDaemons](https://afoo.me/posts/2014-12-12-understanding-launch-daemons-of-macosx.html)  	 
























