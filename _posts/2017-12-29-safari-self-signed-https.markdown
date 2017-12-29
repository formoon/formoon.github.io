---
layout:         page
title:          safari11如何访问自签名https网站
subtitle:       bug还是有意？
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1514525771073&di=709a8d434ebc0fcaa2ac52aec8d131d6&imgtype=0&src=http%3A%2F%2Fs4.51cto.com%2Fwyfs02%2FM00%2F8D%2FA3%2FwKioL1ikfYHgf1kiAAA3w56IVVg610.jpg-wh_651x-s_2465432911.jpg
date:           2017-12-29
tags:           mac
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1514525771073&di=709a8d434ebc0fcaa2ac52aec8d131d6&imgtype=0&src=http%3A%2F%2Fs4.51cto.com%2Fwyfs02%2FM00%2F8D%2FA3%2FwKioL1ikfYHgf1kiAAA3w56IVVg610.jpg-wh_651x-s_2465432911.jpg)

从Safari11开始，无法访问自签名的HTTPS网站了。原来访问这样的网站，会弹出来一个警告页面，大意是这个网站签名证书无法验证，有安全风险，然后用户可以选择继续访问这个不安全的站点，从而访问自签名的HTTPS网站。但是自从Safari升级到11之后，访问此类https网站只会报错说无法建立可靠连接,网页内容已经无法访问。  
尚不知道这是Safari的BUG还是苹果有意为之，从IOS的发展上看，强制要求访问从http升级到https似乎也是趋势。  

已经找到一个方法可以继续访问此类自签名网站：  
Safari浏览器中，设置->隐私->Manage Website Data->Remove ALL，注意必须是清理所有，单独清理某个特定网站经测试是无效的。  
做完这些后，访问自签名HTTPS网站，会跟以前一样，出现警告页面，然后忽略继续访问就可以出现要访问的HTTPS页面。  

还有一个小问题可能会碰到，在Safar设置->隐私页面->Manage Website Data页面中，中间的数据部分会一直显示“Loading website data...”,这个过程会非常慢，曾经等待超过10分钟。  
有一个办法可以加快这个速度：  
Safari->设置->Advanced,选中在菜单条中显示开发者菜单。这时候菜单中会多一项开发者菜单。随后点击开发者菜单，选中Empty Caches，之后会根据你的使用量，大概1分钟左右清空。随后再去设置菜单Remove All Website Data速度就很快了。  



