---
layout:         page
title:          《连连看》算法c语言演示
subtitle:      	自动连连看
card-image:		https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528950362647&di=1a3a97351ea2a503ec25c51bc6494e55&imgtype=0&src=http%3A%2F%2Fpic.962.net%2Fup%2F2013-1%2F20131171730118200.jpg
date:           2018-06-14
tags:           seven c
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528950362647&di=1a3a97351ea2a503ec25c51bc6494e55&imgtype=0&src=http%3A%2F%2Fpic.962.net%2Fup%2F2013-1%2F20131171730118200.jpg)
（图片是游戏的示意图，来自互联网，与本文程序无关）  

看题目就知道是写给初学者的，没需要的就别看了，自己都觉得怪无聊的。  

很多游戏的耐玩性都来自精巧的算法，特别是人工智能的水平。比如前几天看了著名的Alpha GO的算法，用了复杂的人工智能网络。而最简单的，可能就是连连看了，所以很多老师留作业，直接就是实现连连看。  

连连看游戏的规则非常简单：  
1. 两个图片相同。  
2. 两个图片之间，沿着相邻的格子画线，中间不能有障碍物。
3. 画线中间最多允许2个转折。  

所以算法主要是这样几部分：  
1. 用数据结构描述图板。很简单，一个2维的整数数组，数组的值就是图片的标志，相同的数字表示相同的图片。有一个小的重点就是，有些连连看的地图中，允许在边界的两个图片，从地图外连线消除。这种情况一般需要建立的图板尺寸，比实际显示的图板，周边大一个格子，从而描述可以连线的空白外边界。本例中只是简单的使用完整的图板，不允许利用边界外连线。  
2. 生成图板。通常用随机数产生图片ID来填充图板就好。比较复杂的游戏，会有多种的布局方式，例如两个三角形。这种一般要手工编辑图板模板，在允许填充的区域事先用某个特定的整数值来标注，随后的随机数填充只填充允许填充的区域。本例中只是简单的随机填充。  
3. 检查连线中的障碍物。确定有障碍物的关键在于确定什么样的格子是空。通常定义格子的值为0就算空。要求所有的图片ID从1开始顺序编码。复杂的游戏还会定义负数作为特定的标志，比如允许填充区之类的。  
4. 检查直接连接：两张图片的坐标，必然x轴或者y轴有一项相同，表示两张图片在x轴或者y轴的同一条线上才可能出现直接连接。随后循环检查两者之间是否有障碍物即可确定。  
5. 检查一折连接：与检查直接连接相反，两个图片必须不在一条直线上，才可能出现一折连接，也就是x/y必须都不相同。随后以两张图片坐标，可以形成一个矩阵，矩阵的一对对角是两张图片，假设是A/B两点。矩阵另外两个对角分别是C1/C2,分别检查A/C1和C1/B或者A/C2和C2/B能同时形成直线连接，则A图片到B图片的1折连接可以成立。描述比较苍白，建议你自己画张简单的图就容易理解了。在一折连接的检查中，会调用上面的直线连接的检测至少2次，这种调用的方式有点类似递归的调用。  
6. 检查两折连接：同样假设两张图片分别为A/B两点，在A点的X+/X-方向/Y+方向/Y-方向，共4个方向上循环查找是否存在一个点C,使得A到C为直线连接，C到B为1折连接，则两折连接成立。这中间，会调用前面的直接连接检测和一折连接检测。  

用到的算法基本就是这些，下面看程序。本程序使用GCC或者CLANG编译的，可以在Linux或者Mac直接编译执行。  

