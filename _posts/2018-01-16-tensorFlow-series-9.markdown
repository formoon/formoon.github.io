---
layout:         page
title:          从锅炉工到AI专家(9)
subtitle:       TensorFlow实务
card-image:     http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorflowlogo.jpg
date:           2018-01-16
tags:           ml toSeven
post-card-type: image
---
#### 无监督学习
前面已经说过了无监督学习的概念。无监督学习在实际的工作中应用还是比较多见的。  
从典型的应用上说，监督学习比较多用在“分类”上，利用给定的数据，做出一个决策，这个决策在有限的给定可能性中选择其中一种。各类识别、自动驾驶等都属于这一类。  
无监督学习则是“聚类”，算法自行寻找输入数据集的规律，并把它们按照规律分别组合，同样特征的放到一个类群。像自然语言理解、推荐算法、数据画像等，都属于这类（实际实现中还是比较多用半监督学习，但最早概念的导入还是属于无监督学习）。  
无监督学习的确是没有人工的标注，但所有输入的数据都必须保持原有的、必然存在的内在规律。为了保持这些规律或者挑选典型的规律，经常还是需要一些人力。  
介于两者之间的还有半监督学习，比如一半数据有标注，一半数据无标注。通过已标注数据分类，然后将无标注数据“聚类”到已知类型中去。从实现原理上或者组合了两种算法，或者实际上更倾向于监督学习，这里就不单独拿出来说了。  
前面看过了不少监督学习的例子，但还没有展示过无监督学习。今天就来剖析一个。  

#### 单词向量化（Vector Representations of Words）
单词向量化是比较典型的无监督学习。这个概念的本意是这样：在自然语言处理（NLP）中，理解单词的含义是重要的一部分工作。因为我们说过，机器学习的本质是数学运算，解方程。此外单词的长度都不一致，根据归一化的原则，首先要做的事情就是把单词数字化成为统一的维度和数量级，就是每个单词用一个数字代替。几十年前的电报编码其实就是这个意思，一般常用的单词会用比较短的数字，这样数字化之后的长度更短，常用单词因为靠前，被检索的速度也会快。  
但是这样也带来一个大问题，就是单词原本是有一些内部隐藏含义的，比如man/woman。明显有些相关性的单词，数字化之后假设一个是56，一个是34，其中内部的含义就完全丢失了。cat / dog /animal这样的单词也是同样的，这丢失掉的信息对于NLP来讲，实际是很重要的部分。  
因此单词向量化的解决方法就是，把所有的单词嵌入到(embeding)到一个连续的向量空间中去。词义相近或者单词有潜在关联的单词，在向量空间中两个单词之间的距离就近。这个距离也可以作为衡量两个单词相似程度的标准。由此，单词向量化，也称为“word embedding”。  
因为单词向量化的工作是如此重要，TensorFlow官方提供了从低到高一整套示范或工具。  
* 首先是一个简单的示范实现word2vec_basic.py，我们本篇主要看这个例子。  
* 因为word2vec工作非常耗时，官方又提供了一个升级版本word2vec_optimized.py，这个版本用c++重写了耗时的代码，作为TensorFlow的外部模块来使用，提供了较为正式的功能。因为这个代码在机器学习上并没有太多新概念。而又较多的使用了c++开发python外围模块的技术，更多的用于外围model的编写示例，所以这里只做一个简单介绍就跳过。有兴趣的朋友可以自己研究。  
* 官方提供了一个正式的命令行工具word2vec,可以使用pip安装，用于正式的一些单词向量化的工作。因为在NLP项目中，单词向量化通常都是第一步的工作，为NLP后续工作提供数据预处理。有了这个工具，很多工作就可以直接开始，不再另行编程。  

