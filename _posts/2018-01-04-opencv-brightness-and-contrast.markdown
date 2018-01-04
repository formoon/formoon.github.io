---
layout:         page
title:          OpenCV中的亮度对比度调整及其自动均衡
subtitle:       详说亮度对比度自动调整的原理
card-image:     http://p1avd6u2z.bkt.clouddn.com/201801/04/opencvp1.jpg
date:           2018-01-04
tags:           videoaudio
post-card-type: image
---
#### 问题
亮度对比度的调整是视频、图像处理中另外一种常用的基本操作。通常的情况是，无论原图多么好，习惯上，总是会亮度、对比度调整一下，看看是不是会更满意。其实这带出了一个基本问题，那就是，亮度对比度调整有没有依据？到什么样算好？  
作为一个码农最常见的方式是直接把代码贴到这里就算完成了。但是我一向认为，“知其所以然”可能更重要，因此请稍等，让我把原理先解释一下，现在耽误一点时间，将来也许你会跑得更快。  
#### 基本概念
我们常见的图片，有这样几种基本的编码方式（这个编码方式是指图像在电脑中处理基本的数据模式，不是指文件格式）：
灰度图:一般是1个字节表示1个点，取值范围0-255，数字越大，该点就越接近白色，255是纯白。
基本RGB:用代表红绿蓝的3个字节代表1个点，每个字节数字越大，代表该点的该颜色越亮，同样255是纯白。
RGBA:同RGB相比，多了一个遮罩图层，在高清图中，A除了遮罩，也代表该点额外的alpha值（可以理解为额外的亮度）。
以上三种编码方式中，我们以灰度图为例来解释亮度、对比度，RGB就是分别运算3次，RGBA如果A位有效的话就多运算一次，所以不再多解释。碰到复杂的问题，降维分析是常见的模式。  
刚才说过了，代表一个点的数字，数值越大，这个点就越接近白色。反之，越小，就越接近黑色。白色方向也是更亮的方向，黑色方向，也是更暗的方向，那么调整亮度的基本公式也就出来了：
> 某点数值 = 该点原数值 + 要调整的亮度值

要调整的亮度值如果是正值，则调整后的数值越大，看上去就越亮。如果为负，则是越暗。
对比度呢？则是亮的部位更亮，暗的部位更暗，让亮部和暗部的反差更大，则是提高了对比度。因此通常的对比度算法是：
> 某点数值 = 该点原数值 * 对比度系数

对比度系数如果大于1，则是提高对比度，小于1，则是降低对比度。  
网上大多源码都是用这种方法调整对比度。然而实际试验中你会发现，这样的确是调整了对比度，但跟想象中的不一样，对比度虽然加大了，但图片都是更亮，看上去怪怪的。  
原因很简单，刚才说过了代表每个点的数字的取值范围是0-255，本身都是正整数，*对比度系数之后，不论亮部还是暗部，实际数字都增大了，当然整体图片都更亮了。  
知道了原因，就有了另外一种改进的算法，就是亮度可以单独调整，但对比度，要结合亮度一起调整：
> 某点数值 = 该点原数值 * 对比度系数 + 亮度系数

其实改成数学的方式写你肯定更容易看明白，很像我们小学就接触的线性函数：
> f = a*X+b