```c
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>

//常量习惯定义在程序一开始，以便将来的修改，比如重新定义一个更大的地图界限
//定义图板尺寸
#define _width 20
#define _height 20
//定义数组矩阵中，0表示该格子为空
#define empty (0)
//定义共有20种图片
#define _pics (20)
//定义在图板中随机产生100*2个图片的填充
//使用100是为了每次产生2个相同的图片，从而保证整个图可以消除完
#define _datas (100)
//c语言没有bool类型，为了方便自定义一个
typedef int bool;
#define TRUE (1)
#define FALSE (0)
//定义一个结构用来描述一个点坐标
typedef struct {
    int x;
    int y;
} _point;
//描述图板的数组
int map[_width][_height];

//-------------------------init map----------------------
//从图板中获取一个空白格子的坐标，这种方法随着填充图片的增加，
//效率会急剧降低,不过简单实用，这么小的图板对cpu来说也不算什么
_point getRndEmptyBox(){
    int x,y;
    while(TRUE){
        //gcc的随机数跟windows的随机数产生规则不同
        //linux是产生从0开始到RAND_MAX的一个正整数
        //如果移植到windows,这部分要修改
        int x=rand() % _width;
        int y=rand() % _height;
        if (map[x][y]==empty){
            _point r;
            r.x=x;
            r.y=y;
            return r;
        }
    }
}
//设置一对随机图片
void setRandPic(){
    _point p;
    //+1是为了防止出现随机数为0的情况，那样等于填充了空白
    int pic=rand() % _pics + 1;
    p = getRndEmptyBox();
    map[p.x][p.y]=pic;
    //printf("[%02d,%02d]=%02d\n",p.x,p.y,pic);
    p = getRndEmptyBox();
    map[p.x][p.y]=pic;
    return;
}
//用随机图片填充整个图板
void setRndMap(){
    int i;
    for(i=0;i<_datas;i++){
        setRandPic();
    }
    return;
}
//-----------------------------show status --------------------
//显示当前的图板情况
void dumpMap(){
    int i,j;
    printf("--: ");
    for(i=0;i<_width;i++){
        printf("%02d ",i);
    }
    printf("\n");
    for(i=0;i<_height;i++){
        printf("%02d: ",i);
        for(j=0;j<_width;j++){
            printf("%02d ",map[j][i]);
        }
        printf("\n");
    }
}
//显示当前的图板情况，并且使用红色标注上将要消除的2个点
//显示部分使用了linux的终端控制专用方式，移植到windows时需要修改
void dumpMapWithHotPoint(_point c1,_point c2){
    int x,y;
    //为了方便计数，显示x/y轴格子编号
    printf("--: ");
    for(x=0;x<_width;x++){
        printf("%02d ",x);
    }
    printf("\n");
    for(y=0;y<_height;y++){
        printf("%02d: ",y);
        for(x=0;x<_width;x++){
            if ((c1.x==x && c1.y==y) || (c2.x==x && c2.y==y))
                printf("\e[1;31m%02d\e[0m ",map[x][y]);
            else
                printf("%02d ",map[x][y]);
        }
        printf("\n");
    }
}
//-------------------------search path--------------------
//检查直接连接，返回成功或者失败
bool havePathCorner0(_point p1,_point p2){
    if (p1.x != p2.x && p1.y != p2.y)
        return FALSE; // not in the same line
    int min,max;
    if (p1.x == p2.x){
        min = p1.y < p2.y ? p1.y : p2.y;
        max = p1.y > p2.y ? p1.y : p2.y;
        for(min++;min < max;min++){
            if(map[p1.x][min] != empty)
                return FALSE;  //have block false
        }
    } else {
        min = p1.x < p2.x ? p1.x : p2.x;
        max = p1.x > p2.x ? p1.x : p2.x;
        for(min++;min < max;min++){
            if(map[min][p1.y] != empty)
                return FALSE; //have block false
        }
    }
    return TRUE;
}
//检查1折连接，返回1个点，
//如果点的坐标为负表示不存在1折连接
_point havePathCorner1(_point p1,_point p2){
    _point nullPoint;
    nullPoint.x=nullPoint.y=-1;

    if (p1.x == p2.x || p1.y == p2.y)
        return nullPoint;
    _point c1,c2;
    c1.x=p1.x;
    c1.y=p2.y;
    c2.x=p2.x;
    c2.y=p1.y;
    if (map[c1.x][c1.y] ==  empty){
        bool b1=havePathCorner0(p1,c1);
        bool b2=havePathCorner0(c1,p2);
        if (b1 && b2)
            return c1;
    }
    if (map[c2.x][c2.y] ==  empty){
        bool b1=havePathCorner0(p1,c2);
        bool b2=havePathCorner0(c2,p2);
        if (b1 && b2)
            return c2;
    }
    return nullPoint;
}
//检查两折连接，返回两个点，
//返回点坐标为负表示不存在两折连接
//其中使用了4个方向的循环查找
_point result[2];
_point *havePathCorner2(_point p1,_point p2){
    int i;
    _point *r=result;
    //search direction 1
    for(i=p1.y+1;i<_height;i++){
        if (map[p1.x][i] == empty){
            _point c1;
            c1.x=p1.x;
            c1.y=i;
            _point d1=havePathCorner1(c1,p2);
            if (d1.x != -1){
                r[0].x=c1.x;
                r[0].y=c1.y;
                r[1].x=d1.x;
                r[1].y=d1.y;
                return r;
            }
        } else
        break;
    }
    //search direction 2
    for(i=p1.y-1;i>-1;i--){
        if (map[p1.x][i] == empty){
            _point c1;
            c1.x=p1.x;
            c1.y=i;
            _point d1=havePathCorner1(c1,p2);
            if (d1.x != -1){
                r[0].x=c1.x;
                r[0].y=c1.y;
                r[1].x=d1.x;
                r[1].y=d1.y;
                return r;
            }
        } else
        break;
    }
    //search direction 3
    for(i=p1.x+1;i<_width;i++){
        if (map[i][p1.y] == empty){
            _point c1;
            c1.x=i;
            c1.y=p1.y;
            _point d1=havePathCorner1(c1,p2);
            if (d1.x != -1){
                r[0].x=c1.x;
                r[0].y=c1.y;
                r[1].x=d1.x;
                r[1].y=d1.y;
                return r;
            }
        } else
        break;
    }
    //search direction 4
    for(i=p1.x-1;i>-1;i--){
        if (map[i][p1.y] == empty){
            _point c1;
            c1.x=i;
            c1.y=p1.y;
            _point d1=havePathCorner1(c1,p2);
            if (d1.x != -1){
                r[0].x=c1.x;
                r[0].y=c1.y;
                r[1].x=d1.x;
                r[1].y=d1.y;
                return r;
            }
        } else
        break;
    }
    r[1].x=r[0].x=r[0].y=r[1].y=-1;
    return r;
}
//汇总上面的3种情况，查找两个点之间是否存在合法连接
bool havePath(_point p1,_point p2){
    if (havePathCorner0(p1,p2)){
        printf("[%d,%d] to [%d,%d] have a direct path.\n",p1.x,p1.y,p2.x,p2.y);
        return TRUE;
    } 
    _point r=havePathCorner1(p1,p2);
    if (r.x != -1){
        printf("[%d,%d] to [%d,%d] have a 1 cornor path throught [%d,%d].\n",
            p1.x,p1.y,p2.x,p2.y,r.x,r.y);
        return TRUE;
    } 
    _point *c=havePathCorner2(p1,p2);
    if (c[0].x != -1){
        printf("[%d,%d] to [%d,%d] have a 2 cornor path throught [%d,%d] and [%d,%d].\n",
            p1.x,p1.y,p2.x,p2.y,c[0].x,c[0].y,c[1].x,c[1].y);
        return TRUE;
    } 
    return FALSE;
}
//对于给定的起始点，查找在整个图板中，起始点之后的所有点，
//是否存在相同图片，并且两张图片之间可以合法连线
bool searchMap(_point p1){
    int ix,iy;
    bool inner1=TRUE;

    //printf("begin match:%d,%d\n",p1.x,p1.y);
    int c1=map[p1.x][p1.y];
    for (iy=p1.y;iy<_height;iy++){
        for(ix=0;ix<_width;ix++){
            //遍历查找整个图板的时候，图板中，起始点之前的图片实际已经查找过
            //所以应当从图片之后的部分开始查找才有效率
            //遍历的方式是逐行、每行中逐个遍历
            //在第一次循环的时候，x坐标应当也是起始点的下一个，所以使用inner1来确认第一行循环
            if (inner1){
                ix=p1.x+1;
                inner1=FALSE;
            }
            if(map[ix][iy] != c1){
                //printf("skip:%d,%d\n",ix,iy);
                //continue;
            } else {
                _point p2;
                p2.x=ix;
                p2.y=iy;
                if (!havePath(p1,p2)){
                    //printf("No path from [%d,%d] to [%d,%d]\n",p1.x,p1.y,p2.x,p2.y);
                } else {
                    dumpMapWithHotPoint(p1,p2);
                    map[p1.x][p1.y]=empty;
                    map[p2.x][p2.y]=empty;
                    //dumpMap();
                    return TRUE;
                }
            }
        }
    };
    return FALSE;
}
//这个函数式扫描全图板，自动连连看
bool searchAllMap(){
    int ix,iy;
    bool noPathLeft=FALSE;
    while(!noPathLeft){
        noPathLeft=TRUE;
        for (iy=0;iy<_height;iy++){
            for(ix=0;ix<_width;ix++){
                if(map[ix][iy] != empty){
                    _point p;
                    p.x=ix;
                    p.y=iy;
                    if(searchMap(p) && noPathLeft)
                        noPathLeft=FALSE;
                }
            }
        }
        printf("next loop...\n");
    };
    return TRUE;
}
//-----------------main-----------------------------
int main(int argc,char **argv){
    srand((unsigned)time(NULL));
    memset(map,0,sizeof(map));
    setRndMap();
    dumpMap();
    searchAllMap();
}
```
  
