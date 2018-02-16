---
layout:         page
title:          CrossOver和wine
subtitle:       瓶子中的windows
card-image:     https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=537752898,3886757865&fm=15&gp=0.jpg
date:           2018-02-16
tags:           mac linux
post-card-type: image
---
不同于Docker和虚拟机，诞生于Windows尚且一家独大的年代,wine是一个在Linux/Mac上面运行Windows应用的选择。  
当然从诞生开始，对wine的诟病就不曾中断，主要来自于较低的运行效率和不良的兼容性。  
事实上,wine是一个天才的项目和被严重低估的产品。  

在官网的说明中，wine是“Wine Is Not an Emulator” 的递归缩写。其实这已经把wine的出身说的很清楚了，不过仍然有很多人质疑认为”非模拟器“的解释不过是一种娱乐性的说法。  
如果真要从技术的对比上，wine要更类似于cygwin这样的产品，后者是在windows的环境中，编写一个可以运行Linux的底层，从而在windows的环境中实现了一个在应用层运行的linux环境。  
wine则是反过来，在POSIX兼容系统中，编写了一个windows的底层环境，从而在POSIX上运行windows的应用。  
但是因为Windows的复杂度，这个工作艰巨而繁重，很多的应用特别是对显卡等底层要求比较高的应用无法运行。即便能跑起来的一些，也因为兼容层的速度问题，执行效率打了折扣或者软件微小的升级就导致不再兼容。wine的每一个版本更新，几乎都是为了解决一些软件的兼容性问题。  
所以很多下载网站的介绍中，都特别指出“使用wine需要具备较高的技术水平”。  

CrossOver是wine的一个商业版本，对Mac等系统有更好的支持效果，易用性也高了许多。在CrossOver中，每一个Windows的执行环境被称为Bottle，通常是首先安装类似[Visual C++ 6 run time library](https://www.microsoft.com/en-us/download/details.aspx?id=9183)这样的执行环境，然后就可以运行其上的Windows应用。对中文的支持仍然不太理想，但后台服务类（类似linux的命令行类）程序几乎兼容的都还不错。  

在这种情况下，你会感觉到wine和CrossOver的优点，不需要庞大的虚拟机环境和内存等资源限制，几乎如同Mac/Linux本身的应用一样，很小的代价就完成了Windows应用的执行。启动和关闭的速度更是将虚机远远抛在了脑后。  
比如在Mac电脑上，可以看一看CrossOver执行之后的进程情况：  
```bash
$ps -fe 
...
  501 60565     1   0  4:40PM ??         0:10.36 /Applications/CrossOver.app/Contents/MacOS/CrossOver
  501 60568 60565   0  4:40PM ??         0:00.04 /Applications/CrossOver.app/Contents/SharedSupport/X11/bin/xpbproxy
  501 60569 60565   0  4:40PM ??         0:00.09 /Applications/CrossOver.app/Contents/SharedSupport/X11/bin/quartz-wm
  501 60570 60564   0  4:40PM ??         0:00.23 winewrapper.exe --run -- /Applications/CrossOver.app/Contents/SharedSupport/CrossOver/lib/wine/sendwndcmd.exe.so -n -e explorer;winewrapper 
  501 60571 60564   0  4:40PM ??         0:00.40 winewrapper.exe --enable-alt-loader macdrv --wait-children --start -- C:/users/crossover/Start Menu/u.lnk 
  501 60573     1   0  4:40PM ??         0:13.42 /Applications/CrossOver.app/Contents/SharedSupport/CrossOver/lib/../bin/wineserver
  501 60577     1   0  4:40PM ??         0:00.13 C:\windows\system32\services.exe 
  501 60579     1   0  4:40PM ??         0:00.09 C:\windows\system32\winedevice.exe 
  501 60581     1   0  4:40PM ??         0:00.08 C:\windows\system32\plugplay.exe 
  501 60583     1   0  4:40PM ??         0:16.85 C:\windows\system32\winedevice.exe 
  501 60585     1   0  4:40PM ??         0:00.31 Z:\Applications\CrossOver.app\Contents\SharedSupport\CrossOver\lib\wine\sendwndcmd.exe.so -n -e explorer;winewrapper 
  501 60587     1   0  4:40PM ??         0:00.71 C:\windows\system32\explorer.exe /desktop 
  501 60591     1   0  4:40PM ??         0:05.49 C:\Program Files\xxx\xxx\xxx.exe -ProgPath=C:\Program Files\xxx\ -TmpPath=C:\Program Files\freedom\xxx\ -ConnMode=0 -version=1704100 
...
```
从这些信息中，可以清楚的看到，wine运行与macOS应用同一层次的用户空间中，Windows应用就好像macOS应用一样在单独的进程中执行，看起来很让人安心。  

