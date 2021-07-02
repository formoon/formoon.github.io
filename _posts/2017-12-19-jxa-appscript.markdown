---
layout:         page
title:          Javascript已加入AppleScript全家桶
subtitle:       jxa快速入门
card-image:     https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/automator.jpeg
date:           2017-12-19
tags:           mac
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/automator.jpeg)

因为工作环境基本是以跨平台为主，所以纯mac本地化的AppleScript一直关注是不够的，前几天找资料发现AppleScript也在迅速的进步着，目前已经对Javascript做了比较好的支持------当然早就支持，现在只是感觉上更好了。这项技术的全称是JavaScript for Automation，算一项比较新的技术，简称JXA。  
本博不是学术研究性的，因此完全从实用出发，力求给出自己的实用性见解而不是长篇大论引用官方文字。这里给出我总结的几个特点：  
* 脱离脚本编辑器Script Editor运行更顺畅，支持也更好，不再出现原来的一些莫名其妙问题。
* 支持Object C对象的嵌入，并以其为桥梁调用c的函数。
* 支持脚本库，除了自己写脚本库，还可以使用node.js的脚本。
* 运行的速度很快，对mac下的各个应用支持良好，定制起来很顺手。

先介绍几个资源：  
OSX ReleaseNotes:<https://developer.apple.com/library/content/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/Introduction.html>  
AppleScript的官方参考手册：<https://developer.apple.com/library/content/documentation/AppleScript/Conceptual/AppleScriptLangGuide/introduction/ASLR_intro.html#//apple_ref/doc/uid/TP40000983-CH208-SW1>  
写的很详细的一本入门手册：<https://github.com/JXA-Cookbook/JXA-Cookbook/wiki/Foreword>,本文很多样例代码来自于此。  

使用方法，我们这里抛弃mac内置的脚本编辑器，如同我们熟悉的其它类型js脚本一样来使用。首先介绍适合初学者练习用的命令行交互式运行环境，也叫REPL (read-eval-print-loop)：
```bash
osascript -il JavaScript
```
在交互环境中，首先获取当前运行的app,然后运行附加脚本执行，几乎所有的脚本都先要执行这两句来获取脚本运行的环境：
```js
>> var app = Application.currentApplication()			//这是获取当前运行的app
=> undefined		//交互环境的返回值，这里先不用管
>> app.includeStandardAdditions = true		//打开允许运行脚本
=> true
```
然后比如我们弹出一个警告框：
```js
app.displayAlert('wow', { message: 'I like JavaScript' })
```
回车后会立即执行，你可以看到mac屏幕上弹出的gui对话框。  
接下来，如果连在一起，成为一个脚本文件，应当是这个样子：
```js
#!/usr/bin/env osascript -l JavaScript

var app = Application.currentApplication()
app.includeStandardAdditions = true
app.displayAlert('wow', { message: 'I like JavaScript' });
```
把上面的代码保存为一个文件，比如叫testAlert.js,第一句可能是唯一需要解释的，`#!`开头表示是脚本标志，后面的是脚本解释器的路径，在这里是`/usr/bin/env osascript -l JavaScript`,`/usr/bin/env`的意思是在环境参量中寻找后面的`osascript`命令来执行，再后面则是执行参数。  
保存为文本文件之后，`chmod +x testAlert.js`,随后`./testAlert.js`就可以执行了。效果跟交互式环境运行是相同的。  

通过Objc调用c语言库函数的例子：  
```js
#!/usr/bin/env osascript -l JavaScript
//引用c的函数库
ObjC.import('stdlib')
//这样引用的函数，都在$.这个域下面
function run(argv) {    //似乎相当于main函数，是自动启动的
  argc = argv.length // If you want to iterate through each arg.

  status = $.system(argv.join(" "))        //相当于c的system(...)
    //这里实际是把所有的参数当做参数来执行一个system调用
  $.exit(status >> 8)	//使用c函数exit来退出程序并给出返回值
}
```
引用函数库，默认情况下，系统可以从三个位置搜索函数库：  
* ~/Library/Script Libraries/
* 一个macos app包的Contents/Library/Script Libraries/路径。（这个从OSX10.11开始支持）
* 从环境参量OSA_LIBRARY_PATH中寻找，多个路径跟PATH一样，中间用“：”隔开。（这个也是从OSX10.11)开始支持。

首先假设我们写了一个库函数：
```js
function log(message) {
    TextEdit = Application('TextEdit')
    doc = TextEdit.documents['Log.rtf']
    doc.text = message
}
```
功能很简单，就是利用系统的文本编辑器将输出信息保存为一个rtf文件。以上代码保存为文件名为`toolbox.scpt`的文本文件，记住脚本库文件必须用`.scpt`后缀。这个库文件我们放到`~/Library/Script Libraries/`路径下。随后可以在REPL环境下测试使用这个库文件：
```js
toolbox = Library('toolbox')
toolbox.log('Hello world')
```
这个方法是官方推荐的校本库编写和调用方法，实际上我们还可以用类似node.js方法，这种方法首先要自己写一个基本的引入函数：
```js
var require = function (path) {
  if (typeof app === 'undefined') {
    app = Application.currentApplication();
    app.includeStandardAdditions = true;
  }

  var handle = app.openForAccess(path);
  var contents = app.read(handle);
  app.closeAccess(path);

  var module = {exports: {}};
  var exports = module.exports;
  eval(contents);

  return module.exports;
};
```
然后程序中就可以使用类似这样的方法来调用库函数：
```js
app=require('node_modules/jxapp/index.js')
app.displayAlert("text")
```
这个例子仅供示例，并没有实际作用，因为上面的require函数中实际上我们已经得到了app的实例。使用node.js的库函数的时候有两个注意事项：
* jxa实际并非在浏览器环境运行的，这一点很类似node.js的服务器端，所以要注意global和window两个预置的变量是不存在的，可以在程序一开始设定`window=this;global=this;`来规避库内部的调用。这个问题其实前几天我们说AngularJS2的时候也提到了。  
* 调用node.js库，目前主要还是使用Browserify来实现的，所以要提前使用安装相关包：
```bash
npm install -g browserify   
npm install coffeeify lodash  coffeescript
```
具体的使用方法可以参考上面资源链接中的例子，这里就不展开了。

作为mac电脑上最犀利的自动化工具，如果不想大动干戈用Xcode写ObjectC或者Swift的话，jxa脚本还是非常值得推荐的技术手段，如果一直在mac环境生存的话，建议及早试吃。  
