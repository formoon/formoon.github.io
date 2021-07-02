---
layout:         page
title:          给图片加水印
subtitle:       新码农如何把技术变成产品
card-image:		http://blog.17study.com.cn/attachments/201906/waterMark/IMG_20190521_125150_logoed.jpg
date:           2019-06-17
tags:           html
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201906/waterMark/IMG_20190521_125150_logoed.jpg)  
### 前言
加水印是为图片声明版权出处的一种常用方法。  
平常都是写技术文章，文章的重点在技术本身，照片往往不需要加水印，或者需要加也不多，祭出神器PhotoShop很快就能完成。  
前一段趁着夏天还不很热的时候出去游荡，回来应约写了游记，其实是给别人当做攻略来用。  
游记可就不同了，照片成为了主体，并且量很大。随便一个景区的流程，十几副照片总是免不了的。这个时候，还用PhotoShop来加水印，当然不是不行，但那显然非我等“攻城狮”所愿为的。  
于是我们为图片加水印的“产品”，就此立项啦。  
> 某个技术的出现可能是因为积累，可能因为意外，可能因为爱好。但产品，总是因为一个“需求”而开始。

### 水印文件
为图片加水印，首先你得先有一个水印。当然随随便便在图片上加一行字也是水印，但如果想拿得出手，有位美工帮你操刀再好不过。要说现在的程序员，每天团队一起工作，谁还没几位要好的美工朋友。  
什么？你没有？那你可要注意了。现在不管是做研发，还是做产品，一个人打天下的时代已经过了。  
> 在团队中，技术固然重要，沟通能力则更为重要。如果不能在每个岗位都有自己的铁杆兄弟，忙碌一辈子，你也只能是个小码农。  

在这方面，可别迷信职位所带来的“权利”，“权利”和“关系”所能起的作用，那可是天壤之别。  

我手头就有一个现成的水印，用了得十多年了。虽然看起来在设计上已经跟不上时代，但这种纯个性化的东西，你架不住喜欢。  
> 用户的需求才是第一位的，作为程序员，你可以说用户是外行，啥也不懂。但用户要的才算数，你说的，不算数。  
当然如果你的沟通能力超群，把用户给劝服了，那当我没说。  

用作水印的图片，首先要有“镂空”的特质。比如你看题头图的右下角，水印只有主体的部分出现在图片上。其余的部分，仍然是照片本身。看上去水印图片，就是镂空的样子。  
其实很多标准的图片格式本身就支持镂空，比如GIF图片，比如PNG图片。在Web网页的设计中，镂空图片本来就有很大的使用量。  
但是在我们这个显然并不大的项目中，采用这些图形格式作为水印图片的标准并不划算，一方面用户制作水印图片往往需要额外的操作增加工作量。另一方面在自动添加水印的程序中解析这些图片中的镂空结构也需要额外的工作量。  
> 除非“标准化”本身也是用户的需求之一，否则虽然标准化有很多好处，但快速完成项目才是第一追求的目标。  

