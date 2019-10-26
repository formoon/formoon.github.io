---
layout:         page
title:          python scrapy 入门
subtitle:       10分钟完成一个爬虫
card-image:		https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572063415721&di=8c7cb64e18cc76d928b2bf8a58af82e6&imgtype=0&src=http%3A%2F%2Fwww.shwzzz.cn%2Fd%2Ffile%2F2018-10-26%2Fdcd81dbe6d0e6ec45b9ca53dcc627d02.jpg
date:           2018-04-16
tags:           python
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1572063415721&di=8c7cb64e18cc76d928b2bf8a58af82e6&imgtype=0&src=http%3A%2F%2Fwww.shwzzz.cn%2Fd%2Ffile%2F2018-10-26%2Fdcd81dbe6d0e6ec45b9ca53dcc627d02.jpg)
在TensorFlow热起来之前，很多人学习python的原因是因为想写爬虫。的确，有着丰富第三方库的python很适合干这种工作。  
Scrapy是一个易学易用的爬虫框架，尽管因为互联网多变的复杂性仍然有很多爬虫需要自己编写大量的代码，但能够有一个相对全面均衡的基础框架，工作还是会少许多。  

#### 框架安装
不好意思用别人网站作为被爬取的例子，下面从头开始，以本站为例，开始一个简单的爬虫之旅。  
因为习惯原因，本文均以python2作为工作环境。  
scrapy框架的安装非常简单，只要一行命令，前提是你已经有了pip包管理器：
```bash
pip install scrapy
```

#### 建立一个爬虫工程
因为一个爬虫工程中可以包含多个爬虫模块，所以通常对于大多数人来讲，有一个爬虫工程就够用了。  
建立工程同样只需要一行命令：  
```bash
#scrapy startproject <工程名称>，例如：
scrapy startproject formoon
```
上面命令执行后，将在当前目录中建立一个formoon文件夹，并使用基本模板在其中建立一个爬虫工程。  
仅执行scrapy不带任何参数可以给出scrapy的帮助，使用`scrapy 子命令 --help`可以看到更多的帮助信息。  

#### 在工程中加入一个爬虫
首先进入工程目录：  
```bash
cd formoon
```
随后可以建立工程中第一个爬虫：  
```bash
#scrapy genspider <爬虫名称> <爬虫所应用的域名称>，例如：
scrapy genspider pages formoon.github.io
```
上面命令会在路径：`<工作目录>/formoon(这个是工程目录)/formoon/spiders/`路径之下，建立一个python程序文件pages.py，其默认的内容：  
```python
# -*- coding: utf-8 -*-
import scrapy

class PagesSpider(scrapy.Spider):
    name = 'pages'
    allowed_domains = ['formoon.github.io']
    start_urls = ['http://formoon.github.io/']
    
    def parse(self, response):
        pass
```

#### 编写爬虫
假设我们的需求是这样，爬虫爬取整个https://formoon.github.io网站，获取其中所有的文章，列出文章标题，文章链接地址，和文章的发布日期。  
依照惯例，下面直接贴出完成的代码，并在其中以注释的形式详细解释：  
```python
# -*- coding: utf-8 -*-
import scrapy

class PagesSpider(scrapy.Spider):
    name = 'pages'	#爬虫的名称，不可更改
    allowed_domains = ['formoon.github.io']	#域名称
    start_urls = ['https://formoon.github.io/']	#从这个网址开始执行爬虫，注意默认是http，修改成https
	#scrapy爬虫中不会主动修改页面中的链接，所以自己增加一个类变量用于将相对地址完整成为绝对地址。
    baseurl='https://formoon.github.io'
    
    def parse(self, response):
		#scrapy爬虫主要的难点是xpath和css选择器的使用，请在网上搜索相关资源弄清楚
		#爬虫使用相关选择器在整个html中定位自己所需要的节点及获取其中的数据
        for course in response.xpath('//ul/li'):
			#获取文章链接
            href = self.baseurl+course.xpath('a/@href').extract()[0]
			#获取文章标题
            title = course.css('.card-title').xpath('text()').extract()[0]
			#获取文章发布日期
            date = course.css('.card-type.is-notShownIfHover').xpath('text()').extract()[0]
			#显示结果
            print title,href,date
        for btn in response.css('.container--call-to-action').xpath('a'):
            href = btn.xpath('@href').extract()[0]
            name = btn.xpath('button/text()').extract()[0]
			#如果屏幕上有下一页按钮，则递归访问下一页的页面
            if name == u"下一页":  #注意python2中对于中文要显式的增加'u'前缀表示是unicode字符
                yield scrapy.Request(self.baseurl+href,callback=self.parse)
```

