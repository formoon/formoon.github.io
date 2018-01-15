---
layout:         page
title:          从锅炉工到AI专家(7)
subtitle:       TensorFlow实务
card-image:     http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorflowlogo.jpg
date:           2018-01-12
tags:           ml toSeven
post-card-type: image
---
#### 说说计划
不知不觉写到了第七篇，理一下思路：
1. 学会基本的概念，了解什么是什么不是，当前的位置在哪，要去哪。这是第一篇希望做到的。同时第一篇和第二篇的开始部分，非常谨慎的考虑了非IT专业的读者。希望借此沟通技术人员和产品人员，甚至管理和销售人员。我信服“上下同欲者胜”，所以也非常害怕因为大家对概念完全不同的理解而影响到团队的合作。
2. 从最简单的部分入手，由概念到代码，完成技术破冰。这是第二、三篇希望做到的。
3. 逐步迭代，从简单概念到复杂概念，从简单算法到复杂算法，接触到机器学习现实最常用的技术。这是四、五、六篇希望做到的。如果不是人工智能专门人员或公司，在这个基础上开始把机器学习技术导入到自己的业务，已经可以开始动手了。
4. 了解围绕在算法周边的模块和功能，把算法包装到程序，了解机器学习类程序开发中可能碰到的问题和解决手段。这是本篇想完成的。这篇之后，应当也是最基本的一个完整开发循环可以开始尝试了。
5. 开始逐步了解其它领域、其它常见问题所用到的算法及代码，每一篇有兴趣的可以读，没兴趣的也可跳过。这是下一步的连载计划。目标是为学习提供更多参考的案例。

#### 从算法到产品
DNN/CNN都是目前机器学习领域最常用的算法，学习了这些例子，算是前进了一大步。  
但是从产品的观念看，我们还有很多事情要做，比如如何从算法成为一个程序？程序如何调试？技术如何产品化？  
下面我们就说一说这方面的问题。  

#### 不断升级的TensorFlow
TensorFlow是一个快速迭代中的产品，欣欣向荣的同时，作为尝鲜者，你需要忍受API不断的变更。  
有些朋友的做法是，下载一套就一直使用，轻易不升级。而且你看python的包管理工具pip也是推荐这种模式的，pip很少像brew/apt这些包管理工具一样每次都提醒你升级新的软件包。  
两种情况下，我也会推荐这种方式：  
1. 关注的重点是业务，目标是把技术导入到业务，自身方向是业务主导而不是技术主导。
2. 用于实际产品的生产环境。

如果是以学习为目的，我觉得定期关注官方网站、官方的文档，根据自己的进度适时更新还是很重要的。  
从我的体验上，TensorFlow对于版本的更新对API的影响控制的还是非常好的。其实前面所讲解的那些例子，很多来自于0.7.x版本的TensorFlow，基本上不加修改或者很少修改就顺利运行在当前1.4.x的TensorFlow中。这一点可比革命彻底的swift 1.0/2.0一直到最新的4.x强多了，swift的每个版本几乎都是再重新学一遍 :)。  
从这一篇开始说这个问题主要原因也是，其实TensorFlow在主要的算法部分在各版本保持了很好的一致性。而在周边的功能部分变化还是比较大的，比如说XLA、对GPU的支持、整合Keras等特征。所以我建议开发使用的版本至少是选用TensorFlow 1.x之后的版本来入手。  

