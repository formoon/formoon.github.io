---
layout:         page
title:          Ubuntu 16.04.03 LTS 安装CUDA/CUDNN/TensorFlow+GPU流水账
subtitle:       包括TensorFlow再编译
card-image:     http://blog.17study.com.cn/attachments/201801/nvidia.jpg
date:           2018-01-31
tags:           linux
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201801/nvidia.jpg)  
#### 安装CUDA和CUDNN

重要的事情先说：  
1. CUDA对内核各版本依赖度非常高，随后的TensorFlow等编译时间也比较长，所以建议先安装本设备需要的其它软件系统。之后就关闭apt的自动更新，避免系统更新后CUDA不能使用。以当前`cuda_9.1.85_387.26`为例，经测试只能支持到内核版本`4.10.0-28-generic`。已经升级到新版本的，请使用apt卸载，比如：  
```bash
sudo apt-get purge linux-image-4.13.0-32-generic
sudo apt-get purge linux-headers-4.13.0-32-generic
```
CUDA及Kernel的更新都很快，所以估计你安装的时候，两个版本应当都已经变化了，尝试一下，有问题降级估计是必须的。  
错误一般是出现在运行官方.run安装包的时候，最后会报安装失败，错误信息`unable to locate the kernel source`，即便你为安装程序指定了kernel源码路径`/usr/src/xxx`也依然报同样错误，这时候往往是因为cuda与kernel版本不匹配造成的。  
系统需要的其它软件根据自己的需求决定。下面工作需要用到的主要是基本编译系统、内核开发库等，如下安装：  
```bash
sudo apt install build-essential  linux-headers-$(uname -r) swig python-pip python3-pip
sudo pip install numpy sweel
```
关闭ubuntu的自动更新：  
```bash
sudo vi /etc/apt/apt.conf.d/10periodic
```
其中最后所有的值，`"1"`都要修改成`"0"`。  
```bash
sudo vi /etc/apt/apt.conf.d/50unattended-upgrades 
```  
其中`Unattended-Upgrade::Allowed-Origins`一节的内容，没有注释的，全部用`//`注释起来。  

2. CUDA及CUDNN也是版本相关的，下载DNN的时候，特别注意选择对应你下载的CUDA版本。  
3. 官方下载的CUDA同Ubuntu系统内置的nvida驱动互相是冲突的，所以安装官方版本之前，要用apt卸载原有驱动：  
```bash
sudo apt-get autoremove --purge nvidia-*  
```
卸载前有可能需要停掉Ubuntu的GUI界面，参考下面第5项。  
4. 关闭Nouveau，因为跟CUDA不兼容：  
	```bash
	#建立一个参数文件
	vi /etc/modprobe.d/blacklist-nouveau.conf
	#粘贴下面两行进去：
	blacklist nouveau
	options nouveau modeset=0

	#存盘后执行下面命令：
	sudo update-initramfs -u
	#必须重启生效
	reboot
	```


5. 重启完成使用CTRL+ALT+1另外切一个文本终端，随后停掉当前的GUI，因为GUI运行的时候无法安装显示驱动:  
```bash
sudo service lightdm stop 
```
6. 执行安装：  
```bash
sudo sh cuda_9.1.85_387.26_linux.run 
```
各项参数基本上是用默认值，然后该确认确认，该选Yes就选一下。如果你做好了前面那些准备工作，这里安装不会有什么问题。  
安装完成建议重启一次。  
检查安装完成没有可以看一下`cat /proc/driver/nvidia/version`，如果有了正确的版本号，表示安装正常。  

7. 安装cudnn,为了省事，直接下载了deb的版本，安装方式如下：  
```bash
 #安装请注意顺序，因为有依赖关系
 sudo dpkg -i libcudnn7_7.0.5.15-1+cuda9.1_amd64.deb 
 sudo dpkg -i libcudnn7-dev_7.0.5.15-1+cuda9.1_amd64.deb 
 sudo dpkg -i libcudnn7-doc_7.0.5.15-1+cuda9.1_amd64.deb
```
8. 设定环境参数
`sudo vi /etc/environment`在最后添加下面两句，随后使用的用户需要重新登录一遍。  
```
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/cuda/extras/CUPTI/lib64"
export CUDA_HOME=/usr/local/cuda
```


