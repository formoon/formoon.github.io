---
layout:         page
title:          使用SDL2显示一张图片
subtitle:       SDL2上手贴
card-image:     https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/SDL.png
date:           2017-12-28
tags:           videoaudio
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201712/SDL.png)
SDL全名Simple DirectMedia Layer，是一个跨平台的底层音频、视频、键盘、鼠标操作库，操作实际通过更底层的OpenGL/Direct3D完成，在保留跨平台的兼容性之外提供了非常高的效率，所以广泛的应用在多种游戏和对速度敏感的应用中，比如鼎鼎大名的steam平台/ffmpeg/qemu/模拟器等，当前的版本是2.0。更详细的资料可以访问官网：<https://www.libsdl.org/>。  
SDL2的编程理念清晰易用，代码简洁高效，这里用显式一副图片的最简代码来作为入门的示例，正式的教学可以搜索很多国内的教学网站。  
老办法，让代码自己来说话：  
```c
#include <stdio.h>
//引入SDL头文件
#include <SDL.h>        
//显式bmp之外的图片需要用到sdl_image库，需要单独引入头文件
#include <SDL_image.h>

#define bool int
#define false 0
#define true (!false)

int main(int argc, char ** argv)
{
    bool quit = false;
    SDL_Event event;

	 //SDL初始化，这里只显示图片，所以只初始化VIDEO系统，更多的支持查看官方文档
    SDL_Init(SDL_INIT_VIDEO);
	//为了显示png图片，额外使用了图片库，所以要单独初始化
	IMG_Init(IMG_INIT_JPG); 

	//建立SDL窗口
    SDL_Window * window = SDL_CreateWindow("SDL2 Displaying Image",
    			SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
 	//渲染层
    SDL_Renderer * renderer = SDL_CreateRenderer(window, -1, 0);
	//如果只是显示一张bmp图片，使用sdl内置的功能即可
    //SDL_Surface * image = SDL_LoadBMP("only_support_BMP.bmp");
	//因为要显示png图片，所以使用了外部库，sdl_image库当前支持jpg/png/webp/tiff图片格式
	SDL_Surface * image = IMG_Load("/Users/andrew/Downloads/webFavorite/3481980_orig.png");
	//载入的图片生成SDL贴图材质
    SDL_Texture * texture = SDL_CreateTextureFromSurface(renderer, image);
 
    while (!quit)
    {//主消息循环
        SDL_WaitEvent(&event);
 
        switch (event.type)
        {	//用户从菜单要求退出程序
            case SDL_QUIT:
                quit = true;
                break;
        }
 
 	   //如果指定显示位置使用下面注释起来的两句
        //SDL_Rect dstrect = { 5, 5, 320, 240 };
        //SDL_RenderCopy(renderer, texture, NULL, &dstrect);
		//把贴图材质复制到渲染器
        SDL_RenderCopy(renderer, texture, NULL, NULL);
		//显示出来
        SDL_RenderPresent(renderer);
    }
	 //典型的三明治结构，清理各项资源
    SDL_DestroyTexture(texture);
    SDL_FreeSurface(image);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
 	//退出image库
 	IMG_Quit();
	//退出SDL
    SDL_Quit();
 
    return 0;
}
```
代码中基本算是逐句注释，所以读起来应当很清晰。主要需要说明的有两点，但其实跟这段代码并没有直接关系，而是有关在众多的绘图技术、架构、方案中，SDL处于一个什么位置：  
1.首先是绘图哲学，使用过OpenGL及Direct3D的看这些代码应当不陌生，但这里要单独给传统GUI绘图的同学多说两句。通常使用GUI绘图，大概是这样一个逻辑，请看伪代码：
```bash
准备画板();

画一个点(x,y);
画一条线(x1,y1,x2,y2,c);
画一个圆(x,y,r,c);
贴一张图(x,y,w,h,bmp);

结束绘图();
```
在伪代码的过程中，每执行一条命令，比如画了线，在屏幕上就会看到结果，然后那条线也会一直存在，直到程序清掉它或者其它屏幕元素遮住它。  
而SDL所使用的模式用伪代码表示大致是这样的逻辑：
```bash
准备工作();
主循环 {
	游戏逻辑处理();
	界面元素1进场();
	界面元素2进场();
	界面元素n进场();
	渲染();
	是否退出判断();
}
```
比较主要的区别是，每一个界面元素，或者说屏上的元素进场，并非真正的绘图，只是像拍电影一样准备一个场景。等到所有屏幕元素都到齐，场景完全准备好，再一次性渲染，这时候是真正的绘制到屏幕上。更形象的比喻就好像演员都准备好了，相机快门按下，才真正成像。这个成像称为一帧，随后循环起来，一次次的准备好场景、渲染成像，就形成了连续不断的帧从而形成了帧动画，也就是我们熟悉的屏幕游戏画面。这里面每一秒钟能够进行多少次循环，就成为了游戏玩家熟悉的帧率，追求高帧率是大多游戏玩家对电脑的要求。  
这两种绘图的方式，各有优劣，但依据特征，有不同的应用方向。前者多用于打印、绘图输出相关的办公、平面设计等场合，传统软件的界面也多用这种方式，还有比如我们都熟悉的上网浏览器页面也是采用这种渲染方式。这种方式对速度不敏感，虽然有可能硬件加速，但实际上大多工作是由CPU完成的。  
后者也就是SDL所采用的方式，则在游戏、视频、3D动画、VR、AR等领域大放异彩，我们耳熟能详的OpenGL、Direct3D也都采用这种方式，这种方式的流程逻辑，也更适合把大量的数据和素材交给GPU去完成更耗时的计算。  
显而易见，从绘图哲学的角度看，SDL/OpenGL/Direct3D所采用的绘图方式,显然更适合3D类绘图、动画的加速，那么这种技术对平面绘图，比如就是单纯的视频播放，是如何加速的呢？其实很简单，我们知道所有的3D绘图都包括至少两个主要的部分，一是3D物体的构造模型，比如是一个球体还是一个圆柱体；另一部分则是这个3D物体表面看起来是什么样子的，比如是一个石膏的球体还是一个毛绒玩具的球体。这第二部分就需要用到材质，材质实际上主要是由三维物体的表面积在二维展开的图片。所以3D绘图对二维的加速实际上就是在屏幕上绘制一个全屏幕的平面，然后把二维图像当做材质贴图上去的结果。你看上面SDL代码中载入的png图片，实际最后就是当做一副材质(texture)来使用了。  
2.SDL/OpenGL/Direct3D同GTK/MFC/QT/Cocoa是什么关系？  
刚才其实比较清楚的讲了SDL/OpenGL/Direct3D在绘图上的作用，其实它们就是一套绘图的体系。  
GTK/MFC/QT/Cocoa也是显示相关这没错，但是它们主要是提供用户程序的界面管理、显示及事件处理。更具体一点说，比如你看到屏幕上的菜单、窗口、对话框、按钮、文字，几乎都是这些界面管理器来实现的，我们点了一个按钮、拖动一个窗口，都会产生事件，这些事件会由这些界面管理器收集、分类、排序，调用响应用户响应函数做出最后的处理。所以平常我们所见的应用程序，其实都是基于这一类软件库完成的。而重要的是，这些界面管理库，实际上最终也是经由OpenGL/Direct3D或者类似功能更底层一些的显示绘图库来完成界面部分的绘制功能。但是这些显示系统往往太庞大、臃肿了，对于对速度极为敏感的游戏、视频类应用而言，通常我们见到的这些界面所占比重又比较小，所以游戏类的应用，往往不采用或者较少部分采用这些传统的界面管理库。
这两类系统往往不是独立存在的，比如举例说一个视频播放器，播放器的窗口界面、菜单、文件打开等界面和操作，都是由界面管理器比如Windows上的MFC或者Mac上的Cocoa来完成的，到真正视频播放的环节，在窗口中给定的区域，则是由SDL、OpenGL、Direct3D出马，完成视频的逐帧绘制的功能。  