#### 基本原理
几乎所有实现单词向量化的算法都依赖于[分布式假设](https://en.wikipedia.org/wiki/Distributional_semantics#Distributional_Hypothesis)，其核心思想为假定出现于相同上下文情景中的词汇都有相类似的语义。这个概念可能有些含糊，举个例子“我吃了个苹果”是一句话，另外一句话是“我吃了个香蕉”。作为非监督学习，这两句话不会做任何标注，但是经过训练的模型应当能理解“苹果”跟“香蕉”这两个词具有高度相似性，换言之，这两个词在向量空间中，应当具有很接近的距离。  
为了用算法实现这个概念，通常有两种方法：计数法和推理法。  
计数法：在大型语料库中对某词汇及其临近词汇进行统计计数，记下多种指标比如出现频率等，然后再根据这些量把所有单词映射到向量空间中去。  
推理法：也叫预测法，首先假设已经存在一个向量空间，利用这个空间中已经有的数据，通过某词汇的临近词汇，对词汇本身进行预测，对错误的预测在向量空间中调整其位置。  
其实这两种方法经常是结合使用的。  
在word2vec实例中，使用了基于极大似然法的概率化语言模型对连续单词进行关联性预测。极大似然法的资料可以参考最下面的参考链接部分，有一组公式用于实现这个算法。  
随后我们有了任何一个单词之后，根据单词上下文，上下文的定义在程序中是可以设置的，我们采用单词左边1个及右边1个单词作为上下文。举例说有一句话：  
`the quick brown fox jumped over the lazy dog`  
以上下文相关的方式对每个单词进行分组可以得到：  
`([the, brown], quick), ([quick, fox], brown), ([brown, jumped], fox), ...`  
然后我们就可以利用the brown预测quick，用quick fox预测brown。这种预测方式也叫连续词袋模型（CBOW）。还有一种方式是反过来，同上例，比如我们用quick预测the brown，这样叫：Skip-Gram模型。  
从时间复杂性上说，CBOW算法适合较小的数据集，但准确度更高（用多个单词预测1个单词），Skip-Gram则适合较大数据集（用1个单词预测多个单词）。  
  
#### 源码
```python
#!/usr/bin/env python
# -*- coding=UTF-8 -*-

# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
"""Basic word2vec example."""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import collections
import math
import os
import random
from tempfile import gettempdir
import zipfile

import numpy as np
from six.moves import urllib
from six.moves import xrange  # pylint: disable=redefined-builtin
import tensorflow as tf

# Step 1: Download the data.
url = 'http://mattmahoney.net/dc/'

# 从上面的URL下载给定的语料库
# 为了提高速度，这里手工下载后屏蔽了本函数，防止每次运行都重复下载速度太慢
# pylint: disable=redefined-outer-name
def maybe_download(filename, expected_bytes):
  """Download a file if not present, and make sure it's the right size."""
  local_filename = os.path.join(gettempdir(), filename)
  if not os.path.exists(local_filename):
    local_filename, _ = urllib.request.urlretrieve(url + filename,
                                                   local_filename)
  statinfo = os.stat(local_filename)
  if statinfo.st_size == expected_bytes:
    print('Found and verified', filename)
  else:
    print(statinfo.st_size)
    raise Exception('Failed to verify ' + local_filename +
                    '. Can you get to it with a browser?')
  return local_filename

#单词数据包实际下载路径：http://mattmahoney.net/dc/text8.zip
#在这里下载后放到当前目录，所以下面filename做了修改，并且不再调用maybe_download函数
#filename = maybe_download('text8.zip', 31344016)
filename = "./text8.zip"

#从zip包中第一个文件读取所有的数据（实际只有一个文本文件），
#所有的数据只有词，以空格分割，没有标点符号。
#单词之间有语序关系，意思是某文章去掉标点符号之后，每句话中单词的语序仍然存在。
#为了加深印象，可以解压缩text8.zip包，然后显示文本文件看一下，
#文件很大，建议使用more只查看一部分
# Read the data into a list of strings.
def read_data(filename):
  """Extract the first file enclosed in a zip file as a list of words."""
  with zipfile.ZipFile(filename) as f:
    data = tf.compat.as_str(f.read(f.namelist()[0])).split()
  return data

#读取所有单词到字符串数组
vocabulary = read_data(filename)
print('Data size', len(vocabulary))

#整体数据，按照这个下载包是17005207个单词，下面50000是为了演示速度，限制了有效词数
# Step 2: Build the dictionary and replace rare words with UNK token.
vocabulary_size = 50000

def build_dataset(words, n_words):
  """Process raw inputs into a dataset."""
  count = [['UNK', -1]]
  #按照相同词统计数，进行排序，常用词在前面,最前面当然是UNK
  #其次是the/of/and/one，排序靠前的5个单词后面会显示出来...
  count.extend(collections.Counter(words).most_common(n_words - 1))
  dictionary = dict()
  for word, _ in count:
    #计数增加，用于给每个词编一个唯一数字代码
    #UNK是第0个，编码是0，因为加入第一个UNK的时候，dictionary是空，所以len是0。
    #输出看的时候，因为是以单词顺序列出来，所以看着顺序混乱，
    #实际看反查表因为数字在前，看起来会更明显。
    dictionary[word] = len(dictionary) 
  data = list()
  #data最终是数字化之后的words，也就是数字化之后的原文，
  #其中按照原文顺序，每个元素，是该单词的数字编码
  #数字编码是从dictionary中查表找到的，也就是本函数前面数字化单词的过程得到的
  unk_count = 0
  for word in words:
    index = dictionary.get(word, 0)
    if index == 0:  # dictionary['UNK']
      unk_count += 1
    data.append(index)
  count[0][1] = unk_count
  #这个逆转字典是从数字到单词来对应，双向查表用的
  reversed_dictionary = dict(zip(dictionary.values(), dictionary.keys()))
  return data, count, dictionary, reversed_dictionary

# Filling 4 global variables:
# data - list of codes (integers from 0 to vocabulary_size-1).
#   This is the original text but words are replaced by their codes
# count - map of words(strings) to count of occurrences
# dictionary - map of words(strings) to their codes(integers)
# reverse_dictionary - maps codes(integers) to words(strings)
#使用build_dataset函数填充4个全局变量，
#这些全局变量的内容刚才在函数注释中我们都介绍过了
#也可以参考上面官方原本的英文注释
data, count, dictionary, reverse_dictionary = build_dataset(vocabulary,
                                                            vocabulary_size)
#做完了上面的数字化，原文其实就没用了，这里删除以节省内存
del vocabulary  # Hint to reduce memory.
#count表上面说了，是统计出现次数，这里列出最常出现的5个单词
print('Most common words (+UNK)', count[:5])
#数字化后的前10个单词及查表得出的原文,
#注意后面的逆向表查表部分是python特有的语法，其它语言中不多见
print('Sample data', data[:10], [reverse_dictionary[i] for i in data[:10]])

data_index = 0

# Step 3: Function to generate a training batch for the skip-gram model.
def generate_batch(batch_size, num_skips, skip_window):
  global data_index
  assert batch_size % num_skips == 0
  assert num_skips <= 2 * skip_window
  batch = np.ndarray(shape=(batch_size), dtype=np.int32)
  labels = np.ndarray(shape=(batch_size, 1), dtype=np.int32)
  span = 2 * skip_window + 1  # [ skip_window target skip_window ]
  buffer = collections.deque(maxlen=span)
  if data_index + span > len(data):
    data_index = 0
  buffer.extend(data[data_index:data_index + span])
  data_index += span
  for i in range(batch_size // num_skips):
    context_words = [w for w in range(span) if w != skip_window]
    words_to_use = random.sample(context_words, num_skips)
    for j, context_word in enumerate(words_to_use):
      batch[i * num_skips + j] = buffer[skip_window]
      labels[i * num_skips + j, 0] = buffer[context_word]
    if data_index == len(data):
      buffer.extend(data[0:span])
      data_index = span
    else:
      buffer.append(data[data_index])
      data_index += 1
  # Backtrack a little bit to avoid skipping words in the end of a batch
  data_index = (data_index + len(data) - span) % len(data)
  return batch, labels

#生成一批用于学习的数据集，这里首先生成一批很小的量
#然后在下面显示出来，用于人为观察生成的数据集是否合理
batch, labels = generate_batch(batch_size=8, num_skips=2, skip_window=1)
for i in range(8):
  print(batch[i], reverse_dictionary[batch[i]],
        '->', labels[i, 0], reverse_dictionary[labels[i, 0]])

# Step 4: Build and train a skip-gram model.
#这里定义的常量，才是真正学习的时候生成数据集的尺寸等参数
batch_size = 128
embedding_size = 128  # Dimension of the embedding vector.
# 左右各考虑1个单词
skip_window = 1       # How many words to consider left and right.
# 本窗口完成跳2个单词取样下一个窗口
num_skips = 2         # How many times to reuse an input to generate a label.
num_sampled = 64      # Number of negative examples to sample.

# We pick a random validation set to sample nearest neighbors. Here we limit the
# validation samples to the words that have a low numeric ID, which by
# construction are also the most frequent. These 3 variables are used only for
# displaying model accuracy, they don't affect calculation.
valid_size = 16     # Random set of words to evaluate similarity on.
valid_window = 100  # Only pick dev samples in the head of the distribution.
valid_examples = np.random.choice(valid_window, valid_size, replace=False)


graph = tf.Graph()

with graph.as_default():

  # Input data.
  train_inputs = tf.placeholder(tf.int32, shape=[batch_size])
  train_labels = tf.placeholder(tf.int32, shape=[batch_size, 1])
  valid_dataset = tf.constant(valid_examples, dtype=tf.int32)

  # Ops and variables pinned to the CPU because of missing GPU implementation
  with tf.device('/cpu:0'):
    # Look up embeddings for inputs.
    embeddings = tf.Variable(
        tf.random_uniform([vocabulary_size, embedding_size], -1.0, 1.0))
    embed = tf.nn.embedding_lookup(embeddings, train_inputs)

    # Construct the variables for the NCE loss
    nce_weights = tf.Variable(
        tf.truncated_normal([vocabulary_size, embedding_size],
                            stddev=1.0 / math.sqrt(embedding_size)))
    nce_biases = tf.Variable(tf.zeros([vocabulary_size]))

  # Compute the average NCE loss for the batch.
  # tf.nce_loss automatically draws a new sample of the negative labels each
  # time we evaluate the loss.
  # Explanation of the meaning of NCE loss:
  #   http://mccormickml.com/2016/04/19/word2vec-tutorial-the-skip-gram-model/
  loss = tf.reduce_mean(
      tf.nn.nce_loss(weights=nce_weights,
                     biases=nce_biases,
                     labels=train_labels,
                     inputs=embed,
                     num_sampled=num_sampled,
                     num_classes=vocabulary_size))

  # Construct the SGD optimizer using a learning rate of 1.0.
  optimizer = tf.train.GradientDescentOptimizer(1.0).minimize(loss)

  # Compute the cosine similarity between minibatch examples and all embeddings.
  norm = tf.sqrt(tf.reduce_sum(tf.square(embeddings), 1, keep_dims=True))
  normalized_embeddings = embeddings / norm
  valid_embeddings = tf.nn.embedding_lookup(
      normalized_embeddings, valid_dataset)
  similarity = tf.matmul(
      valid_embeddings, normalized_embeddings, transpose_b=True)

  # Add variable initializer.
  init = tf.global_variables_initializer()

# Step 5: Begin training.
num_steps = 100001

with tf.Session(graph=graph) as session:
  # We must initialize all variables before we use them.
  init.run()
  print('Initialized')

  average_loss = 0
  for step in xrange(num_steps):
    batch_inputs, batch_labels = generate_batch(
        batch_size, num_skips, skip_window)
    #可以在tensorflow运算过程中逐批次喂入的数据集是由tf.placeholder定义的，
    #这里把所有要喂入的数据先包装成dict
    feed_dict = {train_inputs: batch_inputs, train_labels: batch_labels}

    # We perform one update step by evaluating the optimizer op (including it
    # in the list of returned values for session.run()
    #运行，并逐批次喂入数据
    _, loss_val = session.run([optimizer, loss], feed_dict=feed_dict)
    average_loss += loss_val

    if step % 2000 == 0:
      if step > 0:
        average_loss /= 2000
      # The average loss is an estimate of the loss over the last 2000 batches.
      #这里显示的是每2000批次平均出来的代价函数返回值
      print('Average loss at step ', step, ': ', average_loss)
      average_loss = 0

    # Note that this is expensive (~20% slowdown if computed every 500 steps)
    if step % 10000 == 0:
      sim = similarity.eval()
      for i in xrange(valid_size):
        valid_word = reverse_dictionary[valid_examples[i]]
        top_k = 8  # number of nearest neighbors
        nearest = (-sim[i, :]).argsort()[1:top_k + 1]
        log_str = 'Nearest to %s:' % valid_word
        for k in xrange(top_k):
          close_word = reverse_dictionary[nearest[k]]
          log_str = '%s %s,' % (log_str, close_word)
        print(log_str)
  final_embeddings = normalized_embeddings.eval()

# Step 6: Visualize the embeddings.


# pylint: disable=missing-docstring
# Function to draw visualization of distance between embeddings.
def plot_with_labels(low_dim_embs, labels, filename):
  assert low_dim_embs.shape[0] >= len(labels), 'More labels than embeddings'
  plt.figure(figsize=(18, 18))  # in inches
  for i, label in enumerate(labels):
    x, y = low_dim_embs[i, :]
    plt.scatter(x, y)
    plt.annotate(label,
                 xy=(x, y),
                 xytext=(5, 2),
                 textcoords='offset points',
                 ha='right',
                 va='bottom')

  plt.savefig(filename)

try:
  # pylint: disable=g-import-not-at-top
  from sklearn.manifold import TSNE
  import matplotlib.pyplot as plt

  tsne = TSNE(perplexity=30, n_components=2, init='pca', n_iter=5000, method='exact')
  plot_only = 500
  low_dim_embs = tsne.fit_transform(final_embeddings[:plot_only, :])
  labels = [reverse_dictionary[i] for i in xrange(plot_only)]
  plot_with_labels(low_dim_embs, labels, './tsne.png')

except ImportError as ex:
  print('Please install sklearn, matplotlib, and scipy to show embeddings.')
  print(ex)

```
源码没有使用从main()开始的函数式编程风格，较多的使用了过程式语言的方式。一块功能定义一个函数，然后接着就在python的全局开始初始化和调用刚才的函数，随后接着是下一个函数和相应的调用。  
除了以前见过的部分，源码中都做了比较多的注释。下面再对一些重点部分做一个讲解。  
讲解之前为了理解方便，这里先把语料库摘个开头贴一下：  
```
 anarchism originated as a term of abuse first used against early working class radicals including the diggers of the english revolution and the sans culottes of the french revolution whilst the term is still used in a pejorative way to describe any act that used violent means to destroy the organization of society it has also been taken up as a positive label by self defined anarchists the word anarchism is derived from the greek without archons ruler chief king anarchism as a political philosophy is the belief that rulers are unnecessary and should be abolished although there are differing interpretations of what this means anarchism also refers to related social movements that advocate the elimination of authoritarian institutions particularly the state the word anarchy as most anarchists use it does not imply chaos nihilism or anomie but rather a harmonious anti authoritarian society in place of what are regarded as authoritarian political structures and coercive economic institutions anarchists advocate social relations based upon voluntary association of autonomous individuals mutual aid and self governance while anarchism is most easily defined by what it is against anarchists also offer positive visions of what they believe to be a truly free society however ideas about how an anarchist society might work vary considerably especially with respect to economics there is also disagreement about how a free society might be brought about origins and predecessors kropotkin and others argue that before recorded history human society was organized on anarchist principles most anthropologists follow kropotkin and engels in believing that hunter gatherer bands were egalitarian and lacked division of labour accumulated wealth or decreed law and had equal access to resources william godwin anarchists including the the anarchy organisation and rothbard find anarchist attitudes in taoism from ancient china kropotkin found similar ideas in stoic zeno of citium according to kropotkin zeno repudiated the omnipotence of the state its intervention and regimentation and proclaimed the sovereignty of the moral law of the individual the anabaptists of one six th century europe are sometimes considered to be religious forerunners of modern anarchism bertrand russell in his history of western philosophy writes that the anabaptists repudiated all law since they held that the good man will be guided at every moment by the holy spirit from
```   
语料库是一个连续的文本文件，其中每个单词之间用一个空格隔开，没有标点符号、没有换行符等控制字符（所以上面的摘录，在终端中看是很多行，在这里显示为1行）。  
参考官方的讲解，我们这里也把程序分成6个部分：  
1. 检测本地如果没有语料库，则去网上下载，下载路径是：`http://mattmahoney.net/dc/text8.zip`。  
同以前的例子相同，因为这个下载包压缩后30多M,我手工下载了语料库，简单的修改了程序，直接从当前目录打开`text8.zip`文件，以便节省时间。  
比后面进阶示例好的地方是，本例中使用了zipfile包来直接读取压缩包中的语料库，不用再解压出来，否则可是100多M的一个文本文件。  
单词会读到vocabulary数组，每个单词占用一个数组元素。数组的顺序就是原来在语料库中单词出现的顺序。  

2. 进行基本的数据整理， 示例起见，这里只使用前面的50000个单词对模型进行训练。在训练集中，统计单词的出现频率，并根据频率生成字典dictionary。字典中频率高的靠前放，在字典中的排名将是这个单词的编号。出现很少的单词替换为“UNK”(因为这种出现非常少的单词没有参考对象，无法进行训练和预测。因此干脆用UNK代替，等于是剔除)。UNK在字典中是第1个，编号是0；后面则按照出现频率排序。程序开始运行时会显示前5个高频词，应当如下：  
`Most common words (+UNK) [['UNK', 418391], ('the', 1061396), ('of', 593677), ('and', 416629), ('one', 411764)]`  
也说明the的编号为1，of是2，and是3，one是4。  
随后使用这个字典，对整个语料库进行数字化，数字化的结果存在data之中，其中稀有词UNK已经被去掉。完成后将是类似这样：  
`5239, 3084, 12, 6, 195, 2, 3137, 46, 59, 156`,这组数字代表原文中的前10个单词：  
`'anarchism', 'originated', 'as', 'a', 'term', 'of', 'abuse', 'first', 'used', 'against'`  
最后，考虑到单词数字化之后，还会需要被逆转成单词，因此又生成了reversed_dictionary字典，其中键值是数字，值则是单词，用于逆向检索。

3. 定义了一个函数，用于生成训练用的数据集。根据训练的特点，训练集是批次生成的。定义完这个函数，使用了一个很小的量（程序中是8）实验生成了一下。这里重点需要理解函数的3个参数：batch_size是每批次生成的单词量；num_skips代表单词窗口移动时跳过的单词数；skip_window是当前单词左右几个单词作为本单词的上下文。前面讲过了，Skip_gram算法是用当前单词，在训练好的模型中预测这个上下文。  

4. 构建用于训练的skip-gram模型，重点2个：
* 没有使用我们熟悉的softmax分类，而是用了nce_loss，同样具体公式在网上查（其实官方word2vec课程中就有，这里略去了）。主要原因是softmax对于一个巨大的分类系统工作非常缓慢，此外nce_loss算法的数学特征使得预测命中的词给出高概率（极大似然法，公式最终结果是可能性概率），给没有命中的词（噪音词）给出低概率，从而达成抑制噪音的目的。  
* tf.nn.embedding_lookup是一个新接触到的函数，为了便于理解，我们后面给一个小例子。其余部分虽然模型不常见，但基本都应当能读懂。  

5. 训练模型，最终向量化的结果，从TensorFlow输出保存到python变量final_embeddings里面。中间每10000步会列出16个单词及其相似单词，这个功能可以清晰的看到相似度正确率的提高。当然作为一个示例程序，离正式的应用还是有很大差距的。  
6. 将得到的向量化结果，抽取前500个，绘制出来，输出为png图片。从图片上看，能够更形象的理解单词向量化的概念。  

还有一点要讲解的是，我们前面的例子一直强调归一化的重要性，在word2vec中，除了数字化，基本没有别的归一化动作。原因很多，最主要的是，在以前的例子中，我们更关注量的概念，拟合到比较接近的数值就算很好的结果。而对数字化之后的单词来讲，每个整数对应一个单词，不可能有小数，就算值相差1，也代表了完全不同的单词。因此在本例中没有传统转换成浮点数那种归一化操作。  

#### tf.nn.embedding_lookup的功能
来看个小例子：  
```python
#!/usr/bin/env/python
# coding=utf-8
import tensorflow as tf
import numpy as np

input_ids = tf.placeholder(dtype=tf.int32, shape=[None])

#定义一个5x5对角矩阵，样式可以看运行结果第一个输出 
embedding = tf.Variable(np.identity(5, dtype=np.int32))
#使用embedding_lookup检索矩阵，检索数据集是input_ids
input_embedding = tf.nn.embedding_lookup(embedding, input_ids)

sess = tf.InteractiveSession()
sess.run(tf.global_variables_initializer())
print(embedding.eval())
print(sess.run(input_embedding, feed_dict={input_ids:[1, 2, 3, 0, 3, 2, 1]}))
```
执行结果：  
```bash
embedding = [[1 0 0 0 0]
             [0 1 0 0 0]
             [0 0 1 0 0]
             [0 0 0 1 0]
             [0 0 0 0 1]]
input_embedding = [[0 1 0 0 0]
                   [0 0 1 0 0]
                   [0 0 0 1 0]
                   [1 0 0 0 0]
                   [0 0 0 1 0]
                   [0 0 1 0 0]
                   [0 1 0 0 0]]
```
embedding_lookup的功能，就是根据input_ids中的id，寻找embedding中的对应行的元素，逐行结果组合在一起，成为一个新的矩阵返回。比如上面就是embedding第1、2、3、0、3、2、1行的结果，重新组合成一个7行的矩阵返回给input_embedding。  

#### 进阶实现
[进阶版本源码](https://github.com/tensorflow/models/tree/master/tutorials/embedding)是一个基本可以应用的实例，在项目页面的介绍中有使用办法，但在macOS中运行有些问题，这里做个说明。  
首先是编译，我是用的TensorFlow1.4.1版本没有这个方法`tf.sysconfig.get_compile_flags()`，无法得到正确的编译参数，最后只好写了一个脚本进行编译：  
```bash
#!/bin/sh

TF_CFLAGS="-I/usr/local/lib/python2.7/site-packages/tensorflow/include"
TF_LFLAGS="-L/usr/local/lib/python2.7/site-packages/tensorflow"

g++ -std=c++11 -shared word2vec_ops.cc word2vec_kernels.cc -o word2vec_ops.so -fPIC ${TF_CFLAGS} ${TF_LFLAGS} -O2 -D_GLIBCXX_USE_CXX11_ABI=0 -undefined dynamic_lookup
```
方法就是人工找到INCLUDE和LIB路径，将路径设置为常量，在编译中直接给定。  
需要注意是在macOS上编译，必须使用`-undefined dynamic_lookup`，不然链接的时候会报错。  
编译之后得到的so文件，会在python程序中使用如下方法调用:  
```python
word2vec = tf.load_op_library(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'word2vec_ops.so'))
...
    (words, counts, words_per_epoch, current_epoch, total_words_processed,
     examples, labels) = word2vec.skipgram_word2vec(filename=opts.train_data,
                                                    batch_size=opts.batch_size,
                                                    window_size=opts.window_size,
                                                    min_count=opts.min_count,
                                                    subsample=opts.subsample)
```


数据文件的准备使用官方给出的命令没有问题：  
```bash
curl http://mattmahoney.net/dc/text8.zip > text8.zip
unzip text8.zip
curl https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/word2vec/source-archive.zip > source-archive.zip
unzip -p source-archive.zip  word2vec/trunk/questions-words.txt > questions-words.txt
rm text8.zip source-archive.zip
```
用于评估训练结果的问题集因为在google的服务器上，可能需要翻墙才能下载。  

最后word2vec_optimized.py的执行结果如下：
```python
2018-01-16 13:17:14.277603: I word2vec_kernels.cc:200] Data file: /Users/andrew/dev/tensorFlow/word2vec/text8 contains 100000000 bytes, 17005207 words, 253854 unique words, 71290 unique frequent words.
Data file:  /Users/andrew/dev/tensorFlow/word2vec/text8
Vocab size:  71290  + UNK
Words per epoch:  17005207
Eval analogy file:  /Users/andrew/dev/tensorFlow/word2vec/questions-words.txt
Questions:  17827
Skipped:  1717
Epoch    1 Step   150943: lr = 0.024 words/sec =    31527
Eval 1469/17827 accuracy =  8.2%
Epoch    2 Step   301913: lr = 0.023 words/sec =    25120
Eval 2395/17827 accuracy = 13.4%
Epoch    3 Step   452887: lr = 0.021 words/sec =     8842
Eval 3014/17827 accuracy = 16.9%
Epoch    4 Step   603871: lr = 0.020 words/sec =     6615
Eval 3532/17827 accuracy = 19.8%
Epoch    5 Step   754815: lr = 0.019 words/sec =     3007
Eval 3994/17827 accuracy = 22.4%
Epoch    6 Step   905787: lr = 0.018 words/sec =    26590
Eval 4320/17827 accuracy = 24.2%
Epoch    7 Step  1056767: lr = 0.016 words/sec =    35439
Eval 4714/17827 accuracy = 26.4%
Epoch    8 Step  1207755: lr = 0.015 words/sec =      401
Eval 4965/17827 accuracy = 27.9%
Epoch    9 Step  1358735: lr = 0.014 words/sec =    36991
Eval 5276/17827 accuracy = 29.6%
Epoch   10 Step  1509744: lr = 0.013 words/sec =    25069
Eval 5415/17827 accuracy = 30.4%
Epoch   11 Step  1660729: lr = 0.011 words/sec =    28271
Eval 5649/17827 accuracy = 31.7%
Epoch   12 Step  1811667: lr = 0.010 words/sec =    29973
Eval 5880/17827 accuracy = 33.0%
Epoch   13 Step  1962606: lr = 0.009 words/sec =    10225
Eval 6015/17827 accuracy = 33.7%
Epoch   14 Step  2113546: lr = 0.008 words/sec =    21419
Eval 6270/17827 accuracy = 35.2%
Epoch   15 Step  2264489: lr = 0.006 words/sec =    27059
Eval 6434/17827 accuracy = 36.1%
```
程序看上去要复杂很多。主要目的是展示把耗时的操作、而TensorFlow中又没有实现的算法，用c++写成TensorFlow扩展包的形式来实现一个复杂的机器学习模型。所以这里不过多说源码，有兴趣的读者可以自行分析。  
最后看一下用于评估的问题库的格式：  
```python
: capital-common-countries
Athens Greece Baghdad Iraq
Athens Greece Bangkok Thailand
Athens Greece Beijing China
Athens Greece Berlin Germany
Athens Greece Bern Switzerland
Athens Greece Cairo Egypt
Athens Greece Canberra Australia
Athens Greece Hanoi Vietnam
Athens Greece Havana Cuba
Athens Greece Helsinki Finland
Athens Greece Islamabad Pakistan
Athens Greece Kabul Afghanistan
Athens Greece London England
Athens Greece Madrid Spain
Athens Greece Moscow Russia
Athens Greece Oslo Norway
Athens Greece Ottawa Canada
Athens Greece Paris France
Athens Greece Rome Italy
Athens Greece Stockholm Sweden
Athens Greece Tehran Iran
Athens Greece Tokyo Japan
Baghdad Iraq Bangkok Thailand
Baghdad Iraq Beijing China
Baghdad Iraq Berlin Germany
Baghdad Iraq Bern Switzerland
...
```
其中使用冒号“:”开头的行是注释行，程序中会跳过。  
随后是`城市-首都 城市-首都`这样形式的关联对，4个词在一行。预测方法就是用前三个词，预测最后一个词，如果预测对了，则正确率+1。可见在训练语料库text8跟评估使用的问题集questions-words.txt完全不同、且没有任何关联性的两个数据集中，达到36.1%的预测正确率是多么不容易(另外这个示例也没有完成全部的训练，否则正确率还可以提高)。 
依赖这种特征，单词向量化也经常用于呼叫中心知识库的智能检索，实现智能回答机器人的一些实现中。  
 





(待续...)

#### 引文及参考  
[TensorFlow中文社区word2vec讲解](http://www.tensorfly.cn/tfdoc/tutorials/word2vec.html)  
[图解word2vec](https://www.jianshu.com/p/f682066f0586)  
[极大似然法](https://en.wikipedia.org/wiki/Maximum_likelihood_estimation)  
[Dependency-Based Word Embeddings](https://levyomer.files.wordpress.com/2014/04/dependency-based-word-embeddings-acl-2014.pdf)  

