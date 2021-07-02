---
layout:         page
title:          Android程序中，内嵌ELF可执行文件
subtitle:       Android开发C语言混合编程总结
card-image:		https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/android_java_c.jpeg
date:           2019-06-14
tags:           html
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/android_java_c.jpeg)  
#### 前言
都知道的，Android基于Linux系统，然后覆盖了一层由Java虚拟机为核心的壳系统。跟一般常见的Linux+Java系统不同的，是其中有对硬件驱动进行支持，以避开GPL开源协议限制的HAL硬件抽象层。    
大多数时候，我们使用JVM语言进行编程，比如传统的Java或者新贵Kotlin。碰到对速度比较敏感的项目，比如游戏，比如视频播放。我们就会用到Android的JNI技术，使用NDK的支持，利用C++开发高计算量的模块，供给上层的Java程序调用。  
本文先从一个最简单的JNI例子来开始介绍Android中Java和C++的混合编程，随后再介绍Android直接调用ELF命令行程序的规范方法，以及调用混合了第三方库略微复杂的命令行程序。  

#### Android Studio配置
第一个配置是安装Android的SDK，这是开发Android程序必须的。  
进入Android Studio的设置界面，Mac的快捷键是`Command`+`,`，Windows和Linux版本请自行从菜单中选择。  
在设置界面中，从左侧顺序选择：Appearance&Behavior -> System Settings -> Android SDK，可以进入到SDK的设置。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/sdk_setting.png)  
右侧的SDK版本列表中，最前面显示了✔️或者后面显示了Installed，表示该版本的SDK已经安装。通常如果没有特殊需要，只安装1个最新版本的SDK即可。图中我是因为某些项目特殊的要求，安装了两个特定不同版本的SDK。  
希望安装某版本的SDK,只要点选相应行最前面的多选框，然后单击右下角确认按钮即可安装。  
如果不是自己从头开始，而是接手了其他开发人员的源码，源码中可能指定了特定版本的SDK。这时候可以修改其项目配置文件中版本的设置，到你安装的SDK版本。更简单的方法是直接在这里安装对应的SDK，防止因为版本依赖出现的很多繁琐问题。  

第二个配置的是NDK，还在刚才SDK设置的界面中，点击界面上侧中间的“SDK Tools”标签，可以进入到NDK设置的界面。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/ndk_setting.png)  
NDK的设置没有那么多的选择，只要安装就好，已经安装碰到有新版本，也可以随性选择更新或者使用老版本继续。NDK不同版本间的兼容性都还不错，大多都不用担心。  
NDK的设置是Android开发中，Java/C混合编程需要的。  

第三个配置是增加一个外部工具javah，这个工具是将Java编写的“包装”文件，转换一个C/C++的.h文件。虽然Java/C++都是面向对象语言，但两者的面向对象实现是不同的。所以在Java中某个类的方法，转换到C++的世界中，是使用很长的函数名来做区分。这种情况使用手工编写虽然效果一样，但很容易出错，使用javah工具则能自动完成。  
在Android Studio设置界面左侧的列表中，顺序选择Tools -> External Tools，单击右侧界面左下角的“+”，新建一个工具，比如就叫"javah"。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/javah_setting.png)  
其中三个需要设置的内容分别是：  
* javah程序路径：`$JDKPath$/bin/javah`，这个跟jdk安装的路径有关。  
* 命令行参数：`-classpath . -jni -d $ModuleFileDir$/src/main/jni $FileClass$`，主要指定输出路径。
* 工作目录：`$ModuleFileDir$/src/main/Java`，当前项目路径。  


至此Android Studio的主要设置就完成了，当然只是最基本必须的设置，如果自己还有其它需求，类似git仓库地址等，可以再自行设置。  
下面就可以开始进行项目的开发。  

#### 先准备一个基本的Android程序
在Android Studio界面选择New Project，如果是在开始界面，直接点击主界面上的按钮；也可以在文件菜单中选择。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/new-project.png)  
选择基本的Empty Activity就好。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/config-project.png)  
接着是项目的设置，项目名称、存储位置这些都不用说了，最低的API版本决定了你的程序可以在最低什么版本的Android手机上执行，如果没有特殊需要，尽量可以低一点，毕竟Android手机的升级比例，比iOS是低了好多倍的。  
这样，项目就建立完成，Android Studio使用标准模板，对项目做了初始化。我们可以在这个基础上再添加自己的内容。  