制作一个水印文件最容易的方法是在PhotoShop中，把主体内容独立一层，随后把背景部分全部涂黑。这个黑一定要是真正的黑，也即RGB三个值全部为0。实际上任何不会引起冲突的颜色都是可以的，比如我们常见到特技拍摄中用到的蓝箱、绿箱。但使用全黑的背景处理起来还是最容易的。  
![](http://blog.17study.com.cn/attachments/201906/waterMark/ps-layers.png)  
![](http://blog.17study.com.cn/attachments/201906/waterMark/logo.png)  

在程序中操作图片，最强大的当然是opencv库。给工程师用，拿Python写个脚本就够了。如果是给普通用户，可以编译为可执行文件的c/c++肯定是更优选。  

### 版本1
接着不管是你本身就是图像处理的高手，原来就熟悉这方面的工作。还是在互联网上搜索别人的经验，学习别人的程序。总之，很快你就拿出了一个版本，为图片添加水印。  
```cpp
#include <stdio.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace std;
using namespace cv;

const char *picfile="IMG_20190521_125150.jpg";
const char *logofile="logo.png";
const char *outputfile="IMG_20190521_125150-logoed.jpg";
const int mx=10,my=10;

int main(int argc, char **argv){
    Mat image = imread(picfile);
    Mat logo = imread(logofile);
    Mat mask=imread(logofile,0);
    Mat imageROI;

    imageROI = image(Rect(mx,my,logo.cols,logo.rows));
    logo.copyTo(imageROI,mask);
    imshow("result",image);
    waitKey();
}
```
问题并不复杂，打开图片和作为水印的logo，然后再读取图片中作为镂空的背景部分。接着把logo镂空部分去除，然后复制到目标图片上就完成了工作，主要的工作代码只有7行。  
主要函数使用[copyTo](https://docs.opencv.org/4.1.0/d3/d63/classcv_1_1Mat.html#a33fd5d125b4c302b0c9aa86980791a77)，点击链接是opencv官方的说明文档。  
opencv的编译，需要在命令行给出头文件和链接库的额外参数，建议写一个脚本来编译，这里也贴出来(本例中使用当前的opencv4)：  
```bash 
#!/bin/bash

g++ -std=c++11 -o $1 $1.cpp `pkg-config --cflags --libs opencv4` 
```
使用脚本来编译和执行使用如下命令（假设源码名称为wmv1.cpp）：  
```bash
$ ./mkcv4.sh wmv1
$ ./wmv1
```
在一张样本的图片上运行这个程序，得到的结果效果如下：  
![](http://blog.17study.com.cn/attachments/201906/waterMark/wmv1.jpg)  

看起来，完美的解决了用户的需求，完活收工......  

等等，这是我们“虚拟”的一个项目，写文章嘛，没点借口怎么向下写。不过如果这是一个真实的项目，这就到了见客户的时候。相信我，如果客户见了这个程序，肯定会提出一堆的意见回来。比如：  
* 这是水印吗？水印应当是半透明的，这只能叫不干胶。  
* 为什么只能处理什么乱七八糟的IMG_20190521_125150.jpg文件，我要把每个文件都改成这个名字才能处理吗？
* 为什么水印看上去这么大，跟画面一点也不协调
* 水印为什么只能放在左上角，我想放在右下角可不可以？
* ......

从客户那边回来，甭管是产品经理还是销售经理，我估计已经被用户教训的怀疑人生了。所以这个时候他们的脾气不会太好，然后跟程序员沟通起来，耐心肯定也就不够。于是程序员，就处在了崩溃的边缘。用户有多少条意见，程序员就有多少条抓狂的理由。  
> * 用户是掏钱的，既然想从用户那里挣钱，用户说什么你都得学会听着。
> * 用户其实根本不知道自己想要什么，乔布斯都这么说。但用户天生会挑毛病。
> * 记着前面说的，一个人打不了天下，因为有很多人挑毛病，你的产品才能适应更多人。

### 版本2
不管有多么不高兴，生活总要继续，工作也得推动下去。  
其实用户挑毛病永远不是最可怕的，可怕的是用户不挑毛病，并且还不买单。  
所以既然用户有反馈，我们逐条解决就好了。  
首先看“水印效果”的问题，opencv中有专门的函数[addWeighted](https://docs.opencv.org/4.1.0/d2/de8/group__core__array.html#gafafb2513349db3bcff51f54ee5592a19)处理两幅图片之间的重叠互动问题。用起来更简单，连蒙版mask部分都不需要了:  
```cpp
	const float _alpha=0.5;

	Mat image = imread(picfile);
	Mat logo = imread(logofile);
	Mat imageROI;

	imageROI = image(Rect(mx,my,logo.cols,logo.rows));
	addWeighted(imageROI, 1.0, logo, _alpha, 0, imageROI);
	imwrite(outputfile,image);
```

水印尺寸偏大的问题，水印文件本身肯定是固定的。但在大的图片中，水印肯定显得小，小的图片中，水印就会显得大。因此需要水印图片的尺寸是可以变化的，是一个合理的需求。  
opencv中调整图片的尺寸很容易，我们可以要求用户输入一个水印logo尺寸的宽度，随后保持logo的比例，计算出来logo的新高度。然后调整logo的尺寸就可以了。  
```cpp
    int neww,newh;
    neww = (int)_logowidth;
    newh = (int)(logo.rows * ((float)neww / logo.cols));
    Size dsize=Size(neww,newh);
    resize(logo,logo,dsize);
```
文件名、logo位置问题，都可以由程序运行时，用户输入的参数来确定，这个再简单不过。  
很快，第二版新鲜出炉：  
```cpp
#include <stdio.h>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace std;
using namespace cv;

#define PATH_MAX 1024

const float _alpha=0.5;

char _picfile[PATH_MAX];
char _outputfile[PATH_MAX];
char _logofile[PATH_MAX];
int _logowidth;
int _mx,_my;

int main(int argc, char **argv){
    if (argc != 7) {
        printf("Wrong parament!\n");
        return 1;
    }

    strcpy(_picfile,argv[1]);
    strcpy(_outputfile,argv[2]);
    strcpy(_logofile,argv[3]);
    _logowidth=atol(argv[4]);
    _mx=atol(argv[5]);
    _my=atol(argv[6]);


    Mat image = imread(_picfile);
    Mat logo = imread(_logofile);
    Mat imageROI;

    int neww,newh;
    neww = (int)_logowidth;
    newh = (int)(logo.rows * ((float)neww / logo.cols));
    Size dsize=Size(neww,newh);
    resize(logo,logo,dsize);

    imageROI = image(Rect(_mx,_my,logo.cols,logo.rows));
    addWeighted(imageROI, 1.0, logo, _alpha, 0, imageROI);
    imwrite(_outputfile,image);
}
```
我们再次编译、执行来试一试：  
```cpp
$ ./mkcv4.sh wmv2
$ ./wmv2 IMG_20190521_125150.jpg IMG_20190521_125150-logoed.jpg logo.png 150 100 100
```
得到的图片如下：  
![](http://blog.17study.com.cn/attachments/201906/waterMark/wmv2.jpg)  
看起来顺眼多了，刚才的问题，也都得到了解决。  

我们就不再“装作”有用户的样子，相信刚才描述的用户反馈，大多人都有过这种经历，谁也不开心别人在自己的心血上指手画脚。但在真实的工作中，往往如此。  
这只是一个虚拟的项目，用户也只是我们自己。所以还是让我们自己来继续为项目挑毛病，期望能进一步完善。  
> * 找到问题最好的办法就是大量使用，大范围使用。  
> * 要珍视给你反馈意见的人，不管是测试还是产品经理，他们是在帮你完善产品。

第二版的程序的确有了进步，但问题依然很多。  
* 参数太多，用起来很繁琐并且不友好，参数多了、少了、错了都会导致程序错误。
* 第一版“不干胶”模式添加水印的方式，实际还是有意义的，值得保留。
* 虽然水印添加位置可以随意了，但并不好用，我们并不希望水印出现在主题的位置。
* 水印的尺寸虽然可以指定，但用起来并不方便，当目标图片尺寸不确定的时候，给定水印的尺寸实际上不现实。

### 版本3
同样是挑毛病，由自己主动挑出来，是不是比别人挑出来在心理上更舒服？  
同理，由自己的团队挑出来，当然也比让用户挑出来，更容易让所有人满意。  
而且，如果把为图片加水印这一个动作算作“核心技术”的话，这一次挑出的所有毛病，基本都不是技术问题。而都是“好用”问题，或者叫“用户体验”问题。  
> 在正常的工作中，最多不超过10%算的上技术问题，绝大多数开发工作，都是为了把技术，开发成可被用户接受的产品。而这些工作中，仍然有绝大多数不过是把参数换个顺序，按钮换个颜色之类的内容。  

对于上面找出来的问题，c/c++中本来就有比较好的解决方案。就是使用getopt_long/switch配合的参数处理系统。在处理过程中，为没有给出的参数，给出合理的默认值。  
命令行程序，一般的窍门都是尽量支持更多的参数，让动手能力强的用户可以更精细的定制。同时为参数尽可能的提供默认值，让极少必要的参数，程序就能正常运行。  
随后在这样的命令行程序的支持下，既可以在服务器端定制网页把程序包装成网络云服务。也能够写图形界面的外壳，给用户单机使用。  
在这个思想的指导下，我们梳理一下可能定制的参数：  
* 输入的图片文件名，程序将为这个图片添加水印，这个参数必不可少。  
* 输出的图片文件名，添加水印之后的图片，保存到这个文件。这个参数可以省略，省略的话，程序应当自动在输入文件名的基础上重命名一个文件名输出。此外还有一个潜在需求，输出文件名如果等同于输入文件名的话，相当于添加水印后替换原始文件。这要求程序读取完输入文件后，马上关闭文件，否则写出到原文件会失败。  
* 水印Logo文件名。如果省略，应当使用当前目录中的一个默认Logo文件。 
* 水印图片缩放尺寸。创意一下，如果这个参数小于1，则代表水印图片缩放到目标图片的比例，比如0.3个目标图片宽度。如果这个参数大于1，则代表水印图片缩放到实际给定的尺寸。潜在需求，在这个应用中，用户天生只对图片宽度敏感，所以这个参数实际代表Logo宽度，Logo的高度应当等比缩放。  
* 水印的位置。刚才一个版本有了高度的自由，实际上并不好用。我们只要指定水印在目标图片的四角之一就够了。这也能避免用户无法知道目标图片中，水印图片坐标的问题。  
* 水印方式，默认使用水印图片和目标图片混合的方式，也可以指定水印图片覆盖目标图片的方式。  

梳理完修改的需求，再次印证了上面的话，这些修改内容，跟核心的技术完全没有关系。现在你知道“码农”这个词所为何来了吧？  
```cpp
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace std;
using namespace cv;

#define PATH_MAX 1024
#define LOGOPIC "./logo.png"

char _logoFilename[PATH_MAX];
char _srcFilename[PATH_MAX];
char _dstFilename[PATH_MAX];
const float _margin=0.01;
const float _alpha=0.5;
float _scale=0.3;
int _position=0;
int _copy=0;

struct option longopts[] = {
    { "input",        required_argument, NULL, 'i'},
    { "out",        required_argument, NULL, 'o'},
    { "scale",      required_argument, NULL, 's'},
    { "position",   required_argument, NULL, 'p'},
    { "logo",   required_argument, NULL, 'l'},
    { "copy",   no_argument, NULL, 'c'},
    { 0, 0, 0, 0},
};

void usage(){
    printf("Options:\n");
    printf("\t -i,--input\tPicture file to add water mark.\n");
    printf("\t -o,--out\tOutput picture name, add postfix '_logoed' on src filename if omit.\n");
    printf("\t -l,--logo\tlogo picture name, set to ./logo.png if omited.\n");
    printf("\t -s,--scale\tZooming logo picture to a new size, if this value below 1, \n");
    printf("\t\t\tmeans width of logo set to width of src picture * scale value,\n");
    printf("\t\t\totherwise, means width of logo scale to this pixel.\n");
    printf("\t -p,--position\tLogo position on src picture. can be 0/1/2/3, four corner.\n");    
    printf("\t -c,--copy\tCopy is keep logo's color, or shadow as default.\n");    
}

void dumpDefault(){
    printf("input:%s\n",_srcFilename);
    printf("out:%s\n",_dstFilename);
    printf("logo:%s\n",_logoFilename);
    printf("scale:%f\n",_scale);
    printf("postion:%d\n",_position);
    printf("copy:%d\n",_copy);
}

void addPostfix(char *srcfile,char *dstfile){
    const char *postfix="_logoed";
    char fname[PATH_MAX];
    strcpy(fname,srcfile);
    // char extName[PATH_MAX];
    char *p=strrchr(fname,'.');
    if (p == NULL) {
        strcpy(dstfile,fname);
        strcat(dstfile,postfix);
        return;
    }
    *p = '\0';
    strcpy(dstfile,fname);
    strcat(dstfile,postfix);
    strcat(dstfile,".");
    strcat(dstfile,p+1);
    return;
}

int getOptions(int argc,char **argv){
    int optIndex = 0;
    int c;

    strcpy(_logoFilename,LOGOPIC);
    strcpy(_srcFilename,"");
    strcpy(_dstFilename,"");

    while(1){
        c = getopt_long(argc, argv, "i:o:s:p:l:c", longopts, &optIndex);
        if(c == -1) {
            break;
        }
        switch(c) {
            case 'i':
                strncpy(_srcFilename,optarg,PATH_MAX);
                break;
            case 'o':
                strncpy(_dstFilename,optarg,PATH_MAX);
                break;
            case 'l':
                strncpy(_logoFilename,optarg,PATH_MAX);
                break;
            case 's':
                _scale = atof(optarg);
                break;
            case 'p':
                _position = atol(optarg);
                if ((_position>3) || (_position<0))
                    _position=0;
                break;
            case 'c':
                _copy = 1; //meas true
                break;
            default:
                usage();
        }
    }
    if (strlen(_srcFilename) == 0) {
        usage();
        exit(1);
    };
    if (strlen(_dstFilename) == 0) {
        addPostfix(_srcFilename,_dstFilename);
    };
    return 0;
}

/*
    position = 0, logo on right,bottom
    position = 1, logo on left,bottom
    position = 2, logo on left,top
    position = 3, logo on right,top
*/
void getPosition(int position,Mat image,Mat logo,int *X,int *Y){
    // x/y _margin using image.cols,not rows

    switch(position){
        case 0:
            *X=(image.cols-logo.cols) - (image.cols * _margin);
            *Y=(image.rows-logo.rows) - (image.cols * _margin);
            break;
        case 1:
            *X=image.cols * _margin;
            *Y=(image.rows-logo.rows) - image.cols * _margin;
            break;
        case 2:
            *X=image.cols * _margin;
            *Y=image.cols * _margin;
            break;
        case 3:
            *X=(image.cols-logo.cols) - (image.cols * _margin);
            *Y=image.cols * _margin;
            break;
        default:
            *X=(image.cols-logo.cols) - (image.cols * _margin);
            *Y=(image.rows-logo.rows) - (image.cols * _margin);
            break;
    };
    return;
}

void markIt(const char *srcpic, const char *logopic, const char *dstpic, int position=0){
    Mat image = imread(srcpic);
    Mat logo = imread(logopic);
    Mat imageROI;
    int markx,marky;

    Mat mask=imread(logopic,0);

    if (_scale < 1){
        float scale=(image.cols * _scale) / logo.cols;
        Size dsize=Size(logo.cols*scale,logo.rows*scale);
        resize(logo,logo,dsize);
        resize(mask,mask,dsize);
    } else if(_scale > 1) {
        int neww,newh;
        neww = (int)_scale;
        newh = (int)(logo.rows * ((float)neww / logo.cols));
        Size dsize=Size(neww,newh);
        resize(logo,logo,dsize);
        resize(mask,mask,dsize);
    };
logo.rows);

    getPosition(position,image,logo,&markx,&marky);
    imageROI = image(Rect(markx,marky,logo.cols,logo.rows));
    if (_copy){
        logo.copyTo(imageROI,mask);
    } else {
        addWeighted(imageROI, 1.0, logo, _alpha, 0, imageROI);
    }
	imwrite(dstpic,image);
}

int main(int argc, char **argv){
    getOptions(argc,argv);
    dumpDefault();

    markIt(_srcFilename,_logoFilename,_dstFilename,_position);
    return 0;
}
```
从完成的程序代码上看同样也是如此，大量的代码都是用于处理参数和默认值逻辑，实际加水印的代码，几乎没有什么变化。  
> 技术人员不能只沉迷于技术，技术人员的升职加薪，往往得益于其它经验的积累，比如行业经验，比如沟通协调经验。  

假设我们当前目录准备了一张图片叫DSCF2183.jpg：
![](http://blog.17study.com.cn/attachments/201906/waterMark/DSCF2183.jpg)  
并且准备两个logo水印文件，一张logo.png是刚才的黑白图片，另外一张logo1.png是红字黑底的图片：  
![](http://blog.17study.com.cn/attachments/201906/waterMark/logo1.png)  
我们把第三版的程序编译一下，然后做几个测试，
```
$ ./mkcv4.sh wmv3
$ ./wmv3 -i DSCF2183.jpg
input:DSCF2183.jpg
out:DSCF2183_logoed.jpg
logo:./logo.png
scale:0.300000
postion:0
copy:0
$
```
这是最简的运行模式，只需要一个输入文件。水印文件自动缩放到目标图片宽度的30%，然后透明叠加在右下角：  
![](http://blog.17study.com.cn/attachments/201906/waterMark/DSCF2183_wite.jpg)  
简单使用-c参数，可以用覆盖的方式叠加水印：  
```bash
$ ./wmv3 -i DSCF2183.jpg -c
input:DSCF2183.jpg
out:DSCF2183_logoed.jpg
logo:./logo.png
scale:0.300000
postion:0
copy:1
```
![](http://blog.17study.com.cn/attachments/201906/waterMark/DSCF2183_wite_copy.jpg)  
更换第二幅水印logo来试试：  
```bash 
$ ./wmv3 -i DSCF2183.jpg --logo logo1.png -o DSCF2183_red.jpg
input:DSCF2183.jpg
out:DSCF2183_red.jpg
logo:logo1.png
scale:0.300000
postion:0
copy:0
$ ./wmv3 -i DSCF2183.jpg --logo logo1.png -o DSCF2183_red_copy.jpg -c
input:DSCF2183.jpg
out:DSCF2183_red_copy.jpg
logo:logo1.png
scale:0.300000
postion:0
copy:1
```
![](http://blog.17study.com.cn/attachments/201906/waterMark/DSCF2183_red.jpg)  
![](http://blog.17study.com.cn/attachments/201906/waterMark/DSCF2183_red_copy.jpg)  

### 补充
作为一个命令行程序，第三版已经基本可以满足应用见用户了。忘了提醒你注意附加在程序内部的程序使用文档，千万注意保证文档的完善、准确。很多优秀的产品，用户能不能用的好，往往是由文档的水平决定的。  
回到最初的话题，如果是自己作为这个用户，那还有一个小需求没有被满足。那就是，我的图片量很大，并且分布在多篇游记的复杂目录结构中。如何同时为多幅图片添加水印？  
这算的上非常个性化的需求，当然可以实现在程序中。但在没有大量用户支持的情况下，这种需求可能只是增加了程序的复杂度，但并没有多少人用。  
对于这种需求，完全可以使用外围脚本的形式来解决。使用bash写这样的脚本，也不过几行代码而已：  
```bash
#!/bin/bash

files=$(find $1 -name "*jpg" -o -name "*png" -o -name "*jpeg")

for file in $files
do
    wmv3 -i $file -o $file
done
```
把脚本设置为可执行，然后把脚本和主程序都拷贝到系统的可执行文件夹：  
```bash
$ chmod +x markall.sh
$ sudo cp markall.sh /usr/bin
$ sudo cp wmv3 /usr/bin
```
这次为再多的图片加水印也不怕了，比如我们有一个测试文件夹，是这样的结构：  
![](http://blog.17study.com.cn/attachments/201906/waterMark/folderStructure.png)  
只要如此执行就可以为文件夹下面，及其子文件夹中所有的jpg/jpeg/png文件添加水印：  
```bash
$ markall.sh test
```
至此，才可以真的完活，收工！  








  