#### 用源码来说话
在第四篇中我们介绍了一个最简单的机器学习算法，主体是线性回归方程接softmax分类。  
源码来自于老版本的TensorFlow,在最新版本中这个源码做了修改。增加了程序结构方面的考虑。  
没有在一开始就讲解新的版本，你看了下面的源码就知道了。跟算法无关的部分太多了，实质上提高了入门的门槛。而现在我们掌握了基本的算法，再回头来看外围的结构部分，理解起来就很快了。  
```python
#!/usr/bin/env python
# -*- coding=UTF-8 -*-

# 注意以上部分官方原本是没有的，其中直接执行是为了使用更方便，
# 不然需要用这种方式执行： python mnist_softmax.py
# 字体编码是因为需要添加中文注释，否则执行时会报错

# ==============================================================================
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

"""A very simple MNIST classifier.

See extensive documentation at
https://www.tensorflow.org/get_started/mnist/beginners
"""
#下面三行是为了利用python3中的一些先进特征而添加，
#实际在本代码中并没有使用这些特征，因此技术是可以屏蔽的，
#但不管是否使用，每次引入避免个别因为习惯引起的低级错误也是推荐的，
#因为脚本方式运行的时候，很可能执行到的时候才会报错。
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

#引入命令行参数解析库
import argparse
import sys

#所有的示例，如果使用官方推荐的方式安装tensorflow包，
#都应当已经已经安装在本地，比如mac上路径是：
#/usr/local/lib/python2.7/site-packages/tensorflow/examples/tutorials/mnist
#所以下面这个是直接从系统包中引用数据准备脚本
from tensorflow.examples.tutorials.mnist import input_data
import tensorflow as tf

#这个变量将用来保存命令行参数，首先清空
#在这里声明是为了成为全局变量，可以直接在函数中调用
FLAGS = None

#主程序，其实python作为重要的脚本语言，
#并不是必须定义主函数，但显然这种方式让程序更规范
def main(_):
  # Import data
  #下面的算法部分基本不需要重复解释，可以看以前版本的注释
  #FLAGS.data_dir是从命令行传递来的参数，
  #可以看后面的解释
  mnist = input_data.read_data_sets(FLAGS.data_dir)

  # Create the model
  x = tf.placeholder(tf.float32, [None, 784])
  W = tf.Variable(tf.zeros([784, 10]))
  b = tf.Variable(tf.zeros([10]))
  y = tf.matmul(x, W) + b

  # Define loss and optimizer
  y_ = tf.placeholder(tf.int64, [None])

  # The raw formulation of cross-entropy,
  #
  #   tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(tf.nn.softmax(y)),
  #                                 reduction_indices=[1]))
  #
  # can be numerically unstable.
  #
  # So here we use tf.losses.sparse_softmax_cross_entropy on the raw
  # outputs of 'y', and then average across the batch.
  #交叉熵的计算，系统已经有内置的函数，
  #不需要自己计算了，对比原来的源码可以看一下
  #上面英文也写出了自己计算的缺陷
  #注意参数:labels表示认为标注的正确值，logits是模型计算出的值
  cross_entropy = tf.losses.sparse_softmax_cross_entropy(labels=y_, logits=y)
  train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy)

  sess = tf.InteractiveSession()
  tf.global_variables_initializer().run()
  # Train
  for _ in range(1000):
    batch_xs, batch_ys = mnist.train.next_batch(100)
    sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})

  # Test trained model
  #注意这里的比较，y_没有跟以前版本一样做argmax，
  #因为y_的值mnist.test.labes本身已经是数字本身，
  #而不是原来代表10个分类的一维数组，
  #这个是由上面read_data_sets函数中one_hot=True参数决定的，
  #没有这个参数代表直接读数值数据，实际上在下载的数据包中就是数值
  correct_prediction = tf.equal(tf.argmax(y, 1), y_)
  accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
  print(sess.run(accuracy, feed_dict={x: mnist.test.images,
                                      y_: mnist.test.labels}))

if __name__ == '__main__':
  #使用引入的argparse库解析命令行参数
  parser = argparse.ArgumentParser()
  #本脚本只支持一个参数，用于指定测试数据集文件夹
  #默认的文件夹路径做了修改，指向本地已有的数据集，
  #免得每次启动时用参数重新指定
  parser.add_argument('--data_dir', type=str, default='MNIST_data',
                      help='Directory for storing input data')
  #解析的参数存入FLAGS,注意这是全局变量
  FLAGS, unparsed = parser.parse_known_args()
  #tf的架构定义，
  #包装了main主函数，熟悉c语言之类的用户看起来肯定更亲切
  tf.app.run(main=main, argv=[sys.argv[0]] + unparsed)
```
粗看起来源码比我们最早看到的复杂了很多是吧？其实有效的代码并没有多少，这里做几个解释：  
* 最大的变化是所有的代码放到了main()函数里面，脚本语言平常是没有这个必要的。但放到main中会更规范，tensorflow在这方面提供了tf.app.run支持。  
* 所有可变的参数，尽可能用命令行参数或者参数文件的方式来指定，而不是每次修改源码。这是所有编程语言都应当遵循的规范。python中主要是通过argparse扩展包来完成的这方面支持，这个不是tensorflow的功能。  
* 新的交叉熵计算方法和最后验证阶段y_不再做argmax这两点比较重要，请仔细看注释搞清楚  