运行结果会是类似这样：  
```bash
link> ./linktest 
--: 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 
00: 14 00 02 16 18 06 00 00 00 00 00 12 13 04 00 00 00 19 18 00 
01: 00 10 00 12 00 05 00 00 00 00 00 00 00 15 09 00 00 00 18 00 
02: 00 00 03 00 00 13 16 00 05 17 00 17 00 00 07 05 00 00 05 16 
03: 02 00 00 00 00 13 00 17 15 00 00 00 00 00 00 02 00 11 15 08 
04: 05 11 00 08 05 00 06 00 00 00 07 06 00 00 06 00 15 17 00 00 
05: 17 18 16 11 01 04 00 16 18 00 04 01 00 02 19 18 00 11 16 00 
06: 00 01 00 11 00 00 00 12 03 00 02 17 01 00 00 19 00 13 07 03 
07: 06 10 00 10 10 00 00 02 00 00 11 15 09 18 00 00 00 00 07 00 
08: 09 14 06 19 00 09 00 00 09 18 00 00 00 12 18 05 00 11 00 18 
09: 01 00 00 07 06 00 15 00 00 00 00 00 00 02 11 00 00 00 08 00 
10: 00 00 02 03 00 15 00 00 19 00 00 07 00 12 00 00 10 00 19 00 
11: 12 11 14 09 10 00 00 00 19 18 00 13 05 11 05 00 00 18 00 07 
12: 11 00 09 00 00 00 00 10 03 00 00 00 00 00 00 00 16 05 12 00 
13: 02 17 00 05 00 00 00 00 04 00 07 00 01 00 09 00 00 00 19 00 
14: 07 00 00 17 00 00 06 00 00 14 00 00 05 00 09 00 08 00 18 00 
15: 00 02 19 00 04 16 00 00 14 00 00 15 16 14 00 00 00 00 00 12 
16: 00 02 00 16 09 00 00 00 00 00 00 09 13 01 19 15 00 17 00 15 
17: 00 18 00 00 08 00 00 00 10 00 00 00 00 06 00 09 02 06 00 01 
18: 00 00 15 00 00 02 08 00 09 07 00 18 06 00 09 00 11 00 00 15 
19: 06 18 00 00 00 02 17 00 00 00 19 00 19 00 00 00 00 04 00 03 
[18,0] to [18,1] have a direct path.
--: 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 
00: 14 00 02 16 18 06 00 00 00 00 00 12 13 04 00 00 00 19 18 00 
01: 00 10 00 12 00 05 00 00 00 00 00 00 00 15 09 00 00 00 18 00 
02: 00 00 03 00 00 13 16 00 05 17 00 17 00 00 07 05 00 00 05 16 
03: 02 00 00 00 00 13 00 17 15 00 00 00 00 00 00 02 00 11 15 08 
04: 05 11 00 08 05 00 06 00 00 00 07 06 00 00 06 00 15 17 00 00 
05: 17 18 16 11 01 04 00 16 18 00 04 01 00 02 19 18 00 11 16 00 
06: 00 01 00 11 00 00 00 12 03 00 02 17 01 00 00 19 00 13 07 03 
07: 06 10 00 10 10 00 00 02 00 00 11 15 09 18 00 00 00 00 07 00 
08: 09 14 06 19 00 09 00 00 09 18 00 00 00 12 18 05 00 11 00 18 
09: 01 00 00 07 06 00 15 00 00 00 00 00 00 02 11 00 00 00 08 00 
10: 00 00 02 03 00 15 00 00 19 00 00 07 00 12 00 00 10 00 19 00 
11: 12 11 14 09 10 00 00 00 19 18 00 13 05 11 05 00 00 18 00 07 
12: 11 00 09 00 00 00 00 10 03 00 00 00 00 00 00 00 16 05 12 00 
13: 02 17 00 05 00 00 00 00 04 00 07 00 01 00 09 00 00 00 19 00 
14: 07 00 00 17 00 00 06 00 00 14 00 00 05 00 09 00 08 00 18 00 
15: 00 02 19 00 04 16 00 00 14 00 00 15 16 14 00 00 00 00 00 12 
16: 00 02 00 16 09 00 00 00 00 00 00 09 13 01 19 15 00 17 00 15 
17: 00 18 00 00 08 00 00 00 10 00 00 00 00 06 00 09 02 06 00 01 
18: 00 00 15 00 00 02 08 00 09 07 00 18 06 00 09 00 11 00 00 15 
19: 06 18 00 00 00 02 17 00 00 00 19 00 19 00 00 00 00 04 00 03 
......
[10,17] to [19,18] have a 1 cornor path throught [10,18].
--: 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 
00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
01: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
02: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
03: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
04: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
05: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
06: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
07: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
08: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
09: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
11: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
12: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
13: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
14: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
15: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
16: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
17: 00 00 00 00 00 00 00 00 00 00 12 00 00 00 00 00 00 00 00 00 
18: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 12 
19: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
next loop...

```


