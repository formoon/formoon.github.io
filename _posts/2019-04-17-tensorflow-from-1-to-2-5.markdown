---
layout:         page
title:          TensorFlow从1到2（五）
subtitle:       图片内容识别和自然语言语义识别
card-image:		http://files.17study.com.cn/201904/tensorFlow2/tf-logo-card-2.png
date:           2019-04-17
tags:           tensorflow
post-card-type: image
---
![](http://files.17study.com.cn/201904/tensorFlow2/tf-logo-card-2.png)  
#### Keras内置的预定义模型
上一节我们讲过了完整的保存模型及其训练完成的参数。  
Keras中使用这种方式，预置了多个著名的成熟神经网络模型。当然，这实际是Keras的功劳，并不适合算在TensorFlow 2.0头上。  
当前TensorFlow 2.0-alpha版本捆绑的Keras中包含：  
* densenet
* inception_resnet_v2
* inception_v3
* mobilenet
* mobilenet_v2
* nasnet
* resnet50
* vgg16
* vgg19
* xception

这些模型都已经使用大规模的数据训练完成，可以上手即用，实为良心佳作、码农福利。  
在[《从锅炉工到AI专家(8)》](http://blog.17study.com.cn/2018/01/15/tensorFlow-series-8/)文中，我们演示了一个使用vgg19神经网络识别图片内容的例子。那段代码并不难，但是使用TensorFlow 1.x的API构建vgg19这种复杂的神经网络可说费劲不小。有兴趣的读者可以移步至原文再体会一下那种纠结。  

而现在再做同样的事则是再简单不过了，你完全可以在你同事去茶水间倒咖啡的时间完成一个全功能的可用代码。比如跟上文功能相同的代码如下：  
```python
#!/usr/bin/env python3

import tensorflow as tf
from tensorflow import keras
# 载入vgg19模型
from tensorflow.keras.applications import vgg19
from tensorflow.keras.preprocessing import image
import numpy as np
import argparse

# 用于保存命令行参数
FLAGS = None

# 初始化vgg19模型，weights参数指的是使用ImageNet图片集训练的模型
# 每种模型第一次使用的时候都会自网络下载保存的h5文件
# vgg19的数据文件约为584M
model = vgg19.VGG19(weights='imagenet')


def main(imgPath):
	# 载入命令行参数指定的图片文件, 载入时变形为224x224，这是模型规范数据要求的
    img = image.load_img(imgPath, target_size=(224, 224))
	# 将图片转换为(224,224,3)数组，最后的3是因为RGB三色彩图
    img = image.img_to_array(img)
	# 跟前面的例子一样，使用模型进行预测是批处理模式，
	# 所以对于单个的图片，要扩展一维成为（1,224,224,3)这样的形式
	# 相当于建立一个预测队列，但其中只有一张图片
    img = np.expand_dims(img, axis=0)
	# 使用模型预测（识别）
    predict_class = model.predict(img)
	# 获取图片识别可能性最高的3个结果
    desc = vgg19.decode_predictions(predict_class, top=3)
	# 我们的预测队列中只有一张图片，所以结果也只有第一个有效，显示出来
    print(desc[0])

if __name__ == '__main__':
	# 命令行参数处理
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--image_file', type=str, default='pics/bigcat.jpeg',
                        help='Pic file name')
    FLAGS, unparsed = parser.parse_known_args()
    main(FLAGS.image_file)

```
Keras库载入图片文件的代码间接引用了pillow库，所以程序执行前请先安装：`pip3 install pillow`。  
仍然使用原文中的图片尝试识别：  
![](http://files.17study.com.cn/201904/tensorFlow2/bigcat.jpeg)  
```python
$ ./pic-recognize.py -i pics/bigcat.jpeg 
[('n02128385', 'leopard', 0.9778516), ('n02130308', 'cheetah', 0.008372171), ('n02128925', 'jaguar', 0.007467962)]
```
结果表示，图片是leopard(美洲豹)的可能性为97.79%，是cheetah(猎豹)的可能性为0.84%，是jaguar(美洲虎)的可能性为0.75%。  

使用这种方式，在图片识别中，换用其他网络模型非常轻松，只需要替换程序中的三条语句，比如我们将模型换为resnet50：  
```python
模型引入，由：
from tensorflow.keras.applications import vgg19
替换为：
from tensorflow.keras.applications import resnet50

模型构建，由：
model = vgg19.VGG19(weights='imagenet')
替换为：
model = resnet50.ResNet50(weights='imagenet')
注意第一次运行的时候，同样会下载resnet50的h5文件，这需要不短时间。  

显示预测结果，由：
    desc = vgg19.decode_predictions(predict_class, top=3)
替换为：
    desc = resnet50.decode_predictions(predict_class, top=3)
```
因为模型不同，执行结果会有细微区别，但这种久经考验的成熟网络，识别正确性没有问题：  
```bash
$ ./pic-recognize.py -i pics/bigcat.jpeg 
[('n02128385', 'leopard', 0.8544763), ('n02128925', 'jaguar', 0.09733019), ('n02128757', 'snow_leopard', 0.040557403)]
```

#### 自然语义识别
类似这样的功能集成、数据预处理工作在TensorFlow 2.0中增加了很多，对技术人员是极大的方便。比如在[《从锅炉工到AI专家(9)》](http://blog.17study.com.cn/2018/01/16/tensorFlow-series-9/)一文中，我们介绍了NLP项目重要的预处理工作：单词向量化。  
在Keras中，单词向量化已经标准化为了模型中的一层。固化的同时，使用的自由度也很高，可以在代码中控制需要编码的单词数量和向量化的维度以及很多其它参数。详细的文档可以看[官方文档](https://www.tensorflow.org/versions/r2.0/api_docs/python/tf/keras/layers/Embedding)。  
单词数字化的相关知识，我们后面一篇也会介绍。  

本例中，我们来看一个TensorFlow 2.0教程中的例子，自然语义识别。  
程序使用IMDB影片点评样本集作为训练数据。数据集的下载、载入和管理，我们使用tensorflow_datasets工具包。所以首先要安装一下：  
```bash
$ pip3 install tfds-nightly 
```
IMDB数据集包括影评和标注两个部分：影评就是摘选的关于影片的评论，是一段英文文字；标注只有0或者1两个数字。0表示本条影评对影片评价低，认为电影不好看，是负面情绪。1则表示本条影评对电影评价高，认为是好看的电影，是正面情绪。  
可惜是英文的数据集。如果想做类似的中文语义分析工作，需要我们自己配合优秀的分词工具来完成。  
我们使用的IMDB的数据集已经预先完成了单词数字化的工作，也就是已经由整数编码代表单词。所以配合的，必须有编码表来对应使用，才能还原原始的评论文字。  
下面我们在Python命令行使用交互模式，来看一下原始数据的样子：  
```python
$ python3
Python 3.7.3 (default, Mar 27 2019, 09:23:39) 
[Clang 10.0.0 (clang-1000.11.45.5)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
# 引入TensorFlow数据集处理工具
>>> import tensorflow_datasets as tfds
# 载入简化版训练样本数据集，简化版只包含8000+单词，这能让训练过程快一点，
# 完整版则包含几万
>>> dataset, info = tfds.load('imdb_reviews/subwords8k', with_info=True,
...                           as_supervised=True)
# 数据集中已经划分好了训练数据集和测试数据集
>>> train_dataset, test_dataset = dataset['train'], dataset['test']
# 初始化单词编码对照表，用于一会儿还原数字数组到影评文字
>>> tokenizer = info.features['text'].encoder
# 显示一条原始数据，是一个数字数组及一个单独的数字
# 前者是已经编码的影评，后者是标注
>>> for i in train_dataset.take(1):
...     print(i[0], i[1])
... 
tf.Tensor(
[ 768   99  416    9  733    1  626    6  467  159   33  788   53   29
 1224    3  156  155 1234 2492   14   32  151 7968   40  193   31  303
 7976   59 4159  104    3   12  258 2674  551 5557   40   44  113   55
  143  121   83   35 1151   11  195   13  746   61   55  300    3 3075
 8044   38   66   54    9    4  355  811   23 1406 6481 7961 1060 6786
  409 3570 7411 3743 2314 7998 8005 1782    3   19  953    9 5922 8029
    3   12  207 7968   21  582   72 8002 7968  123  853  178  132 1527
    3   19 1575   29 1288 2847 2742 8029    3   19  188    9  715 7974
 7753   26  144    1  263   85   33  479  892    3 1566 1380    7 1929
 4887 7961 3760   47 4584  204   88  183  800 1160    5   42    9 6396
   20 1838   24   10   16   10   17   19  349  233    9    1 5845  432
    6   15  208    3   69    9   20   75    1 1876  574   61    6   79
  141    7  115   15   51   20  785   20 3374    3 1976 1515 7968    8
  171   29 7463  104    2 5114    5  569    6 2203   95  185   52 5374
  376  231    5  789   47 7514   11 2246  714    2 7779   49 1709 1877
    4    5   19 3583 3599 7961    7 1302  146    6    1 1871    3  128
   11    1 2674  194 3754  100 7974  267    6  405   68   29 1966 5928
  291    7 2862  488   52 2048  858  700 1532   28 1551    2  142 7968
    8  638  152    1 2246 2968  739  251   19 3712 1183  830 1379 5368
   47    5 1889 7974 4038   34 4636   52 3653 6991   34 4491 8029 7975], shape=(280,), dtype=int64) tf.Tensor(0, shape=(), dtype=int64)
# 显示一条还原的影评和标注
>>> for i in train_dataset.take(1):
...     print(tokenizer.decode(i[0]), i[1].numpy())
... 
Just because someone is under the age of 10 does not mean they are stupid. If your child likes this film you'd better have him/her tested. I am continually amazed at how so many people can be involved in something that turns out so bad. This "film" is a showcase for digital wizardry AND NOTHING ELSE. The writing is horrid. I can't remember when I've heard such bad dialogue. The songs are beyond wretched. The acting is sub-par but then the actors were not given much. Who decided to employ Joey Fatone? He cannot sing and he is ugly as sin.<br /><br />The worst thing is the obviousness of it all. It is as if the writers went out of their way to make it all as stupid as possible. Great children's movies are wicked, smart and full of wit - films like Shrek and Toy Story in recent years, Willie Wonka and The Witches to mention two of the past. But in the continual dumbing-down of American more are flocking to dreck like Finding Nemo (yes, that's right), the recent Charlie & The Chocolate Factory and eye-crossing trash like Red Riding Hood. 0
# 影评部分不多说，标注部分是数字0，表示这是一条负面评价
```
NLP类项目，通常多用RNN、LSTM、GRU网络。主要原因是一条文本，单词数并不确定，虽然可以做补足(Padding)，但使用通常神经网络效果并不好。此外文本中各单词之间是有相关性的，这类似图片中的相邻点之间的相关，但文本的相关性跨度更大。   
关于RNN/LSTM/GRU的原理我们在[《从锅炉工到AI专家(10)》](http://blog.17study.com.cn/2018/01/17/tensorFlow-series-10/)一文中已经有过介绍。这里不再重复，直接进入代码部分，通过注释来理解所做的工作：  
```python
#!/usr/bin/env python3

from __future__ import absolute_import, division, print_function

# 引入tensorflow数据集工具包
import tensorflow_datasets as tfds
# 引入tensorflow
import tensorflow as tf

# 加载数据集，第一次会需要从网上下载imdb数据库
dataset, info = tfds.load('imdb_reviews/subwords8k', with_info=True,
                          as_supervised=True)
# 将训练集和测试集分别赋予两个变量                          
train_dataset, test_dataset = dataset['train'], dataset['test']

# 初始化对应的文本编码对照表
tokenizer = info.features['text'].encoder
# 显示当前样本集包含的所有单词数
print('Vocabulary size: {}'.format(tokenizer.vocab_size))

BUFFER_SIZE = 10000
BATCH_SIZE = 64
# 将训练集打乱顺序
train_dataset = train_dataset.shuffle(BUFFER_SIZE)
# 每批次的数据对齐
train_dataset = train_dataset.padded_batch(BATCH_SIZE, train_dataset.output_shapes)
test_dataset = test_dataset.padded_batch(BATCH_SIZE, test_dataset.output_shapes)

# 构造神经网络模型
# 第一层就是将已经数字化的影评数据向量化
# 向量化在上个系列中已经讲过，功能就是将单词嵌入多维矩阵
# 并使得语义相近的单词，在空间距离上更接近
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(tokenizer.vocab_size, 64),
    tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(
        64, return_sequences=True)),
    tf.keras.layers.Bidirectional(tf.keras.layers.LSTM(32)),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dense(1, activation='sigmoid')
])
# 编译模型
model.compile(loss='binary_crossentropy',
              optimizer='adam',
              metrics=['accuracy'])
# 训练模型
history = model.fit(train_dataset, epochs=10,
                    validation_data=test_dataset)

# 本训练耗时比较长，所以训练完保存一次数据，以便以后我们会想再次尝试
model.save_weights('./imdb-classify-lstm/final_chkp')

# 恢复数据，如果以后想再次测试影评预测，可以将上面训练、保存屏蔽起来
# 然后从这里开始使用
model.load_weights('./imdb-classify-lstm/final_chkp')
# 使用测试集数据评估模型，并显示损失值和准确度
test_loss, test_acc = model.evaluate(test_dataset)
print('\nTest Loss: {}'.format(test_loss))
print('Test Accuracy: {}'.format(test_acc))

#########################################################
# 以下为使用模型对一段文字进行情绪预测

# 工具函数，将一个不足指定长度的数组，使用0在尾部填充，以凑够长度
# 我们使用的模型嵌入层输入序列没有指定input_length，但这个参数是有默认值的，
# 相当于实际上是定长的，补充到同嵌入矩阵相同维度的长度，准确率会更高
# 当然对于只有0、1两个结果的分类来说，效果并不明显
def pad_to_size(vec, size):
    zeros = [0] * (size - len(vec))
    vec.extend(zeros)
    return vec

# 对一段文字进行预测
def sample_predict(sentence, pad):
    # 输入的文字，首先要使用imdb数据库相同的数字、单词对照表进行编码
    # 对于表中没有的单词，还会建立新对照项
    tokenized_sample_pred_text = tokenizer.encode(sentence)
    # 补充短的文字段到定长
    if pad:
        tokenized_sample_pred_text = pad_to_size(tokenized_sample_pred_text, 64)
    # 扩展一维，使数据成为只有1个数据的一个批次
    predictions = model.predict(tf.expand_dims(tokenized_sample_pred_text, 0))
    return (predictions)

# 预测1，文字大意：电影不好，动画和画面都很可怕，我不会推荐这个电影
sample_pred_text = ('The movie was not good. The animation and the graphics '
                    'were terrible. I would not recommend this movie.')
predictions = sample_predict(sample_pred_text, pad=True)
print(predictions)

# 预测2，文字大意：电影很无聊，我不喜欢这个电影
sample_pred_text = ("The movie was boring. I don't like this movie.")
predictions = sample_predict(sample_pred_text, pad=True)
print(predictions)

# 预测3，文字大意：这个电影很赞，里面的一切都很精致，我喜欢它
sample_pred_text = ('The movie was great. Everything in this movies '
                    'is delicate, I love it.')
predictions = sample_predict(sample_pred_text, pad=True)
print(predictions)
```
这个样例的训练已经比较慢了，在我用的电脑使用入门级的GPU运算跑了差不多20分钟。所以程序训练结束的时候保存了一次模型的参数，以便以后我们还想再测试更多的文本。  
程序执行的输出大致如下:  
```bash
$ ./imdb-classify-lstm.py
Vocabulary size: 8185
Epoch 1/10
391/391 [==============================] - 117s 299ms/step - loss: 0.5763 - accuracy: 0.6985 - val_loss: 0.0000e+00 - val_accuracy: 0.0000e+00
Epoch 2/10
391/391 [==============================] - 114s 292ms/step - loss: 0.4639 - accuracy: 0.7876 - val_loss: 0.5006 - val_accuracy: 0.7731
Epoch 3/10
391/391 [==============================] - 115s 295ms/step - loss: 0.3296 - accuracy: 0.8680 - val_loss: 0.3920 - val_accuracy: 0.8344
Epoch 4/10
391/391 [==============================] - 115s 295ms/step - loss: 0.2674 - accuracy: 0.8977 - val_loss: 0.3640 - val_accuracy: 0.8597
Epoch 5/10
391/391 [==============================] - 115s 295ms/step - loss: 0.2168 - accuracy: 0.9218 - val_loss: 0.3190 - val_accuracy: 0.8698
Epoch 6/10
391/391 [==============================] - 115s 294ms/step - loss: 0.1717 - accuracy: 0.9423 - val_loss: 0.3201 - val_accuracy: 0.8754
Epoch 7/10
391/391 [==============================] - 114s 293ms/step - loss: 0.1339 - accuracy: 0.9573 - val_loss: 0.3470 - val_accuracy: 0.8678
Epoch 8/10
391/391 [==============================] - 115s 294ms/step - loss: 0.1044 - accuracy: 0.9693 - val_loss: 0.4094 - val_accuracy: 0.8569
Epoch 9/10
391/391 [==============================] - 116s 296ms/step - loss: 0.0826 - accuracy: 0.9771 - val_loss: 0.4496 - val_accuracy: 0.8704
Epoch 10/10
391/391 [==============================] - 115s 295ms/step - loss: 0.0671 - accuracy: 0.9820 - val_loss: 0.4516 - val_accuracy: 0.8696
    391/Unknown - 37s 95ms/step - loss: 0.4516 - accuracy: 0.8696
Test Loss: 0.45155299115745
Test Accuracy: 0.8695999979972839
[[0.00420592]]
[[0.00562131]]
[[0.99653375]]

```
最终的结果，前两个值很接近0，表示这两句影评倾向于批评意见。第三个值接近1，表示这条影评是正面意见。注意这三条影评都是我们即兴随意写出的，并非样本库中的数据，是真正的“自然语言”。  

（待续...）  

