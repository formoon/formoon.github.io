---
layout:         page
title:          图像识别基本算法之SURF
subtitle:       寻找图像中的SURF points
card-image:		http://www.elecfans.com/uploads/allimg/151126/1965345-1511261149440-L.jpg
date:           2018-03-30
tags:           ml
post-card-type: image
---
![](http://www.elecfans.com/uploads/allimg/151126/1965345-1511261149440-L.jpg)
图像识别、人脸识别可行的算法有很多。但是作为学习，如果能理清这个问题研究的历程及其主线，会对你深入理解当前研究最新的发展有很多帮助。本文是自己在学习过程中的笔记，大多内容来自于网络，出处请参考最后的引文部分。  

#### Sift算法
Sift算法是David Lowe于1999年提出的局部特征描述子，并于2004年进行了更深入的发展和完善。Sift特征匹配算法可以处理两幅图像之间发生平移、旋转、仿射变换情况下的匹配问题，具有很强的匹配能力。总体来说，Sift算子具有以下特性：  
1. Sift特征是图像的局部特征，对平移、旋转、尺度缩放、亮度变化、遮挡和噪声等具有良好的不变性，对视觉变化、仿射变换也保持一定程度的稳定性。  
2. 独特性好，信息量丰富，适用于在海量特征数据库中进行快速、准确的匹配。  
3. 多量性，即使少数的几个物体也可以产生大量Sift特征向量。  
4. 速度相对较快，经优化的Sift匹配算法甚至可以达到实时的要求。  
5. 可扩展性强，可以很方便的与其他形式的特征向量进行联合。  

其Sift算法的三大工序为：
1.  提取关键点；  
2. 对关键点附加详细的信息（局部特征）也就是所谓的描述器；  
3. 通过两方特征点（附带上特征向量的关键点）的两两比较找出相互匹配的若干对特征点，也就建立了景物间的对应关系。

提取关键点和对关键点附加详细的信息（局部特征）也就是所谓的描述器可以称做是Sift特征的生成，即从多幅图像中提取对尺度缩放、旋转、亮度变化无关的特征向量，Sift特征的生成一般包括以下几个步骤：  
1. 构建尺度空间，检测极值点，获得尺度不变性；  
2. 特征点过滤并进行精确定位；  
3. 为特征点分配方向值；  
4. 生成特征描述子；  

#### Surf算法
SURF是speed up robust feature的缩写，可以视为加速版的Sift算法。  
SURF的特点：  
1. 使用积分图像完成图像卷积（相关）操作;  
2. 使用Hessian矩阵检测特征值；  
3. 使用基于分布的描述符（局部信息）。  

SURF算法的一般步骤为：  
1. 构建Hessian矩阵；  
2. 构建尺度空间；  
3. 精确定位特征点；  
4. 主方向确定；  

![](/attachments/201803/30/building1.png)
![](/attachments/201803/30/building2.png)

跟TensorFlow中碰到的情况一样，目前这些常用的算法，在大多的机器学习框架中都已经封装完成了。使用者已经不需要详细的了解内在算法就可以直接使用。  

下面是网上转来的使用OPENCV进行SURF特征点检测示例源码：  
```cpp
#include "highgui/highgui.hpp"    
#include "opencv2/nonfree/nonfree.hpp"    
#include "opencv2/legacy/legacy.hpp"   
#include <iostream>  
  
using namespace cv;  
using namespace std;  
  
int main(int argc,char *argv[])    
{    
    Mat image01=imread(argv[1]);    
    Mat image02=imread(argv[2]);    
    Mat image1,image2;    
    image1=image01.clone();  
    image2=image02.clone();  
  
    //提取特征点    
    SurfFeatureDetector surfDetector(4000);  //hessianThreshold,海塞矩阵阈值，并不是限定特征点的个数   
    vector<KeyPoint> keyPoint1,keyPoint2;    
    surfDetector.detect(image1,keyPoint1);    
    surfDetector.detect(image2,keyPoint2);    
  
    //绘制特征点    
    drawKeypoints(image1,keyPoint1,image1,Scalar::all(-1),DrawMatchesFlags::DEFAULT);      
    drawKeypoints(image2,keyPoint2,image2,Scalar::all(-1),DrawMatchesFlags::DRAW_RICH_KEYPOINTS);       
    imshow("KeyPoints of image1",image1);    
    imshow("KeyPoints of image2",image2);    
  
    //特征点描述，为下边的特征点匹配做准备    
    SurfDescriptorExtractor SurfDescriptor;    
    Mat imageDesc1,imageDesc2;    
    SurfDescriptor.compute(image1,keyPoint1,imageDesc1);    
    SurfDescriptor.compute(image2,keyPoint2,imageDesc2);    
  
    //特征点匹配并显示匹配结果    
    //BruteForceMatcher<L2<float>> matcher;    
    FlannBasedMatcher matcher;  
    vector<DMatch> matchePoints;    
    matcher.match(imageDesc1,imageDesc2,matchePoints,Mat());  
  
    //提取强特征点  
    double minMatch=1;  
    double maxMatch=0;  
    for(int i=0;i<matchePoints.size();i++)  
    {  
        //匹配值最大最小值获取  
        minMatch=minMatch>matchePoints[i].distance?matchePoints[i].distance:minMatch;  
        maxMatch=maxMatch<matchePoints[i].distance?matchePoints[i].distance:maxMatch;  
    }  
    //最大最小值输出  
    cout<<"最佳匹配值是： "<<minMatch<<endl;  
    cout<<"最差匹配值是： "<<maxMatch<<endl;  
  
    //获取排在前边的几个最优匹配结果  
    vector<DMatch> goodMatchePoints;  
    for(int i=0;i<matchePoints.size();i++)  
    {  
        if(matchePoints[i].distance<minMatch+(maxMatch-minMatch)/2)  
        {  
            goodMatchePoints.push_back(matchePoints[i]);  
        }  
    }  
  
    //绘制最优匹配点  
    Mat imageOutput;  
    drawMatches(image01,keyPoint1,image02,keyPoint2,goodMatchePoints,imageOutput,Scalar::all(-1),  
        Scalar::all(-1),vector<char>(),DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS);       
    imshow("Mathch Points",imageOutput);    
    waitKey();    
    return 0;    
}  
```


#### 引文及参考
[SURF算法原理](http://wuzizhang.blog.163.com/blog/static/78001208201138102648854/)  
[Opencv Surf算子特征提取与最优匹配](https://blog.csdn.net/dcrmg/article/details/52602277)  
[特征点检测学习_2(surf算法)](https://www.cnblogs.com/tornadomeet/archive/2012/08/17/2644903.html)  
