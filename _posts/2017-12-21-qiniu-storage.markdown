---
layout:         page
title:          七牛对象存储的使用
subtitle:       兼说在jekyll页面中添加照片引用
card-image:     http://blog.17study.com.cn/attachments/201712/7niu.jpg
date:           2017-12-21
tags:           mac jekyll
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201712/7niu.jpg)

Jekyll个人网页是个好技术，github.com是个好网站，不过存储容量和流量的限制是个头痛的事情，当然，也在情理之中。  
好在我们生于“云”的时代，有很多办法来扩展我们的世界。在引用图片方面，主要的要求就是服务商可以提供外链。由于在国内，我们的选择少了一些，不过还是有几个优选的：
* 百度图片，网址是https://timgsa.baidu.com，图片可以外链，缺点是路径太长，在Markdown源文件中看起来很丑也难操作。另外图片来源主要靠搜索，难以表达自己的精确要求。  
* 新浪图片，在微博中上传的图片就可以使用，外链的地址是：http://sinaimg.cn。当然对于微博用户来说，一堆跟微博本身毫无关关联的图片看起来有点让人费解，不过用起来还是很好用的。
* 七牛云，也是个良心商家，至少当前还是，只需要实名认证一下就有免费账号可以用。而且做为一个开发者的服务平台，提供了丰富的API来进行自动化的管理，支持图片、视频等一切可存储的对象。这也是我当前的主存站和今天的主题。

七牛的注册、认证这里就不说了，控制台的网址是<https://portal.qiniu.com/>。关键要说的是对于普通人员用起来感觉困难的地方：
* 如果你是程序员，当然最好的办法是根据api使用文档编写自己的接口，完成彻底的自动化工作。api文档地址是：<https://developer.qiniu.com/kodo>
* 如果你懒得自己写，七牛有一组用这些API开发的工具供你选择，这些工具包括Windows之下的同步上传工具，命令行的QShell,还有另外两款辅助工具和迁移工具。我们今天的重点说QShell,说明及下载地址是：<https://developer.qiniu.com/kodo/tools/1302/qshell>
* 首先在七牛网页控制台个人中心->秘钥管理中查询自己的AK和SK,这两个秘钥可好好记录下来。
* 在控制台添加对象存储功能，添加时要填写一个存储的名字还有选一个服务器地理位置。添加完成从控制台左侧选择对象存储图标，屏幕右上角的位置会出现一个为你临时生成的域名xxxxx.bkt.clouddn.com，将来你存储到七牛云的文件，可以使用这个域名访问。七牛云专门说了这个域名是临时测试使用的，有访问次数和流量的限制，不过据说对于个人博客来说一般都够用了。不够用的可以根据说明捆绑域名。
* 下载的qshell改一个短一点你喜欢的名字，我就直接叫`qshell`了，使用`chmod +x qshell`设置执行权限，然后移动到/usr/local/bin文件夹以便随时调用。
* 第一次使用首先执行`qshell account 你的ak 你的sk`，这回在`~/.qshell/`生成一个文件account.json文件，其中保存了你的账户信息，以后执行qshell各项功能，就不需要再次登陆了。
* 在电脑本地选择一个文件夹作为对应云端存储的本地空间，为了说明方便，我们假定是`~/fileStorage/`，在之下可以建立自己的目录结构并存储自己的各项文件，将来上传后，~/fileStorage/下面保存的文件，就对应到你七牛测试域名的根目录。随后在你的工程下面建立一个upload.conf文本文件，内容为：
```json
{
//使用时请删除这些注释行
//本地存储路径
"src_dir" : "~/fileStorage",
"bucket" : "你的存储名",
//下面几项不用解释了吧，懂的就懂了，不懂翻译成中文还是不明白
"check_hash"	:	true,
"check_exists"  :   true,
"check_size"    :   true,
"rescan_local"  :   true,
//上传时保持目录结构
"ignore_dir" : false
}
```
* 假设你有一个文件，`~/fileStorage/abc/def.jpg`,上传后，使用http://xxxxx.bkt.clouddn.com/abc/def.jpg就能访问到。在你的jekyll文章中，使用`![](http://xxxxx.bkt.clouddn.com/abc/def.jpg)`可以把这张图片插入到你的文章中。
* 上传的命令为：`qshell qupload upload.conf`，我一般把git的操作及qshell操作一起写入一个脚本，每次写完执行一次就同时完成了文章的上传和图片的上传。不怕献丑，贴出来我的脚本给你参考一下：

```bash
#!/bin/bash

git add . 
git commit -m "$1"
git push
qshell qupload qshellupload.conf
#此外，qshell还可以增加一个线程数参数，来并行上传加快速度，比如下面这条8线程上传：
#qshell qupload 8 qshellupload.conf

```