从屏幕左侧项目文件的列表中，选择app -> res -> layout -> acitvity_main.xml文件，文件会在右侧打开，模式是交互式的界面设计器。在其中，按照下图的样子，我们增加一个TextView控件和一个按钮。文本框是为了将来显示输出的结果，按钮当然就是开始执行的触发器。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/layout_setting.png)  
TextView控件我们修改一下名字，叫textView1。按钮的名字改为button1，另外为按钮的onClick属性增添一个调用：bt1_click。  
界面部分就完成了，记着存盘，然后可以关掉这个文件。  

这时候，Android Studio界面会显示在MainActivity.java文件的位置。这是新建项目之后自动打开的文件，也是这个项目的主窗口程序文件。我们首先编辑窗口布局文件的时候，这个文件被隐藏在了后面。  
我们在文件的库引用部分，增加如下两行：  
```java 
import android.widget.TextView;
import android.view.View;
```
这两行是我们接下来的程序会使用到的库引用。  
在类的变量声明部分，增加这样两行：  
```java
    TextView textview1;
    int c=0;
```
第一行是声明一个文本框，用于关联到刚才界面编辑器中加入的文本框。  
c变量就是一个简单的计数器，我们希望每点击一次按钮，这个计数器累加1，从而确认我们每次点击都被响应了，而不是程序没有任何反馈给用户。  
在`onCreate`函数的最后，增加关联文本框的代码：  
```java
        textview1=(TextView)findViewById(R.id.textView1);
```
R.id.后面的textView1就是我们在界面编辑的时候，为文本框起的名字。  
接着，在类的最后，增加按钮点击响应的处理函数：  
```java
    public void bt1_click(View view){
        c = c+1;
        textview1.setText("click:"+c);
    }
```
清晰起见，我们把这部分完成的代码再抄过来一遍：  
```java
package com.test.calljni;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;
import android.view.View;

public class MainActivity extends AppCompatActivity {

    TextView textview1;
    int c=0;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        textview1=(TextView)findViewById(R.id.textView1);
    }
    public void bt1_click(View view){
        c = c+1;
        textview1.setText("click:"+c);
    }
}
```
程序完成，可以从Build菜单选择Make Project编译项目。然后在Run菜单选择Run 'app'。  
如果是第一次使用Android Studio，你还可能会被提醒需要你新建一个Android模拟器来执行程序。当然也可以把打开了调试功能的Android手机插在电脑上进行真机调试。  
执行的结果如图：  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/base_run1.png)  
点击两次按钮后，画面变为：  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/base_run2.png)  
好了，我们的基本实验平台准备完成，下面才是进入正题。  

#### 调用JNI库
每个JNI库都分为两部分，一个是C++编写的.so动态链接库，另一部分则是Java对这个动态链接库的封装。我们先从Java部分看起。  

##### 编写JNI库的Java封装类
开始写这个JNI库之前，我们首先要对这个库的总体功能、结构划分、接口类型充分做好规划，这样才能保证两种语言之间的顺畅调用。因为尚没有一种工具可以同时有效的对两种语言进行跟踪调试，所以在接口部分如果碰到问题，往往只能在大量的日志输出中去查找线索，费时费力。  
作为一个简单的演示，我们的JNI库功能很简单，从Java封装的角度看，我们有一个名为JniLib的Java类，其中包含一个方法，叫callToCpp，这个方法，将会在C++中来实现。  
在文件列表中，选择MainActivity.java所在的包名，点击右键，选择New->Java Class。  
一切选用默认设置，类名为JniLib。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/new-java-class.png)  
Android Studio会自动生成并打开一个JniLib.java文件。其中只有一个而空白的类定义。我们在其中继续编写自己的内容。  
这个封装类的代码非常简单，我们直接列出全部：  
```java
package com.test.calljni;

public class JniLib {
    static {
        System.loadLibrary("JniLib");
    }

    public static native String callToCpp();
}
```
其中的静态部分，相当于构造函数了，直接载入一个动态链接库，名称为“JniLib”。这个是对于Java来说的库名，实际对应的文件名将是libJniLib.so。就是说，Android在载入动态链接库的时候，自动在给定的链接库名称前面添加“lib”，后面添加“.so”后缀。这个我们在后面还会更直观的展示。  
接着是声明一个native类型的函数，callToCpp()，native表示这个函数将在刚刚载入的libJniLib.so中实现，也就是将由C++来实现。  

