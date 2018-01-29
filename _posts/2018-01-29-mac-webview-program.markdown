---
layout:         page
title:          macOS webview编程
subtitle:       老树依然有新发
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1517214955029&di=db8c16635139ada629988c5bd1351150&imgtype=0&src=http%3A%2F%2Fi2.sinaimg.cn%2FIT%2Fmobile%2Fn%2Fapple%2F2015-01-16%2FU10175P2T1D9966574F13DT20150116090315.jpg
date:           2018-01-29
tags:           mac
post-card-type: image
---
好像是macOS10.10之后，以及iOS8之后，新出现的WKWebview组件就迅速的替代了Webview及UIWebView。后者的确存在一些无法解决的bug,诸如架构导致的速度缓慢和内存泄漏。  
但无法避免的问题总是有的，比如有些客户端软件，仍然要求兼容老版本的系统，这时候，很不想使用，但也不得不仍然把Webview塞到自己的代码中。  
互联网是个喜新厌旧的圈子，网上搜索，几乎只有两类。一是WKWebview的文档，二是iOS类的文档。想要的macOS下面Webview的资料缈如黄鹤。  
经过部分只言片语的资料指导和大量的实验，终于完成了工作。所以决定来烧烧冷灶，写出来记录一下。  

#### 1.添加Webview
最简单添加webview的方法就是直接在Interface Builder中把Webview拖入到窗口并且用鼠标拖动到指定位置和指定大小，随后在程序中加上对应的变量：  
```swift
    @IBOutlet weak var webView: WebView!
```
如果必须动态程序实现，可以使用`window.contentView?.addSubview(webView)`把webview控件插入到界面中。  

#### 2.载入网页
1. 可以直接导向到某个网页，也可以先在本地启动一个静态页面文件，后续一些工作可以在本地静态网页中用js处理。这种方法是比较多用的,因为程序启动速度会感觉快的很多。  
```swift
        let path = Bundle.main.path(forResource: "somepage", ofType: "html")
        let url = NSURL.fileURL(withPath: path!)
        let request = URLRequest(url: url);
        self.webView.mainFrame.load(request);
```
2. 把somepage.html添加到项目，并在项目设置中Build Phases->Copy Bundle Resources中添加上文件somepage.html，这样最后生成app文件的时候，somepage.html文件才会被打包到其中。  
3. 如果建立的项目使用沙箱(sandbox)模式，现在的应用，如果想上App Store，一般是强制要求使用沙箱的，需要在系统设置的Capabilities中允许incoming network/output networking。否则本地网页没问题，之后的任何网站都无法访问。  
4. 新版本的macOS及iOS都强制必须使用https网页访问，如果需要支持老的http网页，还需要在Info.plist中增加一行：App Transport Security Settings，类型为字典项，其中增加一项：Allow Arbitrary Loads，值为YES。
完成以上4项，网页已经可以访问了。  

