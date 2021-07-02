---
layout:         page
title:          Python2中文处理纪要
subtitle:       遇见乱码不用慌，我来跟你说端详
card-image:     http://blog.17study.com.cn/attachments/201801/python.jpg
date:           2018-01-17
tags:           ml
post-card-type: image
---
python2不是以unicode作为基本代码字符类型，碰到乱码的几率是远远高于python3，但即便如此，相信很多人，也不想随意的迁移到python3，这里就总结几个我平常碰到的问题及解法。  
1. 文件中无法使用中文注释  
处理方法：  
在代码中增加`# -*- coding=UTF-8 -*-`，一般加在文件头部第一行，如果第一行是脚本标志，则放在第二行（实际仍然是python正本的第一行）。  
随后将文件另存为UTF-8格式。  
此方法可以解决注释中有中文，及字符串立即数中包含中文的问题。  

2. unicode中文变量打印出来是乱码  
处理方法：  
文件开始引入扩展库的部分加入以下3行代码。  
```python
import sys
reload(sys)
sys.setdefaultencoding('utf-8')
```

3. utf-8 及 gbk互相转换  
直接看代码：  
```python
#utf-8字符串转换成GBK（GB2312及其它编码也是这样用）
print str.decode('UTF-8').encode('GBK')
#gbk转换成utf-8
print str.decode('GBK').encode('UTF-8')
```

4. 参数中的utf-8是用大写还是小写？  
通常大小写都可以，这不是python决定的，是系统的语言代码设定决定的。  

5. 打开utf-8的文本文件
经过1、2的设置，正常直接打开就可以，文件是什么编码，读出来就是什么编码，个别仍有不行的可以使用扩展库codecs：  
```python
import codecs
...
with codecs.open(poetry_file, "r","utf-8") as f:
```

6. print打印出来的结构中的汉字是乱码  
print仅打印一个utf-8的变量是不会有问题的，比如  
```python
a="汉字"
print a
#会正常显示
```  
但是如果用了接续显示，比如：  
```python
print a,
#将会显示乱码
```
如果是其它结构，诸如dict / list / class等，都会出现乱码。  
```python
a = ["中文"，"测试"]
print a
#将会显示乱码
```
这种情况使用基本库没有什么好办法，只能循环逐个打印内容，比如：  
```python
...
for item in items:
	print item
```
或者整合输出，比如：`print ', '.join(a)`  
还可以使用第三方的包，比如：  
```python
import uniout
...
listnine = ['梨', '橘子', '苹果', '香蕉']
print 'listnine list: %s' % listnine
```

7. 变量本身显示正常，循环遍历出来的单个字符乱码  
大多情况是因为字符串不是unicode编码。声明字符串的时候使用`a = u'汉字'`这样方式赋值的变量都是Unicode字符串，不会有问题。  
如果是从外部传入的变量，源头情况又不知道，可以尝试转换成Unicode字符串：  
```python
str=unicode(str,"utf-8");
```

嗯，差不多就这些，想到再补充。  