##### 由封装类生成C++头文件
下面是利用这个JniLib类，生成C++使用的.h头文件。  
在Android Studio界面的左侧列表中，用鼠标右键点击JniLib文件，弹出菜单中选择External Tools -> javah，这个javah就是我们前面建立的附加工具。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/external-tools-javah.png)  
此时最好将Android Studio左侧的视图从默认的“Android”方式修改到“Project”方式，这样能更清晰的看到目录层次关系。  
随后左侧列表中，跟Java文件夹同级，会出现一个jni文件夹，其中有一个文件：com_test_calljni_JniLib.h，这就是刚才由javah自动生成的。  
头文件生成到src/main/jni目录，这是我们在javah扩展工具设定的时候所确定下来的。  
在列表中双击com_test_calljni_JniLib.h文件打开，其内容为：  
```c
/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>
/* Header for class com_test_calljni_JniLib */

#ifndef _Included_com_test_calljni_JniLib
#define _Included_com_test_calljni_JniLib
#ifdef __cplusplus
extern "C" {
#endif
/*
 * Class:     com_test_calljni_JniLib
 * Method:    callToCpp
 * Signature: ()Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_test_calljni_JniLib_callToCpp
  (JNIEnv *, jclass);

#ifdef __cplusplus
}
#endif
#endif
```
Java_com_test_calljni_JniLib_callToCpp函数定义这一行，对应就是我们在Java JniLib类中所声明的callToCpp方法。整个函数名中包含了封装语言Java/Java包名com.test.calljni/类名JniLib/方法名callToCpp几个部分。  
请注意文件第一行的提醒信息，这个头文件的内容不要自行修改，如果修改Java封装文件JniLib.java导致了类名、函数名的变化，应当重复上一步，使用javah工具重新完整生成头文件。  

##### C++实现JNI库
继续用C++编写我们的函数实现。用鼠标右键点击列表中的jni文件夹，新建一个c++源文件，名称定为JniLib.cpp。  
内容如下：  
```cpp
#include "com_test_calljni_JniLib.h"

JNIEXPORT jstring JNICALL Java_com_test_calljni_JniLib_callToCpp
  (JNIEnv *env, jclass){
    return (*env).NewStringUTF("从cpp返回的文本。");
  };
```
c++代码中，首先是引用刚才由javah生成的头文件，这是为了保证c++中定义的函数，严格吻合Java封装类中所指定的类型。  
函数的定义比较长，可以从.h文件中直接拷贝进来。因为JNIEnv参数我们会用到，所以我们在后面添加一个具体的变量名，这里用“env”。  
函数中只有一条语句，就是返回一个文本字符串，使用JNI中提供的NewStringUTF函数把这个C++的字符串转换为一个Java的String对象。  

#### NDK编译脚本
使用NDK系统编译JNI库，还需要有两个文件，都将位于src/main/jni文件夹中，一个是Application.mk文件，内容只有一行：  
```bash
APP_ABI := all
```
ABI是应用程序二进制接口的缩写，指的是Android主机的CPU类型，不同CPU需要有不同的二进制接口类型。  
Java是一种跨CPU的语言，并不要求指定特定的CPU。而C/C++语言，在不同的CPU上，都需要进行特定的编译。  
这里设定APP_ABI为all，指的是我们写的这个JniLib库，将接受所有NDK支持的CPU类型。NDK在编译的时候，会自动编译多个不同CPU需要的动态链接库。并都打包在最终的APK文件中。  
在不同的Android系统安装的时候，会自动选择正确的CPU类型安装其中一种。  

