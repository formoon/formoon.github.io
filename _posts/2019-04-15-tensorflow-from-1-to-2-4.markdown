---
layout:         page
title:          TensorFlow从1到2（四）
subtitle:       时尚单品识别和保存、恢复训练数据
card-image:		http://files.17study.com.cn/201904/tensorFlow2/tf-logo-card-2.png
date:           2019-04-15
tags:           tensorflow
post-card-type: image
---
![](http://files.17study.com.cn/201904/tensorFlow2/tf-logo-card-2.png)  
#### Fashion Mnist --- 一个图片识别的延伸案例
在TensorFlow官方新的教程中，第一个例子使用了由MNIST延伸而来的新程序。  
这个程序使用一组时尚单品的图片对模型进行训练，比如T恤(T-shirt)、长裤(Trouser)，训练完成后，对于给定图片，可以识别出单品的名称。  
![](http://files.17study.com.cn/201904/tensorFlow2/fashion-mnist-sprite.png)
程序同样将所有图片规范为28x28点阵，使用灰度图，每个字节取值范围0-255。时尚单品的类型，同样也是分为10类，跟手写数字识别的分类维度相同。因此实际上，这个例子看起来美观也有趣很多，但是在技术层面上，跟传统的MNIST没有区别。  
不同的地方也有，首先是识别之后需要显示的是单品名称，而不是0-9的数字，所以程序中需要定义一个标签数组，并在显示时做一个转换：  
```python
	......
# 标签列表
class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat', 
               'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']
	......
# 显示标签名称
plt.xlabel(class_names[train_labels[i]])
	......
```
![](http://files.17study.com.cn/201904/tensorFlow2/fashion_mnist_train_samples.png)
其次，从样本图片中你应当能看出来，图片的复杂度，比手写数字还是高多了。从而造成的混淆和误判，显然也高的多。这种情况下，只使用tf.argmax()获取确定的一个标签就有点不足了。所以在这个例子中，增加了使用直方图，显示所有10个预测分类中，每个分类的相似度功能。同时，预测正确的，用蓝色字体表示。预测结果同样本标注不同的，使用红色字体表示。  
```python
	......
def plot_value_array(i, predictions_array, true_label):
    predictions_array, true_label = predictions_array[i], true_label[i]
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    thisplot = plt.bar(range(10), predictions_array, color="#777777")
    plt.ylim([0, 1])
    predicted_label = tf.argmax(predictions_array)

    thisplot[predicted_label].set_color('red')
    thisplot[true_label].set_color('blue')
	......
plot_value_array(i, predictions, test_labels)
	......	
```
完整的代码如下：  
```python
#!/usr/bin/env python3

from __future__ import absolute_import, division, print_function

# TensorFlow and tf.keras
import tensorflow as tf
from tensorflow import keras

# Helper libraries
import numpy as np
import matplotlib.pyplot as plt

# 显示样本集中，指定图片、预测信息、标注信息
def plot_image(i, predictions_array, true_label, img):
    predictions_array, true_label, img = predictions_array[i], true_label[i], img[i]
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])

    plt.imshow(img, cmap=plt.cm.binary)

    predicted_label = tf.argmax(predictions_array)
    if predicted_label == true_label:
        color = 'blue'
    else:
        color = 'red'
  
    plt.xlabel("{} {:2.0f}% ({})".format(class_names[predicted_label],
                                         100*np.max(predictions_array),
                                         class_names[true_label]),
                                         color=color)


# 使用柱状图显示预测结果数组，每一个柱状图，代表图片属于该类的可能性
def plot_value_array(i, predictions_array, true_label):
    predictions_array, true_label = predictions_array[i], true_label[i]
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    thisplot = plt.bar(range(10), predictions_array, color="#777777")
    plt.ylim([0, 1])
    predicted_label = tf.argmax(predictions_array)

    thisplot[predicted_label].set_color('red')
    thisplot[true_label].set_color('blue')

# 加载Fashion Mnist数据集，第一次执行的时候会自动从网上下载，这个速度会比较慢
fashion_mnist = keras.datasets.fashion_mnist
(train_images, train_labels), (test_images, test_labels) = fashion_mnist.load_data()

# 如同数字识别的0-9十类，这里也将时尚潮品分了以下十类
# 所以本质上，这跟手写数字的识别是完全一致的
class_names = ['T-shirt/top', 'Trouser', 'Pullover', 'Dress', 'Coat', 
               'Sandal', 'Shirt', 'Sneaker', 'Bag', 'Ankle boot']

# 数据规范化，将图片数据转化为0-1之间的浮点数字
train_images = train_images / 255.0
test_images = test_images / 255.0

# 为了有一个直观印象，我们把训练集前24个样本图片显示在屏幕上，同时显示图片的标注信息
# 你可能注意到了，我们在显示图片的时候，并没有跟前面显示手写字体图片一样，把图片的规范化数据还原为0-255，
# 这是因为实际上mathplotlib库可以直接接受浮点型的图像数据，
# 我们前面首先还原规范化数据，是为了让你清楚理解原始数据的格式。
plt.figure(figsize=(8, 6))
for i in range(24):
    plt.subplot(4, 6, i+1)
    plt.grid(False)
    plt.xticks([])
    plt.yticks([])
    plt.imshow(train_images[i], cmap=plt.cm.binary)
    plt.xlabel(class_names[train_labels[i]])
plt.show()

# 定义神经网络模型，用了一个比较简单的模型
model = keras.Sequential([
    keras.layers.Flatten(input_shape=(28, 28)),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dense(10, activation='softmax')
])

# 采用指定的优化器和损失函数编译模型
model.compile(optimizer='adam', 
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# 训练模型
model.fit(train_images, train_labels, epochs=15)

# 使用测试集数据评估训练后的模型，并显示评估结果
test_loss, test_acc = model.evaluate(test_images, test_labels)
print('\nTest accuracy:', test_acc)

#########
# 预测所有测试集数据，用于图形显示结果
predictions = model.predict(test_images)

# 以5行x3列显示测试集前15个样本的图片和预测结果
# 正确的预测结果蓝色显示，错误的预测信息会红色显示
# 每一张图片的右侧，会显示图片预测的结果数组，这个数组中，数值最大的，代表最可能的分类
# 或者说，每一个数组元素，都代表图片属于对应分类的可能性
num_rows = 5
num_cols = 3
num_images = num_rows*num_cols
plt.figure(figsize=(2*2*num_cols, 2*num_rows))
for i in range(num_images):
    plt.subplot(num_rows, 2*num_cols, 2*i+1)
    plot_image(i, predictions, test_labels, test_images)
    plt.subplot(num_rows, 2*num_cols, 2*i+2)
    plot_value_array(i, predictions, test_labels)
plt.show()

#############
# 演示预测单独一幅图片
# 从测试集获取一幅图
img = test_images[0]
# 我们的模型是批处理进行预测的，要求的是一个图片的数组，所以这里扩展一维
# 成为(1, 28, 28)这样的形式
img = (np.expand_dims(img, 0))
# 使用模型进行预测
predictions_single = model.predict(img)
# 显示预测结果数组
print("test_images[0] prediction array:", predictions_single)
# 显示转换为可识别类型的预测结果
print("test_images[0] prediction text:", class_names[tf.argmax(predictions_single[0])])
# 显示原标注
print("test_labels[0]:", class_names[test_labels[0]])
# 原图的显示请参考上面大图的左上角第一幅，此处略
```
程序最后还演示了使用1幅图片数据调用模型进行预测的方式。特别不要忘记把这一幅图片扩展一维再进入模型，因为我们的模型是使用批处理方式进行预测的，原本接受的是一个图片的数组。  
程序在第一次执行的时候，会自动由网上下载数据集，下载的网址在下面的显示信息中能看到。下载完成后，数据会存放在~/.keras/datasets/fashion-mnist/文件夹。  
```bash
$ ./fashion_mnist.py 
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/train-labels-idx1-ubyte.gz
32768/29515 [=================================] - 0s 15us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/train-images-idx3-ubyte.gz
26427392/26421880 [==============================] - 65s 2us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/t10k-labels-idx1-ubyte.gz
8192/5148 [===============================================] - 0s 8us/step
Downloading data from https://storage.googleapis.com/tensorflow/tf-keras-datasets/t10k-images-idx3-ubyte.gz
4423680/4422102 [==============================] - 10s 2us/step
```
以后再运行程序的时候，程序就直接使用本地数据运行。执行过程所显示的信息类似下面：  
```bash
$ ./fashion_mnist.py
Epoch 1/15
60000/60000 [==============================] - 4s 68us/sample - loss: 0.4999 - accuracy: 0.8247
Epoch 2/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.3753 - accuracy: 0.8652
Epoch 3/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.3361 - accuracy: 0.8783
Epoch 4/15
60000/60000 [==============================] - 4s 64us/sample - loss: 0.3120 - accuracy: 0.8848
Epoch 5/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.2950 - accuracy: 0.8916
Epoch 6/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.2825 - accuracy: 0.8950
Epoch 7/15
60000/60000 [==============================] - 4s 64us/sample - loss: 0.2681 - accuracy: 0.9004
Epoch 8/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.2564 - accuracy: 0.9052
Epoch 9/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.2463 - accuracy: 0.9088
Epoch 10/15
60000/60000 [==============================] - 4s 64us/sample - loss: 0.2385 - accuracy: 0.9118
Epoch 11/15
60000/60000 [==============================] - 5s 79us/sample - loss: 0.2299 - accuracy: 0.9145
Epoch 12/15
60000/60000 [==============================] - 4s 72us/sample - loss: 0.2224 - accuracy: 0.9165
Epoch 13/15
60000/60000 [==============================] - 4s 65us/sample - loss: 0.2152 - accuracy: 0.9192
Epoch 14/15
60000/60000 [==============================] - 4s 64us/sample - loss: 0.2093 - accuracy: 0.9214
Epoch 15/15
60000/60000 [==============================] - 4s 64us/sample - loss: 0.2031 - accuracy: 0.9227
10000/10000 [==============================] - 0s 38us/sample - loss: 0.3361 - accuracy: 0.8889

Test accuracy: 0.8889
test_images[0] prediction array: [[2.8952907e-09 4.0831842e-06 9.7278274e-08 1.6851689e-09 5.8218838e-08
  3.0680697e-03 1.2691763e-07 1.8435927e-02 3.7783199e-08 9.7849166e-01]]
test_images[0] prediction text: Ankle boot
test_labels[0]: Ankle boot
```
程序执行中，测试集前15幅图片的验证结果显示如下：  
![](http://files.17study.com.cn/201904/tensorFlow2/fashion_mnist_predict.png)
左下角的图片出现了明显的识别错误。不过话说回来，以我这种时尚盲人来说，也完全区分不出来这种样子的凉鞋跟运动鞋有啥区别（手动捂脸），当然图片的分辨率也是问题之一啦。  

#### 保存和恢复训练数据
TensorFlow 2.0提供了两种数据保存和恢复的方式。第一种方式是我们在TensorFlow 1.x中经常用的保存模型权重参数的方式。  
因为在TensorFlow 2.0中，我们使用了model.fit方法来代替之前使用的训练循环，所以保存训练权重数据是使用回调函数的方式完成的。下面举一个例子：  
```python
	...在model.compile之后增加下面代码...
checkpoint_path = "training_data/cp.ckpt"
checkpoint_dir = os.path.dirname(checkpoint_path)

# 设置自己的回调函数
cp_callback = tf.keras.callbacks.ModelCheckpoint(checkpoint_dir, 
                                                 save_weights_only=True,
                                                 verbose=1)
# 修改fit方法增加回调参数
model.fit(train_images, train_labels, epochs=15,
          callbacks = [cp_callback])  
	......
```
这样在每一个训练周期，都会将训练数据写入到文件，屏幕显示会类似这样：  
```bash
Epoch 1/15
60000/60000 [==============================] - 4s 68us/sample - loss: 0.4999 - accuracy: 0.8247
Epoch 00001: saving model to training_data/cp.ckpt
Epoch 2/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.3753 - accuracy: 0.8652
Epoch 00002: saving model to training_data/cp.ckpt
Epoch 3/15
60000/60000 [==============================] - 4s 63us/sample - loss: 0.3361 - accuracy: 0.8783
Epoch 00003: saving model to training_data/cp.ckpt
Epoch 4/15
	......
```
对于稍大的数据集和稍微复杂的模型，训练的时间会非常之长。通常我们都会把这种工作部署到有强大算力的服务器上执行。训练完成，将训练数据保存下来。预测的时候，则并不需要很大的运算量，就可以在普通的设备上执行了。  
还原保存的数据，其实就是把fit方法这一句，替换为加载保存的数据就可以：  
```python
	...替代model.fit那一行代码...
model.load_weights(checkpoint_dir)
	...然后就可以当做训练完成的模型一样进行预测操作了...
```
这种方法是比较多用的，因为很多情况下，我们训练所使用的模型，跟预测所使用的模型，会有细微的调整。这时候只载入模型的权重值，并不影响模型的微调。  
此外，上面的代码仅为示例。在实际应用中，这种不改变文件名、只保存一组文件的形式，实际并不需要回调函数，在训练完成后一次写入到文件是更好的选择。使用回调函数通常都是为了保存每一步的训练结果。  

#### 保存完整模型
如果模型是比较成熟稳定的，我们很可能喜欢完整的保存整个模型，这样不仅操作容易，而且也省去了重新建模的工作。Keras内置的vgg-19/resnet50等模型，实际就使用了这种方式，我们会在下一篇详细介绍。  
保存完整的模型非常简单，只要在model.fit执行完成后，一行代码就可以保存完整、包含权重参数的模型：  
```bash
# 将完整模型保存为HDF5文件
model.save('fashion_mnist.h5')
```
还原完整模型的话，则可以从使用keras.Sequential开始定义模型、模型编译都不需要，直接使用：  
```bash
new_model = keras.models.load_model('fashion_mnist.h5')
```
接着就可以使用new_model这个模型进行预测了。  

（待续...）  

