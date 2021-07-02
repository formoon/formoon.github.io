---
layout:         page
title:          OpenCV中的照片剪裁
subtitle:       从概念到成品
card-image:     http://blog.17study.com.cn/attachments/201801/04/opencvp2.jpg
date:           2018-01-04
tags:           videoaudio
post-card-type: image
---
照片处理的三大基本操作中，照片剪裁是这系列三篇博文中的最后一篇，但是图像处理中应当首先要做的操作。原因很简单，随着数码相机、摄像机分辨率的增加，现在一张照片几十M的容量已经很常见，先进行裁剪，剩下的部分就会小，后续的处理就能快一些。换一个说法，画面中有一些部分无论如何是你不想要的，那还对那些无用的部分做很多处理干啥？  
关于照片处理三大基本操作的说法，很久之前我有一篇文章《简单2步，P出美图》，因为博客多次搬家，这篇文章已经遗失了。大意是在Photoshop中通过简单2步，一共3个方面的操作，把数码相机拍摄的照片处理成作品级的美图，而且每一步的处理有规范、有标准，基于理性的操作而不是随意的所谓“神来之笔”。这些理念在OpenCV这三篇文章中也有了很多的说明，相信你看到了。那篇文章只能等以后有心情的时候再重写一下吧。  
照片裁剪在OpenCV中非常容易：  
```cpp
	Mat dstPic,srcPic;
	...
	dstPic = srcPic(Rect(x,y,width,height));
	...
	//参数x/y/width/height代表裁剪出来要保留的画面
```
别说我托大，这么简单的问题需要单文来说明吗？  
是的，有必要。原因是单独裁剪并不难，真正用起来就带来了以下问题：  
1. 一幅照片，从哪部分裁剪，首先需要把照片显示出来，并接受鼠标框画操作来标注裁剪的部分。用户体验才是这个问题的关键。
2. 鼠标的框画，在事件处理比较简单的OpenCV中，很多部分，都是需要自行编码处理的。
3. 数码相机的照片，分辨率往往高于屏幕的分辨率，因此照片的显示，要有多级的缩放功能。缩放要有单独的控制方法。
4. 照片有了缩放，裁剪的部分不能受照片缩放的影响。  

