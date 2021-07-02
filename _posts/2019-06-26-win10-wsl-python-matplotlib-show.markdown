---
layout:         page
title:          win10配置linux子系统使用python绘图并显示
subtitle:       WSL使用GUI输出
card-image:		http://blog.17study.com.cn/attachments/201906/wsl-python-gui/python-sin.png
date:           2019-06-26
tags:           html
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201906/wsl-python-gui/python-sin.png)  
默认情况下，Win10的linux子系统(WSL)是只能使用命令行程序的。所有图形界面的程序都无法执行。  

通过为Win10安装XWindows协议的终端应用，可以让Win10成为一台XWindow终端，从而接受Linux的XWindow显示输出。  
这样的终端应用有挺多，[Xming](https://sourceforge.net/projects/xming/)和[VcXsrv](https://sourceforge.net/projects/vcxsrv/)是其中著名的两个。下载安装就可以，我因为一些习惯上的原因使用了后者。  

安装设置都使用默认即可，其中在显示端口设置的位置，默认是-1，表示自动选择，大多数情况是可以工作的。也碰到过不能连通的情况，这时候可以尝试设置成跟你Linux设置相同的端口，比如0。  
![](http://blog.17study.com.cn/attachments/201906/wsl-python-gui/VcXrvSetting.png)  

Linux的环境参数设置可以放在~/.bashrc文件中，只要两行：  
```bash
export DISPLAY=:0.0
export LIBGL_ALWAYS_INDIRECT=1
```
使用的时候先启动XWindow终端程序。启动WSL，比如我用的Ubuntu（WSL已经启动的话，刚修改完配置文件也要重新启动或者重新连接一次以便配置生效），这时候Linux已经可以使用GUI输出了，但默认情况下的安装，是没有任何GUI程序的。可以安装一些小程序测试一下：  
```bash
$ sudo apt install x11-apps
    ...
$ xeyes
```
![](http://blog.17study.com.cn/attachments/201906/wsl-python-gui/xeyes.png)  
这表示整个GUI系统已经正常工作了。  

并不建议在Linux安装桌面系统，我觉得既然已经选择了Windows作为前端，就踏踏实实的用Windows，后端Linux使用命令行才是正路子。安装XWindow只是为了使用Linux的GUI应用输出。桌面系统做文件管理、系统设置之类的操作，长久来看一定是得不偿失的，特别是在技能习惯上。  

Python的绘图库，比如常用的matplotlib，在WSL中会默认使用Agg绘图后端。这是一个哑终端，不做GUI输出，但是可以保存绘制的图形到文件。  
安装XWindow之后，希望使用matplotlib绘图输出，需要另外安装TkAgg库，否则仍然无法绘图显示。  
安装之前先在Python的启动信息中确认一下Python的版本，如果不是3.6或者3.6.x的版本，请对应修改下面安装的软件包。  
```bash
$ sudo apt-get install python3.6-tk
```
之后并不需要重新安装matplotlib库。  
使用我们原来[课程](http://blog.17study.com.cn/2018/12/29/python3-lesson12/)中的绘图示例来看看效果：  
```python
#绘制正弦曲线

#引入数值计算库,改为短名称
import numpy as np
#引入绘图库，改为短名称
import matplotlib.pyplot as plt

#生成一个由-4到4、均分为200个元素的列表
x = np.linspace(-4, 4, 200) 
#计算当x取值范围-4至4时所有的sin函数解
f = np.sin(x)

#绘制
plt.plot(x, f, 'red') 

#将绘制好的图显示出来
plt.show()
```
结果就是题头图了，WSL跟Win10桌面应用和平相处，共创和谐社会。  


