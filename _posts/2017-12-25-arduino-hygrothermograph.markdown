---
layout:         page
title:          半小时完成一个湿度温度计
subtitle:       Arduino新手指南
card-image:     http://115.182.41.123/files/201712/25/ar6.png
date:           2017-12-25
tags:           arduino toSeven
post-card-type: image
---
![](http://115.182.41.123/files/201712/25/ar6.png)

这是几年前写的一个笔记，估计Seven会用得到，所以翻出来重新贴上。  
很多人学习电脑其实都是从单片机开始的，单片机结构简单，又五脏俱全，所以学习单片机入门，应当能够更容易的让初学者具备电脑的整体观。相信Z80/C51时候训练的习惯，很可能会伴随某些人整个技术生涯吧。 而随着IOT再次活跃起来的单片机，跟C51这些传统上的单片机相比变化不小。集成度更高、速度更快、外围接口和外围传感器更完善，编程也更加方便容易了。这些IOT常见的单片机中，Arduino无论如何算是比较火的一个系列，这个系列包括很多款，最便宜的差不多只要10多块钱（人民币）就可以买到，而且内置了连接电脑的USB转串口芯片，拿到手插上电脑就可以开发。  
今天说的这个小东西，使用了如下的器件：
* Arduino单片机本身，最便宜的版本就可以
* 温度、湿度感应器
* 液晶显示屏(如果不需要显示也可以没有或者根据需要买其它型号)，本文中使用LCD1602
* 排线若干
* 为了试验方便，建议几块钱买一块Arduino shield马甲板

作为一篇给新手的笔记，首先把器件介绍一下：  
![](http://115.182.41.123/files/201712/25/ar0.jpg)  
这个是温度、湿度传感器，是一款很常见的A/D转换器件，共有3个针脚，分别是V(CC)电源端、G(ND)接地、S(ignal)信号端。大多数的传感器其实都是这样的形式，通过给出工作电压维持器件工作，在信号端得到数据。此类器件因为输出是数字化的模拟量，并非只有开、关两个状态，所以必须接在GPIO的模拟端。  
![](http://115.182.41.123/files/201712/25/ar1.jpg)  
![](http://115.182.41.123/files/201712/25/ar2.jpg)  
这个是LCD1602的液晶显示屏，型号数字指的是每行16个字符，共2行，这里的字符特指是英文字符，这款LCD没有中文显示功能。器件接口使用I2C(读做:I方C),指的是I的平方，所以经常也写作IIC应当更加准确。I2C是一种接口标准，共4根管脚，分别是GND接地、VCC电源、SDA数据、SCL时钟，跟上一个器件的3根管脚主要区别是SDA是数字量，就是只有1、0两个状态，通过时钟信号的配合来区分位与位之间的间隔。IIC接口算是相对比较新的一种接口协议，详细资料可以在网上搜索，目前这种接口在手机、机顶盒、移动设备中有大量的应用。
![](http://115.182.41.123/files/201712/25/ar3.jpg)  
这个就是马甲板，从功能上说，虽然外观区别很大，但其实就类似平常实验常用的面包板。只是这个马甲板专门为了Arduino设计，在管脚和功能方面，更适合Arduino的实验接线。比如请看图中，A/D接口、I2C接口（已经接线的两组）都单独的引了出来，其中很多管脚实际是跟其它管脚复用的，在马甲板上专门跟同协议管脚布线在一起，显然用起来更方便、灵活，对新手来说也更清楚。但是在正常实验结束后，如果会投入生产的话，一般会重新布线重新制作电路板，即便利用标准Arduino板投产也会直接接线到主板上，不会再用马甲板。所以马甲板的目的就是为了实验的方便。  
本实验其实一共就只需要3组接线：温度湿度传感器3根线、LCD显示屏4根线还有Arduino主板到电脑的Usb线，这里的Usb线有供电、数据传输两个功能。下图是连接在一起的全家福：  
![](http://115.182.41.123/files/201712/25/ar4.jpg)  
硬件部分连接好，仔细检查不要有短路、断路的点，可以进入软件部分。

在电脑上打开Arduino IDE软件，这里用的是1.8.4，因为是几年前的笔记，相信当前肯定有更新的版本了。不过对于嵌入式开发，真的往往并不是新版本就好，具体情况要具体看，稳定性通常都是第一需要关注的。  
在Arduino IDE中建立一个新工程，贴入以下代码，为了便于理解，对代码的解析就直接写在注释代码中了：  
```c
//这个是Arduino的标准库，其中提供了I2C接口的操作，这里不需要程序员自己操作I2C接口，是由下面的液晶板代码间接操作的
#include <Wire.h> 
//这个是液晶屏的代码库，是由器件厂商提供的，目前绝大多数的器件都会有厂商提供的软件包（或者叫驱动）来完成器件的操作
#include <LiquidCrystal_I2C.h>
//这个是温度、湿度传感器的软件包
#include <dht11.h>

//A0是温度、湿度传感器的接口号
#define DHT11PIN A0
//声明一个变量来操作传感器
dht11 DHT11;

//同样是声明一个变量来操作液晶屏，0x27是LCD地址，这个是器件手册中给出的，照抄就好
//16*2字符，这也是器件手册中的
LiquidCrystal_I2C lcd(0x27,16,2);  // set the LCD address to 0x27 for a 16 chars and 2 line display

//所有的Arduino程序都分为setup、loop两部分，前者作为正式工作前环境准备、初始化等工作，后者是一个工作循环
void setup()
{
  lcd.init();                      //初始化LCD
 
  //打开背光
  lcd.backlight();
  //下面三行是显示一个简单的启动信息，相当于一般软件的启动页
  lcd.print("Temperature &");
  lcd.setCursor(1,1);  //设置光标位置
  lcd.print("    Humidity");

  //下面三行是初始化串口，从而把温度、湿度的值实时传递到桌面电脑
  //在这个试验中实际串口是没有用的。我曾经把这个数据连接到微信公众号，从而对微信公众号说一句“温度”，就得到房间的温度值
  Serial.begin(9600);
  Serial.println("DHT11 Monitoring");
  Serial.print("\n");
}

//工作主循环
void loop()
{
  char strTemp[0x20],strHumid[0x20];
	//读温度、湿度值
  int val = DHT11.read(DHT11PIN);
  Serial.print("Read sensor: ");
  switch (val)
  {  
//这个switch是用于判断读取值的异常情况，是器件手册中给出的，看下面的信息应当不难理解
//通常一个新手跟专业人员比较大的区别之一就在异常的处理，专业人员不会报有任何幻想，会尽力的处理掉所有异常情况
  case DHTLIB_OK:
    Serial.println("OK");
    break;
  case DHTLIB_ERROR_CHECKSUM: 
    Serial.println("Checksum error"); 
    break;
  case DHTLIB_ERROR_TIMEOUT: 
    Serial.println("Time out error"); 
    break;
  default: 
    Serial.println("Unknown error"); 
    break;
  }

//在串口输出温度湿度值
  snprintf(strHumid,0x20,"%02d%%",(int)DHT11.humidity);
  snprintf(strTemp,0x20,"%02dC",(int)DHT11.temperature);
  Serial.println(strHumid);
  Serial.println(strTemp);

//在lcd输出温度、湿度值
  snprintf(strHumid,0x20,"Humidity:%02d%%    ",(int)DHT11.humidity);
  snprintf(strTemp,0x20,"Temperature:%02dC    ",(int)DHT11.temperature);
  lcd.setCursor(0,0);
  lcd.print(strTemp);
  lcd.setCursor(0,1);
  lcd.print(strHumid);

//延迟两秒后再次循环
  delay(2000);
}

```
好了，在ArduinoIDE中，点击Tools菜单，选择正确的Arduino板型号和端口，把程序upload到单片机运行看一看吧。  
![](http://115.182.41.123/files/201712/25/ar5.jpg)  
