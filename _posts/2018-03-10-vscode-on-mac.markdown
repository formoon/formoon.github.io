---
layout:         page
title:          在Mac上使用vs-code快速上手c语言学习
subtitle:       简说Visual Studio Code for Mac
card-image:     http://img4.imgtn.bdimg.com/it/u=1390883021,2410931279&fm=27&gp=0.jpg
date:           2018-03-10
tags:           mac toSeven
post-card-type: image
---
![](http://img4.imgtn.bdimg.com/it/u=1390883021,2410931279&fm=27&gp=0.jpg)  
天下事，合久必分、分久必合，你肯定想不到当你逃离到Mac平台这么多年之后，有一天你会再用微软的产品来写代码 :)  
其实微软的产品虽然用户体验总是做不到最好，但整体上的确拉低了行业的进入门槛，对于编程也是这样的。  
Seven的c语言课程，老师选择的是vc6，但总不能为了使用vc6，又回到那个我们曾经无爱的世界。  

其实Xcode已经足够好了，足以支撑从入门到专家各个阶段的需求。不过对于入门者来说，还是比较重。好在现在各类代码编辑器非常发达，从Java程序员最爱的intellij idea，到底层程序员喜欢的UltraEdit，还有老牌的Mac代码编辑器TextMate。配合适当的脚本，这些产品都能很好的支持类似集成环境的开发工作。  

在这些产品中，微软团队中年轻的Code还是很亮眼的，下面就来说说如何用vs-code来做c语言的入门开发。  

1. 安装  
到[Visual Studio Code](https://code.visualstudio.com)主页上，最大的那个按钮就是下载。下载后是一个zip包，解压缩之后得到名为"Visual Studio Code.app"的可执行程序，使用鼠标拖动到/Applications文件夹，安装就算完成了。  
2. 配置c语言插件  
启动vs-code之后，默认是一个黑色的窗口，其中左侧窄边上，从上到下有5个快捷图标，最下面的一个就是扩展插件“Extensions”管理。点击这个图标。  
在出现的列表框最上面是一个搜索框，在其中输入c++，会看到很多c/c++的插件，通常第一个出现的就是有"Microsoft"字样的c/c++插件，选择最后的Install。视网速的不同，通常几分钟就能安装完成，“Install”按钮会变成"reload"，点击一下，vs-code会快速的重启，从而激活c/c++插件。  
这个插件的功能主要是提供了c/c++语言的语法高亮编辑器、编译、运行、调试的支持。  
同样的方式，还可以安装一个Code Runner插件，可以为简单的程序提供自动编译、运行的功能，后面会说到使用的方法。  
3. 选择工作目录  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201803/10/code1.png)
不同于我们平常在命令行的编辑、编译、执行。通常说这种集成环境，都需要为每个项目，指定一个工作目录。不管你的项目是只有一行代码的实验小程序，还是包含上千个文件的大工程。  
vs-code重启之后，选择左侧快捷栏最上面的图标，这就回到了最早vs-code一开始的样子，这个图标是文件视窗。  
因为还没有打开任何文件，右侧的主画面，应当仍然在"welcome"欢迎页面。  
在欢迎页面的左上部分，“Start”一节通常是第三行，有"Add workplace folder..."菜单，点击一下，可以在弹出的目录浏览器中选择自己工作的目录，如果还没有来得及准备目录，在窗口的右下角有新建文件夹按钮，最终选定目录之后，选择窗口右下角“Add”按钮可以确定选定的目录为工作目录。选定之后，你会发现左侧的文件列表框已经切换到了对应的目录，只是目录上层的工作区仍然是"UNTITLED"，意思是“未命名”，因为实际上这个工程我们还没有命名。可以不管它，也可以在File菜单选择“Save Workplace As...”将工作区保存为一个文件，然后对文件取一个名字。  
通常习惯上，一个工作区就是一组相关的项目，每个项目单独占用一个目录。  
4. 开始第一个c程序  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201803/10/code2.png)
左侧窗口选择刚才你新加入Workplace的目录，在右侧的欢迎页面选择“New File”，上面的File菜单中也有“New File”选项。可以建立一个新文件，右侧窗口完全空白，就是这个文件当前的内容。随后我们输入简短的几行代码来演示：  
```c
	#include<stdio.h>

	int main(int argc,char **argv){
	    printf("hello vs-code!\n");
	    return 0;
	}
```
代码输入完之后，File菜单有保存，快捷键COMMAND+S也可以。这时候会询问你文件名，比如我们保存为“test.c”。这时候你会发现，屏幕上的代码都有了色彩，这就是语法高亮编辑器的作用。  
想运行这个代码，在编辑窗口右上角有3个图标，其中第一个就是代表执行的三角符号（这个就是我们前面安装的Code Runner插件），点一下，vs-code会自动编译、执行，并且在屏幕的右下角窗口返回执行的结果，当然如果程序有错误，这里也会返回编译的错误信息，帮助你修改程序。  
通常到这里，对于刚学习编程的新手就算够用了。  
5. 配置编译脚本  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201803/10/code3.png)
如果是比较大的工程，就需要自己维护编译过程了，随后通过配置build编译任务，跟vs-code连接在一起。  
在屏幕最上面Tasks菜单中，有Run Build Task选项，第一次运行，就会提示你需要建立任务设置配置文件，并自动打开一个新窗口，给你一个基本的文件模板。这个配置文件名字是tasks.json，对于新手，你可以先不了解过多，在下面这个模板上简单改改就好了（系统自动给出的模板有点偏简单，需要你修改的地方比较多）：  
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build",
            "type": "shell",
            "command": "gcc",
            "args": [
                "-o","test","test.c"
            ],
            "group": {
                "kind": "build",
                "isDefault": true
            }
        }
    ]
}
```
通常只有中部的command及args两个选项需要你改，你能看出来当前实际上是调用gcc命令来编译test.c文件，你可以根据你的工程修改成其它的方式。修改完成存盘后，下次再从菜单选择Run Build Task就可以直接执行脚本，把你的代码编译完成了。  
6. 调试配置  
在Mac,调试通常就是指使用gdb或者lldb进行程序调试。不过一直做服务器端的程序，这个功能我也用的很少。  
配置方法是这样，在Debug菜单选择Add Configurations，同样会新打开一个窗口，并给你一个基本的模板，这个模板基本算可以直接用了。只要在program一节后面修改成"${workspaceFolder}/你编译后的可执行文件名"这种形式存盘就可以使用了。下面是我用的一个模板：  
```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "clang build and debug active file",
            "type": "cppdbg",
            "request": "launch",
            "program": "${fileDirname}/${fileBasenameNoExtension}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb",
            "preLaunchTask": "clang build active file"
        }
    ]
}
```
以后想调试程序，只要菜单选择Start Debug,或者F5快捷键，都可以开始调试。  
vs-code的c/c++插件的调试有一个坑需要注意，就是你使用的默认shell环境必须是bash，因为这个插件依赖了大量的直接脚本来调用系统调试程序及返回运行结果。如果是使用了跟bash兼容性不佳的其它环境，比如fish，则调试程序即便设置正确也无法启动。  
以上...祝用起来开心。  


  
  