#### 执行爬虫
执行爬虫使用如下命令：  
```bash
scrapy crawl pages
```
获得的结果如下：  
```bash
2018-04-16 16:26:14 [scrapy.utils.log] INFO: Scrapy 1.5.0 started (bot: formoon)
2018-04-16 16:26:14 [scrapy.utils.log] INFO: Versions: lxml 4.1.1.0, libxml2 2.9.7, cssselect 1.0.3, parsel 1.4.0, w3lib 1.19.0, Twisted 17.9.0, Python 2.7.14 (default, Mar  9 2018, 23:57:12) - [GCC 4.2.1 Compatible Apple LLVM 9.0.0 (clang-900.0.39.2)], pyOpenSSL 17.5.0 (OpenSSL 1.1.0h  27 Mar 2018), cryptography 2.2.2, Platform Darwin-17.5.0-x86_64-i386-64bit
2018-04-16 16:26:14 [scrapy.crawler] INFO: Overridden settings: {'NEWSPIDER_MODULE': 'formoon.spiders', 'SPIDER_MODULES': ['formoon.spiders'], 'ROBOTSTXT_OBEY': True, 'BOT_NAME': 'formoon'}
2018-04-16 16:26:14 [scrapy.middleware] INFO: Enabled extensions:
['scrapy.extensions.memusage.MemoryUsage',
 'scrapy.extensions.logstats.LogStats',
 'scrapy.extensions.telnet.TelnetConsole',
 'scrapy.extensions.corestats.CoreStats']
2018-04-16 16:26:15 [scrapy.middleware] INFO: Enabled downloader middlewares:
['scrapy.downloadermiddlewares.robotstxt.RobotsTxtMiddleware',
 'scrapy.downloadermiddlewares.httpauth.HttpAuthMiddleware',
 'scrapy.downloadermiddlewares.downloadtimeout.DownloadTimeoutMiddleware',
 'scrapy.downloadermiddlewares.defaultheaders.DefaultHeadersMiddleware',
 'scrapy.downloadermiddlewares.useragent.UserAgentMiddleware',
 'scrapy.downloadermiddlewares.retry.RetryMiddleware',
 'scrapy.downloadermiddlewares.redirect.MetaRefreshMiddleware',
 'scrapy.downloadermiddlewares.httpcompression.HttpCompressionMiddleware',
 'scrapy.downloadermiddlewares.redirect.RedirectMiddleware',
 'scrapy.downloadermiddlewares.cookies.CookiesMiddleware',
 'scrapy.downloadermiddlewares.httpproxy.HttpProxyMiddleware',
 'scrapy.downloadermiddlewares.stats.DownloaderStats']
2018-04-16 16:26:15 [scrapy.middleware] INFO: Enabled spider middlewares:
['scrapy.spidermiddlewares.httperror.HttpErrorMiddleware',
 'scrapy.spidermiddlewares.offsite.OffsiteMiddleware',
 'scrapy.spidermiddlewares.referer.RefererMiddleware',
 'scrapy.spidermiddlewares.urllength.UrlLengthMiddleware',
 'scrapy.spidermiddlewares.depth.DepthMiddleware']
2018-04-16 16:26:15 [scrapy.middleware] INFO: Enabled item pipelines:
[]
2018-04-16 16:26:15 [scrapy.core.engine] INFO: Spider opened
2018-04-16 16:26:15 [scrapy.extensions.logstats] INFO: Crawled 0 pages (at 0 pages/min), scraped 0 items (at 0 items/min)
2018-04-16 16:26:15 [scrapy.extensions.telnet] DEBUG: Telnet console listening on 127.0.0.1:6023
2018-04-16 16:26:16 [scrapy.core.engine] DEBUG: Crawled (404) <GET https://formoon.github.io/robots.txt> (referer: None)
2018-04-16 16:26:16 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://formoon.github.io/> (referer: None)
大恒工业相机多实例使用 https://formoon.github.io/2018/04/04/daheng-camera/ 2018-04-04
图像识别基本算法之SURF https://formoon.github.io/2018/03/30/surf-feature/ 2018-03-30
macOS的OpenCL高性能计算 https://formoon.github.io/2018/03/23/mac-opencl/ 2018-03-23
量子计算及量子计算的模拟 https://formoon.github.io/2018/03/20/dlib-quantum-computing/ 2018-03-20
iPhone多次输入错误密码锁机后恢复 https://formoon.github.io/2018/03/18/IOS-Password-Recovery/ 2018-03-18
Mac版AppStore无法下载、升级错误处理 https://formoon.github.io/2018/03/18/appstore-item-temporarily-unavailabel/ 2018-03-18
在Mac上使用vs-code快速上手c语言学习 https://formoon.github.io/2018/03/10/vscode-on-mac/ 2018-03-10
在Mac上使用远程X11应用 https://formoon.github.io/2018/03/09/remote-xwindows/ 2018-03-09
Docker for mac上使用Kubernetes https://formoon.github.io/2018/03/07/docker-for-mac/ 2018-03-07
那些令人惊艳的TensorFlow扩展包和社区贡献模型 https://formoon.github.io/2018/03/03/TensorFlow-models/ 2018-03-03
swift异步调用和对象间互动 https://formoon.github.io/2018/03/02/macos-thread-and-appdelegate/ 2018-03-02
将dylib库嵌入macOS应用的方法 https://formoon.github.io/2018/02/27/macos-app-embed-dylib/ 2018-02-27
macOS使用内置驱动加载可读写NTFS分区 https://formoon.github.io/2018/02/19/macos-mount-ntfs-as-read-write/ 2018-02-19
mac应用启动时卡死在“验证...” https://formoon.github.io/2018/02/16/macos-stuck-verifying-app/ 2018-02-16
CrossOver和wine https://formoon.github.io/2018/02/16/crossover-wine-copy/ 2018-02-16
2018-04-16 16:26:17 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://formoon.github.io/pages/2/> (referer: https://formoon.github.io/)
Mark https://formoon.github.io/2018/02/09/hello-world/ 2018-02-09
GreenPlum无法远程访问解决 https://formoon.github.io/2018/02/08/greenplum-on-centos/ 2018-02-08
rinetd:轻量级Linux端口转发工具 https://formoon.github.io/2018/02/06/linux-port-forward-tools/ 2018-02-06
Ubuntu16包依赖故障解决 https://formoon.github.io/2018/02/05/ubuntu-apt-error-of-package-depend/ 2018-02-05
iNode环境Windows 10配置固定IP地址 https://formoon.github.io/2018/02/02/win10-inode-2-ipaddress/ 2018-02-02
Ubuntu 16.04.03 LTS 安装CUDA/CUDNN/TensorFlow+GPU流水账 https://formoon.github.io/2018/01/31/ubuntu-cuda-cudnn-tensorflow-setting/ 2018-01-31
resource fork, Finder information, or similar detritus not allowed https://formoon.github.io/2018/01/29/xcode-compile-error-1/ 2018-01-29
macOS webview编程 https://formoon.github.io/2018/01/29/mac-webview-program/ 2018-01-29
新麦装机问题汇 https://formoon.github.io/2018/01/24/new-mac-install/ 2018-01-24
比特币核心算法ECDSA电子签名在线演示 https://formoon.github.io/2018/01/22/bitcoin-and-ecdsa/ 2018-01-22
从锅炉工到AI专家(11)(END) https://formoon.github.io/2018/01/18/tensorFlow-series-11/ 2018-01-18
gem update 升级错误解决 https://formoon.github.io/2018/01/18/gem-update-error-solve/ 2018-01-18
比特币核心概念及算法 https://formoon.github.io/2018/01/18/bitcoin-and-blockchain/ 2018-01-18
从锅炉工到AI专家(10) https://formoon.github.io/2018/01/17/tensorFlow-series-10/ 2018-01-17
Python2中文处理纪要 https://formoon.github.io/2018/01/17/python2-chn-process/ 2018-01-17
2018-04-16 16:26:17 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://formoon.github.io/pages/3/> (referer: https://formoon.github.io/pages/2/)
从锅炉工到AI专家(9) https://formoon.github.io/2018/01/16/tensorFlow-series-9/ 2018-01-16
从锅炉工到AI专家(8) https://formoon.github.io/2018/01/15/tensorFlow-series-8/ 2018-01-15
从锅炉工到AI专家(7) https://formoon.github.io/2018/01/12/tensorFlow-series-7/ 2018-01-12
从锅炉工到AI专家(6) https://formoon.github.io/2018/01/11/tensorFlow-series-6/ 2018-01-11
从锅炉工到AI专家(5) https://formoon.github.io/2018/01/11/tensorFlow-series-5/ 2018-01-11
从锅炉工到AI专家(4) https://formoon.github.io/2018/01/10/tensorFlow-series-4/ 2018-01-10
Octave Fontconfig报错解决 https://formoon.github.io/2018/01/10/octave-fontconfig-warning/ 2018-01-10
5分钟搭建一个quic服务器 https://formoon.github.io/2018/01/10/5mins-support-quic/ 2018-01-10
从锅炉工到AI专家(3) https://formoon.github.io/2018/01/09/tensorFlow-series-3/ 2018-01-09
从锅炉工到AI专家(2) https://formoon.github.io/2018/01/08/tensorFlow-series-2/ 2018-01-08
从锅炉工到AI专家(1) https://formoon.github.io/2018/01/08/tensorFlow-series-1/ 2018-01-08
解决本博客在手机浏览器拖动卡顿问题 https://formoon.github.io/2018/01/04/solve-mobile-browser-pull-problem/ 2018-01-04
OpenCV中的照片剪裁 https://formoon.github.io/2018/01/04/opencv-photo-crop/ 2018-01-04
OpenCV中的亮度对比度调整及其自动均衡 https://formoon.github.io/2018/01/04/opencv-brightness-and-contrast/ 2018-01-04
Mac电脑C语言开发的入门帖 https://formoon.github.io/2018/01/03/c-hello-world-for-mac/ 2018-01-03
2018-04-16 16:26:18 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://formoon.github.io/pages/4/> (referer: https://formoon.github.io/pages/3/)
如何看到微信小程序的源码 https://formoon.github.io/2018/01/02/wechat-mini-app-rd/ 2018-01-02
使用人工辅助点达成更优白平衡 https://formoon.github.io/2018/01/02/opencv-whitebalance-with-point-confirm/ 2018-01-02
不使用插件建立jekyll网站sitemap https://formoon.github.io/2017/12/29/sitemap_of_jekyll/ 2017-12-29
safari11如何访问自签名https网站 https://formoon.github.io/2017/12/29/safari-self-signed-https/ 2017-12-29
赶个时髦，给自己的博客添加一个微信二维码 https://formoon.github.io/2017/12/29/add-wechat-qrcode-on-your-blog/ 2017-12-29
被Docker/VMWare宠坏的孩子们，还记得QEMU吗？ https://formoon.github.io/2017/12/28/qemu-on-mac/ 2017-12-28
在网页显示数学公式 https://formoon.github.io/2017/12/28/mathjax-in-page/ 2017-12-28
使用SDL2显示一张图片 https://formoon.github.io/2017/12/28/hello-world-sdl2/ 2017-12-28
如何规范的把进程放到Linux后台运行 https://formoon.github.io/2017/12/27/selinux-run-app-in-background/ 2017-12-27
两种方法操作其它mac应用的窗口 https://formoon.github.io/2017/12/27/move-other-app-window-on-mac/ 2017-12-27
自己动手，装一个液晶电视 https://formoon.github.io/2017/12/25/lcd-tv-diy/ 2017-12-25
半小时完成一个湿度温度计 https://formoon.github.io/2017/12/25/arduino-hygrothermograph/ 2017-12-25
MacPro4,1升级到MacPro5,1 https://formoon.github.io/2017/12/22/macpro41-upgrade/ 2017-12-22
CameraBox个人讲台客户端使用说明 https://formoon.github.io/2017/12/22/camerabox-manual/ 2017-12-22
一段使用Educast抠像混屏直播的视频展示 https://formoon.github.io/2017/12/21/streaming-mix/ 2017-12-21
2018-04-16 16:26:18 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://formoon.github.io/pages/5/> (referer: https://formoon.github.io/pages/4/)
七牛对象存储的使用 https://formoon.github.io/2017/12/21/qiniu-storage/ 2017-12-21
Educast视频直播控制台使用说明 https://formoon.github.io/2017/12/21/educast-manual/ 2017-12-21
批量自动重命名音乐文件 https://formoon.github.io/2017/12/20/mp3-m4a-rename/ 2017-12-20
把Markdown文本发布到微信公众号文章 https://formoon.github.io/2017/12/20/markdown-to-html-and-wechat/ 2017-12-20
Javascript已加入AppleScript全家桶 https://formoon.github.io/2017/12/19/jxa-appscript/ 2017-12-19
分享一个很通用的Makefile https://formoon.github.io/2017/12/19/Makefile-skill/ 2017-12-19
在Mac电脑编译c51程序 https://formoon.github.io/2017/12/18/c51-on-mac/ 2017-12-18
golang子进程的启动和停止 https://formoon.github.io/2017/12/16/ubuntu-golang-stop-child-process/ 2017-12-16
Ubuntu16.04LTS appstreamcli报错的处理 https://formoon.github.io/2017/12/15/ubuntu-appstreamcli-error/ 2017-12-15
AngularJS2+调用原有的js脚本 https://formoon.github.io/2017/12/14/angular4-ts-and-local-js/ 2017-12-14
在国内使用golang的小技巧 https://formoon.github.io/2017/12/14/use-golang-in-china/ 2017-12-14
Angular2+的两个小技巧 https://formoon.github.io/2017/12/14/angular4-hotkeys-and-detect-browser/ 2017-12-14
Unix程序员的Win10二三事 https://formoon.github.io/2017/12/14/Unix%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84win10%E4%BA%8C%E4%B8%89%E4%BA%8B/ 2017-12-14
在Ubuntu上搭建kindle gtk开发环境 https://formoon.github.io/2017/12/13/hello-world-for-kindle/ 2017-12-13
苹果手机上下载的文件在哪里？ https://formoon.github.io/2017/12/13/download-on-ios/ 2017-12-13
2018-04-16 16:26:18 [scrapy.core.engine] DEBUG: Crawled (200) <GET https://formoon.github.io/pages/6/> (referer: https://formoon.github.io/pages/5/)
K60平台智能车开发工作随手记 https://formoon.github.io/2017/12/11/smart-car-k60-develope/ 2017-12-11
使用Jekyll和github搭建自己的个人博客 https://formoon.github.io/2017/12/11/setting-your-own-jekyll-blog/ 2017-12-11
使用ffmpeg做简单的音视频剪辑 https://formoon.github.io/2017/12/11/ffmpeg-auido-video-edit/ 2017-12-11
安装Homebrew https://formoon.github.io/2017/12/08/install-homebrew-on-mac/ 2017-12-08
在Mac上安装ffmpeg https://formoon.github.io/2017/12/08/install-ffmpeg-on-mac/ 2017-12-08
Hello World https://formoon.github.io/2017/12/08/hello-world/ 2017-12-08
2018-04-16 16:26:19 [scrapy.core.engine] INFO: Closing spider (finished)
2018-04-16 16:26:19 [scrapy.statscollectors] INFO: Dumping Scrapy stats:
{'downloader/request_bytes': 1779,
 'downloader/request_count': 7,
 'downloader/request_method_count/GET': 7,
 'downloader/response_bytes': 57926,
 'downloader/response_count': 7,
 'downloader/response_status_count/200': 6,
 'downloader/response_status_count/404': 1,
 'finish_reason': 'finished',
 'finish_time': datetime.datetime(2018, 4, 16, 8, 26, 19, 71963),
 'log_count/DEBUG': 8,
 'log_count/INFO': 7,
 'memusage/max': 50831360,
 'memusage/startup': 50827264,
 'request_depth_max': 5,
 'response_received_count': 7,
 'scheduler/dequeued': 6,
 'scheduler/dequeued/memory': 6,
 'scheduler/enqueued': 6,
 'scheduler/enqueued/memory': 6,
 'start_time': datetime.datetime(2018, 4, 16, 8, 26, 15, 15007)}
2018-04-16 16:26:19 [scrapy.core.engine] INFO: Spider closed (finished)
```
从结果中可以看到，我们的爬虫已经执行了，并获取了正确的结果。如果不想看到执行过程中的日志输出，可以增加`--nolog`参数，如下所示：  
```bash
> scrapy crawl pages --nolog
大恒工业相机多实例使用 https://formoon.github.io/2018/04/04/daheng-camera/ 2018-04-04
图像识别基本算法之SURF https://formoon.github.io/2018/03/30/surf-feature/ 2018-03-30
macOS的OpenCL高性能计算 https://formoon.github.io/2018/03/23/mac-opencl/ 2018-03-23
量子计算及量子计算的模拟 https://formoon.github.io/2018/03/20/dlib-quantum-computing/ 2018-03-20
iPhone多次输入错误密码锁机后恢复 https://formoon.github.io/2018/03/18/IOS-Password-Recovery/ 2018-03-18
Mac版AppStore无法下载、升级错误处理 https://formoon.github.io/2018/03/18/appstore-item-temporarily-unavailabel/ 2018-03-18
在Mac上使用vs-code快速上手c语言学习 https://formoon.github.io/2018/03/10/vscode-on-mac/ 2018-03-10
在Mac上使用远程X11应用 https://formoon.github.io/2018/03/09/remote-xwindows/ 2018-03-09
Docker for mac上使用Kubernetes https://formoon.github.io/2018/03/07/docker-for-mac/ 2018-03-07
那些令人惊艳的TensorFlow扩展包和社区贡献模型 https://formoon.github.io/2018/03/03/TensorFlow-models/ 2018-03-03
swift异步调用和对象间互动 https://formoon.github.io/2018/03/02/macos-thread-and-appdelegate/ 2018-03-02
将dylib库嵌入macOS应用的方法 https://formoon.github.io/2018/02/27/macos-app-embed-dylib/ 2018-02-27
macOS使用内置驱动加载可读写NTFS分区 https://formoon.github.io/2018/02/19/macos-mount-ntfs-as-read-write/ 2018-02-19
mac应用启动时卡死在“验证...” https://formoon.github.io/2018/02/16/macos-stuck-verifying-app/ 2018-02-16
CrossOver和wine https://formoon.github.io/2018/02/16/crossover-wine-copy/ 2018-02-16
Mark https://formoon.github.io/2018/02/09/hello-world/ 2018-02-09
GreenPlum无法远程访问解决 https://formoon.github.io/2018/02/08/greenplum-on-centos/ 2018-02-08
rinetd:轻量级Linux端口转发工具 https://formoon.github.io/2018/02/06/linux-port-forward-tools/ 2018-02-06
Ubuntu16包依赖故障解决 https://formoon.github.io/2018/02/05/ubuntu-apt-error-of-package-depend/ 2018-02-05
iNode环境Windows 10配置固定IP地址 https://formoon.github.io/2018/02/02/win10-inode-2-ipaddress/ 2018-02-02
Ubuntu 16.04.03 LTS 安装CUDA/CUDNN/TensorFlow+GPU流水账 https://formoon.github.io/2018/01/31/ubuntu-cuda-cudnn-tensorflow-setting/ 2018-01-31
resource fork, Finder information, or similar detritus not allowed https://formoon.github.io/2018/01/29/xcode-compile-error-1/ 2018-01-29
macOS webview编程 https://formoon.github.io/2018/01/29/mac-webview-program/ 2018-01-29
新麦装机问题汇 https://formoon.github.io/2018/01/24/new-mac-install/ 2018-01-24
比特币核心算法ECDSA电子签名在线演示 https://formoon.github.io/2018/01/22/bitcoin-and-ecdsa/ 2018-01-22
从锅炉工到AI专家(11)(END) https://formoon.github.io/2018/01/18/tensorFlow-series-11/ 2018-01-18
gem update 升级错误解决 https://formoon.github.io/2018/01/18/gem-update-error-solve/ 2018-01-18
比特币核心概念及算法 https://formoon.github.io/2018/01/18/bitcoin-and-blockchain/ 2018-01-18
从锅炉工到AI专家(10) https://formoon.github.io/2018/01/17/tensorFlow-series-10/ 2018-01-17
Python2中文处理纪要 https://formoon.github.io/2018/01/17/python2-chn-process/ 2018-01-17
从锅炉工到AI专家(9) https://formoon.github.io/2018/01/16/tensorFlow-series-9/ 2018-01-16
从锅炉工到AI专家(8) https://formoon.github.io/2018/01/15/tensorFlow-series-8/ 2018-01-15
从锅炉工到AI专家(7) https://formoon.github.io/2018/01/12/tensorFlow-series-7/ 2018-01-12
从锅炉工到AI专家(6) https://formoon.github.io/2018/01/11/tensorFlow-series-6/ 2018-01-11
从锅炉工到AI专家(5) https://formoon.github.io/2018/01/11/tensorFlow-series-5/ 2018-01-11
从锅炉工到AI专家(4) https://formoon.github.io/2018/01/10/tensorFlow-series-4/ 2018-01-10
Octave Fontconfig报错解决 https://formoon.github.io/2018/01/10/octave-fontconfig-warning/ 2018-01-10
5分钟搭建一个quic服务器 https://formoon.github.io/2018/01/10/5mins-support-quic/ 2018-01-10
从锅炉工到AI专家(3) https://formoon.github.io/2018/01/09/tensorFlow-series-3/ 2018-01-09
从锅炉工到AI专家(2) https://formoon.github.io/2018/01/08/tensorFlow-series-2/ 2018-01-08
从锅炉工到AI专家(1) https://formoon.github.io/2018/01/08/tensorFlow-series-1/ 2018-01-08
解决本博客在手机浏览器拖动卡顿问题 https://formoon.github.io/2018/01/04/solve-mobile-browser-pull-problem/ 2018-01-04
OpenCV中的照片剪裁 https://formoon.github.io/2018/01/04/opencv-photo-crop/ 2018-01-04
OpenCV中的亮度对比度调整及其自动均衡 https://formoon.github.io/2018/01/04/opencv-brightness-and-contrast/ 2018-01-04
Mac电脑C语言开发的入门帖 https://formoon.github.io/2018/01/03/c-hello-world-for-mac/ 2018-01-03
如何看到微信小程序的源码 https://formoon.github.io/2018/01/02/wechat-mini-app-rd/ 2018-01-02
使用人工辅助点达成更优白平衡 https://formoon.github.io/2018/01/02/opencv-whitebalance-with-point-confirm/ 2018-01-02
不使用插件建立jekyll网站sitemap https://formoon.github.io/2017/12/29/sitemap_of_jekyll/ 2017-12-29
safari11如何访问自签名https网站 https://formoon.github.io/2017/12/29/safari-self-signed-https/ 2017-12-29
赶个时髦，给自己的博客添加一个微信二维码 https://formoon.github.io/2017/12/29/add-wechat-qrcode-on-your-blog/ 2017-12-29
被Docker/VMWare宠坏的孩子们，还记得QEMU吗？ https://formoon.github.io/2017/12/28/qemu-on-mac/ 2017-12-28
在网页显示数学公式 https://formoon.github.io/2017/12/28/mathjax-in-page/ 2017-12-28
使用SDL2显示一张图片 https://formoon.github.io/2017/12/28/hello-world-sdl2/ 2017-12-28
如何规范的把进程放到Linux后台运行 https://formoon.github.io/2017/12/27/selinux-run-app-in-background/ 2017-12-27
两种方法操作其它mac应用的窗口 https://formoon.github.io/2017/12/27/move-other-app-window-on-mac/ 2017-12-27
自己动手，装一个液晶电视 https://formoon.github.io/2017/12/25/lcd-tv-diy/ 2017-12-25
半小时完成一个湿度温度计 https://formoon.github.io/2017/12/25/arduino-hygrothermograph/ 2017-12-25
MacPro4,1升级到MacPro5,1 https://formoon.github.io/2017/12/22/macpro41-upgrade/ 2017-12-22
CameraBox个人讲台客户端使用说明 https://formoon.github.io/2017/12/22/camerabox-manual/ 2017-12-22
一段使用Educast抠像混屏直播的视频展示 https://formoon.github.io/2017/12/21/streaming-mix/ 2017-12-21
七牛对象存储的使用 https://formoon.github.io/2017/12/21/qiniu-storage/ 2017-12-21
Educast视频直播控制台使用说明 https://formoon.github.io/2017/12/21/educast-manual/ 2017-12-21
批量自动重命名音乐文件 https://formoon.github.io/2017/12/20/mp3-m4a-rename/ 2017-12-20
把Markdown文本发布到微信公众号文章 https://formoon.github.io/2017/12/20/markdown-to-html-and-wechat/ 2017-12-20
Javascript已加入AppleScript全家桶 https://formoon.github.io/2017/12/19/jxa-appscript/ 2017-12-19
分享一个很通用的Makefile https://formoon.github.io/2017/12/19/Makefile-skill/ 2017-12-19
在Mac电脑编译c51程序 https://formoon.github.io/2017/12/18/c51-on-mac/ 2017-12-18
golang子进程的启动和停止 https://formoon.github.io/2017/12/16/ubuntu-golang-stop-child-process/ 2017-12-16
Ubuntu16.04LTS appstreamcli报错的处理 https://formoon.github.io/2017/12/15/ubuntu-appstreamcli-error/ 2017-12-15
AngularJS2+调用原有的js脚本 https://formoon.github.io/2017/12/14/angular4-ts-and-local-js/ 2017-12-14
在国内使用golang的小技巧 https://formoon.github.io/2017/12/14/use-golang-in-china/ 2017-12-14
Angular2+的两个小技巧 https://formoon.github.io/2017/12/14/angular4-hotkeys-and-detect-browser/ 2017-12-14
Unix程序员的Win10二三事 https://formoon.github.io/2017/12/14/Unix%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84win10%E4%BA%8C%E4%B8%89%E4%BA%8B/ 2017-12-14
在Ubuntu上搭建kindle gtk开发环境 https://formoon.github.io/2017/12/13/hello-world-for-kindle/ 2017-12-13
苹果手机上下载的文件在哪里？ https://formoon.github.io/2017/12/13/download-on-ios/ 2017-12-13
K60平台智能车开发工作随手记 https://formoon.github.io/2017/12/11/smart-car-k60-develope/ 2017-12-11
使用Jekyll和github搭建自己的个人博客 https://formoon.github.io/2017/12/11/setting-your-own-jekyll-blog/ 2017-12-11
使用ffmpeg做简单的音视频剪辑 https://formoon.github.io/2017/12/11/ffmpeg-auido-video-edit/ 2017-12-11
安装Homebrew https://formoon.github.io/2017/12/08/install-homebrew-on-mac/ 2017-12-08
在Mac上安装ffmpeg https://formoon.github.io/2017/12/08/install-ffmpeg-on-mac/ 2017-12-08
Hello World https://formoon.github.io/2017/12/08/hello-world/ 2017-12-08
```