#### 保存训练的数据
前面的例子我们体会很深了，随着算法的复杂度提高，训练所耗费的时间越来越长。这还只是10M左右的数据集和一个小的练习。在大型的系统中，可能需要一个集群的工作环境做几周的运算。  
在真正投产的时候，实际就只是用训练的数据配合预测部分的代码完成工作即可。这就需要把训练数据保存下来。  
TensorFlow的保存、恢复非常容易，首先要生成一个保存器：  
```python
	filesaver = tf.train.Saver()
```
随后在要保存数据的位置，把数据保存到文件中：  
```python
	datafile='data/softmax_data.tfdata'
	filesaver.save(sess,datafile)
```
在需要用到数据的位置，再把数据还原回来：  
```python
	datafile='data/softmax_data.tfdata'
	filesaver.restore(sess,datafile)
```
应用到程序中，程序的主要变动一般是结构上。或者训练、预测分成两个程序。或者用开关判断分成两个部分。下面就用本篇上面的代码作为例子添加上数据保存、恢复的功能：  
```python
#!/usr/bin/env python
# -*- coding=UTF-8 -*-

# ==============================================================================
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

"""A very simple MNIST classifier.

See extensive documentation at
https://www.tensorflow.org/get_started/mnist/beginners
"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import sys,os

from tensorflow.examples.tutorials.mnist import input_data
import tensorflow as tf

FLAGS = None

 #数据文件保存的位置
datafile='data/softmax_data.tfdata'
 #增加一个函数用于判断数据文件是否已经存在
def datafile_exist():
	#tf写出的数据文件实际是分了几部分，
	#我们判断其中的索引文件是否存在
	#假设索引文件存在，就有完整的数据文件
    return os.path.exists(datafile+".index")

def main(_):    
    # Import data
    mnist = input_data.read_data_sets(FLAGS.data_dir)

    # Create the model
    x = tf.placeholder(tf.float32, [None, 784])
    W = tf.Variable(tf.zeros([784, 10]))
    b = tf.Variable(tf.zeros([10]))
    y = tf.matmul(x, W) + b

    # Define loss and optimizer
    y_ = tf.placeholder(tf.int64, [None])

    cross_entropy = tf.losses.sparse_softmax_cross_entropy(labels=y_, logits=y)
    train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy)

    filesaver = tf.train.Saver()
    
    sess = tf.InteractiveSession()
    tf.global_variables_initializer().run()
    
    if FLAGS.train or (not datafile_exist()):
		#如果命令行指定训练模式，或者数据文件根本不存在则执行训练流程
        # Train
        for _ in range(1000):
            batch_xs, batch_ys = mnist.train.next_batch(100)
            sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})
        print("Training finished, data write to file.")
		#训练结束，写出数据
        filesaver.save(sess,datafile)

        # Test trained model
        correct_prediction = tf.equal(tf.argmax(y, 1), y_)
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
        print(sess.run(accuracy, feed_dict={x: mnist.test.images,
                                      y_: mnist.test.labels}))
    if (not FLAGS.train) and datafile_exist():
		#如果已经存在数据文件，并且没有要求强行重新训练，则恢复文件
        print("Restore data...")
		#恢复数据
        filesaver.restore(sess,datafile)
        # Test trained model
        correct_prediction = tf.equal(tf.argmax(y, 1), y_)
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
        print(sess.run(accuracy, feed_dict={x: mnist.test.images,
                                      y_: mnist.test.labels}))
        
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--data_dir', type=str, default='MNIST_data',
                      help='Directory for storing input data')
	#添加了一个参数，用于强制程序运行在训练数据状态
	#使用时，如果添加-t或者--train参数执行，则运行在训练模式
	#如果没有参数，则判断数据文件是否存在，已经存在直接进入测试模式
	#没有存在，则先训练，写出数据集，再恢复数据集做一次测试
    parser.add_argument('-t','--train', action='store_true',default=False,
                      help='Force do train')
    FLAGS, unparsed = parser.parse_known_args()
    tf.app.run(main=main, argv=[sys.argv[0]] + unparsed)
```
#### JIT XLA
在机器学习领域，学习算法做练习问题不大，实际应用，无论性能多强的电脑你都总是感觉慢。  
JIT XLA是TensorFlow推出的一项新特征，就是运行时编译器。主要功能是把数学模型部分进行运行时编译，融合可组合的op以提高性能，内存需求也会降低很多。  
XLA全称：Accelerated Linear Algebra，也就是加速线性代数。  
使用XLA非常容易只要在Session初始化的时候添加如下代码：  
```python
config = tf.ConfigProto()
jit_level = tf.OptimizerOptions.ON_1
config.graph_options.optimizer_options.global_jit_level = jit_level
with tf.Session(config=config) as sess:
   ...
```
Session的运行就会在XLA方式之下。实际上XLA的运行需要CPU或者GPU的支持。在我的老电脑上，虽然硬件不支持XLA的加速，但内存的需求也降低了大概一倍左右，可说效果明显。  

