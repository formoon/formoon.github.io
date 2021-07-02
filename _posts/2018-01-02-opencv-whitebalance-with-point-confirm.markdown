---
layout:         page
title:          使用人工辅助点达成更优白平衡
subtitle:       opencv平均测光白平衡改进
card-image:     https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201801/02/p2.jpg
date:           2018-01-02
tags:           videoaudio
post-card-type: image
---
图像处理中，白平衡是最常用的一种手段。原因无非是使用数码摄影之后，CCD或CMOS的成像因为与生俱来的电初始化特征，缺少了胶片成像的中立性。即便是胶片成像，因为环境色温的不同，也会对最后的成像有很多颜色方面的影响。  
一般在数码相机和常见的图像处理软件中，都提供了自动白平衡功能，用于自动化的把照片进行校色，使得最终的成像颜色更接近自然。而这些算法中，最多采用的是平均测光白平衡算法。也就是遍历整个画面，求得整体画面的颜色平均值作为参照，从而调整画面的白平衡。为了提高速度，在数码相机中，也多采用多点平均测光的算法，总体原理也是相同的。  
在平均测光白平衡算法中，有一个重要的假设前提，那就是假设整体画面上，RGB三基色的分布值应当是总体均等的，如果违背这个原则，比如在某些照片中某个颜色占了明显较多成分或者明显较少成分，平均测光法就失效了。其实你可能早就注意到了有些照片自动白平衡的效果实在难以接受。而这时候，往往需要用PHOTOSHOP之类的软件，手工进行调整。  
这两年也有很多图像处理软件采用了人工智能的方法进行自动白平衡，效果的确好了很多，但如果照片选题比较偏门，特别是构图、主题参照物等不常见，那自动白平衡的效果仍然不能令人满意。  

这里参照平常使用PhotoShop手工进行白平衡的方法，对常见的白平衡算法进行了改进。主要原理是：  
* 首先人工在画面中选择一个参考点，参考点选取的原则：在现实中参考点的颜色是白色、黑色或者灰色，可以是墙面、纸张或者类似颜色的物体，尽量选择不反光的物体或者不反光的部位。
* 从技术上说，这个参考点的颜色，因为环境光的影响，可能有深度的区别，但R/G/B三个颜色的值，应当接近相等，否则判定该点颜色已经偏色。
* 据此分析参考点的颜色，从而得知环境光及成像系统对整体颜色的影响，达成白平衡校正。

请参考源码：
```cpp
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

Mat imageDest;

void get2D(Mat img,int x,int y,double *b,double *g,double *r){
    int channels = img.channels();
	uchar* data = img.ptr<uchar>(y);
	
	*b = (int)data[x * channels + 0];
	*g = (int)data[x * channels + 1];
	*r = (int)data[x * channels + 2];
	
	return;
}

void whiteBalance(Mat src,Mat *dest,double kb,double kg,double kr){
	vector<Mat> imageRGB;
	split(src, imageRGB);
	imageRGB[0] = imageRGB[0] * kb;
	imageRGB[1] = imageRGB[1] * kg;
	imageRGB[2] = imageRGB[2] * kr;
	merge(imageRGB, *dest);
}

void onMouse(int event, int x, int y, int flags, void* param)
{
    Point pt;
    Mat& image = *(Mat*) param;
    switch(event)
    {
    case EVENT_LBUTTONDOWN: 
        {
            pt = Point(x, y);
			double b,g,r,kb,kg,kr;
			get2D(image,x,y,&b,&g,&r);
            cout << "x:" << pt.x << "   y:" << pt.y << "   ";
			cout << "b:" << b << " g:"<<g<<" r:"<<r << endl;
			kb = (r + g + b) / (3 * b);
			kg = (r + g + b) / (3 * g);
			kr = (r + g + b) / (3 * r);
			whiteBalance(image,&imageDest,kb,kg,kr);
            circle(imageDest, pt, 10, cv::Scalar(0, 0, 255), 2,8,0);
			imshow("after whitebalance", imageDest);
        }
        break;
    }
}

void waitESC(){
	while(int key=waitKey(0) != 27){};
}
int main(int argc,char **argv){
	
	if (argc != 2) {
		printf("%s imgfile",argv[0]);
	}

	Mat imageSource = imread(argv[1]);
	namedWindow("org pic", CV_WINDOW_AUTOSIZE);
	setMouseCallback("org pic",onMouse,&imageSource);
	imshow("org pic", imageSource);

	vector<Mat> imageRGB;

	split(imageSource, imageRGB);

	double R, G, B;
	B = mean(imageRGB[0])[0];
	G = mean(imageRGB[1])[0];
	R = mean(imageRGB[2])[0];

	double KR, KG, KB;
	KB = (R + G + B) / (3 * B);
	KG = (R + G + B) / (3 * G);
	KR = (R + G + B) / (3 * R);

	imageRGB[0] = imageRGB[0] * KB;
	imageRGB[1] = imageRGB[1] * KG;
	imageRGB[2] = imageRGB[2] * KR;

	merge(imageRGB, imageDest);
	imshow("after whitebalance", imageDest);
	waitESC();
	return 0;
}
```
程序首先显示两个图片窗口，“org pic”表示原始的图片，“after whitebalance”窗口是自动白平衡之后的图片。下图是某张数码相机拍照和自动白平衡的结果：
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201801/02/p1.jpg)（原始图片及平均测光自动白平衡的结果）  
应当说右侧自动白平衡之后的结果，比起来原图，还是有了较大的改善，而且从颜色上也比较讨喜。但是稍微专业一点的视频、图像处理人员都能看出来，颜色实际上还是偏色的，主要依据比如猫的爪子，应当是白色，这里虽然比原图纠正了许多，但显然仍然不是白色。  
接着我们人工选择白平衡参考点，刚才说的猫爪算一个可选的点，但因为一根根的毛发是难以选取的，所以这里我们选择了面包车车门，这辆面包车在现实中应当是白色，而且因为车并不是很旧，所以还没有产生自然漆面的偏色，因此可以选做参考点，在原图的窗口中，鼠标选取参考点位置，随后程序自动计算后得到下图：
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201801/02/p2.jpg)（人工选取参考点的白平衡算法）  
看起来是不是更自然了？尤其对比刚才自动白平衡的结果，差别显著。注意在颜色校正后的图片中，车门把手上面的红圈是本次校色所选择的参考点。试验中如果选择有大面积色块的照片，因为平均测光的缺陷，这种方式的效果优势会更明显。此外还有一个额外的好处，就是因为只需要进行点计算，不用遍历整个画面求平均值，白平衡的速度会非常快。你可以找一张比较大的图片试一下这种明显的速度提升。  
最后，考虑到这是本站第一篇关于opencv的博文，贴一下mac电脑上opencv程序编译的脚本：
```bash
#!/bin/sh

export PKG_CONFIG_PATH=/usr/local/opt/opencv3/lib/pkgconfig
g++ -o $1 $1.cpp `pkg-config --cflags --libs opencv`
```
脚本保存为mkcv.sh，首先设定执行权限`chmod +x mkcv.sh`,以后的编译使用：`./mkcv.sh 程序文件主文件名`进行编译即可。  

参考文档：<http://blog.csdn.net/dcrmg/article/details/53545510>

