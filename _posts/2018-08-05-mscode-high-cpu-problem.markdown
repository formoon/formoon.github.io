---
layout:         page
title:          解决vs-code高cpu占用率问题
subtitle:       microsoft.vscode.cpp.extension.darwin进程高cpu占用问题
card-image:	https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201808/vscode.jpg
date:           2018-08-05
tags:           mac linux
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201808/vscode.jpg)
免费的vs-code现在已经成为mac/linux平台的码农新宠，毕竟从windows平台开发virsul studio多年的经验积累不是白给的。  
我也从诸多的代码编辑器环境，逐渐迁移、统一到了vs-code。最近发现一启动vs-code，风扇就呼呼转，才开始还没注意，以为微软的Windows中二病做派再次发作了。后来逐渐感觉系统响应速度严重下降，仔细检查发现是一个进程CPU占用高企不坠：microsoft.vscode.cpp.extension.darwin，如果是在linux平台则是：microsoft.vscode.cpp.extension.linux。  
在网上搜索，发现这个问题早已有之，社区中投诉帖汗牛充栋，大致可以把问题界定向vs-code的插件机制和扩展插件的问题，但实际解决问题的方法一直没有，大家都寄期望于软件的升级。  
不过花费大量时间后，最终在一个帖子的很靠后位置找到一个解决办法：  
编辑文件：.vscode/extensions/ms-vscode.cpptools-0.17.7/out/src/LanguageServer/client.js,注意如果你的c++插件不是0.17.7版本（当前最新版），请修改为你当前版本的文件夹。  
修改内容：  
```javascript
-        extensionProcessName += '.linux';
+        //extensionProcessName += '.linux';
+        extensionProcessName += '.linux.sh';
     }
     else if (plat == 'darwin') {
        extensionProcessName += '.darwin';
```
随后再建立一个文件：~/.vscode-insiders/extensions/ms-vscode.cpptools-0.17.7/bin/Microsoft.VSCode.CPP.Extension.linux.sh，同样注意版本号跟文件夹对应。内容为：  
```bash
#!/bin/bash
exec /opt/glibc-2.18/lib/ld-linux-x86-64.so.2 \
        --library-path /opt/glibc-2.18/lib:/lib64:/lib64  \
   "${0//.sh/}" ${1+"$@"}
```
原文的修改方式是对linux。尝试修改完重启vs-code，故障排除了。  
但是在mac电脑，这种方式就不灵了，macOS所使用的链接库不是这种方式，而且签名机制也不太容易搞定。  
所以建议先卸载微软提供的c/c++扩展，可以安装第三方的c++扩展工具,用起来没太大的区别。比如austin出品的C++ Intellisense。  

#### 参考文档
<https://github.com/Microsoft/vscode-cpptools/issues/1249>
