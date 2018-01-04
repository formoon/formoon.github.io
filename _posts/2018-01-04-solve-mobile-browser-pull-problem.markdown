---
layout:         page
title:          解决本博客在手机浏览器拖动卡顿问题
subtitle:       鼠标Hover带来的副作用
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1515070059275&di=23a7f9343b79e3c1b892cd216c2f877b&imgtype=0&src=http%3A%2F%2Fimg3.3lian.com%2F2013%2Fs1%2F30%2Fd%2F62.jpg
date:           2018-01-04
tags:           html
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1515070059275&di=23a7f9343b79e3c1b892cd216c2f877b&imgtype=0&src=http%3A%2F%2Fimg3.3lian.com%2F2013%2Fs1%2F30%2Fd%2F62.jpg)（图文无关）

本博使用了从网上分享的模板，一直还是很满意的。为了增加功能，中间经过了几次小的修补，这不，这就又来了一次。  
起因是在微信上给朋友分享了一篇博文，自己看的时候，博文挺好，模板页面一看就专门考虑了小尺寸屏幕的适配，基本是尽力保持了看上去优雅的设计。  
但是到了首页就碰到了麻烦，因为屏幕尺寸，所以每一行只能显示一个博文块，向上拖动滚屏的时候，总是卡，也就是手指在页面上拖动操作，页面并没有产生相应的滚动。  
随后进行了较多的实验，找到规律，就是如果拖动博文块边缘页面的部分，是没有问题的。每个博文块第一次点击上的时候，都不能被拖动，第二次则就可以了。随之而来，再移动到另外一个博文块的时候，现象重复出现。  
查看页面的源码，很容易就感觉是博文块鼠标"hover"时候的特效有问题。因为在手机浏览器上，不会有鼠标悬停的操作。在网上搜索，中英文页面都没有搜索到类似现象，大多是用touchdown之类的触摸屏操作来模拟鼠标的方式，并不适合本博的情况。无果的情况下，决定实验试一试。  
在scripts.html页面中增加了几行代码：
```javascript
var u = navigator.userAgent;
if (u.indexOf('Android') > -1 || u.indexOf('iPhone') > -1 || u.indexOf('iPad') > -1){
	$("a").addClass("hover");
}
```
脚本的意思是检查当前浏览器，如果是手机浏览器，则强制给所有html a标签链接增加'hover'属性。  
起jekyll服务器测试，居然解决了，看来症结就是在此。  
留文记录一下。  


