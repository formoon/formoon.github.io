---
layout:         page
title:          在网页显示数学公式
subtitle:       使用latex语法显示数学公式
card-image:     https://www.mathjax.org/badge/mj-logo.svg
date:           2017-12-28
tags:           html
post-card-type: image
---
![](https://www.mathjax.org/badge/mj-logo.svg)
<script src="https://cdn.bootcdn.net/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML"></script>
网页显示数学公式不是一个大问题，问题的关键是要易用、兼容性好。兼容性好有两个评价标准，一个是支持常见浏览器，另外一项则是支持业界文档最常用没有之一的Latex语法。  
这里推荐的MathJax就算不错的选择，官网地址：<https://www.mathjax.org>。使用方法首先引入js库：  
```html
<script src="https://cdn.bootcdn.net/ajax/libs/mathjax/2.7.7/MathJax.js?config=TeX-MML-AM_CHTML"></script>
```
随后网页就可以嵌入一个数学公式试一下：  
```latex
  When \(a \ne 0\), there are two solutions to \(ax^2 + bx + c = 0\) and they are
  $$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$
```
这段文字经过js实时转换后的效果是这样的：  
<p>
  When \(a \ne 0\), there are two solutions to \(ax^2 + bx + c = 0\) and they are
  $$x = {-b \pm \sqrt{b^2-4ac} \over 2a}.$$
</p>  
再比如：  
```letex
\[ J_\alpha(x)=\sum_{m=0}^\infty \frac{(-1)^m}{m!\Gamma(m+\alpha+1)}{\left({\frac{x}{2}}\right)}^{2m+\alpha} \]
```
渲染结果是：  
<p>
\[ J_\alpha(x)=\sum_{m=0}^\infty \frac{(-1)^m}{m!\Gamma(m+\alpha+1)}{\left({\frac{x}{2}}\right)}^{2m+\alpha} \]
</p>  

公式的编辑方法是使用Latex语法，是纯文本字符串。输入完成后，如果是行中插入公式，在公式的两端使用`$ 公式 $`或者`\( 公式 \)`封装起来；如果是独立的公式，则使用`$$ 公式 $$`或者`\[ 公式 \]`把公式封装起来。然后整体填写到HTML页面中，我在这里用同样的方法插入到markdown文件中，效果也是一样的。  
详细的使用方法可以参考官方文档，看英文文档如果有困难的话，这里再推荐一篇中文教程：  
<http://www.360doc.com/content/14/0930/23/9482_413578190.shtml>
