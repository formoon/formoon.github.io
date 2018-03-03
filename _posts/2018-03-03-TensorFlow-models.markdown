---
layout:         page
title:          那些令人惊艳的TensorFlow扩展包和社区贡献模型 
subtitle:       Tensorflow models
card-image:		http://p1avd6u2z.bkt.clouddn.com/201801/ml/tensorflowlogo.jpg
date:           2018-03-03
tags:           ml toSeven
post-card-type: image
---
随着TensorFlow发布的，还有一个models库(仓库地址:<https://github.com/tensorflow/models>)，里面包含官方及社群所发布的一些基于TensorFlow实现的模型库，用于解决各式各样的机器学习问题。  
很多任务，在其中都能找到相同或者近似功能的实现，这时候无需编程或者只要很少的编程，就可以在已有模型的基础上建立自己的人工智能应用。  
而且models的更新也比较快，因为大量的社群参与者，几乎每天都有模块的更新commit。  

#### 简介
当前版本TensorFlow(1.6.x)中的models分为4个部分，分别是tutorials（用于保存TensorFlow官方教程中的案例）、samples（保存了用于展示TensorFlow功能特征的一些代码片段）、official（由官方技术人员维护的一些示例代码及模型，保持同最新版本TensorFlow的兼容性）、research（由非官方研究者维护的一大批模型及代码，可以解决很多问题，但分属于不同的开发者，代码质量由不同的开发者自己保证。）  

#### tutorials目录
**embedding:** 我们系列中用过的《单词向量化》示例代码，除了纯python的版本，还包括使用c++编写的TensorFlow扩展组件示例。  
**image:** 用于图像学习的几个教学示例，其中的mnist我们多次用来当做示例。  
**rnn:** rnn循环神经网络的示例，包括sequence-to-sequence的示例，是学习谷歌机器翻译模型NMT的前置课程。
#### samples目录
同tutorials代码比较类似，提供一些代码片段或者小型的模型用于演示tensorflow的一些功能特征。也包含一些博文中的代码段。可用于学习参考，但并不直接面向应用。  

#### official目录
**mnist:** 我们的系列中一再用到的手写数字识别例程，算是最简单的TensorFlow入门教程。与时俱进的官方版本还增加了最新的TPU加速版本和Eager execution版本。  
**resnet:** ResNet(深度残差网络结构)可支持非常深层的卷积神经网络，在大量图片分类中有良好的表现。TensorFlow中用于展示典型的cifar10图片分类例程。  
**wide_deep:** 使用wide and deep模型对成年人收入调查数据模型进行学习及预测。成年人调查数据集也称Census Income Dataset，包含48,000个样本，涵盖成年人年龄、职业、教育程度、收入等信息。  
官方承诺很快还将增加更多的典型模型。  

#### research目录
很多人认为这是TensorFlow models中最精华也最有魅力的部分。来自大量的社区贡献者。  
**adversarial_crypto:** 基于Adversarial Neural Cryptography算法，使用随机的输入数据和秘钥对，训练编码、解码、对抗三元组，并评估它们的效率。  
**adversarial_text:** 使用半监督学习进行对抗性文本分类。训练样本使用IMDB的影评数据。  
**attention_ocr:** 带有注意力机制的街景照片结构化文本信息抽取模型。![](https://github.com/tensorflow/models/raw/master/research/street/g3doc/avdessapins.png)
比如这样的照片中，可以有效的识别出“Avenue des Sapins”文字。  
**street:** 跟上一个例子很类似，使用基于深度循环神经网络的STREET算法对街景中的街道标识进行识别的模型。  
**audioset:** AudioSet是Google语音理解小组发布于2017年3月的大规模语音数据集，含有从YouTube视频音轨中提取的超过2百万条经过人工标记的音频文件，每段音频长度10秒钟，分类为600余种声音事件。这个仓库提供用于AudioSet检测、评估的模型和代码。可以作为语音理解机器学习的起始点。  
**autoencoder:** 自动编码器是一个很有趣的应用，学习过程相当于编码，用于提取原始数据特征，随后解码同原始数据进行比较，不断修正权重参数来提高数据解码后的还原能力，最终获得一个自动编码器。  
**compression:** 自动压缩解压，跟上例中差不多的原理，使用RNN网络实现，对于图片的压缩和还原有非常明显的效果，可以有很大的压缩比，并且还原基本没有什么明显的损失。示例中还提供了一种无损压缩的算法。目前的主要缺点是压缩和解压缩都属于机器学习的过程，速度非常慢。  
**brain_coder:** 是一个程序合成实验框架，可以量化的评估实验算法的效率。使用优先级队列和 RNN 的搜索算法进行实验，并展示了将优先级队列作为 RNN的训练目标是一种高效、稳定的方法。  
**cognitive_mapping_and_planning:** 实现了一个基于空间记忆的地图搜索、路线规划的虚拟导航模型。  
**delf:** delf是DEep Local Features的缩写，特指一副图片中一些特定的、标志性的关键特征。以建筑照片为例，多幅同一位置、不同角度的照片，所提取出来的DELF特征具有可对比、可关联的特征，下图为本模型所生成的一副典型特征图。![](https://raw.githubusercontent.com/tensorflow/models/master/research/delf/delf/python/examples/matched_images_example.png)  
**differential_privacy:** 这是一个很有前瞻性的项目。通常的机器学习都对接在大数据系统的下游，而监督学习的特征往往需要大量重复性的人工标注工作，这种工作在大多数公司往往都是采用“众包”的形式进行的，这就造成了数据集中一些敏感信息、特别是涉及到人的隐私的保护问题。本算法试图在不暴露用户隐私的情况下实现学习、预测的过程，且不降低学习效率、不过多增加模型复杂度。  
**domain_adaptation:** 领域适应性是几乎所有机器学习行业的人都会遇到的问题。数据集的收集、标注和模型的建立、训练、调优是成本非常高昂的工作，人们都希望自己的模型在一个“源域”训练完成后，可以直接应用到“目标域”的工作中。这实际也是我们说过的“迁移学习”的概念。本仓库中包含两个根据不同论文实现的两个案例模型可供研究参考。  
**gan:** GANs是生成型对抗网络(Generative Adversarial Networks)的缩写。本仓库中包含了4个完全独立的示例源码，展示GANs的TensorFlow版本实现在图像识别、图像压缩等领域的应用。  
**im2txt:** 这个是很有名的一个模型，实现对给定图片完成文字的自动标注，有很多移动app中都使用了这个模型。下图是作者给出的标注结果图片：  
![](https://raw.githubusercontent.com/tensorflow/models/master/research/im2txt/g3doc/example_captions.jpg)  
**inception:** 用于计算机图像识别的一个深度卷积网络模型，当前是v3版本。模型的结构如下：![](https://raw.githubusercontent.com/tensorflow/models/master/research/inception/g3doc/inception_v3_architecture.png)  
**learning_to_remember_rare_events:** 用于深度学习的大规模全生命期记忆模型。  
**lfads:** lfads是Latent Factor Analysis via Dynamical Systems的缩写，表示分析动态系统中的潜在因素。是一个专门为研究神经科学数据而设计的连续变分自动编码器，但可广泛应用于任何时间序列数据。属于非监督学习。  
**lm_1b:** 基于One Billion Word Benchmark的预训练模型。One Billion Word Benchmark是一个2013年发布的英语大型语料库。该数据集包含约10亿字，词汇量大约为800K字。 它主要包含新闻数据。 由于训练集中的语句被打散混编，模型可以忽略语境并关注语句级语言建模。  
**maskgan:** 基于 PTB(Penn Treebank)模型，用于生成一句话中给定空白处最合适的单词。  
**namignizer:** 使用Kaggle Baby Name Database数据集识别和生成名字。语言模型基于修改过的PTB模型。  
**neural_gpu:** 一组高性能的GPU神经计算的代码库，实现了排序、检索等常用算法可供直接调用。  
**neural_programmer:** 一个神经网络编程的具体实现。  
**next_frame_prediction:** 通过交叉卷积网络来学习一个动画帧序列，并预测合成最可能的未来帧。比如基于一个已有的动画帧序列：  
<img width='65' height='256' style='max-width:65px;max-height:256px' src="https://raw.githubusercontent.com/tensorflow/models/master/research/next_frame_prediction/g3doc/cross_conv.png">  
可能得到这样的结果：  
<img style='max-width:65px;max-height:256px'  src='https://raw.githubusercontent.com/tensorflow/models/master/research/next_frame_prediction/g3doc/cross_conv2.png'>  
**object_detection:** 这个是我见到普及范围最广的一个案例，没有之一。最近两个月就见到了最少3家公司在使用这个模型来为自己的产品提高智能程度。本应用允许用户在图片上标定物件，形成训练数据集。随后可以使用数据集在给定的照片中识别出来是否包含物件及坐标位置，如下图示例：  
![](https://raw.githubusercontent.com/tensorflow/models/master/research/object_detection/g3doc/img/kites_detections_output.jpg)  
**pcl_rl:** 几个强化学习（RL）的代码示例，包括路径一致性学习(PCL)模型。  
**ptn:** PTN是透视变换网络（perspective transformer nets）模型的缩写，用于3D物体重构。下图是运行的示例，其中从左到右包含3组3D模型，每一组的第三列和第五列分别是算法预测出的蒙版和3D重构模型,左侧（第二列和第四列）则是实际的真值:  
![](https://camo.githubusercontent.com/ccc0cc8a167b033697d16491def67a66c19092b3/68747470733a2f2f64726976652e676f6f676c652e636f6d2f75633f6578706f72743d766965772669643d3042313258756b6362553754375a46563661455642534464434d6a51)  
**qa_kg:** 基于知识图谱(kg)的问答(qa)模型。  
**real_nvp:** 基于真实数据、非容积保留变换（real NVP)算法的密度评价模型。训练使用LSUN（<http://lsun.cs.princeton.edu/2016/>）数据集。  
**rebar:** REBAR是低方差、无偏差梯度评估算法模型的名字，本例中基于此模型实现了一个加强学习的示例。  
**skip_thoughts:** Skip-Thought模型是语句向量化的一种算法，类似TensorFlow官方案例中是的word2vec，据称拥有更好的性能，本模型的实现者给出了一组输出样例：  
```
Sentence:
 simplistic , silly and tedious .

Nearest neighbors:
 1. trite , banal , cliched , mostly inoffensive . (0.247)
 2. banal and predictable . (0.253)
 3. witless , pointless , tasteless and idiotic . (0.272)
 4. loud , silly , stupid and pointless . (0.295)
 5. grating and tedious . (0.299)
 6. idiotic and ugly . (0.330)
 7. black-and-white and unrealistic . (0.335)
 8. hopelessly inane , humorless and under-inspired . (0.335)
 9. shallow , noisy and pretentious . (0.340)
 10. . . . unlikable , uninteresting , unfunny , and completely , utterly inept . (0.346)
 ```
 **slim:** TF-slim是一个对Tensorflow库(tensorflow.contrib.slim)的轻量级、高抽象层的实现。用于定义、训练、评估更复杂的模型。  
 **swivel:** 同样是一个单词向量化的实现，基于旋转算法(Swivel algorithm)。  
 **syntaxnet:** Google花费大量的投资研究如何让计算机更智能的理解人类的语言，也就是自然语言理解（Natural Language Understanding）(NLU) ，最终成果就是SyntaxNet/DRAGNN。  
**tcn:** 基于时间对比网络（Time Contrastive Networks）实现了一个多视角视频自监督学习的算法模型。算法的描述示意图如下：  
![](https://camo.githubusercontent.com/e3117fa6594808e84d2475caa0855762c57fc497/68747470733a2f2f7365726d616e65742e6769746875622e696f2f74636e2f646f63732f666967732f6d7654434e2e706e67)  
**textsum:** 基于带有注意力机制的Sequence-to-Sequence模型实现的文本摘要自动生成算法。注意力机制的Sequence-to-Sequence模型也是谷歌翻译模型NMT算法的核心部分。算法文档中给出了一些示例：  
```
原文: novell inc. chief executive officer eric schmidt has been named chairman of the internet search-engine company google .
人工摘要: novell ceo named google chairman
算法自动生成的摘要: novell chief executive named to head internet company
```
**transformer:** 空间变换网络，允许操作数据进行空间变换，案例使用了MNIST数据集，将原始图片进行空间变换从而具有更好的可识别度：  
![](https://camo.githubusercontent.com/bb81d6267f2123d59979453526d958a58899bb4f/687474703a2f2f692e696d6775722e636f6d2f4578474456756c2e706e67)  
**video_prediction:** 前面已经有了两个类似的例子，同样是在一个视频序列中根据前面的视频帧预测后续的帧图像：  
<img style='max-width:256px;max-height:256px' src='https://camo.githubusercontent.com/e20728d90a3531a6a5324e4864b00529288bd7b7/68747470733a2f2f73746f726167652e676f6f676c65617069732e636f6d2f707573685f67656e732f6e6f76656c67656e67696673392f315f33382e676966'>  

#### 小结：
实际上很多机器学习工作，都不需要你从头干起。这也恰恰是现在如此多机器学习框架纷纷出炉的目的。这些丰富的模型中，相信总能找到接近你需求的一款。  
一个小技巧，在这些模型甚至还有很多并非TensorFlow发布的模型中，有很多是功能比较类似的，究竟采用哪一个实现到自己的工作中？当然一方面是看具体需求，找比较接近、上手容易的。另外一方面也可以根据github的Watch数据（相当于点击量）和Star数据（相当于点赞的人数）来从侧面帮助你做一个决策。  



