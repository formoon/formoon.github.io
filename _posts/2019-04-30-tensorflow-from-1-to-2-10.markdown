---
layout:         page
title:          TensorFlow从1到2（十）
subtitle:       带注意力机制的神经网络机器翻译
card-image:		http://blog.17study.com.cn/attachments/201904/tensorFlow2/tf-logo-card-2.png
date:           2019-04-30
tags:           tensorflow
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201904/tensorFlow2/tf-logo-card-2.png)  
#### 基本概念
机器翻译和语音识别是最早开展的两项人工智能研究。今天也取得了最显著的商业成果。  
早先的机器翻译实际脱胎于电子词典，能力更擅长于词或者短语的翻译。那时候的翻译通常会将一句话打断为一系列的片段，随后通过复杂的程序逻辑对每一个片段进行翻译，最终组合在一起。所得到的翻译结果应当说似是而非，最大的问题是可读性和连贯性非常差。  
实际从机器学习的观点来讲，这种翻译方式，也不符合人类在做语言翻译时所做的动作。其实以神经网络为代表的机器学习，更多的都是在“模仿”人类的行为习惯。  
一名职业翻译通常是这样做：首先完整听懂要翻译的语句，将语义充分理解，随后把理解到的内容，用目标语言复述出来。  
而现在的机器翻译，也正是这样做的，谷歌的[seq2seq](https://github.com/tensorflow/nmt)是这一模式的开创者。  
如果用计算机科学的语言来说，这一过程很像一个编解码过程。原始的语句进入编码器，得到一组用于代表原始语句“内涵”的数组。这些数组中的数字就是原始语句所代表的含义，只是这个含义人类无法读懂，是需要由神经网络模型去理解的。随后解码过程，将“有含义的数字”解码为对应的目标语言。从而完成整个翻译过程。这样的得到的翻译结果，非常流畅，具有更好的可读性。  
![](http://blog.17study.com.cn/attachments/201904/tensorFlow2/nmt-encdec.jpg)  
（图片来自谷歌NMT文档）  

注意力机制是人类特有的大脑思维方式，比如看到下面这幅照片：
![](http://blog.17study.com.cn/attachments/201904/tensorFlow2/nmt-attention.png)  
（图片来自互联网）  
照片的内容实际很多，甚至如果从数学上说，背景树林的复杂度要高于前景。但看到照片的人，都会先注意到迎面而来的飞盘，随后是投掷者，接着是图像右侧的小孩子。其它的信息都被忽略了。  
这是人类在上万年的进化中所形成的本能。对于快速向自己移动的物体首先会看到、识别危险、并且快速应对。接着是可能对自己造成威胁的同类或者生物。为了做到集注，不得不忽略看起来无关紧要的东西。  
在机器学习中引入注意力模型，在图像处理、机器翻译、策略博弈等各个领域中都有应用。这里的注意力机制有两个作用：一是降低模型的复杂度或者计算量，把主要资源分配给更重要的内容。二是对应把最相关的输入导出到相关的输出，更有针对性的得到结果。  

在机器翻译领域，前面我们已经确定和解释了编码、解码模型。那么第二点的输入输出相关性就显得更重要。  
我们举例来说明：比如英文“I love you”，翻译为中文是“我爱你”。在一个编码解码模型中，首先由编码器处理“I love you”，从而得到中间语义，比如我们称为C：  
```python
	C = Encoder("I love you")  
```
解码的时候，如果没有注意力机制，那序列输出则是：  
```python
	"我" = Decoder(C)  
	"爱" = Decoder(C)  
	"你" = Decoder(C)  
```
因为C相当于“I love you”三个单词共同的作用。那么解码的时候，每一个字的输出，都相当于3个单词共同作用的结果。这显然是不合理的，而且也不大可能得到一个理想、顺畅的结果。  
一个理想的解码模型应当类似这样的方式：  
```python
	"我" = Decoder(C+"I")  
	"爱" = Decoder(C+"love")  
	"你" = Decoder(C+"you")  
```
当然，机器学习不是人。人通过大量的学习、经验的积累，一眼就能看出来“I”对应翻译成“我”，“love”翻译成“爱”。机器不可能提前知道这一切，所以我们比较切实的方法，只能是增加一套权重逻辑，在不同的翻译处理中，对应不同的权重属性。这就好像下面这样的方式：  
```python
	"我" = Decoder(C+0.8x"I"+0.1x"love"+0.2x"you")  
	"爱" = Decoder(C+0.1x"I"+0.7x"love"+0.1x"you")  
	"你" = Decoder(C+0.2x"I"+0.1x"love"+0.8x"you")  
```
没错了，这个权重值，比如翻译“我”的时候的权重序列：(0.8,0.1,0.2)，就是注意力机制。在翻译某个目标单词输出的时候，通过注意力机制，模型集注在对应的某个输入单词。  
当然，注意力机制还包含上面示意性的表达式没有显示出来的一个重要操作：结合解码器的当前状态、和编码器输入内容之后的状态，在每一次翻译解码操作中更新注意力的权重值。  

#### 翻译模型
回到上面的编解码模型示意图。编码器、解码器在我们的机器学习中，实际都是神经网络模型。那么把上面的示意图展开，一个没有注意力机制的编码、解码翻译模型是这个样子：  
![](http://blog.17study.com.cn/attachments/201904/tensorFlow2/nmt-seq2seq.jpg)  
（图片来自谷歌NMT文档）  

随后，我们为这个模型增加解码时候的权重机制。模型在处理每个单词输出的时候，会在权重的帮助下，把重点放在对应的输入单词上。示意图如下：  
![](http://blog.17study.com.cn/attachments/201904/tensorFlow2/nmt-greedy_dec.jpg)  
（图片来自谷歌NMT文档）  

最终，结合权重生成的过程，成为完整的注意力机制。注意力机制主要作用于解码，在每一个输出步骤中都要重新计算注意力权重，并更新到解码模型从而对输出产生影响。模型的示意图如下：  
![](http://blog.17study.com.cn/attachments/201904/tensorFlow2/nmt-attention_mechanism.jpg)  
（图片来自谷歌NMT文档）  
图片中注意力权重的来源和去向箭头，要注意看清楚，这对你下面阅读实现的代码会很有帮助。  

#### 样本及样本预处理
前面的编解码模型示意图，还有模拟的表达式，当然都做了很多简化。实际上中间还有很多工作要做，首先是翻译样本库。  

本例中使用<http://www.manythings.org/anki/>提供的英文对比西班牙文样本库，网站上还有很多其它语言的对比样本可以下载，有兴趣的读者不妨在做完这个练习后尝试一下其它语言的机器翻译。  
这个样本是文本格式，包含很多行，每一行都是一个完整的句子，包含英文和西班牙文两部分，两种文字之间使用制表符隔开，比如：  
```bash
May I borrow this book? ¿Puedo tomar prestado este libro?
```
对于样本库，我们要进行以下几项预处理：  
* 读取样本库，建立数据集。每一行的样本按语言分为两个部分。  
* 为每一句样本，增加开始标志`<start>`和结束标志`<end>`。看过[《从锅炉工到AI专家(10)》](http://blog.17study.com.cn/2018/01/17/tensorFlow-series-10/)的话，你应当理解这种做法。经过训练后，模型会根据这两个标志作为翻译的开始和结束。  

做完上面的处理后，刚才的那行样本看起来会是这个样子：  
```bash
<start> may i borrow this book ? <end>
<start> ¿ puedo tomar prestado este libro ? <end>
```
注意标点符号也是语言的组成部分，每个部分用空格隔开，都需要单独数字化。所以你能看到，上面的两行例句，标点符号之前也添加了空格。  
* 进行数据清洗，去掉不支持的字符。
* 把单词数字化，建立从单词到数字和从数字到单词的对照表。
* 设置一个句子的最大长度，把每个句子按照最大长度在句子的后端补齐。

一行句子数字化之后，编码同单词之间的对照关系可能类似下面的样子：  
```bash
Input Language; index to word mapping
1 ----> <start>
8 ----> no
38 ----> puedo
804 ----> confiar
20 ----> en
1000 ----> vosotras
3 ----> .
2 ----> <end>

Target Language; index to word mapping
1 ----> <start>
4 ----> i
25 ----> can
12 ----> t
345 ----> trust
6 ----> you
3 ----> .
2 ----> <end>
```
你可能注意到了，“can't”中的单引号作为不支持的字符被过滤掉了，不过你放心，这并不会影响模型的训练。当然在一个完善的翻译系统中，这样的字符都应当单独处理，本例中就忽略了。  

#### 模型构建
本例中使用了编码器、解码器、注意力机制三个网络模型，都继承自keras.Model，属于三个自定义的Keras模型。  
三个模型共同组成了完整的翻译模型。完整模型的组装，是在训练过程和翻译（预测）过程中，通过相应子程序把他们组装在一起的。这是因为它们三者之间的逻辑机制相对比较复杂。无法用前面常用的keras.models.Sequential方法直接耦合在一起。  
自定义Keras模型在本系列中是第一次遇到，所以着重讲一下。实现自定义模型有三个基本要求：  
* 继承自keras.Model类。
* 实现`__init__`方法，用于实现类的初始化，同所有面向对象的语言一样，这里主要完成基类和类成员的初始化工作。
* 实现call方法，这是主要的计算逻辑。模型接入到神经网络之后，训练逻辑和预测逻辑，都通过逐层调用call方法来完成计算。方法中可以使用keras中原有的网络模型和自己的计算通过组合来完成工作。  

自定义模型之所以有这些要求，主要是为了自定义的模型，可以跟Keras原生层一样，互相兼容，支持多种模型的组合、互联，从而共同形成更复杂的模型。  

Encoder/Decoder主体都使用GRU网络，读起来应当比较容易理解。有需要的话，复习一下[《从锅炉工到AI专家(10)》](http://blog.17study.com.cn/2018/01/17/tensorFlow-series-10/)。  
注意力机制的BahdanauAttention模型就很令人费解了，困惑的关键在于其中的算法。算法的计算部分只有两行代码，代码本身都知道是在做什么，但完全不明白组合在一起是什么功能以及为什么这样做。其实阅读由数学公式推导、转换而来的程序代码都有这种感觉。所以现在很多的知识保护，根本不在于源代码，而在于公式本身。没有公式，很多源代码非常难以读懂。  
这部分推荐阅读Dzmitry Bahdanau的论文[《Neural Machine Translation by Jointly Learning to Align and Translate》](https://arxiv.org/abs/1409.0473)和之后Minh-Thang Luong改进的算法[《Effective Approaches to Attention-based Neural Machine Translation》](https://arxiv.org/abs/1508.04025)。论文中对于理论做了详尽解释，也有公式的推导过程。  
这里的BahdanauAttention模型实际就是公式的程序实现。如果精力不够的话，死记公式也算一种学习方法。  

##### 训练和预测
我们以往碰到的模型，训练和预测基本都是一行代码，几乎没有什么需要解释的。  
今天的模型涉及了带有注意力机制的自定义模型，主要的逻辑，是通过程序代码，在训练和评估子程序中把模型组合起来完成的。  
程序如果只是编码器和解码器串联的逻辑，完全可以同以前一样，一条keras.Sequential函数完成组装，那就一点难度没有了。而加上注意力机制，复杂度高了很多，也是最难理解的地方。做一个简单的分析：  
* 编码器Encoder是一次整句编码，得到一个enc_output。enc_output相当于模型对整句语义的理解。
* 解码器Decoder是逐个单词输入，逐个单词输出的。训练时，输入序列由`<start>`起始标志开始，到`<end>`标志结束。预测时，没有人知道这一句翻译的结果是多少个单词，就是逐个获取Decoder的输出，直到得到一个`<end>`标志。
* Encoder和Decoder都引出了隐藏层，用于计算注意力权重。keras.layers.GRU的state输出其实就是隐藏层，平时这个参数我们是用不到的。
* 对于每一个翻译的输出词，注意力对其影响就是通过`attention_weights * values`，然后将结果跟前一个输出词一起作为Decoder的GRU输入，values实际就是编码器输出enc_output。
* Decoder输出上一个词时候的隐藏层，跟enc_output一起通过公式计算，得到下一个词的注意力权重attention_weights。在第一次循环的时候Decoder还没有输出过隐藏层，这时候使用的是Encoder的隐藏层。
* 注意力权重attention_weights从程序逻辑上并不需要引出，程序中在Decoder中输出这个值是为了绘制注意力映射图，帮助你更好的理解注意力机制。所以如果是在这个基础上做翻译系统，输出权重值到模型外部是不需要的。
* 为了匹配各个网络的不同维度和不同形状，注意力机制的计算逻辑和注意力权重经过了各种维度变形。Decoder的输入虽然是一个词，但也需要扩展成一批词的第一个元素（也是唯一一个元素），这个跟我们以前的模型在预测时所做的是完全一样的。

#### 完整源码
下面是完整的可执行源代码，请参考注释阅读：  
```python
#!/usr/bin/env python3

from __future__ import absolute_import, division, print_function, unicode_literals

import tensorflow as tf

import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split

import unicodedata
import re
import numpy as np
import os
import io
import time
import sys

# 如果命令行增加了参数'train'则进入训练模式，否则按照翻译模式执行
TRAIN = False
if len(sys.argv) == 2 and sys.argv[1] == 'train':
    TRAIN = True

# 下载样本集，下载后自动解压。数据保存在路径：~/.keras/datasets/
path_to_zip = tf.keras.utils.get_file(
    'spa-eng.zip',
    origin='http://storage.googleapis.com/download.tensorflow.org/data/spa-eng.zip',
    extract=True)
# 指向解压后的样本文件
path_to_file = os.path.dirname(path_to_zip)+"/spa-eng/spa.txt"

# 将文本从unicode编码转换为ascii编码
def unicode_to_ascii(s):
    return ''.join(
        c for c in unicodedata.normalize('NFD', s)
        if unicodedata.category(c) != 'Mn')

# 对所有的句子做预处理
def preprocess_sentence(w):
    w = unicode_to_ascii(w.lower().strip())

    # 在单词和标点之间增加空格
    # 比如: "he is a boy." => "he is a boy ."
    # 参考: https://stackoverflow.com/questions/3645931/python-padding-punctuation-with-white-spaces-keeping-punctuation
    w = re.sub(r"([?.!,¿])", r" \1 ", w)
    w = re.sub(r'[" "]+', " ", w)

    # 用空格替换掉除了大小写字母和"."/ "?"/ "!"/ ","之外的字符
    w = re.sub(r"[^a-zA-Z?.!,¿]+", " ", w)
    # 截断两端的空白
    w = w.rstrip().strip()

    # 在句子两端增加开始和结束标志
    # 这样经过训练后，模型知道什么时候开始和什么时候结束
    w = '<start> ' + w + ' <end>'
    return w

# 载入样本集，对句子进行预处理
# 最终返回(英文,西班牙文)这样的配对元组
def create_dataset(path, num_examples):
    lines = io.open(path, encoding='UTF-8').read().strip().split('\n')

    word_pairs = [[preprocess_sentence(w) for w in l.split('\t')]  for l in lines[:num_examples]]

    return zip(*word_pairs)
# 至此的输出为：
# <start> go away ! <end>
# <start> salga de aqui ! <end>
# 这样的形式。

# 获取最长的句子长度
def max_length(tensor):
    return max(len(t) for t in tensor)

# 将单词数字化之后的数字<->单词双向对照表
def tokenize(lang):
    lang_tokenizer = tf.keras.preprocessing.text.Tokenizer(
        filters='')
    lang_tokenizer.fit_on_texts(lang)

    tensor = lang_tokenizer.texts_to_sequences(lang)

    tensor = tf.keras.preprocessing.sequence.pad_sequences(
        tensor,
        padding='post')

    return tensor, lang_tokenizer

def load_dataset(path, num_examples=None):
    # 载入样本，两种语言分别保存到两个数组
    targ_lang, inp_lang = create_dataset(path, num_examples)
    # 把句子数字化，两种语言是两套对照编码
    input_tensor, inp_lang_tokenizer = tokenize(inp_lang)
    target_tensor, targ_lang_tokenizer = tokenize(targ_lang)

    return input_tensor, target_tensor, inp_lang_tokenizer, targ_lang_tokenizer

# 训练的样本集数量，越大翻译效果越好，但训练耗时越长
num_examples = 80000
input_tensor, target_tensor, inp_lang, targ_lang = load_dataset(path_to_file, num_examples)
# 至此，input_tensor/target_tensor 是数字化之后的样本（数字数组）
# inp_lang/targ_lang 是数字<->单词编码对照表
# 计算两种语言中最长句子的长度
max_length_targ, max_length_inp = max_length(target_tensor), max_length(input_tensor)

# 将样本按照8:2分为训练集和验证集
input_tensor_train, input_tensor_val, target_tensor_train, target_tensor_val = train_test_split(input_tensor, target_tensor, test_size=0.2)

##############################################

BUFFER_SIZE = len(input_tensor_train)
BATCH_SIZE = 64
steps_per_epoch = len(input_tensor_train)//BATCH_SIZE
embedding_dim = 256
units = 1024
vocab_inp_size = len(inp_lang.word_index)+1
vocab_tar_size = len(targ_lang.word_index)+1

dataset = tf.data.Dataset.from_tensor_slices((input_tensor_train, target_tensor_train)).shuffle(BUFFER_SIZE)
dataset = dataset.batch(BATCH_SIZE, drop_remainder=True)

# 编码器模型
class Encoder(tf.keras.Model):
    def __init__(self, vocab_size, embedding_dim, enc_units, batch_sz):
        super(Encoder, self).__init__()
        self.batch_sz = batch_sz
        self.enc_units = enc_units
        self.embedding = tf.keras.layers.Embedding(vocab_size, embedding_dim)
        self.gru = tf.keras.layers.GRU(
                                    self.enc_units, 
                                    return_sequences=True, 
                                    return_state=True, 
                                    recurrent_initializer='glorot_uniform')

    def call(self, x, hidden):
        x = self.embedding(x)
        output, state = self.gru(x, initial_state=hidden)
        return output, state

    def initialize_hidden_state(self):
        return tf.zeros((self.batch_sz, self.enc_units))

encoder = Encoder(vocab_inp_size, embedding_dim, units, BATCH_SIZE)

# 注意力模型
class BahdanauAttention(tf.keras.Model):
    def __init__(self, units):
        super(BahdanauAttention, self).__init__()
        self.W1 = tf.keras.layers.Dense(units)
        self.W2 = tf.keras.layers.Dense(units)
        self.V = tf.keras.layers.Dense(1)

    def call(self, query, values):
        # query为上次的GRU隐藏层
        # values为编码器的编码结果enc_output
        hidden_with_time_axis = tf.expand_dims(query, 1)

        # 计算注意力权重值
        score = self.V(tf.nn.tanh(
            self.W1(values) + self.W2(hidden_with_time_axis)))

        attention_weights = tf.nn.softmax(score, axis=1)

        # 使用注意力权重*编码器输出作为返回值，将来会作为解码器的输入
        context_vector = attention_weights * values
        context_vector = tf.reduce_sum(context_vector, axis=1)

        return context_vector, attention_weights

# 解码器模型
class Decoder(tf.keras.Model):
    def __init__(self, vocab_size, embedding_dim, dec_units, batch_sz):
        super(Decoder, self).__init__()
        self.batch_sz = batch_sz
        self.dec_units = dec_units
        self.embedding = tf.keras.layers.Embedding(vocab_size, embedding_dim)
        self.gru = tf.keras.layers.GRU(
            self.dec_units, 
            return_sequences=True,
            return_state=True, 
            recurrent_initializer='glorot_uniform')
        self.fc = tf.keras.layers.Dense(vocab_size)

        self.attention = BahdanauAttention(self.dec_units)

    def call(self, x, hidden, enc_output):
        # 使用上次的隐藏层（第一次使用编码器隐藏层）、编码器输出计算注意力权重
        context_vector, attention_weights = self.attention(hidden, enc_output)

        x = self.embedding(x)

        # 将上一循环的预测结果跟注意力权重值结合在一起作为本次的GRU网络输入
        x = tf.concat([tf.expand_dims(context_vector, 1), x], axis=-1)

        # state实际是GRU的隐藏层
        output, state = self.gru(x)

        output = tf.reshape(output, (-1, output.shape[2]))

        x = self.fc(output)

        return x, state, attention_weights

decoder = Decoder(vocab_tar_size, embedding_dim, units, BATCH_SIZE)


optimizer = tf.keras.optimizers.Adam()
loss_object = tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)

# 损失函数
def loss_function(real, pred):
    mask = tf.math.logical_not(tf.math.equal(real, 0))
    loss_ = loss_object(real, pred)

    mask = tf.cast(mask, dtype=loss_.dtype)
    loss_ *= mask

    return tf.reduce_mean(loss_)

# 保存中间训练结果
checkpoint_dir = './training_checkpoints'
checkpoint_prefix = os.path.join(checkpoint_dir, "ckpt")
checkpoint = tf.train.Checkpoint(optimizer=optimizer,
                                 encoder=encoder,
                                 decoder=decoder)

# 一次训练
@tf.function
def train_step(inp, targ, enc_hidden):
    loss = 0

    with tf.GradientTape() as tape:
        # 输入源语言句子进行编码
        enc_output, enc_hidden = encoder(inp, enc_hidden)
        # 保留编码器隐藏层用于第一次的注意力权重计算
        dec_hidden = enc_hidden

        # 解码器第一次的输入必定是<start>，targ_lang.word_index['<start>']是转换为对应的数字编码
        dec_input = tf.expand_dims([targ_lang.word_index['<start>']] * BATCH_SIZE, 1)       

        # 循环整个目标句子（用于对比每一次解码器输出同样本的对比）
        for t in range(1, targ.shape[1]):
            # 使用本单词、隐藏层、编码器输出共同预测下一个单词，同事保留本次的隐藏层作为下一次输入
            predictions, dec_hidden, _ = decoder(dec_input, dec_hidden, enc_output)
            # 计算损失值，最终的损失值是整个句子所有单词损失值的合计
            loss += loss_function(targ[:, t], predictions)

            # 在训练时，每次解码器的输入并不是上次解码器的输出，而是样本目标语言对应单词
            # 这称为teach forcing
            dec_input = tf.expand_dims(targ[:, t], 1)

    # 所有单词的平均损失值
    batch_loss = (loss / int(targ.shape[1]))
    # 最终的训练参量是编码器和解码的集合
    variables = encoder.trainable_variables + decoder.trainable_variables
    # 根据代价值计算下一次的参量值
    gradients = tape.gradient(loss, variables)
    # 将新的参量应用到模型
    optimizer.apply_gradients(zip(gradients, variables))

    return batch_loss

def training():
    EPOCHS = 10

    for epoch in range(EPOCHS):
        start = time.time()
        # 初始化隐藏层和损失值
        enc_hidden = encoder.initialize_hidden_state()
        total_loss = 0

        # 一个批次的训练
        for (batch, (inp, targ)) in enumerate(dataset.take(steps_per_epoch)):
            batch_loss = train_step(inp, targ, enc_hidden)
            total_loss += batch_loss

        # 每100次显示一下模型损失值
        if batch % 100 == 0:
            print('Epoch {} Batch {} Loss {:.4f}'.format(
                                                        epoch + 1,
                                                        batch,
                                                        batch_loss.numpy()))
        # 每两次迭代保存一次数据
        if (epoch + 1) % 2 == 0:
            checkpoint.save(file_prefix=checkpoint_prefix)
        # 显示每次迭代的损失值和消耗时间
        print('Epoch {} Loss {:.4f}'.format(epoch + 1,
                                            total_loss / steps_per_epoch))
        print('Time taken for 1 epoch {} sec\n'.format(time.time() - start))

# 根据命令行参数选择本次是否进行训练
if TRAIN:
    training()
################################################

# 评估（翻译）一行句子
def evaluate(sentence):
    # 清空注意力图
    attention_plot = np.zeros((max_length_targ, max_length_inp))
    # 句子预处理
    sentence = preprocess_sentence(sentence)
    # 句子数字化
    inputs = [inp_lang.word_index[i] for i in sentence.split(' ')]
    # 按照最长句子长度补齐
    inputs = tf.keras.preprocessing.sequence.pad_sequences([inputs], 
                                                           maxlen=max_length_inp, 
                                                           padding='post')
    inputs = tf.convert_to_tensor(inputs)

    result = ''

    # 句子做编码
    hidden = [tf.zeros((1, units))]
    enc_out, enc_hidden = encoder(inputs, hidden)

    # 编码器隐藏层作为第一次解码器的隐藏层值
    dec_hidden = enc_hidden
    # 解码第一个单词必然是<start>,表示启动解码
    dec_input = tf.expand_dims([targ_lang.word_index['<start>']], 0)

    # 假设翻译结果不超过最长的样本句子
    for t in range(max_length_targ):
        # 逐个单词翻译
        predictions, dec_hidden, attention_weights = decoder(dec_input,
                                                             dec_hidden,
                                                             enc_out)

        # 保留注意力权重用于绘制注意力图
        # 注意每次循环的每个单词注意力权重是不同的
        attention_weights = tf.reshape(attention_weights, (-1, ))
        attention_plot[t] = attention_weights.numpy()

        # 得到预测值
        predicted_id = tf.argmax(predictions[0]).numpy()

        # 从数字查表转换为对应单词，累加到上一次结果，最终组成句子
        result += targ_lang.index_word[predicted_id] + ' '

        # 如果是<end>表示翻译结束
        if targ_lang.index_word[predicted_id] == '<end>':
            return result, sentence, attention_plot

        # 上次的预测值，将作为下次解码器的输入
        dec_input = tf.expand_dims([predicted_id], 0)
    # 如果超过样本中最长的句子仍然没有翻译结束标志，则返回当前所有翻译结果
    return result, sentence, attention_plot

# 绘制注意力图
def plot_attention(attention, sentence, predicted_sentence):
    fig = plt.figure(figsize=(10,10))
    ax = fig.add_subplot(1, 1, 1)
    ax.matshow(attention, cmap='viridis')

    fontdict = {'fontsize': 14}

    ax.set_xticklabels([''] + sentence, fontdict=fontdict, rotation=90)
    ax.set_yticklabels([''] + predicted_sentence, fontdict=fontdict)

    plt.show()

# 翻译一句文本
def translate(sentence):
    result, sentence, attention_plot = evaluate(sentence)

    print('Input: %s' % (sentence))
    print('Predicted translation: {}'.format(result))

    attention_plot = attention_plot[:len(result.split(' ')), :len(sentence.split(' '))]
    plot_attention(attention_plot, sentence.split(' '), result.split(' '))

# 恢复保存的训练结果
checkpoint.restore(tf.train.latest_checkpoint(checkpoint_dir))

# 测试以下翻译
translate(u'hace mucho frio aqui.')
translate(u'esta es mi vida.')
translate(u'¿todavia estan en casa?')
# 据说这句话的翻译结果不对，不懂西班牙文，不做评论
translate(u'trata de averiguarlo.')
```
第一次执行的时候要加参数tain:  
```bash
$ ./translate_spa2en.py train
Epoch 1 Batch 0 Loss 4.5296
Epoch 1 Batch 100 Loss 2.2811
Epoch 1 Batch 200 Loss 1.7985
Epoch 1 Batch 300 Loss 1.6724
Epoch 1 Loss 2.0235
Time taken for 1 epoch 149.3063322815 sec
	...训练过程略...
	
Input: <start> hace mucho frio aqui . <end>
Predicted translation: it s very cold here . <end> 
Input: <start> esta es mi vida . <end>
Predicted translation: this is my life . <end> 
Input: <start> ¿ todavia estan en casa ? <end>
Predicted translation: are you still at home ? <end> 
Input: <start> trata de averiguarlo . <end>
Predicted translation: try to figure it out . <end> 
```
以后如果只是想测试翻译效果，可以不带train参数执行，直接看翻译结果。  
对于每一个翻译句子，程序都会绘制注意力矩阵图：  
![](http://blog.17study.com.cn/attachments/201904/tensorFlow2/nmt-attention1.png)  
通常语法不是很复杂的句子，基本是顺序对应关系，所以注意力亮点基本落在对角线上。  
图中X坐标是西班牙文单词，Y坐标是英文单词。每个英文单词，沿X轴看，亮点对应的X轴单词，表示对于翻译出这个英文单词，是哪一个西班牙文单词权重最大。  

（待续...）  