接着看第二个NDK编译所需文件，Android.mk： 
```bash
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := JniLib
LOCAL_SRC_FILES := JniLib.cpp
include $(BUILD_SHARED_LIBRARY)
```
用过Makefile的人应当看上去感觉很熟悉。这个就相当于Makefile的主文件，用于描述如何编译我们的JNI库。当然因为我们其中大量的使用了NDK已有的环境变量和脚本，所以Applcation.mk/Android.mk实际都将被NDK的主体Makefile调用，最终完成完整的编译。  
其中LOCAL_MODULE变量所指定的名称，就是我们编译之后的模块名称，这个跟JniLib.java中加载的类名，必须是一致的。  

##### Gradle自动编译NDK项目
有了这些，如果用过命令行的话，我们可以直接在命令行对JNI部分进行编译了。  
但作为一个完整的程序，我们更希望JNI部分，也能在整体Android Studio项目编译的时候编译，并一起打包进APK。  
所以我们修改一下本项目的Gradle脚本，增加NDK编译的配置。Gradle是Android Studio中所采用的开源工具，用于项目的管理和自动构建。  
在Android Studio左侧列表中找到app/build.gradle文件，双击打开。在项目的主目录下还有一个build.gradle文件，不要误选到那一个。  
在android一节中，defaultConfig之下、buildTypes之上增加如下代码：  
```java
    externalNativeBuild {
        ndkBuild {
            path "src/main/jni/Android.mk"
        }
    }
```
表示本项目使用ndk编译JNI库，本项目JNI库的编译脚本为src/main/jni/Android.mk文件。还可以选择使用CMAKE系统来编译JNI项目，不过为了不扩展太大的话题，这里就不讲了。对CMAKE情有独钟的开发者可以搜索相关资料。  
为了能看的清楚，贴一次完整的app/build.gradle文件:  
```java
apply plugin: 'com.android.application'

android {
    compileSdkVersion 28
    defaultConfig {
        applicationId "com.test.calljni"
        minSdkVersion 19
        targetSdkVersion 28
        versionCode 1
        versionName "1.0"
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
    }
    externalNativeBuild {
        ndkBuild {
            path "src/main/jni/Android.mk"
        }
    }
    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    implementation 'com.android.support:appcompat-v7:28.0.0'
    implementation 'com.android.support.constraint:constraint-layout:1.1.3'
    testImplementation 'junit:junit:4.12'
    androidTestImplementation 'com.android.support.test:runner:1.0.2'
    androidTestImplementation 'com.android.support.test.espresso:espresso-core:3.0.2'
}
```
至此，JNI部分的完整定义就完成了。  

##### 在Java中调用JNI库
JNI库的效果，还要修改一下我们程序的MainActivity类，才能体现出来。不然JNI库会被编译，会被打包，但并没有什么用。  
首先修改项目的布局文件activity_main.xml文件，在当前按钮的右边，再增加一个按钮，名称为button2，onClick设置为bt2_click，顺便也为按钮设置一个新的显示字符串“CALLJNI”。修改完成存盘，关闭文件。  
这个小例子重点是说明同C/C++语言的混合编程，所以很多细节都从简了，比如刚才按钮的显示信息，都应当是定义在资源文件中的，而不是在这里直接使用常量字符串。常量字符串虽然简便，但无法完成多国语言自动切换等基本功能，在正式的项目中应当避免这样使用。  
接着在MainActivity.java文件中，增加点击事件处理程序，添加在bt1_click定义的下面就成：  
```java
    public void bt2_click(View view){
        c = c+1;
        textview1.setText("click:"+c+"\n"+JniLib.callToCpp());
    }
```
现在可以完整的编译一遍了，如果没有错误发生，就在模拟器中执行来测试。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/second_run1.png)  
点击CALLJNI按钮后，文本框显示的信息表示JNI正常执行了。  

##### 解析包含JNI库的APK安装文件
先上一张apk包的文件结构图片吧：  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/apk-structure1.png)  
包含JNI库的安装包，比平常的安装包多一个lib文件夹。其中按照支持的CPU类型，再细致分类。最终里面是JNI库的二进制文件。  
在我们这个例子中，就是libJniLib.so，如同前面说过的。  
APK包安装的时候，根据确定的硬件平台，实际只有一个对应的.so文件会被安装的设备上。  

