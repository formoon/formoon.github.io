---
layout:         page
title:          Grapher--寂寞无名的神器
subtitle:      	Draw a heart in Grapher
card-image:		https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201805/19/heart1.png
date:           2018-05-28
tags:           mac
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201805/19/heart1.png)  
<script src='https://cdn.bootcdn.net/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML'></script>
承自上一篇中的函数图形，有人问，能不能别把画个图搞那么复杂，我说当然，只要你有一台mac。  
话说出来很潇洒的样子，充斥着一股迷之自信。  

可能这就是mac用户典型的特征，尽管也许并没有那么值得骄傲。  
其实在上一篇中我见到照片的时候就看出来用的是什么软件了，mac内置的grapher。grapher的诞生还有一段荡气回肠的“硅谷往事”，是一个令我汗颜而又激励我努力的故事。故事英文原文请看：<http://www.PacificT.com/Story/>，中文译文的网址打不开了，这里有个转载：<https://blog.csdn.net/pkuaku/article/details/5828424>  
其实就是这样一个个生动而又如同就在身边的故事，累计在一起，造就了mac的不同吧。  

跟Grapher比起来，Python的兼容性和普及度无疑会更好，所以上一篇中我给出了用Python绘制心形的方法。使用Python，不管是mac/Linux亦或Win,都能很顺畅的绘制出函数图形。  
但是如果说操作简单、效果直观，Grapher出山，无人敢领其锋。至于我上篇中说到的mathmatica，那是很贵的好不好？  
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201805/28/heartofgrapher.png)  

Grapher打开，选择2D/Default模式，就可以在界面上输入公式了。公式的输入大致有以下几种情况：  
* 通常的符号可以直接输入，类似y=。  
* 根号、分数、π符号等，点界面最右侧的“西格玛”符号，进去有很多预定义的结构，可以选中之后直接输入。  
* 绝对值直接使用竖线`|`符号，会自动出来两个，在中间输入绝对值中间的内容。
* arccos这样的，是预定义的函数，可以直接输入。
* 上标（乘方）可以使用^符号后输入。
* 下标，比如西格玛函数的下标，可以使用下划线_之后输入。  

基本上知道这些就可以输入公式了。注意输入公式的过程中，全部要使用西文、半角字符，这样输入完成后，Grapher才能自动进行运算，并绘制出图形。  
心形图像分成上下两部分，有两个y=f(x)公式，在Grapher中可以输入两个公式，然后在左侧公式列表中全部勾选上公式前面的选中框，两部分函数图形就可以同屏显示了。  

除了进行函数计算、图形计算，所输入的公式也可以直接拷贝出来，粘贴到keynote/pages文档里面，因为是矢量图形，放大多少也不会造成锯齿和失真。  

