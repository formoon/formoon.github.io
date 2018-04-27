---
layout:         page
title:          swift异步调用和对象间互动
subtitle:       在WKWebView组件使用evaluateJavaScript时蹚的小坑
card-image:		http://n.sinaimg.cn/news/transform/w1000h500/20180301/RqX2-fwnpcns6091105.jpg
date:           2018-03-02
tags:           mac
post-card-type: image
---
![](http://n.sinaimg.cn/news/transform/w1000h500/20180301/RqX2-fwnpcns6091105.jpg)  
修改原来一个程序的时候，需要从定义于另外一个类中的后台进程调用回AppDelegate类中的一个方法，然后方法中调用evaluateJavaScript来通知JS子程序做页面的变化处理。  
功能很简单，但实现后到调用evaluateJavaScript的时候总会出现崩溃，而这个功能以前肯定是正常的。  
首先想到在后台进程中偷懒使用了`AppDelegate().methodName()`这种方式，虽然通常的静态方法都没关系，但牵涉到需要初始化webView等工作的非静态方法，这种方式肯定是不可用的，老老实实的修改回调用共享实例的方式：  
```swift
let appDelegate = NSApplication.shared.delegate as? AppDelegate
appDelegate?.methodName()
```
接着发现还是不稳定，从经验上感觉通常都是由于线程的不可重入或者冲突造成的，再给两边加上异步的队列调用方式：  
```swift
//从AppDelegate调用到后台类
let background = DispatchQueue.global()
background.async {
    someClass.someMethod(...)
}

//从后台类回调到AppDelegate
let main = DispatchQueue.main
main.async {
    let appDelegate = NSApplication.shared.delegate as? AppDelegate
    appDelegate?.methodName()
}
```
修改后编译测试，一切正常了。  

