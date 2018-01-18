---
layout:         page
title:          gem update 升级错误解决
subtitle:       SSL错误
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516280881231&di=885456ae6eea93514608bedd6ae1cd67&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170616%2F02b6c59574d24fd7aebffaca424e1bac_th.jpg
date:           2018-01-18
tags:           mac
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516280881231&di=885456ae6eea93514608bedd6ae1cd67&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170616%2F02b6c59574d24fd7aebffaca424e1bac_th.jpg)  

挺少用gem update，因为我基本不怎么用ruby，本博的维护使用jekyll，似乎就躲不开了。  
今天运行`sudo gem update --system`得到报错信息：  
```bash
ERROR:  SSL verification error at depth 1: unable to get local issuer certificate (20)
ERROR:  You must add /O=Digital Signature Trust Co./CN=DST Root CA X3 to your local trusted store
```
网上搜索有两种解决方案，一是把国外的源换成国内的源，此外TAOBAO的源已经不维护了，都应当更换成ruby-china.org；  
第二就是设置不检查SSL签名，也就是设置`~/.gemrc`增加参数`:ssl_verify_mode:0`：  
```bash
- https://gems.ruby-china.org/
:update_sources: true
:verbose: true
:ssl_verify_mode: 0
```
两种方法都试了，仍然报错。  

最后尝试升级ruby到2.3版本。  
```bash
brew install ruby@2.3
```
安装完成后，ruby新版和老版本都会共存的，所以让新版本生效需要修改环境文件中的路径设置，我是用fish shell，可以按照提示做如下操作：  
```bash
echo 'set -g fish_user_paths "/usr/local/opt/ruby@2.3/bin" $fish_user_paths' >> ~/.config/fish/config.fish
```
关掉终端，重启一个窗口，执行`ruby --version`检查，版本已经是2.3了。  
随后再次运行`sudo gem update --system`，错误消失。  

最后还有一个麻烦事，因为ruby的多版本并存，以前安装的各种ruby包，在2.3版本中实际并不存在，如果需要使用的话，需要重新安装。[哭脸]  
以jekyll为例，以前博文写过，但不完整，再补充一下：  
```bash
	#首先安装jekyll及包管理器
sudo gem install jekyll bundler
	#到博文目录
cd jekyll_blog
	#升级相关包
bundle update
```
接着运行`jekyll server`可以正常进入环境。  