#### 调用一个完整的命令行可执行文件
调用完整的可执行文件，这在Android中并不是官方推荐的。但通常基于Linux系统的编程，这又是不可避免的。很多必要操作，如果开发系统的SDK支持不足，或者用起来不方便。都可以通过直接访问系统层参数文件或者系统层可执行文件来完成。  
不同的操作系统，有不同的可执行文件格式。比如Windows的EXE/PE格式，macOS的Mach-O。在Linux上，就是ELF格式。  
作为C语言为主要编程工具的Linux系统，拥有庞大的ELF可执行资源，几乎所有的程序都是直接、或者间接由ELF可执行程序完成的，甚至包括JVM本身。  
一些新兴语言，比如golang，也提供了直接生成Android二进制文件的交叉编译功能。  
所以让Android程序直接可以同ELF可执行程序互动，不仅仅是同C语言混合编程的问题，而是这样可以获得大量社区资源的支持。很多开源项目拿来，很少的修改，就可以在Android程序的背后发挥作用。  

早期的Android系统调用可执行程序非常容易，把编译好的程序拷贝到Android中，设置为可执行属性，就可以执行了。  
随着Android系统的升级，安全性越来越好，除非root，上面这种方式已经不灵了。越来越多的限制让直接执行内嵌的可执行文件变得不再可行。  

在当前的Android版本中，在APK程序中内嵌可执行文件，需要通过以下几个步骤：  
* 在NDK中编译对应的源代码。或者在其它语言环境中，使用对应工具，生成在Android环境可以执行的二进制代码。  
* 除了.so之外的编译结果，并不会自动打包到APK中。所以编译出的二进制代码，需要作为数据文件，放入APK的资源区。  
* 在Java代码中，根据检测到的CPU类型，把对应的可执行文件，从数据区拷贝到Android设备上，并设置为可执行。  
* 在Java代码中调用可执行程序，并获取结果。  

##### 编译可执行文件
首先当然是准备一个C/C++代码，比如我们用一个最经典的Hello World。这么多年以来，这居然是兼容性最好的代码了:)  
```c
#include<stdio.h>

int main(int argc, char **argv){
    printf("你好世界, I'm hello.c\n");
    return 0;
}
```
文件名叫hello.c，放到jni文件夹下面。  

然后配置Android.mk文件，以编译这个代码。  
把下面的代码放置到Android.mk的最后：  
```bash

include $(CLEAR_VARS)
LOCAL_MODULE := hello
LOCAL_SRC_FILES := hello.c
include $(BUILD_EXECUTABLE)
```
仔细看，其实只有最后一行有区别，根据英文应当能理解含义，就是编译为可执行文件的意思。  

##### 编译结果打包进入APK
因为内置可执行文件并不是官方推荐的方式，所以编译的结果，并不会被自动打包到安装包APK。  
经由Gradle调用ndk-build编译的结果保存在如下的路径：  
```bash
# Debug版本
app/build/intermediates/ndkBuild/debug/obj/local/
# Release版本
app/build/intermediates/ndkBuild/release/obj/local/
```
同样在Gradle的设置中，可以指定把具体的内容打包到Android的assets文件夹中。assets文件夹中包含的是程序运行所需的资源文件，所以这里，也是把可执行文件，当做资源、数据文件，嵌入在APK中。  
请把下面代码，放置到app/build.gradle文件，android.defaultConfig一节的最后：  
```java
        sourceSets{
            main{
                assets{
                    srcDirs = ['build/intermediates/ndkBuild/debug/obj/local']
                }
            }
        }
```
sourceSets.main.assets.srcDirs的设置实际是一个数组，可以包含多个路径。如果开发的项目还有别的数据文件需要打包，可以在这里增添自己的内容。  
注意上面示例中设置中的路径，是个不完美的地方。当前指向了debug调试编译输出的结果。在开发完成，正式投产的时候，应当换到release输出结果，也即：`build/intermediates/ndkBuild/release/obj/local`。不然包含的二进制文件中间会有调试信息，除了文件尺寸会大，也造成不安全因素。  
其实我个人常用的方式，是直接用Release方式编译一遍整个项目，然后release文件夹中就会有二进制编译结果。随后Gradle的设置，就一直保持在release版本的打包。反正你也不可能用Android Studio对C/C++代码进行调试，那个工作你肯定是使用另外的开发工具完成的。  

