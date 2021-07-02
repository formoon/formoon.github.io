---
layout:         page
title:          为OPENCV添加freetype支持并显示中文字符
subtitle:       在mac上编译opencv及contrib库
card-image:		/attachments/201810/opencv-freetype-demo.png
date:           2018-10-10
tags:           mac opencv
post-card-type: image
---
![](/attachments/201810/opencv-freetype-demo.png)
　　在mac电脑上管理这些gnu的库一般都使用Homebrew，但总有一些你个性化的需要是官方的Homebrew配方无法满足的。比如在屏幕的输出中使用中文字符。  
　　在OPENCV中输出UTF8字符集早已经有人完成过类似的工作，方法是使用freetype的支持，程序中选择使用的字库，从而在屏幕上输出任意的字符。但官方的Homebrew OPENCV的配方中，并不包含freetype的支持。这时候，只好自己来编译OPENCV及contrib库，因为freetype的支持就在contrib库中。  
#### 编译安装
　　OPENCV的开发已经非常成熟，所以编译过程并不复杂，大致包含如下的过程：
1. 使用App Store安装Xcode，随后执行一次Xcode根据提示安装其命令行工具。
2. 使用brew安装第三方的依赖库，比如git/cmake/freetype等，很多依赖库根据你使用的模块不同，也有不同的需求。大多依赖库如果你不安装，OPENCV在编译的时候会自动下载，但下载和编译的过程都很慢，不如提前预装编译好的版本。  
```bash
brew install cmake automake pkg-config ant autoconf git freetype
```
3. 准备一个工作目录，下载OPENCV和contrib的源码(以OPENCV3.4为例)：
```bash
mkdir source
cd source
git clone --single-branch -b 3.4 https://github.com/opencv/opencv.git
git clone --single-branch -b 3.4 https://github.com/opencv/opencv_contrib.git
```
master分支可能会包含一些并不稳定的代码，所以不推荐使用master分支的代码。  
4. 配置、编译及安装
```bash
mkdir source/opencv/build
cd source/opencv/build
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/ ..
make -j4
sudo make install 
```

　　上面这种方式通常能满足大多的需求。如果你不想要在编译中加入所有的扩展包，可以使用BUILD_opencv_*的参数屏蔽，比如：  
```bash
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules/ -DBUILD_opencv_legacy=OFF ..
```
　　如果已经使用Homebrew安装了OPENCV，并不想全部重新安装，只想安装freetype支持，可以手工将编译出的freetype部分拷贝到系统路径：　　
```bash
cp source/opencv-3.4.3/build/lib/libopencv_freetype* /usr/local/lib/
cp source/opencv_contrib-3.4/modules/freetype/include/opencv2/freetype.hpp /usr/local/include/opencv2/
```
　　然后还要在pkg-config配置文件中增加freetype库的链接（使用make install的自动安装是不需要这一步的）：  
```bash
vi /usr/local/lib/pkgconfig/opencv.pc
在Libs一行的最后增加：-lopencv_freetype  
```
#### 使用
　　使用freetype替代opencv原有的文字输出功能很简单，这里提供一个修改过的官方样例，假设文件名为drawUtf8.cpp:  
```cpp
#include <opencv2/opencv.hpp>
#include <opencv2/freetype.hpp>

using namespace std;
using namespace cv;

int main(int argc,char **argv){
	String text = "Hello世界！毛泽东";
	int fontHeight = 60;
	int thickness = -1;
	int linestyle = 8;
	int baseline=0;

	Ptr<freetype::FreeType2> ft2;
	ft2 = freetype::createFreeType2();
	//下面的字库要自己下载并拷贝到需要的位置
	ft2->loadFontData( "/user/local/ttf/毛泽东草体.ttf", 0 );

	namedWindow("box");
	Mat img(600, 800, CV_8UC3, Scalar::all(0));

	Size textSize = ft2->getTextSize(text,
	                             fontHeight,
	                             thickness,
	                             &baseline);
	if(thickness > 0){
	    baseline += thickness;
	}

	Point textOrg((img.cols - textSize.width) / 2,
	              (img.rows + textSize.height) / 2);
	rectangle(img, textOrg + Point(0, baseline),
	      textOrg + Point(textSize.width, -textSize.height),
	      Scalar(0,255,0),1,8);
	line(img, textOrg + Point(0, thickness),
	 textOrg + Point(textSize.width, thickness),
	 Scalar(0, 0, 255),1,8);
	ft2->putText(img, text, textOrg, fontHeight,
	         Scalar::all(255), thickness, linestyle, true );
	imshow("box",img);
	
	while(1){ if(waitKey(100)==27)break; } 

	return 0;
}
```
　　随后编译执行：  
```bash
#编译
g++ -o drawUtf8 drawUtf8.cpp $(pkg-config --cflags --libs opencv)
#执行
./drawUtf8
```
　　执行的效果请参看题头图。  
　　最后一种情况，如果编译后只想在当前目录使用，不想安装。这种情况通常还是并不常见，因为默认OPENCV是使用动态编译，各项依赖库如果不安装到系统路径，是无法使用的。可以考虑在cmake参数中增加-DBUILD_SHARED_LIBS=0选项来进行静态编译，但这种情况我并没有尝试，参数仅来自于官方的介绍。  
　　在当前目录中进行应用程序的编译最主要是配置头文件路径及链接库文件的路径，这些内容是比较多的，建议自己使用Makefile或者建立脚本文件来编译，比如mk.sh：  
```bash
#!/bin/sh
CFLAGS="-I source/opencv/include -I source/opencv_contrib/modules/freetype/include -lopencv_stitching -lopencv_superres -lopencv_videostab -lopencv_aruco -lopencv_bgsegm -lopencv_bioinspired -lopencv_ccalib -lopencv_dnn_objdetect -lopencv_dpm -lopencv_face -lopencv_photo -lopencv_fuzzy -lopencv_hfs -lopencv_img_hash -lopencv_line_descriptor -lopencv_optflow -lopencv_reg -lopencv_rgbd -lopencv_saliency -lopencv_stereo -lopencv_structured_light -lopencv_phase_unwrapping -lopencv_surface_matching -lopencv_tracking -lopencv_datasets -lopencv_dnn -lopencv_plot -lopencv_xfeatures2d -lopencv_shape -lopencv_video -lopencv_ml -lopencv_ximgproc -lopencv_calib3d -lopencv_features2d -lopencv_highgui -lopencv_videoio -lopencv_flann -lopencv_xobjdetect -lopencv_imgcodecs -lopencv_objdetect -lopencv_xphoto -lopencv_imgproc -lopencv_core -lopencv_freetype"
LDFLAGS="-L source/opencv/build/lib"
g++ $CFLAGS -o $1 $1.cpp $LDFLAGS
```
　　使用举例:`./mk.sh drawUtf8`。  

#### 参考资料
官方的编译介绍：<https://github.com/opencv/opencv_contrib>  
contrib模块列表：<https://github.com/opencv/opencv_contrib/tree/3.4/modules>  


