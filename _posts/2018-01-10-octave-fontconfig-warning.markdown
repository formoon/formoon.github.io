---
layout:         page
title:          Octave Fontconfig报错解决
subtitle:       
card-image:     https://www.gnu.org/software/octave/img/example-mesh.svg
date:           2018-01-10
tags:           mac
post-card-type: image
---
mac系统Octave运行一直挺好，今天执行一个程序的时候出现警告信息：  
```bash
Fontconfig warning: ignoring UTF-8: not a valid region tag
```
检查运行情况，发现是程序中的绘图部分没有出来，并且给出了这个警告信息。
Octave的绘图使用gnuplot，从报错提示上看应当是绘图时字体的渲染部分，因为mac上语言代码设置使用了UTF-8不能正常识别导致的问题。  
尝试设置：  
```bash
export LC_CTYPE="en_US.UTF-8"
```
再次执行Octave运行绘图程序警告消失，运行结果正常。

