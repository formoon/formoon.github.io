---
layout:         page
title:          TensorFlow从1到2（二）
subtitle:       样本可视化和神经网络识别手写数字
card-image:		http://115.182.41.123/files/201904/tensorFlow2/tf-logo-card-2.png
date:           2019-04-10
tags:           tensorflow
post-card-type: image
---
![](http://115.182.41.123/files/201904/tensorFlow2/tf-logo-card-2.png)  
#### 图片样本可视化
[原文第四篇](http://blog.17study.com.cn/2018/01/10/tensorFlow-series-4/)中，我们介绍了官方的入门案例MNIST，功能是识别手写的数字0-9。这是一个非常基础的TensorFlow应用，地位相当于通常语言学习的"Hello World!"。  
我们先不进入TensorFlow 2.0中的MNIST代码讲解，因为TensorFlow 2.0在Keras的帮助下抽象度比较高，代码非常简单。但这也使得大量的工作被隐藏掉，反而让人难以真正理解来龙去脉。特别是其中所使用的样本数据也已经不同，而这对于学习者，是非常重要的部分。模型可以看论文、在网上找成熟的成果，数据的收集和处理，可不会有人帮忙。  
在原文中，我们首先介绍了MNIST的数据结构，并且用一个小程序，把样本中的数组数据转换为JPG图片，来帮助读者理解原始数据的组织方式。  
这里我们把小程序也升级一下，直接把图片显示在屏幕上，不再另外保存JPG文件。这样图片看起来更快更直观。  
在TensorFlow 1.x中，是使用程序input_data.py来下载和管理MNIST的样本数据集。当前官方仓库的master分支中已经取消了这个代码，为了不去翻仓库，你可以在[这里](http://115.182.41.123/files/201904/tensorFlow2/input_data.py)下载，放置到你的工作目录。  
在TensorFlow 2.0中，会有keras.datasets类来管理大部分的演示和模型中需要使用的数据集，这个我们后面再讲。  
MNIST的样本数据来自[Yann LeCun](http://yann.lecun.com/exdb/mnist/)的项目网站。如果网速比较慢的话，可以先用下载工具下载，然后放置到自己设置的数据目录，比如工作目录下的data文件夹，input_data检测到已有数据的话，不会重复下载。  
下面是我们升级后显示训练样本集的源码，代码的讲解保留在注释中。如果阅读有疑问的，建议先去原文中看一下样本集数据结构的图示部分：  
```python
#!/usr/bin/env python3

# 引入mnist数据预读准备库
# 2.0之后建议直接使用官方的keras.datasets.mnist.load_data
# 此处为了同以前的讲解对比，沿用之前的引用文件
import input_data
# tensorflow 2.0库
import tensorflow as tf
# 引入绘图库
import matplotlib.pyplot as plt

# 这里使用mnist数据预读准备库检查给定路径是已经有样本数据，
# 没有的话去网上下载，并保存在指定目录
# 已经下载了数据的话，将数据读入内存，保存到mnist对象中
mnist = input_data.read_data_sets("data/", one_hot=True)

# 样本集的结构如下：
# mnist.train 训练数据集
# mnist.validation 验证数据集
# mnist.test 测试数据集
# len(mnist.train.images)=55000
# len(mnist.train.images[0])=784
# len(mnist.train.labels[0])=10


def plot_image(i, imgs, labels):
    # 将1维的0-1的数据转换为标准的0-255的整数数据，2维28x28的图片
    image = tf.floor(256.0 * tf.reshape(imgs[i], [28, 28]))
    # 原数据为float，转换为uint8字节数据
    image = tf.cast(image, dtype=tf.uint8)
    # 标签样本为10个字节的数组，为1的元素下标就是样本的标签值
    # 这里使用argmax方法直接转换为0-9的整数
    label = tf.argmax(labels[i])
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    # 绘制样本图
    plt.imshow(image)
    # 显示标签值
    plt.xlabel("{}".format(label))


def show_images(num_rows, num_cols, images, labels):
    num_images = num_rows*num_cols
    plt.figure('Train Samples', figsize=(2*num_cols, 2*num_rows))
    # 循环显示前num_rows*num_cols副样本图片
    for i in range(num_images):
        plt.subplot(num_rows, num_cols, i+1)
        plot_image(i, images, labels)
    plt.show()

# 显示前4*6=24副训练集样本
show_images(4, 6, mnist.train.images, mnist.train.labels)
```
注意这个代码只是用来把样本集可视化。TensorFlow 2.0新特征，在这里只体现了取消Session和Session.run()。目的只是为了延续原来的讲解，让图片直接显示而不是保存为图像文件，以及升级到Python3和TensorFlow 2.0的执行环境。  
样本集显示出来效果是这样的：  
![](http://115.182.41.123/files/201904/tensorFlow2/mnist-train_Samples.png)

#### TensorFlow 2.0中的模型构建
原文第四篇中，我们使用了一个并不实用的线性回归模型来做手写数字识别。这样做可以简化中间层，从而能够使用可视化的手段来讲解机器视觉在数学上的基本原理。因为线性回归模型我们在本系列第一篇中讲过了，这里就跳过，直接说使用神经网络来解决MNIST问题。  
神经网络模型的构建在TensorFlow 1.0中是最繁琐的工作。我们曾经为了讲解vgg-19神经网络的使用，首先编写了一个复杂的辅助类，用于从字符串数组的遍历中自动构建复杂的神经网络模型。  
而在TensorFlow 2.0中，通过高度抽象的keras，可以非常容易的构建神经网络模型。  
为了帮助理解，我们先把TensorFlow 1.0中使用神经网络解决MNIST问题的代码原文粘贴如下：  
```python
#!/usr/bin/env python
# -*- coding=UTF-8 -*-

import input_data
mnist = input_data.read_data_sets('data/', one_hot=True)

import tensorflow as tf
sess = tf.InteractiveSession()

#对W/b做初始化有利于防止算法陷入局部最优解，
#文档上讲是为了打破对称性和防止0梯度及神经元节点恒为0等问题，数学原理是类似问题
#这两个初始化单独定义成子程序是因为多层神经网络会有多次调用
def weight_variable(shape):
    #填充“权重”矩阵，其中的元素符合截断正态分布
    #可以有参数mean表示指定均值及stddev指定标准差
  initial = tf.truncated_normal(shape, stddev=0.1)
  return tf.Variable(initial)
def bias_variable(shape):
    #用0.1常量填充“偏移量”矩阵
  initial = tf.constant(0.1, shape=shape)
  return tf.Variable(initial)


#定义占位符，相当于tensorFlow的运行参数，
#x是输入的图片矩阵，y_是给定的标注标签，有标注一定是监督学习
x = tf.placeholder("float", shape=[None, 784])
y_ = tf.placeholder("float", shape=[None, 10])

#定义输入层神经网络，有784个节点，1024个输出，
#输出的数量是自己定义的，要跟第二层节点的数量吻合
W1 = weight_variable([784, 1024])
b1 = bias_variable([1024])
#使用relu算法的激活函数，后面的公式跟前一个例子相同
h1 = tf.nn.relu(tf.matmul(x, W1) + b1)

#定义第二层（隐藏层）网络，1024输入，512输出
W2 = weight_variable([1024, 512])
b2 = bias_variable([512])
h2 = tf.nn.relu(tf.matmul(h1, W2) + b2)

#定义第三层（输出层），512输入，10输出，10也是我们希望的分类数量
W3 = weight_variable([512, 10])
b3 = bias_variable([10])
#最后一层的输出同样用softmax分类（也算是激活函数吧）
y3=tf.nn.softmax(tf.matmul(h2, W3) + b3)

#交叉熵代价函数
cross_entropy = -tf.reduce_sum(y_*tf.log(y3))
#这里使用了更加复杂的ADAM优化器来做"梯度最速下降"，
#前一个例子中我们使用的是：GradientDescentOptimizer
train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)
#计算正确率以评估效果
correct_prediction = tf.equal(tf.argmax(y3,1), tf.argmax(y_,1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
#tf初始化及所有变量初始化
sess.run(tf.global_variables_initializer())
#进行20000步的训练
for i in range(20000):
    #每批数据50组
  batch = mnist.train.next_batch(50)
  #每100步进行一次正确率计算并显示中间结果
  if i%100 == 0:
    train_accuracy = accuracy.eval(feed_dict={
        x:batch[0], y_: batch[1]})
    print "step %d, training accuracy %g"%(i, train_accuracy)
    #使用数据集进行训练
  train_step.run(feed_dict={x: batch[0], y_: batch[1]})

#完成模型训练给出最终的评估结果
print "test accuracy %g"%accuracy.eval(feed_dict={
    x: mnist.test.images, y_: mnist.test.labels})
```
总结一下上面TensorFlow 1.x版本MNIST代码中的工作：  
* 使用了一个三层的神经网络，每一层都使用重复性的代码构建
* 每一层的代码中，要精心计算输入和输出数据的格式、维度，使得每一层同上、下两层完全吻合
* 精心设计损失函数（代价函数）和选择回归算法
* 复杂的训练循环

如果你理解了我总结的这几点，请继续看TensorFlow 2.0的实现：  
```python
#!/usr/bin/env python3

# 引入mnist数据预读准备库
# 2.0之后建议直接使用官方的keras.datasets.mnist.load_data
# 此处为了同以前的讲解对比，沿用之前的引用文件
import input_data
# tensorflow库
import tensorflow as tf
# tensorflow 已经内置了keras
from tensorflow import keras
# 引入绘图库
import matplotlib.pyplot as plt

# 这里使用mnist数据预读准备库检查给定路径是已经有样本数据，
# 没有的话去网上下载，并保存在指定目录
# 已经下载了数据的话，将数据读入内存，保存到mnist对象中
mnist = input_data.read_data_sets("data/", one_hot=True)

# 样本集的结构如下：
# mnist.train 训练数据集
# mnist.validation 验证数据集
# mnist.test 测试数据集
# len(mnist.train.images)=55000
# len(mnist.train.images[0])=784
# len(mnist.train.labels[0])=10


def plot_image(i, imgs, labels, predictions):
    # 将1维的0-1的数据转换为标准的0-255的整数数据，2维28x28的图片
    image = tf.floor(256.0 * tf.reshape(imgs[i], [28, 28]))
    # 原数据为float，转换为uint8字节数据
    image = tf.cast(image, dtype=tf.uint8)
    # 标签样本为10个字节的数组，为1的元素下标就是样本的标签值
    # 这里使用argmax方法直接转换为0-9的整数
    label = tf.argmax(labels[i])
    prediction = tf.argmax(predictions[i])
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    # 绘制样本图
    plt.imshow(image)
    # 显示标签值，对比显示预测值和实际标签值
    plt.xlabel("predict:{} label:{}".format(prediction, label))


def show_images(num_rows, num_cols, images, labels, predictions):
    num_images = num_rows*num_cols
    plt.figure('Predict Samples', figsize=(2*num_cols, 2*num_rows))
    # 循环显示前num_rows*num_cols副样本图片
    for i in range(num_images):
        plt.subplot(num_rows, num_cols, i+1)
        plot_image(i, images, labels, predictions)
    plt.show()

# 原文中已经说明了，当前是10个元素数组表示一个数字，
# 值为1的那一元素的索引就是代表的数字，这是分类算法决定的
# 下面是直接转换为0-9的正整数，用作训练的标签
train_labels = tf.argmax(mnist.train.labels, 1)

# 定义神经网络模型
model = keras.Sequential([
    # 输入层为28x28共784个元素的数组,节点1024个
    keras.layers.Dense(1024, activation='relu', input_shape=(784,)),
    keras.layers.Dense(512, activation='relu'),
    keras.layers.Dense(10, activation='softmax')
])
# 编译模型
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
# 使用训练集数据训练模型
model.fit(mnist.train.images, train_labels, epochs=3)

# 测试集的标签同样转成0-9数字
test_labels = tf.argmax(mnist.test.labels, 1)
# 使用测试集样本验证识别准确率
test_loss, test_acc = model.evaluate(mnist.test.images, test_labels)
print('\nTest accuracy:', test_acc)

# 完整预测测试集样本
predictions = model.predict(mnist.test.images)
# 图示结果的前4*6个样本
show_images(4, 6, mnist.test.images, mnist.test.labels, predictions)
```
#### 代码讲解
通常我都是直接在注释中对程序做仔细的讲解，这次例外一下，因为我们需要从大局观上看清楚代码的结构。  
这几行代码是定义神经网络模型：  
```python
# 定义神经网络模型
model = keras.Sequential([
    # 输入层为28x28共784个元素的数组,节点1024个
    keras.layers.Dense(1024, activation='relu', input_shape=(784,)),
    keras.layers.Dense(512, activation='relu'),
    keras.layers.Dense(10, activation='softmax')
])
```
每一行实际就代表一层神经网络的节点。在第一行中特别指明了输入数据的形式，即可以有未知数量的样本，每一个样本784个字节(28x28)。实际上这个输入样本可以不指定形状，在没有指定的情况下，Keras会自动识别训练数据集的形状，并自动将模型输入匹配到训练集形状。只是这种习惯并不一定好，除了效率问题，当样本集出错的时候，模型的定义也无法帮助开发者提前发现问题。所以建议产品化的模型，应当在模型中指定输入数据类型。  
除了第一层之外，之后的每一层都无需指定输入样本形状。Keras会自动匹配相邻两个层的数据。这节省了开发人员大量的手工计算也不易出错。  
最后，激活函数的选择成为一个参数。整体代码看上去简洁的令人惊讶。  

接着在编译模型的代码中，直接指定Keras中预定义的“sparse_categorical_crossentropy”损失函数和“adam”优化算法。一个函数配合几个参数选择就完成了这部分工作：  
```python
# 编译模型
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
```
对原本复杂的训练循环部分，TensorFlow 2.0优化的最为彻底，只有一行代码：  
```python
# 使用训练集数据训练模型
model.fit(mnist.train.images, train_labels, epochs=3)
```
使用测试集数据对模型进行评估同样只需要一行代码，这里就不摘出来了，在上面完整代码中能看到。  
可以想象，TensorFlow 2.0正式发布后，模型搭建、训练、评估的工作量大幅减少，会催生很多由实验性模型创新而出现的新算法。机器学习领域会再次涌现普及化浪潮。  
这一版代码中，我们还细微修改了样本可视化部分的程序，将原来显示训练集样本，改为显示测试集样本。主要是增加了一个图片识别结果的参数。将图片的识别结果同数据集的标注一同显示在图片的下面作为对比。  
程序运行的时候，控制台输出如下：  
```bash
$ python3 mnist-show-predict-pic-v1.py 
Extracting data/train-images-idx3-ubyte.gz
Extracting data/train-labels-idx1-ubyte.gz
Extracting data/t10k-images-idx3-ubyte.gz
Extracting data/t10k-labels-idx1-ubyte.gz
Epoch 1/3
55000/55000 [==============================] - 17s 307us/sample - loss: 0.1869 - accuracy: 0.9420
Epoch 2/3
55000/55000 [==============================] - 17s 304us/sample - loss: 0.0816 - accuracy: 0.9740
Epoch 3/3
55000/55000 [==============================] - 16s 298us/sample - loss: 0.0557 - accuracy: 0.9821
10000/10000 [==============================] - 1s 98us/sample - loss: 0.0890 - accuracy: 0.9743

Test accuracy: 0.9743
```
最终的结果表示，模型通过3次的训练迭代之后。使用测试集数据进行验证，手写体数字识别正确率为97.43%。  
程序最终会显示测试集前24个图片及预测结果和标注信息的对比：  
![](http://115.182.41.123/files/201904/tensorFlow2/mnist_predict_samples.png)


（待续...）  