#### 进阶爬虫，items和pipeline
对大多数用户来讲，到了上面一步，已经能够满足基本的需求。但仍然有两个机制可以让爬虫程序结构更清晰、运行更流畅、功能也更强大。  
Item是scrapy处理数据的基本单位，实际上在爬虫的parse的方法中，应当返回1个item对象，来表达一个基本数据单元。  
使用item，首先修改`<工程目录>/formoon/items.py`文件，定义我们自己的数据结构：  
```python
# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy

class FormoonItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
	#以上是模板中已经有的内容，下面是我们自己增加的3个字段
    title = scrapy.Field()
    link = scrapy.Field()
    date = scrapy.Field()    
```
使用item处理基本的数据单元有很多好处，其中比较重要的一个就是可以使用scrapy自带的pipeline流水线机制。这个流水线机制提供爬虫开始工作前、工作全部完成之后、每个数据单元的处理三种基本的处理情况，从而把程序的结构划分的非常清晰，更容易对接复杂的后期功能。  
编辑`<工程目录>/formoon/pipelines.py`文件：  
```python
# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html

class FormoonPipeline(object):
    total = 0	#我们自定义的变量，用于统计文章总数
	#open_spider方法在爬虫开始工作之前调用，通常可以初始化环境、打开数据库、打开文件等工作
    def open_spider(self, spider):
		#这里只显示一行文字作为示例
        print "open spider ..."
	#这个方法是最基本的方法，每次爬虫parse方法返回一个item的时候，都会调用这个函数，对基本的一个数据单元进行处理
    def process_item(self, item, spider):
        self.total += 1	#累计文章数
		#显示基本数据内容，通常可以在这个方法中对数据保存入库、触发分析动作等
        print("%s %s %s"%(item['date'],item['title'],item['link']))
        return item
	#所有链接处理完毕，结束爬虫工作时调用，通常可以用于关闭数据库、关闭文件等。
    def close_spider(self, spider):
		#作为示例，这里只是显示处理结果
        print u"共",self.total,u"篇文章"
        print "close spider ..."
```
有了上面两个基本定义，还要将item和pipeline连接起来，这个配置在settings.py文件中，通常是被屏蔽的，表示不使用item及pipeline机制，将注释符号删除就可以开启：  
```python
# Configure item pipelines
# See https://doc.scrapy.org/en/latest/topics/item-pipeline.html
ITEM_PIPELINES = {
    'formoon.pipelines.FormoonPipeline': 300,
}
```
最后是修改爬虫程序，将原来在爬虫中直接的数据显示，修改为规范的返回item数据单元，为了同原来的爬虫做比较，我们直接另外增加一个爬虫程序来应用新功能：  
```bash
scrapy genspider pagesnew formoon.github.io
```
就像前面说的，这会在`<工程目录>/formoon/spiders/`目录下建立pagesnew.py文件，容纳新的爬虫程序，我们编辑这个文件：  
```python
# -*- coding: utf-8 -*-
import scrapy
from formoon.items import FormoonItem 	#要引入我们自定义的item
class PagesnewSpider(scrapy.Spider):
    name = 'pagesnew'
    allowed_domains = ['formoon.github.io']
    start_urls = ['https://formoon.github.io/']

    baseurl='https://formoon.github.io'

    def parse(self, response):
        for course in response.xpath('//ul/li'):
            href = self.baseurl+course.xpath('a/@href').extract()[0]
            title = course.css('.card-title').xpath('text()').extract()[0]
            date = course.css('.card-type.is-notShownIfHover').xpath('text()').extract()[0]
			#区别从这里开始，我们删除了直接显示数据，初始化一个空白的item,将数据填充进去
            item = FormoonItem()
            item['date']=date
            item['link']=href
            item['title']=title
            yield item	#将数据返回
        for btn in response.css('.container--call-to-action').xpath('a'):
            href = btn.xpath('@href').extract()[0]
            name = btn.xpath('button/text()').extract()[0]
            if name == u"下一页":
                yield scrapy.Request(self.baseurl+href,callback=self.parse)
```
你看，在爬虫程序中使用这种机制，让爬虫程序的结构也简单、清晰了。  
试着执行一下：  
```bash
> scrapy crawl pagesnew --nolog
open spider ...
2018-04-04 大恒工业相机多实例使用 https://formoon.github.io/2018/04/04/daheng-camera/
2018-03-30 图像识别基本算法之SURF https://formoon.github.io/2018/03/30/surf-feature/
2018-03-23 macOS的OpenCL高性能计算 https://formoon.github.io/2018/03/23/mac-opencl/
2018-03-20 量子计算及量子计算的模拟 https://formoon.github.io/2018/03/20/dlib-quantum-computing/
2018-03-18 iPhone多次输入错误密码锁机后恢复 https://formoon.github.io/2018/03/18/IOS-Password-Recovery/
2018-03-18 Mac版AppStore无法下载、升级错误处理 https://formoon.github.io/2018/03/18/appstore-item-temporarily-unavailabel/
2018-03-10 在Mac上使用vs-code快速上手c语言学习 https://formoon.github.io/2018/03/10/vscode-on-mac/
2018-03-09 在Mac上使用远程X11应用 https://formoon.github.io/2018/03/09/remote-xwindows/
2018-03-07 Docker for mac上使用Kubernetes https://formoon.github.io/2018/03/07/docker-for-mac/
2018-03-03 那些令人惊艳的TensorFlow扩展包和社区贡献模型 https://formoon.github.io/2018/03/03/TensorFlow-models/
2018-03-02 swift异步调用和对象间互动 https://formoon.github.io/2018/03/02/macos-thread-and-appdelegate/
2018-02-27 将dylib库嵌入macOS应用的方法 https://formoon.github.io/2018/02/27/macos-app-embed-dylib/
2018-02-19 macOS使用内置驱动加载可读写NTFS分区 https://formoon.github.io/2018/02/19/macos-mount-ntfs-as-read-write/
2018-02-16 mac应用启动时卡死在“验证...” https://formoon.github.io/2018/02/16/macos-stuck-verifying-app/
2018-02-16 CrossOver和wine https://formoon.github.io/2018/02/16/crossover-wine-copy/
2018-02-09 Mark https://formoon.github.io/2018/02/09/hello-world/
2018-02-08 GreenPlum无法远程访问解决 https://formoon.github.io/2018/02/08/greenplum-on-centos/
2018-02-06 rinetd:轻量级Linux端口转发工具 https://formoon.github.io/2018/02/06/linux-port-forward-tools/
2018-02-05 Ubuntu16包依赖故障解决 https://formoon.github.io/2018/02/05/ubuntu-apt-error-of-package-depend/
2018-02-02 iNode环境Windows 10配置固定IP地址 https://formoon.github.io/2018/02/02/win10-inode-2-ipaddress/
2018-01-31 Ubuntu 16.04.03 LTS 安装CUDA/CUDNN/TensorFlow+GPU流水账 https://formoon.github.io/2018/01/31/ubuntu-cuda-cudnn-tensorflow-setting/
2018-01-29 resource fork, Finder information, or similar detritus not allowed https://formoon.github.io/2018/01/29/xcode-compile-error-1/
2018-01-29 macOS webview编程 https://formoon.github.io/2018/01/29/mac-webview-program/
2018-01-24 新麦装机问题汇 https://formoon.github.io/2018/01/24/new-mac-install/
2018-01-22 比特币核心算法ECDSA电子签名在线演示 https://formoon.github.io/2018/01/22/bitcoin-and-ecdsa/
2018-01-18 从锅炉工到AI专家(11)(END) https://formoon.github.io/2018/01/18/tensorFlow-series-11/
2018-01-18 gem update 升级错误解决 https://formoon.github.io/2018/01/18/gem-update-error-solve/
2018-01-18 比特币核心概念及算法 https://formoon.github.io/2018/01/18/bitcoin-and-blockchain/
2018-01-17 从锅炉工到AI专家(10) https://formoon.github.io/2018/01/17/tensorFlow-series-10/
2018-01-17 Python2中文处理纪要 https://formoon.github.io/2018/01/17/python2-chn-process/
2018-01-16 从锅炉工到AI专家(9) https://formoon.github.io/2018/01/16/tensorFlow-series-9/
2018-01-15 从锅炉工到AI专家(8) https://formoon.github.io/2018/01/15/tensorFlow-series-8/
2018-01-12 从锅炉工到AI专家(7) https://formoon.github.io/2018/01/12/tensorFlow-series-7/
2018-01-11 从锅炉工到AI专家(6) https://formoon.github.io/2018/01/11/tensorFlow-series-6/
2018-01-11 从锅炉工到AI专家(5) https://formoon.github.io/2018/01/11/tensorFlow-series-5/
2018-01-10 从锅炉工到AI专家(4) https://formoon.github.io/2018/01/10/tensorFlow-series-4/
2018-01-10 Octave Fontconfig报错解决 https://formoon.github.io/2018/01/10/octave-fontconfig-warning/
2018-01-10 5分钟搭建一个quic服务器 https://formoon.github.io/2018/01/10/5mins-support-quic/
2018-01-09 从锅炉工到AI专家(3) https://formoon.github.io/2018/01/09/tensorFlow-series-3/
2018-01-08 从锅炉工到AI专家(2) https://formoon.github.io/2018/01/08/tensorFlow-series-2/
2018-01-08 从锅炉工到AI专家(1) https://formoon.github.io/2018/01/08/tensorFlow-series-1/
2018-01-04 解决本博客在手机浏览器拖动卡顿问题 https://formoon.github.io/2018/01/04/solve-mobile-browser-pull-problem/
2018-01-04 OpenCV中的照片剪裁 https://formoon.github.io/2018/01/04/opencv-photo-crop/
2018-01-04 OpenCV中的亮度对比度调整及其自动均衡 https://formoon.github.io/2018/01/04/opencv-brightness-and-contrast/
2018-01-03 Mac电脑C语言开发的入门帖 https://formoon.github.io/2018/01/03/c-hello-world-for-mac/
2018-01-02 如何看到微信小程序的源码 https://formoon.github.io/2018/01/02/wechat-mini-app-rd/
2018-01-02 使用人工辅助点达成更优白平衡 https://formoon.github.io/2018/01/02/opencv-whitebalance-with-point-confirm/
2017-12-29 不使用插件建立jekyll网站sitemap https://formoon.github.io/2017/12/29/sitemap_of_jekyll/
2017-12-29 safari11如何访问自签名https网站 https://formoon.github.io/2017/12/29/safari-self-signed-https/
2017-12-29 赶个时髦，给自己的博客添加一个微信二维码 https://formoon.github.io/2017/12/29/add-wechat-qrcode-on-your-blog/
2017-12-28 被Docker/VMWare宠坏的孩子们，还记得QEMU吗？ https://formoon.github.io/2017/12/28/qemu-on-mac/
2017-12-28 在网页显示数学公式 https://formoon.github.io/2017/12/28/mathjax-in-page/
2017-12-28 使用SDL2显示一张图片 https://formoon.github.io/2017/12/28/hello-world-sdl2/
2017-12-27 如何规范的把进程放到Linux后台运行 https://formoon.github.io/2017/12/27/selinux-run-app-in-background/
2017-12-27 两种方法操作其它mac应用的窗口 https://formoon.github.io/2017/12/27/move-other-app-window-on-mac/
2017-12-25 自己动手，装一个液晶电视 https://formoon.github.io/2017/12/25/lcd-tv-diy/
2017-12-25 半小时完成一个湿度温度计 https://formoon.github.io/2017/12/25/arduino-hygrothermograph/
2017-12-22 MacPro4,1升级到MacPro5,1 https://formoon.github.io/2017/12/22/macpro41-upgrade/
2017-12-22 CameraBox个人讲台客户端使用说明 https://formoon.github.io/2017/12/22/camerabox-manual/
2017-12-21 一段使用Educast抠像混屏直播的视频展示 https://formoon.github.io/2017/12/21/streaming-mix/
2017-12-21 七牛对象存储的使用 https://formoon.github.io/2017/12/21/qiniu-storage/
2017-12-21 Educast视频直播控制台使用说明 https://formoon.github.io/2017/12/21/educast-manual/
2017-12-20 批量自动重命名音乐文件 https://formoon.github.io/2017/12/20/mp3-m4a-rename/
2017-12-20 把Markdown文本发布到微信公众号文章 https://formoon.github.io/2017/12/20/markdown-to-html-and-wechat/
2017-12-19 Javascript已加入AppleScript全家桶 https://formoon.github.io/2017/12/19/jxa-appscript/
2017-12-19 分享一个很通用的Makefile https://formoon.github.io/2017/12/19/Makefile-skill/
2017-12-18 在Mac电脑编译c51程序 https://formoon.github.io/2017/12/18/c51-on-mac/
2017-12-16 golang子进程的启动和停止 https://formoon.github.io/2017/12/16/ubuntu-golang-stop-child-process/
2017-12-15 Ubuntu16.04LTS appstreamcli报错的处理 https://formoon.github.io/2017/12/15/ubuntu-appstreamcli-error/
2017-12-14 AngularJS2+调用原有的js脚本 https://formoon.github.io/2017/12/14/angular4-ts-and-local-js/
2017-12-14 在国内使用golang的小技巧 https://formoon.github.io/2017/12/14/use-golang-in-china/
2017-12-14 Angular2+的两个小技巧 https://formoon.github.io/2017/12/14/angular4-hotkeys-and-detect-browser/
2017-12-14 Unix程序员的Win10二三事 https://formoon.github.io/2017/12/14/Unix%E7%A8%8B%E5%BA%8F%E5%91%98%E7%9A%84win10%E4%BA%8C%E4%B8%89%E4%BA%8B/
2017-12-13 在Ubuntu上搭建kindle gtk开发环境 https://formoon.github.io/2017/12/13/hello-world-for-kindle/
2017-12-13 苹果手机上下载的文件在哪里？ https://formoon.github.io/2017/12/13/download-on-ios/
2017-12-11 K60平台智能车开发工作随手记 https://formoon.github.io/2017/12/11/smart-car-k60-develope/
2017-12-11 使用Jekyll和github搭建自己的个人博客 https://formoon.github.io/2017/12/11/setting-your-own-jekyll-blog/
2017-12-11 使用ffmpeg做简单的音视频剪辑 https://formoon.github.io/2017/12/11/ffmpeg-auido-video-edit/
2017-12-08 安装Homebrew https://formoon.github.io/2017/12/08/install-homebrew-on-mac/
2017-12-08 在Mac上安装ffmpeg https://formoon.github.io/2017/12/08/install-ffmpeg-on-mac/
2017-12-08 Hello World https://formoon.github.io/2017/12/08/hello-world/
共 81 篇文章
close spider ...
```

#### 参考链接
[scrapy中文文档](http://scrapy-chs.readthedocs.io/zh_CN/latest/intro/overview.html)  
[xpath教程](http://www.w3school.com.cn/xpath/)  
[css选择器使用手册](http://www.w3school.com.cn/cssref/css_selectors.asp)  

