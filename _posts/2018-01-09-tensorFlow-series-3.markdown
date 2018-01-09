---
layout:         page
title:          从锅炉工到AI专家(3)
subtitle:       TensorFlow实务
card-image:     http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorflowlogo.jpg
date:           2018-01-09
tags:           ml toSeven
post-card-type: image
---
#### 剖析第一个例子
学习《机器学习》，很多IT高手是直接去翻看TensorFlow文档，但碰壁的很多。究其原因，TensorFlow的文档跨度太大了，它首先假设你已经对“机器学习”和人工智能非常熟悉，所有的文档和样例，都是用于帮助你从以前的计算平台迁移至TensorFlow，而并不是一份入门教程。  
所以本文尽力保持一个比较缓慢的节奏和阶梯，希望弥合这种距离。本文定位并非取代TensorFlow文档,而是希望通过对照本文和TensorFlow文档，帮助你更顺利的进入Google的机器学习世界。  
基于这个思路，这一节开始对上一节的例子做一个更详细的讲解。  
```python
import tensorflow as tf
import numpy as np
```
代码一开始，引入了两个python扩展库，第一个是我们的主角tensorflow,第二个是一个数学计算库，numpy。数学计算通常有有两个方向，一个是符号计算，或者叫化简公式；我们这里用到的是另外一个方向，就是数值计算，也就是不管公式多么复杂，最后的结果是不是无限不循环的小数，最终都计算出来具体的数值结果。所以习惯上也称numpy库叫做数值计算库。  
有心人可能想到了，这个库跟前面提到的大计算器“Octave”功能是对应的。这里可以额外举一个使用python配合numpy解前面五元一次方程的例子：  
```python
#!/usr/bin/env python 
# -*- coding=UTF-8 -*-

import numpy as np

#五元一次方程的左边部分的系数，定义为矩阵A
A=np.mat("2,1,1,1,1;1,2,1,1,1;1,1,2,1,1;1,1,1,2,1;1,1,1,1,2")
#方程组右侧的常数，定义为矩阵（向量）B
B=np.mat("6;12;24;48;96")
#使用numpy内置的解方程函数求解
x=np.linalg.solve(A,B)

#打印出来两个矩阵和结果
print "A=\n",A,"\nB=\n",B,"\nsolve=\n",x,"\n"

```
执行后运算结果是这样的：
```bash
> ./solveEqu.py 
A=
[[2 1 1 1 1]
 [1 2 1 1 1]
 [1 1 2 1 1]
 [1 1 1 2 1]
 [1 1 1 1 2]] 
B=
[[ 6]
 [12]
 [24]
 [48]
 [96]] 
solve=
[[-25.]
 [-19.]
 [ -7.]
 [ 17.]
 [ 65.]] 
```
计算结果同Octave是完全相同的。  
其实在IT行业本来解决一个问题就会有很多方法，只看用户喜欢哪种方法和习惯哪种方法。就目前的用户群看，Octave / Mathlab是在理工科学术界普及型的工具。而python则还是IT行业流行度比较高。“机器学习”刚好是一个跨学科的领域。所以，Python + numpy跟Octave / Mathlab的选择，还是交给大家的喜好吧。  
这里的重点是，numpy跟tensorflow如何取舍和配合。
从根本上说,numpy和tensorflow最终都是完成矩阵的数值计算，numpy倾向于打造一个python数值计算器，包络数学计算的各个方面。tensorflow主要是进行机器学习相关的算法实现，比如梯度下降算法就是tensorflow的一部分而numpy则没有。  
在还没有tensorflow的的年代，使用python进行机器学习算法研究的人中，很多是利用numpy这样的工具支持，自行实现各种机器学习算法的。本文省去了“梯度下降法”的具体公式，但是网上有很多详细的资料，评估一下复杂度，利用numpy实现起来，估计也就是半天的工作量。  
从这个角度看起来，numpy和tensorflow就是单纯的互补关系吗？不完全是，主要原因是tensorflow的框架特征。  
tensorflow设计了一种很独特的框架，从源码的注释中应当能看出来，tensorflow的强项在于构建数学模型，复杂的数学模型可能要很多行代码，才能一点点拼接成，这个数学模型在tensorflow中称为图(Graph)。在这个模型构建的过程中，实际上tensorflow并不进行模型的任何计算。一直到最后整个模型构建完全完成，才在session.run()的时候真正的将这张图或者说这个数学模型运行起来。  
这种设计，看上去就好像是在python中增加了一个黑盒，盒子上各种仪表逐一设定，最后打开开关开始运行。这种设计既有利于把研发人员注意力集中到数学模型的设计上，也有利于后端使用c/c++等语言实现高效率的运算，甚至也为使用GPU和可能的集群计算打下了基础。  
把这个模式搞清楚，tensorflow和numpy的分工也就清楚了。所有需要立即计算直接出结果的任务，并且计算量不大、属于数据准备过程中或者交叉验算过程中的任务，可以交给numpy。需要构建机器学习数学模型的任务，都必须使用tensorflow进行。此外由于tensorflow会进行很多遍的循环，所以如果其中可以抽象出来，在外部使用numpy完成少量计算，然后以常量的形式构建在tensorflow中的运算，可以考虑提前使用numpy完成，这样可以提高整体数学模型的效率。  
```python
x = np.float32(np.random.rand(100,1))
y = np.dot(x,0.5) + 0.7
```
这两句就是利用numpy的计算功能“模拟”准备一组房屋面积和价格的数据。在正式的机器学习系统中，这样的数据集一定是提前准备好的，python的功能就是把这些数据集“喂”到tensorflow中去。而在这里因为我们是一个演示性的实验，所处用随机数的方式制备数据，这样的准备工作，就必须利用tensorflow外围的工具包实现。整体看起来，在这个例子中，很有numpy出题、tensorflow解答的意味。  
```python
b = tf.Variable(np.float32(0.3))
a = tf.Variable(np.float32(0.3))
```
在tensorflow中定义两个变量，变量的初始值设置为0.3，这里设置这个值没有特别的意思，相当于随机数。在实际的梯度下降法中，一般都采用函数生成随机数进行初始化或者提前对模型进行数学分析，设置初始值的时候人为避开可能的“局部最优解”，从而得到最优的“机器学习”效果。tensorflow中变量的作用跟所有语言中变量的功能是相同的，用于参与计算和保存计算结果。   
```python
y_value = tf.multiply(x,a) + b
```
用tensorflow构建数学模型的主公式，y_value就相当于前面伪代码描述算法时候的y'。我多嘴一句，这里因为是模型的一部分，必须用tensorflow的内置函数来实现，不可以用numpy的函数。  
此外，numpy和tensorflow属于不同组织出品的两个不同的产品，因此尽管都是用python语言，也有很多重合、同样的功能，但是所采用的保留字和格式并不一定一样。甚至同样的保留字所代表的函数，用法也完全不同，切莫混淆。比如这里`tf.multiply`函数，跟上面`np.dot`函数，从程序功能和数学意义上，是完全相同的两个函数，分属tensorflow和numpy,但是你看保留字的差别非常巨大。  
```python
loss = tf.reduce_mean(tf.square(y_value - y))
optimizer = tf.train.GradientDescentOptimizer(0.5)
train = optimizer.minimize(loss)
```
这三句仍然是tensorflow构建数学模型，但主要属于解方程的部分。构建了代价函数，并使用代价函数和给定的下降梯度值来解方程。作为主要工作模式为黑盒和可拼接的图，tensorflow的语句大多可以串起来写到一条语句里面----尽管这样会降低可读性，但将来读别人的程序，你仍然会见到很多这样的写法。比如上面三条语句跟下面一条语句是等效的：  
```python
train=tf.train.GradientDescentOptimizer(0.5).minimize(tf.reduce_mean(tf.square(y_value - y)))
```
接下来是tensorflow开始运行的部分：
```python
init = tf.global_variables_initializer()
sess = tf.Session()
sess.run(init)
```
在tensorflow内部任何一个开始运行的运算必然要分配一系列的资源，这些资源就从属于一个session。一个模型开始运行前，所有模型中定义的变量都要先初始化。初始化变量本身也是一个任务，需要在所有其它任务开始前首先sess.run()。这就是上面三句代码的含义。  
```python
for step in xrange(0, 200):
    sess.run(train)	
    if step % 5 == 0:
        print step, sess.run(loss),sess.run(a), sess.run(b)
```
进入到了梯度下降求解的执行部分，`sess.run(train)`一条语句其实完成了所有的主要工作，tensorflow黑盒的本质可以看得很清楚了，不管背后有多少复杂的运算，都隐藏在里一个任务执行中。两点需要解释：  
* 在这个例子中，数据集有限，并且算法上不需要不断添加数据集，因此这里没有给tensorflow“喂”数据的过程。这个以后很看到，大多数机器学习的代码，“喂”是循环中主要的工作。  
* 每次sess.run()都会返回tensorflow数学模型中的某个值，可能是函数的返回值，也可能是变量的值，总之都是使用sess.run()反馈回来的。忽略掉返回值就好像是一个调用，但实际都是一回事。

