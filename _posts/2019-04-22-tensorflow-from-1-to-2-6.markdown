---
layout:         page
title:          TensorFlow从1到2（六）
subtitle:       结构化数据预处理和心脏病预测
card-image:		https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201904/tensorFlow2/tf-logo-card-2.png
date:           2019-04-22
tags:           tensorflow
post-card-type: image
---
![](https://raw.githubusercontent.com/formoon/formoon.github.io/master/attachments/201904/tensorFlow2/tf-logo-card-2.png)  

#### 结构化数据的预处理
前面所展示的一些示例已经很让人兴奋。但从总体看，数据类型还是比较单一的，比如图片，比如文本。  
这个单一并非指数据的类型单一，而是指数据组成的每一部分，在模型中对于结果预测的影响基本是一致的。  
更通俗一点说，比如在手写数字识别的案例中，图片坐标(10,10)的点、(14,14)的点、(20,20)的点，对于最终的识别结果的影响，基本是同一个维度。
再比如在影评中，第10个单词、第20个单词、第30个单词，对于最终结果的影响，也在同一个维度。  
是的，这里指的是数据在维度上的不同。在某些问题中，数据集中的不同数据，对于结果的影响维度完全不同。这是数据所代表的属性意义不同所决定的。这种情况在[《从锅炉工到AI专家(2)》](http://blog.17study.com.cn/2018/01/08/tensorFlow-series-2/)一文中我们做了简单描述，并讲述了使用规范化数据的方式在保持数据内涵的同时降低数据取值范围差异对于最终结果的负面影响。  
随着机器学习应用范围的拓展，不同行业的不同问题，让此类情况出现的越加频繁。特别是在与大数据相连接的商业智能范畴，数据的来源、类型、维度，区别都很大。  
在此我们使用心脏病预测的案例，对结构化数据的预处理做一个分享。  

#### 心脏病预测
我们能从TensorFlow 2.0的变化中看出来，TensorFlow越来越集注，只做好自己擅长的事情。很多必要的工作，TensorFlow会借助第三方的工具来完成。本例中的数据处理，将使用Python的Pandas和sklearn库。这两个库在第一篇的开始部分我们已经安装了。  
样本数据来自于克利夫兰临床基金会，是美国最大的心脏外科中心。样本是一个包含几百行数据的csv文件。每一行属于一个病患，而每一列，则描述病人的某一项指征。我们试图使用这些数据来预测一个病人是否患有心脏病。  
延续我们的习惯，首先关注原始数据。这里只是一个示例，有很多样本的选取只是为了说明问题，并不符合心脏外科的理论。在任何一个机器学习的实际应用中，都应当是专业人员，配合机器学习工程师一起分析、筛选、设计出这样的表格，进而由全部团队配合，得到尽可能多的原始数据。  
样本数据各列的名称和所代表的含义成表如下：  

特征名称| 描述| 特征类型 | 数据类型
:------------|:--------------------|:----------------------|:-----------------
Age | 年龄 | 数值 | integer
Sex | (1 = 男; 0 = 女) | 分类 | integer
CP | 胸腔疼痛类型(0, 1, 2, 3, 4) | 分类 | integer
Trestbpd | 静态血压 (in mm Hg on admission to the hospital) | 数值 | integer
Chol | 胆固醇 in mg/dl | 数值 | integer
FBS | (空腹血糖含量达到120 mg/dl) (1 = 是; 0 = 否) | 分类 | integer
RestECG | 静态心电图 (0, 1, 2) | 分类 | integer
Thalach | 最大心率 | 数值 | integer
Exang | 运动是否引发心绞痛 (1 = 是; 0 = 否) | 分类 | integer
Oldpeak | 运动相对休息诱发ST段压低 | 数值 | integer
Slope | 运动峰ST段坡度 | 数值 | float
CA | 用荧光染色的主要血管数量(0-3)| 数值 | integer
Thal | 地中海贫血：3 = 正常; 6 = 固定缺陷; 7 = 可逆转缺陷 | 分类 | string
Target | 诊出心脏疾病 (1 = 是; 0 = 否) | 分类标注结果 | integer

表格出来，我们的问题也能看的很清楚了，这是一个典型的监督学习。使用表格中所有特征的值，进行模型训练，最后一行的人工确诊结果，相当于标定的目标值。  
正式应用的时候，通过填表、体检获取模型所需各项数据，数据经过模型的预测，就能得到一个可以提供给医生参考的心脏病初步诊断结果。  

Pandas库支持直接使用网址打开数据文件。但考虑到网络访问的问题，建议先手工自<https://storage.googleapis.com/applied-dl/heart.csv>下载数据文件。下载后保存到工作目录，不要修改文件名称。  
接着我们先在Python3交互模式中，直观的看一下数据内容。  
```python
$ python3
Python 3.7.3 (default, Mar 27 2019, 09:23:39) 
[Clang 10.0.0 (clang-1000.11.45.5)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import pandas as pd
>>> dataframe = pd.read_csv('heart.csv')
>>> dataframe.head()
   age  sex  cp  trestbps  chol  fbs  restecg  thalach  exang  oldpeak  slope  ca        thal  target
0   63    1   1       145   233    1        2      150      0      2.3      3   0       fixed       0
1   67    1   4       160   286    0        2      108      1      1.5      2   3      normal       1
2   67    1   4       120   229    0        2      129      1      2.6      2   2  reversible       0
3   37    1   3       130   250    0        0      187      0      3.5      3   0      normal       0
4   41    0   2       130   204    0        2      172      0      1.4      1   0      normal       0
>>> 
```
这些数据中，我们会根据不同数据的特征，采用不同的方式进行预处理。  

以年龄数据为例，年龄是一个数值特征。同专业人员沟通之后就知道，一个人的年龄是31岁还是32岁，对于确诊是否有心脏病帮助并不大。反而年龄段，一个人是30多岁（30-39岁）还是40多岁（40-49岁），对于判断心脏病的可能性帮助更大。所以我们更希望的数据是年龄段数据。  
接着问题来了，即便我们计算得到了年龄段数据，仍然存在数据数字化和规范化的问题。我们怎么表达60-69岁、70-79岁这样的年龄段呢？用了这么久的机器学习，你肯定不会天真的认为计算机就应当知道“年龄段”是啥意思吧。  

#### 常用编码方式
这里打断一下，我们先梳理一下数据数字化的常用编码方式。  
数据的数字化，最常见有三种编码方式，也就是所谓数字化方式。  
第一种是 _One-hot_ 。这种编码方式，把每一项数据当成一个N项的数组，数据有多少种，数组就有多少项。数组中每一个元组取值只有0、1两种形式。并且每一个数组中，只有一项是1。你想到了，前面手写数字识别，有一种样本的标签就是这种形式。手写数字的识别结果，实际也是这种形式。我们用一张表格来描述一下，假设我们对猫、狗、猴、鸡四种动物做编码：  

&nbsp; | 猫 | 狗 | 猴 | 鸡
---|---|---|---
猫|1|0|0|0
狗|0|1|0|0
猴|0|0|1|0
鸡|0|0|0|1

这种方式编码效率最低，直观度也不够。但是通常实现比较容易，速度快，并且适合表达某一特征“是”或者“否”的强烈因素。再者每一分类之间，并没有强烈的连接性关系。  

第二种编码方式最常见，就是 _序列化的唯一值_ 。比如1代表猫；2代表狗；3代表猴；4代表鸡。  
这种方式是我们平常用的最多的，至少下意识的，数据库中每行记录都是一个序列递增值。  
但这种编码方式用在机器学习中通常有比较大的副作用，就是值的大小，往往会在神经网络的数学运算中被赋予我们并不期望的含义。而且这些值，也不适合规范化到0到1、-1到+1这样的浮点数字空间。所以在机器学习领域，除非这种值的递增本身就有特殊的意义，否则并不建议使用。  

第三种编码方式就是我们在NLP中使用的 _向量化_ 。向量化同样首先确定一个N项的数组，每个数组元素值的取值范围会非常广，通常都是用浮点数据。这使得向量化的结果密度很高，能代表更多的分类。  
 不仅如此，对于NLP类的项目，向量化提供了对编码结果进一步调整的机会。两个我们期望更紧密的分类，比如意义相近的词，可以在向量空间中更接近。这个“更接近”如果太抽象，你想象一下二维、或者三维空间中的两个点之间的距离就理解了。  
我们用表格做一个示例(仅为示例，表中数字并无特殊含义)：  

&nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp;
---|---|---|---
猫|1.3|0.7|0.1|2.1|
狗|0.9|1.1|0.9|1.0|
猴|1.8|0.4|1.3|0.8|
鸡|0.6|0.5|0.5|1.3|
...|

其它的编码方案多为这些方案的变种，我们后面在示例讲解的部分会说到。  

#### 结构化数据的预处理 
回到我们的心脏病预测实例。  
年龄段的数据，实际就非常适合One-Hot编码方式。因为我们关注的是某个年龄段的人，属于心脏病的高发人群。特别是在经验数据足够之前，也不能简单的就认为年龄大于多少就高发心脏病。因此年龄的线性特征，在我们的例子中也没有必要过分强调。  
我们把年龄段划分为18岁以下、18-25岁、25-30岁、30-35岁、35-40岁、40-45岁、45-50岁、50-55岁、55-60岁、60-65岁、65岁以上共11个年龄段。  
那如下的年龄数据：  
```python
[[60.]
 [41.]
 [61.]
 [59.]
 [52.]]
```
经过处理之后，就是这样的形式：  
```python
[[0. 0. 0. 0. 0. 0. 0. 0. 0. 1. 0.]
 [0. 0. 0. 0. 0. 1. 0. 0. 0. 0. 0.]
 [0. 0. 0. 0. 0. 0. 0. 0. 0. 1. 0.]
 [0. 0. 0. 0. 0. 0. 0. 0. 1. 0. 0.]
 [0. 0. 0. 0. 0. 0. 0. 1. 0. 0. 0.]]
```
TensorFlow中对于这种情况的数据已经有了专门的处理方式，以下一行语句就是完成这个工作：  
```python
# 代码请在完整程序中执行
age_buckets = feature_column.bucketized_column(age, boundaries=[18, 25, 30, 35, 40, 45, 50, 55, 60, 65])
```
这等于是将线性的年龄数据，变成了年龄段的分类数据。  

我们继续看Thal字段，这代表患者地中海贫血症的表现情况。原始数据包括normal(正常)、fixed(固定)、reversible(可逆转)三种情况。并且在原始数据中，是直接以字符串的形式来表达的。  
我们可以使用下面语句，将Thal字段也转换为one-hot编码方式：  
```python
# 请在完整代码中执行
# 获取thal字段原始数据
thal = feature_column.categorical_column_with_vocabulary_list(
      'thal', ['fixed', 'normal', 'reversible'])
# 转换为one-hot编码
thal_one_hot = feature_column.indicator_column(thal)
```
新的thal字段会是这个样子：  
```python
[[0. 0. 1.]
 [0. 1. 0.]
 [0. 1. 0.]
 [0. 0. 1.]
 [0. 1. 0.]]
```
那么如果实例中不仅这三种可能，而是成千上万中可能呢？你想到了，这种情况就需要选用向量化的编码方式(还记得我们在前面自然语言语义识别中先将单词数字化，然后再嵌入向量中的例子吗？)，比如：  
```python
# 此代码不要执行，仅为示例
# 将thal字段嵌入到8维空间
thal_embedding = feature_column.embedding_column(thal, dimension=8)
```
编码的结果会类似这样：  
```python
[[ 0.15909313 -0.17830053 -0.01482905  0.26818395 -0.7063258   0.17809148
  -0.33043832  0.34121528]
 [ 0.2877485   0.20686264  0.2649153  -0.2827308   0.10686944 -0.12080232
  -0.28829345  0.43876123]
 [ 0.2877485   0.20686264  0.2649153  -0.2827308   0.10686944 -0.12080232
  -0.28829345  0.43876123]
 [ 0.15909313 -0.17830053 -0.01482905  0.26818395 -0.7063258   0.17809148
  -0.33043832  0.34121528]
 [ 0.2877485   0.20686264  0.2649153  -0.2827308   0.10686944 -0.12080232
  -0.28829345  0.43876123]]
```
在分类可能性非常多的时候，还有一种可选的编码方案是使用哈希表：  
```python
# 本代码仅为示例，不要执行
thal_hashed = feature_column.categorical_column_with_hash_bucket(
      'thal', hash_bucket_size=1000)
```
某两项或者某多项字段互相关联作用，需要整体表达的情况也很常见。这时候可以使用feature crosses编码方式：  
```python
# 本代码仅为示例，不要执行
crossed_feature = feature_column.crossed_column([age_buckets, thal], hash_bucket_size=1000)
```
上面三个编码都是为了说明编码方式本身，医学方面的工作者千万不要用来参考。  

#### 建模
建模本身跟前几篇讲过的基本相同。网络的第一层也就是数据的输入层需要单独说明一下，那就是Keras已经为这种复杂的自定义结构化数据提供了输入层的支持：  
```python
# 定义输入层
feature_layer = tf.keras.layers.DenseFeatures(feature_columns)

# 将输入层一定要放在模型的第一层
model = tf.keras.Sequential([
  feature_layer,
  layers.Dense(128, activation='relu'),
  layers.Dense(128, activation='relu'),
  layers.Dense(1, activation='sigmoid')
])
```
有了自定义结构化数据的自动处理，节省了我们在TensorFlow1.0中需要自己操作的大量预处理过程，工作量减少，出错的几率也少了。  
模型的训练和评估就都是一条语句，略去不讲。  

#### 完整代码
好了，贴出完整的可执行代码：  
```python
#!/usr/bin/env python3
from __future__ import absolute_import, division, print_function

# 引入所需头文件
import numpy as np
import pandas as pd
import tensorflow as tf
from tensorflow import feature_column
from tensorflow.keras import layers
from sklearn.model_selection import train_test_split

# 打开样本数据文件
# URL = 'https://storage.googleapis.com/applied-dl/heart.csv'   #直接从网上打开可以使用这一行
URL = 'heart.csv'
dataframe = pd.read_csv(URL)
# 显示数据的头几行
# dataframe.head()

# 将数据中20%分做测试数据
train, test = train_test_split(dataframe, test_size=0.2)
# 将数据的64%作为训练数据，16%作为验证数据
train, val = train_test_split(train, test_size=0.2)
# 显示训练、验证、测试三个数据集的记录数量
print(len(train), 'train examples')
print(len(val), 'validation examples')
print(len(test), 'test examples')

# 定义一个函数，将Pandas Dataframe对象转换为TensorFlow的Dataset对象
def df_to_dataset(dataframe, shuffle=True, batch_size=32):
    dataframe = dataframe.copy()
    # target字段是确诊是否罹患心脏病的数据，取出来作为标注数据
    labels = dataframe.pop('target')
    # 生成Dataset
    ds = tf.data.Dataset.from_tensor_slices((dict(dataframe), labels))
    if shuffle:
        # 是否需要乱序
        ds = ds.shuffle(buffer_size=len(dataframe))
    # 设置每批次的记录数量
    ds = ds.batch(batch_size)
    return ds

# 训练、验证、测试三个数据集都转换成Dataset类型，其中训练集需要重新排序
train_ds = df_to_dataset(train)
val_ds = df_to_dataset(val, shuffle=False)
test_ds = df_to_dataset(test, shuffle=False)

# 用于保存所需的数据列
feature_columns = []

# 根据字段名，添加所需的数据列
for header in ['age', 'trestbps', 'chol', 'thalach', 'oldpeak', 'slope', 'ca']:
    feature_columns.append(feature_column.numeric_column(header))

# 取出年龄数据
age = feature_column.numeric_column("age")
# 按照18-25/25-30/30-35/.../60-65为年龄分段，最后形成one-hot编码
age_buckets = feature_column.bucketized_column(age, boundaries=[18, 25, 30, 35, 40, 45, 50, 55, 60, 65])
# 数据段作为一个新参量添加到数据集
feature_columns.append(age_buckets)

# 获取thal字段原始数据
thal = feature_column.categorical_column_with_vocabulary_list(
      'thal', ['fixed', 'normal', 'reversible'])
# 做one-hot编码
thal_one_hot = feature_column.indicator_column(thal)
# 作为新的数据列添加
feature_columns.append(thal_one_hot)

# 将thal嵌入8维空间做向量化
thal_embedding = feature_column.embedding_column(thal, dimension=8)
feature_columns.append(thal_embedding)

# 把年龄段和thal字段作为关联属性加入新列
crossed_feature = feature_column.crossed_column([age_buckets, thal], hash_bucket_size=1000)
crossed_feature = feature_column.indicator_column(crossed_feature)
feature_columns.append(crossed_feature)

# 定义输入层
feature_layer = tf.keras.layers.DenseFeatures(feature_columns)

# 定义完整模型
model = tf.keras.Sequential([
  feature_layer,
  layers.Dense(128, activation='relu'),
  layers.Dense(128, activation='relu'),
  layers.Dense(1, activation='sigmoid')
])

# 模型编译
model.compile(optimizer='adam',
              loss='binary_crossentropy',
              metrics=['accuracy'])

# 训练
model.fit(train_ds, 
          validation_data=val_ds, 
          epochs=5)
# 评估
test_loss, test_acc = model.evaluate(test_ds)
# 显示评估的正确率
print('===================\nTest accuracy:', test_acc)
```
这样的内容，的确是使用IPython笔记本的互动方式边讲边试效果最好。不过可惜国内访问Colab这样的工具网站还是不方便。  
上面程序执行的输出如下：  
```python
Epoch 1/5
7/7 [==============================] - 1s 110ms/step - loss: 1.2045 - accuracy: 0.5884 - val_loss: 1.1234 - val_accuracy: 0.7755
Epoch 2/5
7/7 [==============================] - 0s 46ms/step - loss: 1.0691 - accuracy: 0.6383 - val_loss: 0.5731 - val_accuracy: 0.7959
Epoch 3/5
7/7 [==============================] - 0s 43ms/step - loss: 0.9016 - accuracy: 0.7100 - val_loss: 0.5924 - val_accuracy: 0.7551
Epoch 4/5
7/7 [==============================] - 0s 44ms/step - loss: 0.5362 - accuracy: 0.7055 - val_loss: 0.6440 - val_accuracy: 0.7755
Epoch 5/5
7/7 [==============================] - 0s 43ms/step - loss: 0.7290 - accuracy: 0.6940 - val_loss: 0.5966 - val_accuracy: 0.7347
2/2 [==============================] - 0s 24ms/step - loss: 0.4600 - accuracy: 0.7705
===================
Test accuracy: 0.7704918
```
为了说明数据的预处理，我们选用了一些并不合理的特征项用于演示。再加上较少的训练数据和训练过程，预测准确率很低也就没有什么好奇怪了。  

最后还有一个问题要补充。就是比如年龄字段，我们已经预处理并且增加了一个年龄段字段，那原来的年龄字段还需要保留吗？  
我们上面的代码仅为示例，保留了年龄字段，但这并不能说明什么问题。类似这样的字段是否保留，关键还是看专业方面的需求。如果觉得年龄的线性特征本身对于预测结果还是有意义的，那就保留。额外增加的年龄段等于是一个强调的作用。  
如果觉得年龄原始数据本身并没有什么意义，用年龄段表达足以说明问题，那年龄字段就应当去掉。通常说，在机器学习中，如果特征项非常多的话，单独一个年龄字段保留或者不保留，对最终结果的影响都不大，不用太过认真。  
与此对应的，thal字段，原本就是字符串类型。这种字段一定需要预处理之后再进入数据集，而原始的字段是不能保留在数据集中的。字符串在神经网络中不能直接处理是一方面。即便能处理，这种无数学意义的高维数据对最终结果一定有很大的负面影响。  

（待续...）  