然后事情并没有结束，我们打开编译结果的文件夹看一看，是类似下面的样子：  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/compile-rs1.png)  
其中同样会根据CPU类型不同，分为几个文件夹，这是预料之中的。但中间除了有我们需要的hello可执行文件，还会有本已打包的JNI库.so文件，以及一些编译输出信息和中间文件。而这些，就成为了我们的垃圾文件，需要排除在外。  
可以把下面代码，添加在app/build.gradle中，externalNativeBuild上面的位置，跟externalNativeBuild处在同一级：  
```bash
    aaptOptions {
        ignoreAssetsPattern '!*.txt:!*.so:!*debug:!*release:!*.a'
    }
```
这里要吐槽一下Android Studio Gradle脚本的设计。通常讲，ignoreAssetsPattern关键词已经有了“忽略、排除”的含义，是个否定词。而在其中的设置中，又对每个需要排除的内容，前面增加“!”否定，实在是反人类啊......  

现在如果编译一遍，看看打包的结果，当然也只是完成了打包，我们还没有执行这个程序。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/apk-structure2.png)  
APK中多了一个assets文件夹，其中根据CPU类型分类，hello已经在里面了。  

##### 把可执行程序拷贝到Android系统
这个工作是最复杂的部分，至少比我们演示中显示一个字符串复杂多了。  
好在这个程序非常通用，把这个类留着，以后所有同类程序都可以直接拿来使用。  
在java文件夹自己的包名上右键点击鼠标，增加一个Java类，命名为CopyElfs。在生成的java文件中，把下面的代码帖进去：  
```java
package com.test.calljni;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import android.os.Build;

public class CopyElfs {
    String TAG="Ce_Debug:";
    Context ct;
    String appFileDirectory,executableFilePath;
    AssetManager assetManager;
    List resList;
    String cpuType;
    String[] assetsFiles={
            "hello"
    };

    CopyElfs(Context c){
        ct=c;
        appFileDirectory = ct.getFilesDir().getPath();
        executableFilePath = appFileDirectory + "/executable";

        // cpuType = Build.SUPPORTED_ABIS[0];
        cpuType = Build.CPU_ABI;
        assetManager = ct.getAssets();
        try {
            resList = Arrays.asList(ct.getAssets().list(cpuType+"/"));
            Log.d(TAG,"get assets list:"+resList.toString());
        } catch (IOException e){
            Log.e(TAG, "Error list assets folder:", e);
        }
    }
    boolean resFileExist(String filename){
        File f=new File(executableFilePath+"/"+filename);
        if (f.exists())
            return true;
        return false;
    }
    void copyFile(InputStream in, OutputStream out){
        try {
            byte[] buf = new byte[1024];
            int len;
            while ((len = in.read(buf)) > 0) {
                out.write(buf, 0, len);
            }
        } catch (IOException e){
            Log.e(TAG, "Failed to read/write asset file: ", e);
        }
    };
    private void copyAssets(String filename) {
        InputStream in = null;
        OutputStream out = null;
        Log.d(TAG, "Attempting to copy this file: " + filename);

        try {
            in = assetManager.open(cpuType+"/"+filename);
            File outFile = new File(executableFilePath, filename);
            out = new FileOutputStream(outFile);
            copyFile(in, out);
            in.close();
            in = null;
            out.flush();
            out.close();
            out = null;
        } catch(IOException e) {
            Log.e(TAG, "Failed to copy asset file: " + filename, e);
        }
        Log.d(TAG, "Copy success: " + filename);
    }
    void copyAll2Data(){
        int i;

        File folder=new File(executableFilePath);
        if (!folder.exists()){
            folder.mkdir();
        }

        for(i=0;i<assetsFiles.length;i++){
            if (!resFileExist(assetsFiles[i])){
                copyAssets(assetsFiles[i]);
                File execFile = new File(executableFilePath+"/"+assetsFiles[i]);
                execFile.setExecutable(true);
            }
        }
    }

    String getExecutableFilePath(){
        return executableFilePath;
    }
}
```
类成员assetsFiles数组中，可以包含多个可执行文件，把文件名放在这里，就会被拷贝到Android设备的/data/data/包名/files/excutable/文件夹，并设置为可以执行。  
接着在MainActivity类的onCreate成员中，增加对拷贝可执行文件功能的调用：  
```java
    CopyElfs ce;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        textview1=(TextView)findViewById(R.id.textView1);

        ce = new CopyElfs(getBaseContext());
        ce.copyAll2Data();
    }
```

