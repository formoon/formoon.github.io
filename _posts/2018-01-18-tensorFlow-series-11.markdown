---
layout:         page
title:          从锅炉工到AI专家(11)(END)
subtitle:       TensorFlow实务
card-image:     http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorflowlogo.jpg
date:           2018-01-18
tags:           ml toSeven
post-card-type: image
---
#### 语音识别
TensorFlow 1.x中提供了一个语音识别的例子[speech_commands](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/examples/speech_commands)，用于识别常用的命令词汇，实现对设备的语音控制。speech_commands是一个很成熟的语音识别原型，有很高的正确率，除了提供python的完整源码，还提供了c/c++的示例程序，方便你移植到嵌入设备及移动设备中去。  
官方提供了关于这个示例的[语音识别教程](https://www.tensorflow.org/tutorials/audio_recognition)。不过实际就是一个使用说明，没有对代码和原理做过多解释。  
这个程序相对前面的例子复杂了很多，整体结构、代码、算法都可以当做范本，我觉得我已经没有资格象前面的讲解一样随意在代码中注释和指手画脚。因此建议大家把这个例子当做参考资料，有兴趣也有能力的，自己去阅读一下代码来研究。你碰到最多的困难不会来自机器学习算法，而是程序结构、音频处理等方面。  

下面结合我学习的过程对官方教程做一个补充，相信会方便你的入手。  
建模部分(models.py)是这个示例的主体，create_model()是主要的入口函数，提供了四种算法来建立语音识别模型，分别是:single_fc(全连接神经网络)/ conv(卷积)/ low_latency_conv(低延时卷积)/ low_latency_svdf(低延时二维奇异值分解)。  
低延时算法的实现主要是做了一些权衡，比如去掉池化层来加快计算速度。构成模型的大量基础运算中，我们只有SVDF算法没有用到过。  
不过SVDF在实现中，也是使用conv1d配合标准的全连接fc层运算来实现的。SVD是在音频降噪算法中经常用到的，中文名字叫做“奇异值分解”。SVDF没有搜到合适的翻译名，我们暂用它的实现原理叫做“二维奇异值分解”吧。从网上搜到的资料看，这种算法对于过滤信号矩阵中噪音数据比较有效。  
所以从整体上说，以我们当前对机器学习的知识，读懂这个程序问题不大。  
input_data.py是属于下载、解压缩、预处理、生成训练集的辅助工具库，看命名就是TensorFlow的风格:)，我觉得在国内学习这个示例最大的难度就在语音[样本库](https://download.tensorflow.org/data/speech_commands_v0.01.tar.gz)的下载上，1.49G的压缩包，一般的翻墙手段都不够用了，希望你好运。  
训练用的主程序是train.py，其中预置了大量的命令行参数进行各种设定，比如数据包路径、训练数据保存路径、采用的识别算法等，大多参数都已经有预设值。如果你的电脑足够快，直接使用官方的指导直接运行就可以。我是手工下载数据包，在当前目录下建立speech_commands_train/ speech_dataset/ retrain_logs/三个文件夹，随后将数据放入speech_commands_train文件夹。随后在当前目录使用下面命令来开始训练，这样可以避免在长时间的运行中意外重启之类的丢失数据：  
```bash
python train.py --summaries_dir=./retrain_logs --train_dir=./speech_commands_train --data_dir=./speech_dataset/
```
训练主程序中还用了一个小技巧，程序默认是前15000个批次使用梯度0.001进行训练，后3000个批次使用梯度0.0001进行训练，这种方式既保证了精度，又尽力提高了学习速度，还是很值得参考的。  

不算数据包下载的时间，训练模型在16G/8核16线程的服务器（服务器的意思也是指显卡很渣）上耗费了接近12个小时。最后生成的数据包并不大，只有3.6M。  
训练结束时会在屏幕上显示一个Confusion Matrix，矩阵的主轴代表对所选择训练单词的拟合度，应当明显高于矩阵的其它位置元素。这个矩阵每次运行的结果都会特征一致、取值不同，所以这里就不贴图了。  
train.py还有很多参数值得你提前看一下做一个了解，比如下载的语音库实际上包含很多个常用单词，主要是涵盖在智能家居范畴。而程序默认识别的只有10个（yes,no,up,down,left,right,on,off,stop,go）。  
训练中，原始的语音库会解压在speech_dataset中，每个单词一个文件夹，其中放置大量wav文件，每个文件时长1秒，下载的语音库原始压缩包在这个路径也会被保存一份。最终训练结果保存在speech_commands_train目录。另外一个则是事件日志文件，可以挂上TensorBoard来做模型分析。  
因为训练结果最常用的场景是智能家居中，而智能家居方案不管是使用嵌入式电脑还是手机做控制，都具有很有限的存储能力。所以TensorFlow的最终训练结果会进一步压缩并合并为一个文件，实际最终使用一个训练结果文件和一个标签文件就可以工作。所以测试正常后，其它的数据集都可以手工删除（原始程序默认是在tmp目录保存数据，可以让系统自动删除）。压缩数据文件的方式是：  
```python
python freeze.py --start_checkpoint=speech_commands_train/conv.ckpt-18000 --output_file=./frozen_graph.pb
```
./frozen_graph.pb就是最终生成的压缩版文件，大概3.5M。另外注意如果你修改了训练步长，那上面最终保存的结果文件名也会不同，请注意选择正确的文件。  
使用的时候，首先是使用录制语音成为wav文件，具体你是用现成的工具录制还是自己编程序录制是你的事情。随后用下面命令来识别（wav样例是采用语音库中随机选择了一个文件）：  
```python
python label_wav.py --graph=frozen_graph.pb --labels=speech_commands_train/conv_labels.txt --wav=speech_dataset/yes/03c96658_nohash_0.wav 
yes (score = 0.98647)
left (score = 0.00962)
_unknown_ (score = 0.00312)
```
识别结果显示，是单词yes的可能性98.6%。  
官方还提供了label_wav.cc的c++源程序，可以应用到更广泛的识别场合。  
因为实际上如果你不是做算法研究，对这个程序最大的用途反而是把识别客户端移植到各个环境，训练嘛，反正是用户看不到的后台，就无所谓了。因此我建议你好好读读label_wav.py的代码，这个程序小巧耐看，加上注释都没有超过150行，绝不会有读不懂的可能。  

#### 机器翻译
作为世界上最重视英语的非英语母语大国，机器翻译在中国的历史可说久远，不过可惜至今，最强大的机器翻译实现仍然被Google霸占。Google的在线翻译已经可以提供超过100种语言的全文互译，在多个严苛的评测中，其翻译的可读性得分也是最高的。  
幸福的是，基于TensorFlow的Google翻译引擎[NMT(Neural Machine Translation 神经机器翻译)](https://github.com/tensorflow/nmt/)也开源了。  
官网的文档对NMT的主线算法Seq2Seq(序列到序列)原理讲解比较细致，在机器学习的实现上较多的采用了LSTM神经网络，这在上一篇我们刚刚用过，你肯定不陌生。如果读英文有困难，[《如何使用TensorFlow构建自己的神经机器翻译系统》](https://mp.weixin.qq.com/s?__biz=MzA3MzI4MjgzMw==&mid=2650728901&idx=1&sn=7c9a47a9b55678794cd5f70460e0f561&scene=0#wechat_redirect)是一篇优秀的译文，值得一看。在其中，我们前面讲过的单词向量化、LSTM对语义模型的理解都逐一用到。  
NMT项目的testdata中是使用的示例性训练数据集，可以看到在对于原始语素的标注上可说异乎寻常的简单。前面说过，数据集就是钱啊，机器学习项目最大的投资往往是在数据的获取上，对标注要求的简化，就是对项目资金的大量节省。而算法能力的提高，又是达成这种能力的前提。  
可以说人工智能的进步，一个方向是对算法更深入的研究，另一个则是对大量数据的掌控。  
注意力机制也是这个项目中的一个重点，在[这里](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/contrib/seq2seq/python/ops/attention_wrapper.py)有一个注意力算法的实际实现。这种机制在很多机器学习项目中都有应用，是提高机器学习效率和准确率的有效手段之一。  
NMT的使用在官方文档中有介绍，这里再汇总一下：  
1. 下载源码  
```bash
git clone https://github.com/tensorflow/nmt/
```
2. 下载官方推荐的语料库样本，这个语料库来自于TED演讲，是越南语和英文的翻译语料库：  
```bash
cd nmt
mkdir nmt_data
nmt/scripts/download_iwslt15.sh ./nmt_data
```
这里跟官方文档稍有不同，官方是下载到tmp目录，而我们总是在下载上浪费大量时间，所以下载到当前路径并保存以供复用。  
3. 训练带有注意力机制的翻译模型（官方文档中的中级部分）  
```bash
mkdir nmt_model
python -m nmt.nmt \
    --src=vi --tgt=en \
    --vocab_prefix=./nmt_data/vocab  \
    --train_prefix=./nmt_data/train \
    --dev_prefix=./nmt_data/tst2012  \
    --test_prefix=./nmt_data/tst2013 \
    --out_dir=./nmt_model \
    --num_train_steps=12000 \
    --steps_per_stats=100 \
    --num_layers=2 \
    --num_units=128 \
    --dropout=0.2 \
    --metrics=bleu
```
参数很多，解释请看官方文档。  
上面语句是从越南文到英文的翻译，把--src和--tgt的参数互换可以训练从英文到越南文的翻译模型。  
4. 用训练好的模型进行翻译（算法中叫推理inference）  
首先拷贝一段越南文文本，这里使用下载的tst2013演讲文稿：
```bash
cp ./nmt_data/tst2013.vi /tmp/my_infer_file.vi
```
翻译：
```bash
python -m nmt.nmt \
    --out_dir=./nmt_model \
    --inference_input_file=/tmp/my_infer_file.vi \
    --inference_output_file=./nmt_model/output_infer
```
查看翻译的结果：
```bash
cat ./nmt_model/output_infer
```
翻译的效果其实看训练过程中的输出会更有直观印象，因为其中是越南文原文、英文对照和NMT的翻译结果3行对照输出的，这里摘两行例子：  
```
    src: Bạn có biết bạn thực hiện bao nhiêu sự lựa chọn trong 1 ngày ?
    ref: Do you know how many choices you make in a typical day ?
    nmt: Do you know how much choices you do in a day ?
	
    src: Có người nói với chúng tôi rằng như bình thường , để xây dựng lên một phần mềm sẽ phải mất ít nhất 2 năm và tiêu tốn khoảng hai triệu đô-la .
    ref: We were told afterward that if that had gone through normal channels , it would have taken at least two years and it would have cost about two million dollars .
    nmt: There &apos;s a man who says to us that as usual , to build the software , to take the least two years , and the cost of the two million dollars .
```
样本量所限，翻译结果也就是有那么些意思吧。数据才永远是核心啊。  

#### TensorFlow剩下的那些话题
我们不断的重复，机器学习本质就是以数学为代表的最新成就在计算机算法上的展现，因此TensorFlow也好，Matlab/Octave也好，所有的机器学习软件包，都具备非常强悍的数学计算能力。  
因此除了前面讲到的这些，用TensorFlow解决数学问题也非常有优势。  
官方提供的教程中，后续还有两个这方面的应用，因为与本课程的定位相关性比较弱，建议有兴趣的读者去官方的教程学习。喜欢看中文的读者也可以参考TensorFlow中文社区的翻译版本。  
[TensorFlow中文社区：曼德布洛特(Mandelbrot)集合](http://www.tensorfly.cn/tfdoc/tutorials/mandelbrot.html)  
[TensorFlow中文社区：偏微分方程](http://www.tensorfly.cn/tfdoc/tutorials/pdes.html)  

此外就是TensorFlow的应用方面的特征，也就是官方教程中的进阶部分。这里面我们只讲解了非常必须的TensorBoard。  
其它的部分，比如队列、线程、GPU计算，也非常重要。但是在你的学习阶段可以先不关注，等到项目正式成型，进入产品研发的阶段，相信随着原型设计阶段对TensorFlow的使用，你已经比较熟悉了，抽上很短的时间看看就能让你用起来。而且这部分官方的教程已经很好了，我也做不到锦上添花:)  

#### 他山之石
TensorFlow的确是非常优秀的机器学习框架，上手非常容易，资源丰富，效率也非常高。  
但是其它的竞争软件包也一直在努力，并且往往有自己的独到之处。  

_OpenCV_ 是我原来经常用的一款软件包，开源免费，全部由c/c++写成，效率超高。  
OpenCV最初定位是“计算机视觉”，在这方面走的很远，内置了很多功能可以直接对照片、视频、摄像头等进行处理。这种内置可比python利用第三方软件包完成的功能更易用，完全是一体的感觉。我们曾经提到过cv2这个python的扩展包，这实际就是使用python调用OpenCV的接口方式。  
所以有一些图像识别类的算法在OpenCV上的实现更早、更新更快。比如AR中的物品追踪、人像识别，OpenCV的实现和TensorFlow的实现基本同样是社区的贡献，但OpenCV的版本因为更新更快，往往有更强的功能。  
例如对某个物体的识别，机器学习的思路我们应当很熟悉了，需要很多已标注的样本，经过调优、训练完成模型，就可以用来进行识别。但是在很多情况下，你根本没有这么多的样本。OpenCV同样可以使用“人工智能”的某些非“机器学习”范畴的方式，不用很多样本也同样可以做到物体的识别追踪。这些其实已经不是TensorFlow不足，而是“机器学习”在这些方面的不足。  
与此类似，很多图像预处理的工作也经常习惯先用OpenCV做一遍。并不是说python利用扩展库无法完成，而是因为更方便。  
在本博中有几篇博文，展示了使用OpenCV在图像处理方面的优势，有兴趣的也可以去看看，体验一下我说的“方便”。  
  
_Octave_ 这个软件包和它模仿的商业版本Matlab我们已经一再提及了，非学术界的纯粹程序员大多都有点小看它，实际上很多时候，配合上强悍的数学公式，这个软件包能做到的事情往往出人意料。  
我收藏有一个吴恩达介绍的公式，仅用一行代码解决“鸡尾酒会问题”。  
这个问题是指，在类似鸡尾酒会这种人多、嘈杂的环境下，有两个麦克风。其中一个麦克风附近，有人在对话；另外一个麦克风附近，是一个小提琴手在演奏。  
如果是真实的人类的话，大脑会本能的、自动的过滤掉背景嘈杂的声音，从中选取自己想听到的资讯。  
而“人工智能”处理这个问题就难了很多。不过通过数学家的帮助，如前所述场景，利用两个麦克风所得到的声源中音量的区别，Octave可以用一行公式把两个声音区分出来:  
```matlab
[W,s,v] = svd((repmat(sum(yy.*yy,1),size(yy,1),1).*yy)*yy');
```
当然这里仅是示例，上面的公式跑起来，还需要附加处理的配合，诸如音源输入、预处理、分离之后的音频输出等。  

还有一些软件包，是在机器学习尚未火爆的年代就启动，做了很多年的研究，专注于解决某一方面的问题并且有很高成就的。比如分离同一个信号源中混杂的多个不同频点的信号（Independent component analysis），已经有成熟的专用软件包FastICA解决，同样可以应用在“鸡尾酒会问题”的解决中。  

所以这一节想要强调的，“机器学习”之外，实际上还有很多值得关注的技术、算法。千万不要“手里有把锤子，看什么都是钉子。”  

#### 其它那些机器学习框架
除了TensorFlow，当前还有很多机器学习框架广为应用，或者正在研发中。其中有些重量级的产品你也应当知道。  
__Caffe__: 卷积神经网络框架，专注于卷积神经网络和图像处理，用C++语言写成的。一个新的由Facebook 支持的Caffe迭代版本称为Caffe2，现在正在开发过程中，即将进行1.0发布。其目标是为了简化分布式训练和移动部署，提供对于诸如FPGA等新类型硬件的支持，并且利用先进的如16位浮点数训练的特性。   
__Chainer__: 一个强大、灵活、直观的机器学习Python软件库，能够在一台机器上利用多个GPU。是由深度学习创业公司 Preferred Networks 开发；Chainer 的设计基于 define by run 原 则，也就是说，该网络在运行中动态定义，而不是在启动时定义。  
__DMTK__: 微软的DMTK(分布式机器学习工具集)框架解决了在系统集群中分布多种机器学习任务的问题。  
__CNTK__: 微软研究人员开发的用于深度神经网络和多GPU加速技术的完整开源工具包。微软称CNTK在语音和图像识别方面，比谷歌的 TensorFlow 等其它深度学习开源工具包更有优势。  
__Deeplearning4j__: 专注于神经网络的 Java 库，可扩展并集成 Spark，Hadoop 和其他基于 Java 的分布式集成软件。  
__Nervana Neo__: 是一个高效的 Python 机器学习库，它能够在单个机器上使用多个GPU。  
__Theano__: 是一个用 Python 编写的极其灵活的 Python 机器学习库，用它定义复杂的模型相当容易，因此它在研究中极其流行。  
__Torch__: 是一个专注于 GPU 实现的机器学习库，得到了几个大公司的研究团队的支持。  
__Apache Spark MLlib__: 看名字就知道，Apache基金会的开源系统，来源于Spark中面向数学和统计用户的平台，同Spark的兼容性毋庸置疑。  
__H2O__: 现在已经发展到第三版，可以提供通过普通开发环境(Python, Java, Scala, R)、大数据系统(Hadoop, Spark）以及数据源(HDFS, S3, SQL, NoSQL)访问机器学习算法的途径。H2O是用于数据收集、模型构建以及服务预测的端对端解决方案。  
__Singa__: 是一个Apache的孵化器项目，也是一个开源框架，作用是使在大规模数据集上训练深度学习模型变得更简单。Singa提供了一个简单的编程模型，用于在机器群集上训练深度学习网络，它支持很多普通类型的训练工作：卷积神经网络，受限玻尔兹曼机 以及循环神经网络。 模型可以同步训练（一个接一个）或者也异步（一起）训练，也可以允许在在CPU和GPU群集上，很快也会支持FPGA。Singa也通过Apache Zookeeper简化了群集的设置。   
__Turi Create__：苹果公司发布，可以帮苹果几大操作系统上所运行软件的开发者，构建用于推荐、对象检测、图像分类、图像相似性以及活动分类的机器学习模型。  
__CoreML__: 同样是苹果发布，针对IOS系统，可以利用到苹果内置的机器学习CPU功能，在IOS上做机器学习首选框架。  

##### 云端产品：  
__亚马逊的机器学习服务__: 不同于前面那些，亚马逊的机器学习主要以服务的形式提供，就类似于它的其它云服务产品。该服务可以连接到存储在亚马逊 S3、Redshift或RDS上的数据，并且在这些数据上运行二进制分类、多级分类或者回归以构建一个模型。但是，值得注意的是生成的模型不能导入或导出，而训练模型的数据集不能超过100GB。亚马逊的深度学习机器图景包含了许多主要的深度学习框架，包括 Caffe2、CNTK、MXNet和TensorFlow。   
__微软的Azure ML Studio__: 考虑到执行机器学习所需的大量数据和计算能力，对于机器学习应用云是一种理想环境。微软已经为Azure配备了自己的即付即用的机器学习服务-Azure ML Studio，提供了按月、按小时和免费的版本。(该公司的HowOldRobot项目就是利用这个系统创立的。)你甚至不需要一个账户来就可以试用这项服务;你可以匿名登录，免费使用Azure ML Studio最多8小时。  
国内的百度、腾讯、阿里，也都有了自己一些机器学习的云端产品值得大家关注。  

机器学习的产品和框架如同雨后春笋般层出不穷，此处肯定不能尽列，我的建议是关注大公司产品，一般就能跟上风向。另外就是关注特定设备的特定应用，比如你在iPhone上做研发，那使用CoreML可能就是必要的选择，否则无法用到CPU内置的机器学习功能，出来的产品也会更费电、更慢。  
  
#### 其它一些模型  
快速发展的机器学习领域经常有一些新的技术或者模型，比如：  
__增强学习（强化学习）__：举一个例子更能说明。比如在一盘围棋中，盘中的某一步，实际上并不一定代表对于最终结果更优或者更差。  
传统方法是使用大规模的棋谱训练模型，来对下一步的选择做出预测。  
而增强学习是随机生成下一步的选择，然后以综合全局胜者累计增加1分，败者累计减去1分，从而在全局的角度上进行学习。  
因为电脑运算速度快，可能很快的进行非常大量的模拟棋局，从而让模型具备较好的棋局预测能力。  
最新的AlphaGo Zero就是典型代表，该项目通过随机的对游戏进行推演来逐渐建立一棵不对称的蒙特卡罗树(Monte Carlo Tree)，然后用搜索的方式来推导下一步的落子。但这种模式对于训练的数据量需求是非常非常庞大的，在无法自动生成数据集的场景中尚需继续探索。
  
__迁移学习__：这种方法实际一直在应用，只是目前有了一些更规范和更具效果的方法。顾名思义就是就是把已经训练好的模型参数迁移到新的模型来帮助新模型训练。  
比如在自动驾驶的训练中，如果我们一直用白天的视频进行训练，如果到了晚上，同一个地点，可能自动驾驶系统的表现就会非常差。  
而迁移学习就是利用同样的数据集，经过各种变换和预处理以及算法的改进，虽然并不能完全替代用夜晚数据的训练，但可以明显加强不同环境下模型的表现，这就是迁移学习。  
通常我们在图像识别应用中，为了增加数据集，也会把图片适当的调整角度、调整位置、调整颜色、增加噪点。这些方法今天来看实际也属于迁移学习的范畴。  

__多任务学习__：跟上一种模式是比较相似的。在某个模型的训练中，同时考虑到应用的多个场景，并行的进行训练，从而让完全不同的数据集发挥更大的作用，增强模型的适应性。  

#### 结束语
非常感谢你读到最后，这里我们也进展到了尾声。  
2017是人工智能的元年，这一点是可以确认的。  
但今后是不是能称为人工智能的时代，还言之尚早。人工智能尚处于发展中，很多问题需要研究，很多难点尚未突破。所以，这是我们更需要努力的地方。  
个人在实践中的感觉，不要随时都抱着一种试图“颠覆一切”的心态。  
“人工智能”和“机器学习”最大的价值，在于除了传统的编程模式，又多了一套完整的理论、框架体系，让我们有了更多的选择来解决现实中的实际问题。实践起来可能更快、更好。  
对于发展时间还很短的“机器学习”框架来说，我们都是初学者。希望我们能互相帮助、互相促进。  
水平有限，错误、疏漏在所难免，希望得到大家的批评指正，多谢。  

(END)
#### 引文及参考  
[深度学习中的注意力机制](http://blog.csdn.net/qq_40027052/article/details/78421155)  
[VESPCN, SRGAN, DemosaicNet, SVDF, LCNN](https://antkillerfarm.github.io/dl/2017/10/22/Deep_Learning_22.html)  
[增强学习、增量学习、迁移学习](http://blog.csdn.net/zyazky/article/details/51942135)  

