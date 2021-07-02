---
layout:         page
title:          TensorFlow从1到2（三）
subtitle:       数据预处理和卷积神经网络
card-image:		/attachments/201904/tensorFlow2/tf-logo-card-2.png
date:           2019-04-13
tags:           tensorflow
post-card-type: image
---
![](/attachments/201904/tensorFlow2/tf-logo-card-2.png)  
#### 数据集及预处理
从这个例子开始，相当比例的代码都来自于[官方新版文档](https://www.tensorflow.org/alpha/tutorials/quickstart/beginner)的示例。开始的几个还好，但随后的程序都将需要大量的算力支持。Google Colab是一个非常棒的云端实验室，提供含有TPU/GPU支持的Python执行环境(需要在Edit→Notebook Settings设置中打开)。速度比不上配置优良的本地电脑，但至少超过平均的开发环境。  
所以如果你的电脑运行速度不理想，建议你尝试去官方文档中，使用相应代码的对应链接进入Colab执行试一试。  
[Colab](https://colab.research.google.com/notebooks/welcome.ipynb#recent=true)还允许新建Python笔记，来尝试自己的实验代码。当然这一切的前提，是需要你科学上网。  

上一个例子已经完全使用了TensorFlow 2.0的库来实现。但数据集仍然沿用了TensorFlow 1.x讲解时所使用的样本。  
TensorFlow 2.0默认使用Keras的datasets类来管理数据集，包括Keras内置模型已经训练好的生产数据集，和类似MNIST这种学习项目所用到的练习数据集。  
使用Keras载入数据集同样只是一行代码：  
```python
(train_images, train_labels), (test_images, test_labels) = keras.datasets.mnist.load_data()
```
Keras.datasets默认是从谷歌网站下载数据集，以MNIST为例，数据下载地址是：<https://storage.googleapis.com/tensorflow/tf-keras-datasets/mnist.npz>。文件下载之后，放置到`~/.keras/datasets`文件夹，以后执行程序的时候，会自动从本地读取数据。数据保存路径Linux/Mac都是如此，Windows同样是在用户主目录，比如：c:\Users\Administrator\.keras\datasets。  

接着是数据预处理的问题，主要是从原始的图片、标注，转换为机器学习所需要的规范化之后的数据。我们在TensorFlow 1.x中所使用的数据实际是已经规范化之后的。我们可以使用Python3的交互模式，载入数据之后，查看一下数据：  
```python
$ python3
Python 3.7.3 (default, Mar 27 2019, 09:23:39) 
[Clang 10.0.0 (clang-1000.11.45.5)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import input_data
>>> mnist = input_data.read_data_sets("data/", one_hot=True)
Extracting data/train-images-idx3-ubyte.gz
Extracting data/train-labels-idx1-ubyte.gz
Extracting data/t10k-images-idx3-ubyte.gz
Extracting data/t10k-labels-idx1-ubyte.gz
>>> mnist.train.images[0]
array([0.        , 0.        , 0.        , 0.        , 0.        ,
   ...省略部分...
       0.        , 0.        , 0.        , 0.        , 0.        ,
       0.9215687 , 0.9215687 , 0.9215687 , 0.9215687 , 0.9215687 ,
       0.9843138 , 0.9843138 , 0.9725491 , 0.9960785 , 0.9607844 ,
       0.9215687 , 0.74509805, 0.08235294, 0.        , 0.        ,
   ...省略部分...
       0.        , 0.        , 0.        , 0.        , 0.        ,
       0.        , 0.        , 0.        , 0.        ], dtype=float32)
>>> mnist.train.labels[0]
array([0., 0., 0., 0., 0., 0., 0., 1., 0., 0.])
```
对于图，就是28x28的二维数组，其中每一个数据，代表一个点，数据的值越接近1，代表这个点的颜色越接近白色；反之，则颜色越接近黑色。借用[原文第四篇](http://blog.17study.com.cn/2018/01/10/tensorFlow-series-4/)中的一幅图来帮你回忆一下这个关系（上一篇中，图片显示部分的代码，功能也是还原这组数据）：  
![](http://www.tensorfly.cn/tfdoc/images/MNIST-Matrix.png)  
对于标签，因为我们是识别为0-9共10个数字，是10个输出的分类器。所以标签组某一个值为1，表示图像代表的手写数字属于该分类。同样借用一下原图：  
![](http://www.tensorfly.cn/tfdoc/images/mnist-train-ys.png)
如果想将这样的分类数据转成我们习惯的0-9数字，可以使用TensorFlow中内置的函数argmax:  
```python
   ...接着上面的交互模式继续执行...
>>> import tensorflow as tf
>>> train_labels = tf.argmax(mnist.train.labels, 1)
>>> train_labels
<tf.Tensor: id=2, shape=(55000,), dtype=int64, numpy=array([7, 3, 4, ..., 5, 6, 8])>
```
现在的数据看起来很习惯了吧？更幸福的是，使用Keras的的分类器模型训练，已经可以直接使用这样的标签数据了。  
keras.datasets.mnist.load_data()所载入的样本数据，跟TensorFlow 1.0所使用的数据有一些区别。其中的图像数据并未做规范化，仍然是通常BMP图像中的0-255的字节数据方式。标签数据，也直接是我们更熟悉的0-9数字标签。这两个微小的变化提现了TensorFlow理念的转变，TensorFlow更贴近真实的工作环境了。  
我们同样在交互模式来看一下这两组数据：  
```python
$ python3
Python 3.7.3 (default, Mar 27 2019, 09:23:39) 
[Clang 10.0.0 (clang-1000.11.45.5)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> from tensorflow import keras
>>> (train_images, train_labels), (test_images, test_labels) = keras.datasets.mnist.load_data()
>>> train_images[0]
array([[  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
          0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
          0,   0],
   ...省略部分...
       [  0,   0,   0,   0,   0,   0,   0,   0,  30,  36,  94, 154, 170,
        253, 253, 253, 253, 253, 225, 172, 253, 242, 195,  64,   0,   0,
          0,   0],
       [  0,   0,   0,   0,   0,   0,   0,  49, 238, 253, 253, 253, 253,
        253, 253, 253, 253, 251,  93,  82,  82,  56,  39,   0,   0,   0,
          0,   0],
       [  0,   0,   0,   0,   0,   0,   0,  18, 219, 253, 253, 253, 253,
        253, 198, 182, 247, 241,   0,   0,   0,   0,   0,   0,   0,   0,
          0,   0],
       [  0,   0,   0,   0,   0,   0,   0,   0,  80, 156, 107, 253, 253,
        205,  11,   0,  43, 154,   0,   0,   0,   0,   0,   0,   0,   0,
          0,   0],
       [  0,   0,   0,   0,   0,   0,   0,   0,   0,  14,   1, 154, 253,
         90,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
          0,   0],
   ...省略部分...
       [  0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
          0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
          0,   0]], dtype=uint8)
>>> train_labels
array([5, 0, 4, ..., 5, 6, 8], dtype=uint8)
```
就像从上一个系列中我就一直强调的，TensorFlow的使用越来越容易，成熟的模型越来越多。难度更多的会集中在样本的选取和预处理，所以一定要多关注对原始数据的理解。  
TensorFlow 2.0可以直接处理如上所示的标签数据。图像的数据则仍然需要规范化，图像数据的取值范围我们很清楚是0-255，规范化也很简单：  
```python
# 数据规范化为0-1范围的浮点数
train_images = train_images / 255.0
test_images1 = test_images / 255.0
```
下面看看完整的代码：  
```python
#!/usr/bin/env python3

# tensorflow库
import tensorflow as tf
# tensorflow 已经内置了keras
from tensorflow import keras

# 引入绘图库
import matplotlib.pyplot as plt

# 第一次使用会自动从网上下载mnist的训练样本
(train_images, train_labels), (test_images, test_labels) = keras.datasets.mnist.load_data()


def plot_image(i, imgs, labels, predictions):
	# TensorFlow 2.x的数据已经是0-255范围，无需再次还原
    image = imgs[i]
    label = labels[i]
    prediction = tf.argmax(predictions[i])
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    # 绘制样本图
    plt.imshow(image)
    # 显示标签值，对比显示预测值和实际标签值
    plt.xlabel("predict:{} label:{}".format(prediction, label))


def show_samples(num_rows, num_cols, images, labels, predictions):
    num_images = num_rows*num_cols
    plt.figure('Predict Samples', figsize=(2*num_cols, 2*num_rows))
    # 循环显示前num_rows*num_cols副样本图片
    for i in range(num_images):
        plt.subplot(num_rows, num_cols, i+1)
        plot_image(i, images, labels, predictions)
    plt.show()

# 数据规范化为0-1范围的浮点数
train_images = train_images / 255.0
test_images1 = test_images / 255.0

# 定义神经网络模型
model = keras.Sequential([
    # 输入层把28x28的2维矩阵转换成1维
    keras.layers.Flatten(input_shape=(28, 28)),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dense(10, activation='softmax')
])
# 编译模型
model.compile(optimizer='adam', 
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
# 使用训练集数据训练模型
model.fit(train_images, train_labels, epochs=5)

# 使用测试集样本验证识别准确率
test_loss, test_acc = model.evaluate(test_images1, test_labels)
print('\nTest accuracy:', test_acc)

# 完整预测测试集样本
predictions = model.predict(test_images1)

# 显示测试样本预测结果
show_samples(4, 6, test_images, test_labels, predictions)
```
代码中，图片显示的部分也对应取消了把规范化的数据还原为0-255原始图像数据的过程。其它部分则并没有什么变化。  
现在，MNIST已经是完整的TensorFlow 2.0的原生代码了。绕了这么远，希望能帮你更深刻理解这些代码背后的工作。  

#### 卷积和池化
在前一个系列中，卷积和池化部分据很多反馈说是一个很严重的门槛。有读者说完全算不清每一层和相连接的层之间的数据关系。  
在TensorFlow 2.0中，就像前面说过的，这种层与层之间的数据维度模型完全是无需自己计算的，Keras会自动匹配这种数据关系。因此单纯从这一点上说，在TensorFlow 2.0中，无论多复杂的模型构建都不会再成为问题。只是会多一点其它的担心，那就是这样隐藏起来机器学习本质上的数学模型，究竟对程序员来说是好事还是坏事？  
TensorFlow 1.x中使用卷积神经网络解决MNIST问题的讲解在[前系列第六篇](http://blog.17study.com.cn/2018/01/11/tensorFlow-series-6/)。篇幅很长，这里就不重贴了。在TensorFlow 2.0中，则只是一个函数几行代码(请尽量跟TensorFlow 1.x版本的代码对应着看。对卷积、池化的概念已经忘记的也强烈建议去前系列复习一下)：  
```python
# 定义卷积池化神经网络模型
model = keras.Sequential([
    keras.layers.Conv2D(32, (5, 5), strides=(1, 1),
                        padding='same', activation='relu'),
    keras.layers.MaxPooling2D(pool_size=(2, 2),
                              strides=(2, 2), padding='same'),
    keras.layers.Conv2D(64, (5, 5), strides=(1, 1),
                        padding='same', activation='relu'),
    keras.layers.MaxPooling2D(pool_size=(2, 2),
                              strides=(2, 2), padding='same'),
    keras.layers.Flatten(),  # 下面的神经网络需要1维的数据
    keras.layers.Dense(1024, activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(10, activation='softmax')
])
```
Keras让模型构建的过程变得极其容易。  
从原理上说，卷积是对图像的二维数据做扫描，还需要指定图像的色深。所以在样本预处理的阶段，我们还要对其做一个变形：  
```python
# 卷积需要2维数据，还需要指定色深，因此是（样本数，长，宽，色深）
train_images = train_images.reshape(train_labels.shape[0], 28, 28, 1)
test_images1 = test_images1.reshape(test_labels.shape[0], 28, 28, 1)
```
训练集的样本我们直接用变形后的数据替代了原始样本。测试集则另外使用了一个变量保留了原始的测试集，这是因为我们显示测试集图片的时候，使用原始数据集显然更方便。  
实际上整个代码只有这么两点区别，不过为了你练习的时候方便，还是把完整代码贴一遍：  
```python
#!/usr/bin/env python3

# tensorflow库
import tensorflow as tf
# tensorflow 已经内置了keras
from tensorflow import keras

# 引入绘图库
import matplotlib.pyplot as plt

# 第一次使用会自动从网上下载mnist的训练样本
(train_images, train_labels), (test_images, test_labels) = keras.datasets.mnist.load_data()
# 数据路径：~/.keras/datasets/mnist.npz


def plot_image(i, imgs, labels, predictions):
    image = imgs[i]
    label = labels[i]
    prediction = tf.argmax(predictions[i])
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    # 绘制样本图
    plt.imshow(image)
    # 显示标签值
    plt.xlabel("predict:{} label:{}".format(prediction, label))


def show_samples(num_rows, num_cols, images, labels, predictions):
    num_images = num_rows*num_cols
    plt.figure('Predict Samples', figsize=(2*num_cols, 2*num_rows))
    # 循环显示前4*6副训练集样本图片
    for i in range(num_images):
        plt.subplot(num_rows, num_cols, i+1)
        plot_image(i, images, labels, predictions)
    plt.show()

# 数据规范化为0-1范围的浮点数
train_images = train_images / 255.0
test_images1 = test_images / 255.0

# 卷积需要2维数据，还需要指定色深，因此是（样本数，长，宽，色深）
train_images = train_images.reshape(train_labels.shape[0], 28, 28, 1)
test_images1 = test_images1.reshape(test_labels.shape[0], 28, 28, 1)
# 定义卷积池化神经网络模型
model = keras.Sequential([
    keras.layers.Conv2D(32, (5, 5), strides=(1, 1),
                        padding='same', activation='relu'),
    keras.layers.MaxPooling2D(pool_size=(2, 2),
                              strides=(2, 2), padding='same'),
    keras.layers.Conv2D(64, (5, 5), strides=(1, 1),
                        padding='same', activation='relu'),
    keras.layers.MaxPooling2D(pool_size=(2, 2),
                              strides=(2, 2), padding='same'),
    keras.layers.Flatten(),  # 下面的神经网络需要1维的数据
    keras.layers.Dense(1024, activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(10, activation='softmax')
])
# 编译模型
model.compile(optimizer='adam', 
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
# 使用训练集数据训练模型
model.fit(train_images, train_labels, epochs=3)

# 使用测试集样本验证识别准确率
test_loss, test_acc = model.evaluate(test_images1, test_labels)
print('\nTest accuracy:', test_acc)

# 完整预测测试集样本
predictions = model.predict(test_images1)

# 显示测试样本预测结果
show_samples(4, 6, test_images, test_labels, predictions)

```
程序执行的时候，在控制台的输出信息类似下面：  
```bash
$ chmod +x mnist-conv-maxpool-v2.py
$ ./mnist-conv-maxpool-v2.py
Epoch 1/3
60000/60000 [==============================] - 141s 2ms/sample - loss: 0.1139 - accuracy: 0.9643
Epoch 2/3
60000/60000 [==============================] - 143s 2ms/sample - loss: 0.0417 - accuracy: 0.9869
Epoch 3/3
60000/60000 [==============================] - 138s 2ms/sample - loss: 0.0312 - accuracy: 0.9904
10000/10000 [==============================] - 7s 659us/sample - loss: 0.0289 - accuracy: 0.9903

Test accuracy: 0.9903
```
在样本集的测试上，卷积神经网络的版本可以达到超过99%的正确率。  
这个正确率，只进行了3次的训练迭代，当然因为卷积神经网络模型的复杂，这3次的训练就远远比上一例中的5次训练速度更慢。  

（待续...）  