#### 3.从swift调用js
假定在网页中有如下内容：  
```js
<script>
function callFromSwift(msg){
    document.getElementById('msgbox').innerHTML=msg;
    return("msg return from js");
}
</script>
<div id='msgbox'></div>
```
其中定义了一个函数callFromSwift,当被调用的时候，在下面预定义的div中显示传入的字符串，并且返回一个字符串“msg return from js”。  
在swift中调用网页中的callFromSwift函数并获取其返回值可以这样做：  
```swift
        let s=webView.windowScriptObject.evaluateWebScript("callFromSwift('Hello, JavaScript')")
        NSLog(s as! String)	//s是js函数的返回结果，可以是多种类型，本例要求是string
```
#### 4.从js调用swift
前面的3部分都比较容易，跟WKWebview也大同小异。从JS到swift的调用要复杂的多了。  
首先在初始化的时候，要加上一句：  
```swift
        webView!.frameLoadDelegate=self;
```
对应的，要在类声明的位置加上一个继承：`WebFrameLoadDelegate`，随后加入代码：  
```swift
	//为js对象声明一个接口
    func webView(_ webView: WebView!, didClearWindowObject windowObject: WebScriptObject!, for frame: WebFrame!) {
        self.webView.windowScriptObject.setValue(self, forKey: "swiftHost")
    }
	//这个是基本框架，声明了本类中有两个函数会开放给js对象，并供其调用
	//这里示例了两个，一个是callFromJS1,另一个是quit
	//注意swift中的函数名跟js中的函数名可以不一样，
	//#selector中指明的是swift中声明的函数名，因为selector是object-c中的机制，
	//所以后面在声明真正函数的时候，前面必须加@objc的标志
	//在后面return "xxx"的部分，返回的字符串js中会使用的名字，
	//本例中，swift中函数名跟js中函数名使用了相同的名字，我认为这是好习惯
    override class func webScriptName(for aSelector: Selector) -> String?
    {
        //NSLog("%@",aSelector.description)
        if aSelector == #selector(callFromJS1)
        {
            return "callFromJS1"
        }
        else
        if aSelector == #selector(quit)
        {
            return "quit"
        }
        else
        {
            return nil
        }
    }
	//这个函数顾名思义，应当是不允许在js中调用的，对所有的来值都返回false表示全部允许调用
    override class func isSelectorExcluded(fromWebScript aSelector: Selector) -> Bool
    {
        //NSLog("%@",aSelector.description)
        return false
    }
	//具体的函数
    @objc
    func callFromJS1(message:String)
    {
        NSLog(message)
    }
    @objc
    func quit()
    {
        NSLog("call for quit")
        NSApp.terminate(self);
    }

```
前三个函数是基本的框架，其中第二个麻烦一些，随后实际上工作的函数没有什么特别。  
接着来看看js的部分：  
```js
    <a href='javascript:testCallSwift();'>testCallSwift</a><p>
    <a href='javascript:needQuit();'>Quit</a><p>
	<script>
		function testCallSwift(){
			//注意调用方式，window是js的对象
			//swiftHost是swift的接口
			//其后则是声明的swift函数
		    window.swiftHost.callFromJS1("hello swift");
		}
		function needQuit(){
		    window.swiftHost.quit();
		}
	</script>

```
#### 5.截获webview每一次访问
跟上面类似，要再增加一个代理：
```swift
//初始化的时候增加：
        webView!.policyDelegate=self;
```
并且声明类的时候多一个继承:`WebPolicyDelegate`。随后代码中可以实现一个接口：  
```swift
    func webView(_ webView: WebView!,
                 decidePolicyForNavigationAction actionInformation: [AnyHashable : Any]!,
                 request: URLRequest!,
                 frame: WebFrame!,
                 decisionListener listener: WebPolicyDecisionListener!) {
        NSLog("nav to %@",request.url!.absoluteString)  //这里是将要转向的网址
        listener.use()	//允许访问这个网址
        //listener.ignore()   //不允许访问这个网址则调用这个
    }
```
也有些程序中为了简化从js调用swift的工作量，会用链接的方式，在链接地址中传入一些指令，就可以用这个函数截获网址并且处理，被处理的网址通常使用listener.ignore()来禁止本次浏览器转向，免得影响当前页面。  
#### 6.响应js中的警告窗
通常的webview都是不允许js中的alert警告窗的，一方面是为了应用程序整体的效果；另一方面，webview作为一个空间，自己没有UI的控制权，所以类似的工作，是要有应用程序自己实现警告框窗口的。实现警告窗依然要给类增加一个集成`WebUIDelegate`,并在初始化中增加：  
```swift
        webView!.uiDelegate=self;

//随后可以实现一个接口：
    func webView(_ sender: WebView!,
                 runJavaScriptAlertPanelWithMessage message: String!,
                 initiatedBy frame: WebFrame!){
        NSLog("msg of alert: %@",message)
    }
```
如果不满足于只是得到警告消息，要自己在这个函数中使用cocoa的警告窗来显示相关的信息。  

#### 7.其它
还可以实现从js中访问swift中的变量功能。使用`isKeyExcludedFromWebScript`和`webScriptNameForKey`函数，我用得少，如果需要，参考上面定义函数的方法，查一查官方文档自己来试试吧。  



#### 参考资料：
[Swift & JavaScript integration](http://blog.sibo.me/2016/07/11/swift-and-javascript-integration.html)  