这个例子可以说是机器学习中，最简单的一个实验。但是麻雀虽小，五脏俱全，希望你大致弄清楚了tensorflow的工作模式。  
至此第一个例子源代码部分我们算完整的讲解了一遍，如果感觉已经明白了，建议你跳过下一节直接看第二个例子，否则，下面准备了一些真正基础的内容，相信可以帮你解惑。  
#### TensorFlow基础入门
习惯上学习一种新技术或者新语言，都是从Hello World入门，如果不是“机器学习”的很多概念需要更多篇幅和影响本文的结构的话，我们也是应当从这里开始的，不过我想从这里补上也不晚，毕竟机器学习本身可能更重要。  
好的代码会说话，我们直接列代码在这里。为了节省篇幅，4个相关的基础示例我们放到同一个源码中展示，并加上详细的注释来帮助你理解：  
```python
#!/usr/bin/env python
# -*- coding=UTF-8 -*-

import tensorflow as tf

#----------------------------------------------------
#Hello World 示例
#在tf中定义一个常量
#前一个例子中我们使用了变量
#这里的常量跟通常编程中的常量含义是相同的，也就是其中的值不可再改变
hello = tf.constant('Hello World from TensorFlow!')
#启动一个任务
sess = tf.Session()
#运行任务并返回hello常量的值
print sess.run(hello)
#在屏幕输出：Hello World from TensorFlow!

#----------------------------------------------------
#一个简单的整数常量计算示例
a = tf.constant(4)
b = tf.constant(7)
with tf.Session() as sess:
    print "a=4 / b=7"
    print "a + b = %i" % sess.run(a+b)
    print "a * b = %i" % sess.run(a*b)
#屏幕输出：
#  a=4 / b=7
#  a + b = 11
#  a * b = 28
#----------------------------------------------------
# 矩阵常量运算的例子
matrix1 = tf.constant([[3., 3.]])
matrix2 = tf.constant([[2.],[2.]])
product = tf.matmul(matrix1, matrix2)
with tf.Session() as sess:
    result = sess.run(product)
    print result
#屏幕输出：
# [[12.]]
#----------------------------------------------------
#占位符placeholder示例
#占位符是tf中的从python向
#tensorflow传输数据的主要手段
#与此对应，我们上一节例子中使用的变量，
#用于在tensorflow中参与运算和返回结果
x = tf.placeholder(tf.int16)
y = tf.placeholder(tf.int16)
add = tf.add(x, y)
mul = tf.multiply(x, y)

with tf.Session() as sess:
    print "12 + 36 = %i" % sess.run(add, feed_dict={x:12,y:36})
    print "12 * 36 = %i" % sess.run(mul, feed_dict={x:12,y:36})
#屏幕输出：
# 12 + 36 = 48
# 12 * 36 = 432
```
相信你看起来应当不困难，看起来这几个小例子简单，但是排除了“机器学习”算法方面的复杂性，tensorflow的主要特点也就是这些。  
所以入门的难度，主要还是集中在“机器学习”本身上。  
关于上面4个例子，唯一我认为需要解释的就是，因为我们是把4段独立的代码集成过来，所以tf.Session我们实际上是初始化了4次。  
也就是4个例子，都在各自的Session中运行的。在这个例子中，看不出来任何问题和副作用，但是如果在大的项目中你应当理解，这几个Session，互相是不同的任务，其中定义的任务，同样也是互相是不干扰的，这个特征跟在tensorflow中定义几个不同的图是同样的意思。图的例子我们后面会涉及到。  
关于TensorFlow的安装，在官方的文档中有非常详细、分操作系统的讲解，我们只是官方文档的补充，并不是打算替代官方文档，所以请移步至官方文档参考。阅读英文文档有困难的，请使用最下面的参考链接，有中文社区的链接。  
#### 第二个例子
作为加深印象，我们把tensorflow官方文档中最简单的一个例子列在下面。同样是梯度下降法求解，略微增加了数据的维度，配以逐句的注释，让你再熟悉一遍。  
```python
#!/usr/bin/env python 
# -*- coding=UTF-8 -*-

import tensorflow as tf
import numpy as np

# 使用 NumPy 生成假数据集x_data
# 数据集是一个2维数组，每维100个随机数
x_data = np.float32(np.random.rand(2, 100)) 
#运算得到数据结果集y_data
#下面tensorflow的梯度下降目标就是求这里给定的向量常数[0.100,0.200]及偏移量常数0.300
y_data = np.dot([0.100, 0.200], x_data) + 0.300
	
# 使用tensorflow构造线性模型
# 模型的数学公式是：y=W*x+b

# 首先定义了两个tf变量:b和W 
b = tf.Variable(tf.zeros([1]))		#b初始化为0
W = tf.Variable(tf.random_uniform([1, 2], -1.0, 1.0))		#W是1*2维的矩阵（向量），使用随机数初始化

#定义公式模型
#tf.matmul是矩阵乘法，两个参数必须都是矩阵
#先前房价例子中的tf.multiply是两个自然数相乘或者通过放射达成一个矩阵对一个自然数相乘
#另外注意在numpy中，这两种乘法使用同样的函数np.dot
y = tf.matmul(W, x_data) + b 

# 定义代价函数
loss = tf.reduce_mean(tf.square(y - y_data))
#梯度下降法求解
optimizer = tf.train.GradientDescentOptimizer(0.5)
#求解目标为最小化代价函数的值
train = optimizer.minimize(loss)

# 初始化变量
init = tf.global_variables_initializer()

# 启动图（启动模型）
sess = tf.Session()
sess.run(init)

# 求解（原文称“拟合”，也很贴切）
for step in xrange(0, 401):
    sess.run(train)	#没有定义占位符，所以不用喂值
    if step % 20 == 0:
        print step, sess.run(W), sess.run(b)

```
代码看上去跟前面的例子看上去差别很小是吧？如果不是提前知道，可能你都会看错。  
最后的运算结果会类似这样：
```bash
0 [[ 0.7986201 -0.3793277]] [0.41285288]
20 [[0.18275234 0.09449076]] [0.30691865]
40 [[0.1086577  0.18028098]] [0.30492488]
60 [[0.0999373 0.1954711]] [0.30222526]
80 [[0.09947924 0.19870569]] [0.3009042]
100 [[0.09972703 0.19956781]] [0.30035478]
120 [[0.09988438 0.1998434 ]] [0.30013746]
140 [[0.09995399 0.19994119]] [0.300053]
160 [[0.09998206 0.1999776 ]] [0.3000204]
180 [[0.09999307 0.19999143]] [0.30000782]
200 [[0.09999734 0.19999675]] [0.300003]
220 [[0.09999898 0.19999875]] [0.30000114]
240 [[0.09999961 0.19999954]] [0.30000043]
260 [[0.09999985 0.19999982]] [0.30000016]
280 [[0.09999986 0.19999984]] [0.30000016]
300 [[0.09999986 0.19999984]] [0.30000016]
320 [[0.09999986 0.19999984]] [0.30000016]
340 [[0.09999986 0.19999984]] [0.30000016]
360 [[0.09999986 0.19999984]] [0.30000016]
380 [[0.09999986 0.19999984]] [0.30000016]
400 [[0.09999986 0.19999984]] [0.30000016]
```
可以看到，增加了一维数据，同样的算法也可以得到不错的结果。  
本节的最后再说一下python2和python3，tensorflow对两个版本都能很好支持，python还可以支持c/c++/go等多种高级语言，但因为外围工具的原因，目前仍然是对python的支持最好。  
对python版本的偏爱纯属个人偏好，有的人喜欢python2,有的人则是python3的拥趸。其实对于一个成熟的程序员来讲，真的学会了python,随便换用哪个版本都不是大问题，那些语法的差距没有你想象的那么大。    
对于应用范围来讲，主要写通用性系统脚本的，首先用python2,因为几乎所有linux/mac电脑内置都已经有了python2。主要写独立性应用系统的，可以使用python3，其中一些特征很多人认为有利于企业型的应用系统编写，并且反正部署也是独立运行的，不用考虑兼容性。  




(待续...)


#### 引文及参考  
[大数据与多维度](http://www.raincent.com/content-108-8449-1.html)  
[多元线性回归模型公式](https://wenku.baidu.com/view/9560b9334a7302768e9939d0.html?from=search)  
[梯度下降法](https://www.cnblogs.com/pinard/p/5970503.html)  
[numpy官网](http://www.numpy.org)  
[TensorFlow中文社区](http://www.tensorfly.cn)  