##### 执行对Elf执行文件的调用
做了这么多准备性工作，开始真正对程序的调用。  
首先还是修改布局文件，再增加一个按钮，名称叫button3，显示字符串是“CALLELF”，onClick的事件处理函数是bt3_click。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/layout1.png)  
这次要添加的代码不仅仅是bt3_click方法，还要对调用命令行程序以及获取其结果单独抽象为一个方法。  
考虑到还要增加一些对应的类成员变量，和库文件的引用。我们把完整的MainActivity.java代码列出来：  
```java
package com.test.calljni;

import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;
import android.view.View;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import android.util.Log;

public class MainActivity extends AppCompatActivity {
    String TAG="Main_Debug:";
    TextView textview1;
    int c=0;
    CopyElfs ce;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        textview1=(TextView)findViewById(R.id.textView1);

        ce = new CopyElfs(getBaseContext());
        ce.copyAll2Data();
    }
    public void bt1_click(View view){
        c = c+1;
        textview1.setText("click:"+c);
    }
    public void bt2_click(View view){
        c = c+1;
        textview1.setText("click:"+c+"\n"+JniLib.callToCpp());
    }
    public String callElf(String cmd){
        Process p;
        String tmpText;
        String execResult = "";

        try {
            p = Runtime.getRuntime().exec(ce.getExecutableFilePath() + "/"+cmd);
            BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
            while ((tmpText = br.readLine()) != null) {
                execResult += tmpText+"\n";
            }
        }catch (IOException e){
            Log.i(TAG,e.toString());
        }
        return execResult;
    }

    public void bt3_click(View view){
        c = c+1;
        textview1.setText("click:"+c+"\n"+callElf("hello"));
    }
}
```
现在已经完整了，可以编译然后在模拟器执行来尝试一下。  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/3_run1.png)  

还可以详细探究可执行文件，拷贝到Android设备之后的细节。这个使用adb工具连接到设备上就能看出来，请看下面执行的截图：  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/cmd1.png)  

#### 编译带有扩展库的可执行文件
前面的例子，我们已经认识到了NDK的强大。而ndk-build编译工具，基本属于一个Makefile的工作方式。  
然而在Linux庞大的开源社区中，多种编译管理工具都同时存在。其实不仅仅Android，即便在桌面版的Linux版本中，编译不同的软件包，也是一件费时费力的事情。  
因此想继承开源社区的庞大优势，除了上面讲到的这些必要工作，把软件包编译到Android的环境中，是最主要需要完成的工作。  
这个话题太大，内容太多也太分散，我们的文章是远远无法涵盖的。以最常用的OpenSSL开源库为例，GitHub上有一个编译脚本，值得参考：  
<https://github.com/lllkey/android-openssl-build>  