回到今天的主题。上面的代码在编译的时候，因为使用了SDL2/SDL_image两个额外的附加库，所以在编译、执行代码之前，首先要安装这两个软件库。在mac电脑上安装这两个库的命令是：`brew install sdl2 sdl2_image`。
编译代码使用：
```bash
gcc -o sdlpng sdlpng.c $(pkg-config --cflags --libs sdl2_image)
```
后面`$(pkg-config --cflags --libs sdl2_image)`的意思是，将sdl2_image代码库及其依赖库（这里当然就是sdl2库)的编译参数和引用库参数全部显示出来，作为字符串加入到编译命令中去。这个功能是由pkg-config这个包管理器完成的。如果不需要处理png图片，只是bmp图片，则不需要使用sdl2_image库，仅适用sdl2库即可。这个时候可以使用`$(pkg-config --cflags --libs sdl2)`。sdl2也提供了自己的包参数工具sdl2-config可以完成类似的功能，但仅对自己有效，所以为了通用起见，我们还是使用pkg-config更方便一些。  
谈到附加包的编译参数，我们也经常看到一些教科书上写成类似：`` `pkg-config --cflags --libs sdl2` ``这样的形式，这是因为在bash下面，反单引号`` ` ``就是用来执行命令、并将结果当做字符串返回的功能。但是这种方式在别的shell,比如fish中是不起作用的，但是`$( ... )`这样的方式就有了更好的通用性。  



参考链接：  
<http://gigi.nullneuron.net/gigilabs/loading-images-in-sdl2-with-sdl_image/>