#### TensorBoard
不同于传统程序的DEBUG，机器学习类的程序，在程序逻辑上大多不会犯什么大错误，毕竟整个流程很简单。  
大多的过程实际上是在“调优”而不是“调试”。在调优中需要关注到的，主要是数据方面的问题。而数据不管原来是什么格式，进入机器学习系统后，往往都已经变成了抽象的矩阵。所以整个调优过程往往充满着痛苦和无力感。  
TensorBoard是一个官方出品的优秀工具，可以通过读取事件文件的形式把数据图形化的显示出来，从而大幅降低调优难度。  
使用TensorBoard本身很简单，是一个B/S结构的程序，在浏览器中就可以操作所有功能。比较麻烦的是生成事件文件，需要在程序代码中嵌入很多用于监控的语句，用于输出数据留待tensorboard分析。  
官方有一个写的很好的样例：`mnist_with_summaries.py`，但是这个源码看上去偏于复杂。我们还是以上面的softmax分类识别的源码为例，对此做一个介绍。有了这个基础，官方的样例留给读者在读完这里的内容之后，自己尝试去分析。  
生成事件数据文件只需要两行语句：
```python
 #在Session建立后执行：
    train_writer = tf.summary.FileWriter('logs/train', sess.graph)
 #在Session关闭前执行：
    train_writer.close()
```
程序执行完成后，将在`./logs/train/`目录下生成事件数据文件。随后可以用tensorboard来分析和显示数据文件：  
```bash
> tensorboard --logdir=logs/
TensorBoard 0.4.0rc3 at http://127.0.0.1:6006 (Press CTRL+C to quit)
```
命令中指定数据文件路径只需要指定到上一级即可，因为tensorbaord支持多组数据文件对比显示，这个我们后面再介绍。  
查看图形化的分析结果可以使用浏览器访问：http://127.0.0.1:6006。  
![](http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorboard3.png) 
能够显示出来完整的数学模型，只是图的可读性感觉还是比较差，大多节点要思考一下才能明白代表的是什么。而且除了图基本也没有提供其它参数，难以做更深入的分析。  
我们还可以继续定义一些输出来改善数学模型的显示：  
我们可以监控常量的状态：  
```python
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
 #第一个参数是指定显示时图表的名字，第二个参数是监控的值
tf.summary.scalar('accuracy', accuracy)
```
可以监控变量的状态：
```python
cross_entropy = tf.losses.sparse_softmax_cross_entropy(labels=y_, logits=y)
 #第一个参数是指定显示图表的名字，第二个参数是监控的值
tf.summary.histogram('cost', cross_entropy)
```
可以对节点命名以便更直观的看到图形化后模型的结构：
```python
with tf.name_scope("pic_samples"):
    x = tf.placeholder(tf.float32, [None, 784])
with tf.name_scope("weight"):
    W = tf.Variable(tf.zeros([784, 10]))
```
注意：`with tf.name_scope("pic_samples"):`这种形式，其实也是TensorFlow中的变量作用域的定义。  
因为机器学习中的变量一般都占用了比较大的空间，我们肯定希望尽可能重复使用变量，所以如果在大系统中，会存在很多变量。这时候就需要有作用域在对变量做出管理。这方面的功能，初学肯定用到不到，用到的时候看看手册就够了，这里不多说。  
我们既然监控了变量、常量，必然需要tensorflow的运算才能得到这些值，虽然这些值只是输出到事件文件中的。所以记住一点，只要使用了任何的summary操作，我们就需要在FileWriter定义的同时，定义一个运算操作,并在之后在Session.run中运算这个操作,随后把返回的结果添加到事件文件中去,这样才能真正把监控的值输出到事件文件中去：  
```
  	#注意这一行应当在所有需要监控的变量、常量、图片等都设置好后，最后运行
	#此语句之后定义的观察器将都不会被输出到时间文件。也就无法被查看了
    merged = tf.summary.merge_all()
    train_writer = tf.summary.FileWriter('logs/train', sess.graph)
	...
    summary,_ = sess.run([merged,train_step], feed_dict={x: batch_xs, y_: batch_ys})
    train_writer.add_summary(summary, i)
```
因为定义了placeholder,所以每次sess.run()都是需要喂数据的。即便我们定义的merged这个操作并不需要数据。所以如果单独运行这个操作，附带喂入数据肯定是很不经济。因此通常的方法，都是跟主要的操作一起运行。同时运行多个操作，并且同时得到多个返回值的语法既是python的语言特色，也是TensorFlow支持的功能。  
现在重复运行程序，得到新的事件文件，再次启动tensorboard然后用浏览器查看，我们可以看到更多的内容了：  
![](http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorboard5.png) 
请注意看两个命名的节点，都已经有更友好的节点名了。  
![](http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorboard6.png) 
我们监控的变量，能清晰的看到代价函数的值逐渐变小，表示逐渐趋于收敛。（请忽略这个粗糙示例中的抖动，这里仅是为了示例可视化的效果。）  
其它监控的各种值基本类似，这里就不一一贴出图片了，建议你把源码执行一下然后看看效果。  