我们下面只演示一下，在自己的程序中，调用openssl库的方式。实际在Android SDK以及Java标准库中，都已经有很多编、解码功能足以满足应用。所以这里只是用于演示操作的方法，正式开发中，要根据实际需要选择开源库来使用。  
首先我们把上面编译好的openssl库下载到本地，放到跟当前的Android项目平级就好，其实路径随意自己定，只要在接下来的设置中，指到正确的路径就没有问题。  
```bash
$ git clone https://github.com/lllkey/android-openssl-build.git
```
因为这个开源库并非我们项目的一部分，我们只把它的编译结果，链接到我们的项目中：  
```bash
$ cd calljni/app/src/main/jni
$ ln -s /home/andrew/dev/android/android-openssl-build/result/ openssl
#注意上面的路径，应当是你clone下来的真实路径
$ ls -lh openssl/
total 0
drwxr-xr-x  4 andrew  staff   136B Jun  4 08:48 arm64-v8a
drwxr-xr-x  4 andrew  staff   136B Jun  4 08:48 armeabi-v7a
drwxr-xr-x  4 andrew  staff   136B Jun  4 08:48 x86
drwxr-xr-x  4 andrew  staff   136B Jun  4 08:48 x86_64
```
下面我们写一个小程序，用于调用openssl库中的md5编码功能，程序名为md5.c，放置在jni路径下面:  
```c
#include <stdio.h>
#include <string.h>
#include <openssl/md5.h>

void openssl_md5(const char *data, int size, char *rs){
    unsigned char buf[16];

    memset(buf,0,16);

    MD5_CTX c;
    MD5_Init(&c);
    MD5_Update(&c,data,size);
    MD5_Final(buf,&c);

    char tmp[3];
    strcpy(rs,"");
    int i;
    for (i = 0; i < 16; i++){
        sprintf(tmp,"%02x",buf[i]);
        strcat(rs,tmp);
    }
}

int main(int argc, char **argv){
    if (argc != 2){
        printf("Wrong argument.\n");
        return 1;
    }
    char md5str[33];
    openssl_md5(argv[1],strlen(argv[1]),md5str);
    printf("%s\n",md5str);
    return 0;
}
```
然后是修改Android.mk编译脚本，这次增加的是三部分。两个是已经编译完成的openssl Android版本库；一个是我们新增的md5.c编译。编译时还要满足，根据不同的CPU类型，选择不同的openssl库，并且编译对应的CPU版本md5可执行文件。这个过程中，需要使用不同的预定义环境参量来完成这个工作：  
```bash
include $(CLEAR_VARS)
LOCAL_MODULE    := ssl
LOCAL_SRC_FILES := $(LOCAL_PATH)/openssl/$(TARGET_ARCH_ABI)/lib/libssl.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE    := crypto
LOCAL_SRC_FILES := $(LOCAL_PATH)/openssl/$(TARGET_ARCH_ABI)/lib/libcrypto.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SHARED_LIBRARIES := \
	ssl \
	crypto
LOCAL_C_INCLUDES += $(LOCAL_PATH)/openssl/$(TARGET_ARCH_ABI)/include
LOCAL_MODULE := md5
LOCAL_SRC_FILES := md5.c
include $(BUILD_EXECUTABLE)
```
上面的代码中：  
* $(PREBUILT_STATIC_LIBRARY)指定了预定义的静态库文件
* $(LOCAL_PATH)就是指jni文件夹路径
* $(TARGET_ARCH_ABI)是根据目标CPU的ABI不同，选择不同的库文件和C语言头文件。  

想必你也想到了，还要在MainActivity.java中，增加调用md5的代码，当然还有layout文件：  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/layout2.png)  
按键响应代码：  
```java
    public void bt4_click(View view){
        c = c+1;
        textview1.setText("click:"+c+"\n"+callElf("md5 testString"));
    }
```
作为md5参数的字符串，在正式的程序中，肯定应当是从某些计算中获取，或者从屏幕的输入框读取。这里直接使用一个常量“testString”。  
最后还有特别容易忘的一个地方，就是CopyElfs中可执行文件的列表：  
```java
    String[] assetsFiles={
            "hello","md5"
    };
```
不得不承认，有了上一小节的基础，增加个可执行程序或者第三方库，都不算什么工作量。  
程序的执行结果如下：  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201906/android_jni/4_run1.png)  
还可以在台式电脑中验证一下计算的结果：  
```bash
$ echo -n "testString" | md5
536788f4dbdffeecfbb8f350a941eea3
```

##### 使用第三方库的其它注意事项
md5程序，使用了openssl的静态链接库.a文件。在Android4之后的版本中，如果不做root，似乎暂时没有好办法使用.so动态链接库。  
JNI则可以使用.so文件，这时候在Android.mk中，应当使用$(PREBUILT_SHARED_LIBRARY)参量，来说明一个.so的预定义动态链接库。  
使用了第三方的动态链接库，在调用JNI的时候也有额外一点需要注意，就是在载入自己的JNI库之前，必须把用到的依赖库，首先载入进来，否则直接载入JNI库会报错：  
```java
public class JniLib {
    static {
        System.loadLibrary("crypto");
        System.loadLibrary("ssl");
        System.loadLibrary("JniLib");
    }
    .......
```
