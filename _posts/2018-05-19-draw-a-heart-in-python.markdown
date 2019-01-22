---
layout:         page
title:          就算会用python画颗心，可你依然还是只单身狗
subtitle:      	Draw a heart in python
card-image:		http://files.17study.com.cn/201805/19/heart1.png
date:           2018-05-19
tags:           python seven
post-card-type: image
---
![](http://files.17study.com.cn/201805/19/heart1.png)  
<script src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.2/MathJax.js?config=TeX-MML-AM_CHTML'></script>
:) 标题是开玩笑的，千万别认真。

随着AI的飞速发展，有志于此行的码农也是急剧的增加，带来的就是大家对算法、数学的兴趣也格外升高。  
本文的来历是这样，今天某老同事在朋友圈发了一张屏拍，求公式。  
![](http://files.17study.com.cn/201805/19/heart0.jpeg)  
看了一下还是难度不大，上半部分基本是两个半圆，下半部分是两个旋转了的反余弦函数。  
不过我的数学也比较渣，看到这个步骤后面也就倒腾不清了，不过到这种程度在互联网上搜一搜找到答案还是不难的，很快就找到了正确的公式(以y=0为界限，肯定是需要两组解)：  
<p>
$$ y = \sqrt{1-(\left| x \right|-1)^2}, arccos(1-\left| x \right|)-\pi $$  
</p>
否则只是搜心形函数，肯定会得到一大票各式各样，但不吻合题意的图片，比如：  
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1526750623357&di=8b18bef5ed15eb5c28180013e1b09c56&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201406%2F16%2F20140616214851_JsMwt.jpeg)

验证这个公式用mathmatica最方便，不过刚换了电脑，刚好没装。  

最近在做python3方面的事情，5分钟用python3写了一个验证程式，源码附上：  
```python
#!/usr/bin/env python3

import matplotlib.pyplot as plt
import numpy as np


x = np.linspace(-2, 2, 200) 
y1 = np.sqrt(1-np.square(np.fabs(x)-1))
y2 = np.arccos(1-np.fabs(x))-np.pi

plt.plot(x, y1, 'r',x,y2,'r') 
plt.axis([-2.5, 2.5, -3.5, 1.5])

plt.title('Heart of numbers, By @andrew', fontsize=16)

plt.show()
```
绘制的结果就是题头图。  
程序用到了matplotlib和numpy两个库，运行前需要先用pip3安装一下。  
#### 参考资料
<https://www.quora.com/What-is-the-equation-that-gives-you-a-heart-on-the-graph>
