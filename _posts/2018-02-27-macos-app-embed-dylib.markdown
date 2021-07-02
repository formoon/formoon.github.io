---
layout:         page
title:          将dylib库嵌入macOS应用的方法
subtitle:       otool和install_name_tool
card-image:     /attachments/201802/sun1.jpg
date:           2018-02-27
tags:           mac
post-card-type: image
---
![]/attachments/201802/sun1.jpg)  
写作是一种习惯，稍微松懈，也许失去的就很多。过了一个年，居然很多天都没有更新，幸福的代价吧:)  

标题的问题其实以前碰到过，不过当时在iOS，所以随手处理了没有重视。  
而这次是在macOS，所使用的库，本身已经用brew安装过，所以本机调试没有发现这个问题。  
等到拷贝到用户的机器上，突然发现程序无法启动，查看log才发现库没有找到。而实际上当时，我已经很确认的将dylib库文件打包到了app中。  

随后发现macOS的dylib采取了比较特殊的机制，每个文件都内置有完整的路径名，如果不把dylib文件放置到这个路径上去，应用调用dylib的时候就会报错找不到库文件。  
官方推荐的解决的方法是将库文件及头文件打包编译为Frameworks，随后引入到项目中。不过对于很多gnu的跨平台程序员，肯定不希望单独为macOS来写一个Xcode工程。  
所以我建议还是使用内置的工具来修改这个执行路径，步骤如下：  
1. 假设我们的库文件名为libabc.0.dylib，通常是放置在/usr/local/lib文件夹中，为了不影响macOS下面其它应用对这个库的调用，我们首先把这个文件拷贝出来到我们的开发工作目录。  
2. 使用`otool -L libabc.0.dylib`命令来查看这个库内置的路径名，没有意外的话，应当是`/usr/local/lib/libabc.0.dylib`。  
3. 修改dylib文件中保存的文件路径：  
```bash
install_name_tool -id @executable_path/../Frameworks/libabc.0.dylib libabc.0.dylib 
```
注意修改之后的路径`@executable_path/../Frameworks/libabc.0.dylib`，这个是app中的Frameworks目录，许多引用的框架和sdk内置的dylib文件，编译时候会放置到这里。  
4. 随后在程序中正常引用dylib的头文件，注意.h头文件要拷贝到开发目录或者在工程中设置搜索路径来引用。  
5. 在工程设置的General->Embedded Binaries中引入所使用的库文件`libabc.0.dylib`，这是保证app编译链接的时候能够正常通过。我记得Xcode7还是什么版本中，在这里银如意了库文件，库文件就会被自动的加入到Frameworks目录，但也许是不是sdk内置的库文件，只在这里引用解决了链接问题，但并不能自动把dylib库文件打包到app中。  
6. 在工程设置的Build Phases中，点左上角“+”，选择Embed Libraries，然后在其中选择Destination为Frameworks，其它项目保持默认值不变。把libabc.0.dylib文件拖过来到本项目下面的列表中。这样编译的时候，才会把库文件打包到app的Frameworks文件夹。  

做完了以上这些，编译出来的app应用就能正确的调用自己包中的库文件了。  