所以本文的副标题，叫《从概念到成品》，意思就是说，裁剪很简单，真正能让用户用起来，要解决的事情其实一点也不少。  
请看源码：  
```cpp
#include <iostream>
#include "opencv2/core.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"

using namespace std;
using namespace cv;

Mat org,dst,img,tmp;
double dScale;
const int startWidth=1280;

void showPicInScale(const char *wndName,Mat &pic,double scale){
	Size outSize;
	Mat displayPic;

	outSize.width=pic.cols * scale;
	outSize.height=pic.rows * scale;
	resize(pic,displayPic,outSize,0,0,INTER_AREA);
	imshow(wndName,displayPic);
	return;
}

void on_mouse(int event,int x1,int y1,int flags,void *ustc)//event鼠标事件代号，x,y鼠标坐标，flags拖拽和键盘操作的代号
{
	static Point pre_pt = Point(-1,-1);//初始坐标
	static Point cur_pt = Point(-1,-1);//实时坐标
	char temp[16];
	int x = x1 / dScale;
	int y = y1 / dScale;
	double fontSize=0.5 / dScale;
	int lineSize= 1 / dScale;
	//printf("fontsize:%d linesize:%d\n",fontSize,lineSize);
	if (event == CV_EVENT_LBUTTONDOWN)//左键按下，读取初始坐标，并在图像上该点处划圆
	{
		org.copyTo(img);//将原始图片复制到img中
		sprintf(temp,"(%d,%d)",x,y);
		pre_pt = Point(x,y);
		putText(img,temp,pre_pt,FONT_HERSHEY_SIMPLEX,fontSize,Scalar(0,0,0,255),lineSize,8);//在窗口上显示坐标
		circle(img,pre_pt,2/dScale,Scalar(255,0,0,0),CV_FILLED,CV_AA,0);//划圆
		showPicInScale("org",img,dScale);
	}
	else if (event == CV_EVENT_MOUSEMOVE && !(flags & CV_EVENT_FLAG_LBUTTON))//左键没有按下的情况下鼠标移动的处理函数
	{
		img.copyTo(tmp);//将img复制到临时图像tmp上，用于显示实时坐标
		sprintf(temp,"(%d,%d)",x,y);
		cur_pt = Point(x,y);
		putText(tmp,temp,cur_pt,FONT_HERSHEY_SIMPLEX,fontSize,Scalar(0,0,0,255),lineSize,8);//只是实时显示鼠标移动的坐标
		showPicInScale("org",tmp,dScale);
	}
	else if (event == CV_EVENT_MOUSEMOVE && (flags & CV_EVENT_FLAG_LBUTTON))//左键按下时，鼠标移动，则在图像上划矩形
	{
		img.copyTo(tmp);
		sprintf(temp,"(%d,%d)",x,y);
		cur_pt = Point(x,y);
		putText(tmp,temp,cur_pt,FONT_HERSHEY_SIMPLEX,fontSize,Scalar(0,0,0,255),lineSize,8);
		rectangle(tmp,pre_pt,cur_pt,Scalar(0,255,0,0),lineSize,8,0);//在临时图像上实时显示鼠标拖动时形成的矩形
		showPicInScale("org",tmp,dScale);
	}
	else if (event == CV_EVENT_LBUTTONUP)//左键松开，将在图像上划矩形
	{
		org.copyTo(img);
		sprintf(temp,"(%d,%d)",x,y);
		cur_pt = Point(x,y);
		putText(img,temp,cur_pt,FONT_HERSHEY_SIMPLEX,fontSize,Scalar(0,0,0,255),lineSize,8);
		circle(img,pre_pt,2/dScale,Scalar(255,0,0,0),CV_FILLED,CV_AA,0);
		rectangle(img,pre_pt,cur_pt,Scalar(0,255,0,0),lineSize,8,0);//根据初始点和结束点，将矩形画到img上
		showPicInScale("org",img,dScale);
		img.copyTo(tmp);
		//截取矩形包围的图像，并保存到dst中
		int width = abs(pre_pt.x - cur_pt.x);
		int height = abs(pre_pt.y - cur_pt.y);
		if (width == 0 || height == 0){
			return;
		}
		dst = org(Rect(min(cur_pt.x,pre_pt.x),min(cur_pt.y,pre_pt.y),width,height));
		imshow("cuted pic",dst);
	}
}

int setWindowTop(){
	namedWindow("GetFocus", CV_WINDOW_NORMAL);
	Mat img = cv::Mat::zeros(100, 100, CV_8UC3);
	imshow("GetFocus", img);
	setWindowProperty("GetFocus", CV_WND_PROP_FULLSCREEN, CV_WINDOW_FULLSCREEN);
	waitKey(1);
	setWindowProperty("GetFocus", CV_WND_PROP_FULLSCREEN, CV_WINDOW_NORMAL);
	destroyWindow("GetFocus");
	return 0;
}
int main(int argc,char **argv){
	int nQuit=1;
	
	if (argc != 2) {
		printf("%s imgfile",argv[0]);
	}
	org = imread(argv[1]);
	org.copyTo(img);
	dScale = (double)startWidth/org.cols;

	setWindowTop();
	//namedWindow("org",CV_WINDOW_NORMAL);//定义一个img窗口
	namedWindow("org");//定义一个img窗口
	setMouseCallback("org",on_mouse,0);//调用回调函数
	showPicInScale("org",img,dScale);

	double dZoomFactor=0.05;
	do {
		int key=waitKey(0);
		switch(key){
			case 27:
				nQuit=0;
				break;
			case 'q':
				dScale += 2*dZoomFactor;
			case 'a':
				dScale -= dZoomFactor;
				if (dScale <= 0)
					dScale = dZoomFactor;
				showPicInScale("org",img,dScale);
				break;
			default: continue;
		}
	} while (nQuit);
	
	return 0;
}
```
源码中已经有了很多的注释，这里再大框架的解释一下：  
* showPicInScale是将照片以给定的缩放率在屏幕上显示
* on_mouse是所有在原图片窗口的鼠标动作事件回调到这个函数来处理，主要处理以下几项：
	 * 如果没有鼠标键按下，则仅在鼠标位置显示当前鼠标位置坐标，注意这个坐标换算成了以全幅图片为标准的坐标，尽管在屏幕显示的时候照片可能缩小了
	 * 如果鼠标左键按下，在该坐标点标记框画起始点
	 * 如果鼠标左键按下移动，则实时用绿线在屏幕上画框
	 * 如果鼠标左键抬起来，则获取框画结束点，配合起始点，就得到了要裁剪的矩形，从而完成裁剪
* setWindowTop，可能是OpenCV跟Mac电脑的兼容问题，每次出来的窗口都在后面，这个函数的功能是使得之后出现的窗口，都出现在屏幕最前面
* main主函数中，do - while循环中主要处理了原始照片缩放级别的加大和缩小

使用示例：  
![](http://blog.17study.com.cn/attachments/201801/04/opencvp2.jpg)
至此关于使用OpenCV进行自动化照片处理的三篇系列就全部完成了，希望对你有用。  

参考链接：<http://blog.csdn.net/skeeee/article/details/16844937>