#### 重编译TensorFlow
1. 安装java环境，这是为了运行TensorFlow的编译工具bazel。  
考虑到机器学习通常关联大数据，大数据常用hadoop，hadoop及其开发更偏好Oracle的版本，所以不用apt默认的openjdk，直接安装oracle的版本：  
```bash
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
```
2. 安装bazel  
```bash
echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
sudo apt-get update
sudo apt-get install bazel
```
3. 下载TensorFlow源码，另注意下面的操作，尽量使用普通用户身份进行  
```bash
git clone --recurse-submodules https://github.com/tensorflow/tensorflow
```
4. 编译
```bash
cd tensorflow
./configure
 #这一步会有很多配置的提示，根据自己的需求选择，这里主要是需要打开cuda的选项，
 #以及设定cuda的版本9.1
 #其它相关项基本使用默认值即可
 #下面这句是真正开始编译，时间会比较长
bazel build -c opt --config=cuda //tensorflow/tools/pip_package:build_pip_package --action_env="LD_LIBRARY_PATH=${LD_LIBRARY_PATH}"
 #编译完成，打包成pip安装包
bazel-bin/tensorflow/tools/pip_package/build_pip_package ./tensorflow_pkg
```
5. 使用pip安装，因编译时版本不同，文件名请改为自己生成的文件名：  
```bash
sudo pip install ./tensorflow_pkg/tensorflow-1.5.0-cp27-cp27mu-linux_x86_64.whl
```
如果碰到报错：`xxxx is not a supported wheel on this platform.`，原因可能是pip默认链接到了python3的pip，可以尝试pip2安装或者参考下面的方法：  
```bash
sudo python -m pip install -U tensorflow_pkg/tensorflow-1.5.0-cp27-cp27mu-linux_x86_64.whl
```
6. 最后是在tensorflow中测试gpu,测试有很多办法，最简单是随便做一个运算，然后打印出来资源分配看一下，比如下面源码：  
	```python
	#!/usr/bin/env python

	import tensorflow as tf
	a = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[2, 3], name='a')
	b = tf.constant([1.0, 2.0, 3.0, 4.0, 5.0, 6.0], shape=[3, 2], name='b')
	c = tf.matmul(a, b)
	sess = tf.Session(config=tf.ConfigProto(log_device_placement=True))
	print sess.run(c)
	```
结果如果能看到类似下面这样：  
	```bash
	/job:localhost/replica:0/task:0/device:GPU:0 -> device: 0, name: Quadro P5000, pci bus id: 0000:03:00.0, compute capability: 6.1

	MatMul: (MatMul): /job:localhost/replica:0/task:0/device:GPU:0
	2018-01-31 17:30:27.920258: I tensorflow/core/common_runtime/placer.cc:875] MatMul: (MatMul)/job:localhost/replica:0/task:0/device:GPU:0
	b: (Const): /job:localhost/replica:0/task:0/device:GPU:0
	2018-01-31 17:30:27.920280: I tensorflow/core/common_runtime/placer.cc:875] b: (Const)/job:localhost/replica:0/task:0/device:GPU:0
	a: (Const): /job:localhost/replica:0/task:0/device:GPU:0
	2018-01-31 17:30:27.920292: I tensorflow/core/common_runtime/placer.cc:875] a: (Const)/job:localhost/replica:0/task:0/device:GPU:0
	[[22. 28.]
	 [49. 64.]]
	```  
上面信息可以看出计算明显分配到了GPU:0在执行，表示GPU正常工作了。  
7. 一些坑：  
错误信息：  
```bash
kernel version 387.26.0 does not match DSO version 384.111.0 -- cannot find working devices in this configuration
```
以及：  
```bash
cudaGetDevice() failed. Status: CUDA driver version is insufficient for CUDA runtime version
```
基本都是各版本之前不匹配，如同开头的提示，安装好，别随便升级系统各个软件部件。  