从合理性上讲，如果单独调整对比度的话，应该给出一个更适合的、可弥补主要暗部亮度增加的基础亮度系数值效果会更好。不过你可以见到，大多图像处理程序，亮度对比度都是一起调整的，所以这种情况下，这一步省掉也没关系。也因此，你也可以明白为什么这类程序设计的时候，要安排亮度、对比度在一起调整了吧？  
这样的算法应当已经可以交付了。不过网上还有更优的算法被我翻到了，后面你可以在源码中看到细节，这里先说一下原理。  
新算法原理上是利用三角函数的非线性特征，使得调整对比度的时候，真正实现亮的部位更亮，而暗的部位不是少许加亮，而是暗的部位更暗。  
此外可能你也注意到了，原来调整亮度对比度的时候，虽然我们是线性的增加亮度、对比度系数，但肉眼看起来图像的变化，感觉并不是线性的，开始时候会变化较小，后面会变化更大。使得鼠标稍微移动，图像就产生了很大变化，控制起来会更困难。新的算法利用三角函数的特征，使得图像的调整看上去线性更好。感觉上更接近PhotoShop这类大牌软件的操作感觉。  
#### 什么样算好？
好了我们已经知道了亮度对比度调整的技术层面原理。那么一副照片，调整到什么时候算效果最好呢？其实这才是本文的主题。   
照片的调整，从来都是有主观性的，我们先来看两幅照片：  
![](http://p1avd6u2z.bkt.clouddn.com/201801/04/mcsjz.jpg)（国产电视剧《琅琊榜》剧照）

![](http://p1avd6u2z.bkt.clouddn.com/201801/04/xqdzjz.jpg)（《星球大战》某前传剧照）  
这两幅照片都是出品方原图，转帖未经任何处理，也就是说符合各自出品方对于照片处理的规范要求。  
先说第一幅照片。应当说看上去很美，在同时代不管是国产电视剧、电影，又或影楼的婚纱照，基本都是这样一个感觉。干净、完美、阳光、靓丽或者很多这样可以罗列的形容词。  
接着我们看第二幅照片，如果按照第一幅照片的标准来说，这实在是太糟糕了。衣服脏兮兮的，脸脏兮兮的，手套脏到可以感觉到那种油腻，机器人满身划痕......这样的形容词一样可以列出很多，但是且慢，这些感觉，为什么如此真实？好像照片中描述的未来世界，难道真实存在的吗？  
其实这正是中、美两国从文化层面对于影视画面的不同理解，也就是我刚才说的，审美“从来都是有主观性的”。  
审美是有主观性的，但是技术并不是。有一个摄影行业的老师傅曾经给我说过一个经验，他说这个经验值万金，这里我分享出来：__一副正常的照片，不是指特殊效果照比如剪影，都应当尽量保留并忠实于事实和细节。细节怎么看呢？看最亮的地方和最暗的地方，最亮部和最暗部如果细节没有丢失，那其它部分也就差不多了。__  
这句话是什么意思呢？我们回过头来再看第一幅照片，我们取一个最暗部比如头发的下缘，然后取一个亮部，如果取天窗的话有点太刻意，我们只看脖子部分的里衣。看出来了吗？那已经完全糊在一起了，你完全分不出来头发丝，也看不出来里衣的材质和纹路。这就叫“细节丢失”了。  
用同样的标准你再看看《星战前传》的剧照，我就不啰嗦了，如此丰富的细节让一切都充满着真实感。然后你可能还会惊讶的想到，为了保持如此丰富的细节，从剧务、服装、美术、灯光、器材，到演员、导演、摄影，需要付出多么大的努力和投入。这些丰富的细节，在行业中有一句流传于口头的形容：厚重感。  
高下立判。今日的影视设备，720P，全高清，2K屏，4K屏，8K屏，这些增长为了什么你懂了吗？  
#### 亮度对比度的自动均衡
有了标准，就要考虑如何从技术上实现。我们引用一张opencv官方论坛的图片。  
![](http://answers.opencv.org/upfiles/14474311256968999.png)  
这张图中用英文描述了自动均衡亮度对比度的算法，你可以对照本文后部的源码来看。这里我先从原理上做一个解释。  
如果我们对每张照片从暗部到亮部做一个统计直方图的话，大多是上图左上角图表的样子。这张图表的意思是，左侧代表最暗部（0是全黑）在画面中所占的数量，线性的延伸一直到最右侧，就是最亮部分（255是全亮）在画面中所占的数量。统计结果跟我们对于典型照片的主观印象是吻合的，就是最暗和最亮的部分，在一张照片中并不多。中间色调的部分，也是占整幅画面最多的部分。  
所以亮度对比度自动均衡调整的原理，就是尽可能减少最暗和最亮部分所占的比重，让中间色调部分尽量充分利用整个0-255有效表达空间（表达空间是指，不管画面多么复杂，也是用0-255的数字来描述、表达出来的）。右上角的图展示了假设我们切掉原图右侧多余的最亮部分，然后整体画面拉伸平铺占满整个0-255表达空间的样子。  
你可能会问，这样的大幅度的调整，不会看起来不自然吗？不会的，只要维持好相邻色域的比例，同等比例的变化，就不影响视觉的效果。试想，一个苹果，放在明亮的阳光下，或者放在暗弱的烛光中，都是一个苹果的样子，人类早已经看惯了这种明暗的变化，不会觉得不自然。反而对于色偏，我们的眼睛才会很敏感，不过这是上一篇《白平衡》的话题，这里不再复述。  
完整的再重复一遍自动亮度、对比度均衡的原理：  
```bash
	1.把彩色图转换成灰度图，因为亮度对比度调整不涉及偏色的调整。
	2.统计灰度图每一个色值的数量。
	3.min=最小的非0值。
	4.max=最大的非255值。
	5.使用灰度图计算出来的min/max值，把彩色图min-max之间的数据重新分布于0-255的范围。
```
这种方法也叫做无损自动亮度、对比度均衡。因为从上面步骤就可以看出来，被抛弃掉的只是全黑和全白的部分，这部分本身已经没有什么细节空间了。所以调整之后，对画面没有什么损失。如果用opencv按照这个算法做出来程序，你会发现对很多数码相机照片，几乎没有什么效果。原因很简单，就是数码相机绝大多数在出图前，已经自动做过了这样的无损自动均衡。  
下面贴出的源码给出了另外一个选择，就是可以给出一个人为设置的百分比值，用于把照片的最暗部及最亮部，含有少量细节的部分，也按照比例抛弃掉一些，剩余的重新分布到0-255的表达空间中。这样出来的图片，会更讨喜一些，如果这个抛弃数据的百分比值比较大的话，那就是上面第一幅《琅琊榜》照片效果的来源了。这个百分比究竟取值多少，取决于照片本身和你对照片的审美认识。  
好的源码会说话，下面来看源码吧。  

#### 源码
```cpp
#include <iostream>
#include "opencv2/core.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/highgui.hpp"

using namespace std;
using namespace cv;

#define CLIP_RANGE(value, min, max)  ( (value) > (max) ? (max) : (((value) < (min)) ? (min) : (value)) )
#define COLOR_RANGE(value)  CLIP_RANGE(value, 0, 255)

/**
 *  \brief Automatic brightness and contrast optimization with optional histogram clipping
 *  \param [in]src Input image GRAY or BGR or BGRA
 *  \param [out]dst Destination image 
 *  \param clipHistPercent cut wings of histogram at given percent tipical=>1, 0=>Disabled
 *  \note In case of BGRA image, we won't touch the transparency
*/
void BrightnessAndContrastAuto(const Mat &src, Mat &dst, float clipHistPercent=0)
{
    CV_Assert(clipHistPercent >= 0);
    CV_Assert((src.type() == CV_8UC1) || (src.type() == CV_8UC3) || (src.type() == CV_8UC4));

    int histSize = 256;
    float alpha, beta;
    double minGray = 0, maxGray = 0;

    //to calculate grayscale histogram
    Mat gray;
    if (src.type() == CV_8UC1) gray = src;
    else if (src.type() == CV_8UC3) cvtColor(src, gray, CV_BGR2GRAY);
    else if (src.type() == CV_8UC4) cvtColor(src, gray, CV_BGRA2GRAY);
    if (clipHistPercent == 0)
    {
        // keep full available range
        minMaxLoc(gray, &minGray, &maxGray);
    }
    else
    {
        Mat hist; //the grayscale histogram

        float range[] = { 0, 256 };
        const float* histRange = { range };
        bool uniform = true;
        bool accumulate = false;
        calcHist(&gray, 1, 0, Mat(), hist, 1, &histSize, &histRange, uniform, accumulate);

        // calculate cumulative distribution from the histogram
        vector<float> accumulator(histSize);
        accumulator[0] = hist.at<float>(0);
        for (int i = 1; i < histSize; i++)
        {
            accumulator[i] = accumulator[i - 1] + hist.at<float>(i);
        }

        // locate points that cuts at required value
        float max = accumulator.back();
        clipHistPercent *= (max / 100.0); //make percent as absolute
        clipHistPercent /= 2.0; // left and right wings
        // locate left cut
        minGray = 0;
        while (accumulator[minGray] < clipHistPercent)
            minGray++;

        // locate right cut
        maxGray = histSize - 1;
        while (accumulator[maxGray] >= (max - clipHistPercent))
            maxGray--;
    }

    // current range
    float inputRange = maxGray - minGray;

    alpha = (histSize - 1) / inputRange;   // alpha expands current range to histsize range
    beta = -minGray * alpha;             // beta shifts current range so that minGray will go to 0

    // Apply brightness and contrast normalization
    // convertTo operates with saurate_cast
    src.convertTo(dst, -1, alpha, beta);

    // restore alpha channel from source 
    if (dst.type() == CV_8UC4)
    {
        int from_to[] = { 3, 3};
        mixChannels(&src, 4, &dst,1, from_to, 1);
    }
    return;
}

/**
 * Adjust Brightness and Contrast
 *
 * @param src [in] InputArray
 * @param dst [out] OutputArray
 * @param brightness [in] integer, value range [-255, 255]
 * @param contrast [in] integer, value range [-255, 255]
 *
 * @return 0 if success, else return error code
 */
int adjustBrightnessContrast(InputArray src, OutputArray dst, int brightness, int contrast)
{
	Mat input = src.getMat();
	if( input.empty() ) {
		return -1;
	}

	dst.create(src.size(), src.type());
	Mat output = dst.getMat();

	brightness = CLIP_RANGE(brightness, -255, 255);
	contrast = CLIP_RANGE(contrast, -255, 255);

	/**
	Algorithm of Brightness Contrast transformation
	The formula is:
		y = [x - 127.5 * (1 - B)] * k + 127.5 * (1 + B);

		x is the input pixel value
		y is the output pixel value
		B is brightness, value range is [-1,1]
		k is used to adjust contrast
			k = tan( (45 + 44 * c) / 180 * PI );
			c is contrast, value range is [-1,1]
	*/

	double B = brightness / 255.;
	double c = contrast / 255. ;
	double k = tan( (45 + 44 * c) / 180 * M_PI );

	Mat lookupTable(1, 256, CV_8U);
	uchar *p = lookupTable.data;
	for (int i = 0; i < 256; i++)
		p[i] = COLOR_RANGE( (i - 127.5 * (1 - B)) * k + 127.5 * (1 + B) );

	LUT(input, lookupTable, output);

	return 0;
}


void waitESC(){
	while(int key=waitKey(0) != 27){};
}

static string window_name = "photo";
static Mat src,src1,dst1;
static int brightness = 255;
static int contrast = 255;

static void callbackAdjust(int , void *)
{
	Mat dst;
	adjustBrightnessContrast(src, dst, brightness - 255, contrast - 255);
	imshow(window_name, dst);
}


int main(int argc,char **argv){
	
	if (argc != 2) {
		printf("%s imgfile",argv[0]);
	}
	src1=imread(argv[1]);
	imshow("org",src1);
	BrightnessAndContrastAuto(src1,src,5);
	
	if ( !src.data ) {
		cout << "error read image" << endl;
		return -1;
	}

	namedWindow(window_name);
	createTrackbar("brightness", window_name, &brightness, 2*brightness, callbackAdjust);
	createTrackbar("contrast", window_name, &contrast, 2*contrast, callbackAdjust);
	callbackAdjust(0, 0);

	waitESC();

	return 0;

}

```
程序以一副照片为参数执行。先显示出来原图，窗口名称为“org”,随后以5%为抛弃比例做亮度、对比度自动均衡，结果图片显示于窗口"photo"，同时在窗口为用户提供了进一步调整亮度对比度的两个工具条。下图是运行的截图:  
![](http://p1avd6u2z.bkt.clouddn.com/201801/04/opencvp1.jpg)
参考链接：  
<http://blog.csdn.net/c80486/article/details/52505061>  
<http://answers.opencv.org/question/75510/how-to-make-auto-adjustmentsbrightness-and-contrast-for-image-android-opencv-image-correction/>  
(本文照片素材来自于网络，如有侵权请通知博主删除。)