TensorBoard功能非常强大，很多功能超乎我们的想象。前面我们介绍过一个小程序，自己把输入的数据图形化，然后写出到一个图片文件。  
这样的功能，如果使用TensorBoard将更加容易，比如下面代码监控输入矩阵及计算的权重值，并以图片的形式显示出来：  
```python
x = tf.placeholder(tf.float32, [None, 784])
image_shaped_input = tf.reshape(x, [-1, 28, 28, 1])
tf.summary.image('input_images', image_shaped_input, 10)
...
W = tf.Variable(tf.zeros([784, 10]))
Wt=tf.transpose(W)	#因为权重值跟图片数据定义不同，要先转置一下，再转成图片
image_shaped_weight = tf.reshape(Wt, [-1, 28, 28, 1])
tf.summary.image('weight_images', image_shaped_weight, 10)
```
最终生成图片的样子我们前面的内容中见过，这里也不贴图了。  
其中权重部分，因为不是[None,784]这样的形式，而是[784,10],所以要先使用tf.transpose转换成[10,784]的形式，再reshape成28x28的图片，最后才能以图片的方式显示出来。  

这一节的最后部分，把上面示例的完整代码列出来，以供你参考实验，因为上面讲解都很详细了，例子中就没有加过多的注释。请注意这个例子因为经历了多次的补丁和无逻辑意义的作用域定义，程序结构上比较混乱，大家在正式的项目中可千万不要模仿。  
```python
#!/usr/bin/env python
# -*- coding=UTF-8 -*-

# ==============================================================================
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

"""A very simple MNIST classifier.

See extensive documentation at
https://www.tensorflow.org/get_started/mnist/beginners
"""

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import argparse
import sys,os

from tensorflow.examples.tutorials.mnist import input_data
import tensorflow as tf

FLAGS = None

datafile='data/softmax_data.tfdata'
def datafile_exist():
    return os.path.exists(datafile+".index")

def main(_):    
    # Import data
    mnist = input_data.read_data_sets(FLAGS.data_dir)

    # Create the model
    with tf.name_scope("pic_samples"):
        x = tf.placeholder(tf.float32, [None, 784])
        image_shaped_input = tf.reshape(x, [-1, 28, 28, 1])
        tf.summary.image('input_images', image_shaped_input, 10)
    with tf.name_scope("weight"):
        W = tf.Variable(tf.zeros([784, 10]))
        Wt=tf.transpose(W)
        image_shaped_weight = tf.reshape(Wt, [-1, 28, 28, 1])
        tf.summary.image('weight_images', image_shaped_weight, 10)
    b = tf.Variable(tf.zeros([10]))
    tf.summary.histogram('bias', b)
    y = tf.matmul(x, W) + b

    # Define loss and optimizer
    y_ = tf.placeholder(tf.int64, [None])

    cross_entropy = tf.losses.sparse_softmax_cross_entropy(labels=y_, logits=y)
    tf.summary.histogram('cost', cross_entropy)
    train_step = tf.train.GradientDescentOptimizer(0.5).minimize(cross_entropy)

    filesaver = tf.train.Saver()
    
    
    sess = tf.InteractiveSession()
    tf.global_variables_initializer().run()
    
    correct_prediction = tf.equal(tf.argmax(y, 1), y_)
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
    tf.summary.scalar('accuracy', accuracy)

    merged = tf.summary.merge_all()
    train_writer = tf.summary.FileWriter('logs/train', sess.graph)

    if FLAGS.train or (not datafile_exist()):
        # Train
        for i in range(1000):
            batch_xs, batch_ys = mnist.train.next_batch(100)
            sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})
            summary,_ = sess.run([merged,train_step], feed_dict={x: batch_xs, y_: batch_ys})
            train_writer.add_summary(summary, i)
            # Test trained model
            if (i % 100 == 0):
                summary1,ac = sess.run([merged,accuracy], feed_dict={x: mnist.test.images,
                                              y_: mnist.test.labels})
                train_writer.add_summary(summary1,i)
        print("Training finished, data write to file.")
        
        filesaver.save(sess,datafile)
        print(ac)   

        train_writer.close()
    if (not FLAGS.train) and datafile_exist():
        print("Restore data...")
        filesaver.restore(sess,datafile)
        # Test trained model
        correct_prediction = tf.equal(tf.argmax(y, 1), y_)
        accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
        
        print(sess.run(accuracy, feed_dict={x: mnist.test.images,
                                      y_: mnist.test.labels}))

        
if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--data_dir', type=str, default='MNIST_data',
                      help='Directory for storing input data')
    parser.add_argument('-t','--train', action='store_true',default=False,
                      help='Force do train')
    FLAGS, unparsed = parser.parse_known_args()
    tf.app.run(main=main, argv=[sys.argv[0]] + unparsed)
```
注意程序运行的时候要使用-t参数，因为图示部分的代码主要加在了训练环节。  
读完了这个程序，再去读官方的示例应当容易很多，非常建议你以官方程序为范例仔细阅读。  
#### 团队合作
作为实践环节的最后一部分，介绍一下通常机器学习项目的一般工作流程和团队。  
* 几乎大多数的项目都是从确定需求入手的。最初的需求可能来自于内、外部客户，如果能明确到文档化这就是最幸福的开始了。不过还有很多不是这样，很多公司可能只是为了赶时髦建立了一个小团队开始人工智能的尝试。这时候往往还不知道要做什么，许多也只能模仿成熟业界流行的应用入手。或者从一大堆漫无目标、或者不属于人工智能甚至当前技术还无法做到的需求中去梳理、寻找最基本的需求。  
* 随后一般就需要算法的专家上场。不过大多数公司在开始都没有这样的人才，因此更多的可能是程序人员代替，或者太独特的项目就需要外援专家。这一环节一般是根据需求，来确定初步的数学模型，如果是比较生僻的项目，一般需要进行大量的数学实验最后确定几个可能的模型来进行规模化测试。在正规的IT公司一般是聘请比较资深的数学专家配合技术人员完成这部分工作。  
* 接下来会根据数学模型的要求，确定需要收集的数据，并预估数据量。大多数情况都需要组建数据小组，有专门技术人员带领，编写数据收集的代码，开始收集数据。数据的预处理和标注通常能用程序解决一部分，但最终一般还是要人工进行标注，最终汇总成规范化的数据集。
* 跟数据组并行，会有程序人员把数学的算法代码化。如果是图像识别等比较成熟的例子当然容易了很多，一般用成熟的框架就能够工作。但不管哪种情况，一般最初的模型都需要监控尽可能多的指标，以供效果评估和调优。  
* 最后实现的训练代码会在预先挑选的小数据集上工作，对算法进行调优和最终算法的选择。这部分工作一般需要数学的专家和程序人员配合一起完成。所以这时候程序人员要多听取算法人员的意见，挑选更能说明算法问题的监控环节。调优完成后一般可以去掉大部分耗时的监视代码，只留下算法核心的部分。  
* 最终完成的机器学习内核部分，会一边进行正式的训练进程，一边由前端人员完成产品化和用户体验优化的工作，最终达成一个可输出的产品。  
 
稍微成熟的公司，一般都已经有自己规范的研发流程和管理方式，此处列出的流程仅供参考。其实主要是强调算法专家的角色和数据收集的工作。这两组人员在一般的项目中是没有或者位置并不是很重要的。但是在机器学习项目中，往往是核心部分。在图像识别等监督学习领域，数据收集、标注成本往往占了最主要的预算。  
(待续...)

#### 引文及参考  
[TensorBoard:可视化学习](http://wiki.jikexueyuan.com/project/tensorflow-zh/how_tos/summaries_and_tensorboard.html)  
[tensorflow里面name_scope, variable_scope等如何理解？](https://www.zhihu.com/question/54513728)  
[python argparse用法总结](https://www.jianshu.com/p/fef2d215b91d)  
[谷歌官博详解XLA：可在保留TensorFlow灵活性的同时提升效率](http://www.sohu.com/a/128440204_465975)  
[完整机器学习项目的工作流程](https://ask.julyedu.com/question/7013)  

#### 另请参考官方示例源码：
```bash  
mnist_softmax_xla.py
mnist_deep.py
mnist_with_summaries.py
```

