---
layout:         page
title:          Python和C++的混合编程
subtitle:       使用Boost编写Python的扩展包
card-image:		https://www.boost.org/doc/libs/1_60_0/libs/python/doc/html/images/python.png
date:           2018-10-10
tags:           mac opencv
post-card-type: image
---
![](https://www.boost.org/doc/libs/1_60_0/libs/python/doc/html/images/python.png)
　　想要享受更轻松愉悦的编程，脚本语言是首选。想要更敏捷高效，c++则高山仰止。所以我一直试图在各种通用或者专用的脚本语言中将c++的优势融入其中。原来贡献过一篇[《c++和js的混合编程》](https://formoon.github.io/2018/08/02/callto-cpp-from-nodejs/)也是同样的目的。  
　　得益于机器学习领域的发展，Python最近一直维持热度，但Python的速度，比node.js都差距不小，所以使用c++来提高一些速度更有必要。  
　　编写Python的扩展模块已经有不少的不错的框架，但感觉上boost是最好用的一个。  

#### 环境准备
　　本文的实验环境为mac电脑。使用Linux环境通常也可以使用apt或者yum来安装配置对应的开发环境，请查看其它介绍文档。  
　　在mac上准备环境很容易，首先要已经安装Xcode，并且安装了Xcode的命令行工具。其次要安装Homebrew扩展包管理工具。这部分是基础的开发环境，这里不做额外说明。  
　　在命令行执行`brew install boost-python3`，一行命令就可以安装完成Python模块的开发环境。（本例中完全使用Python3为例来说明，如果想制作Python2的扩展包，请根据需要修改相应的名称和版本号）。  

#### 简单示例
　　从boost官网抄了一个简单的示例，包括了初始化、从Python传递参数给c++和从c++返回结果给Python的一个基本流程。源代码非常短，请看下面：  
```cpp
#include <string>
#include <boost/python.hpp>

using namespace std;
using namespace boost::python;
	
struct World{
    void set(string msg) { this->msg = msg; }
    string greet() { return msg; }
    string msg;
};

//特别注意下面的模块名hello同将来引入Python的模块名、编译完成的文件名，三者必须相同 
BOOST_PYTHON_MODULE(hello){
   class_<World>("World")
        .def("greet", &World::greet)
        .def("set", &World::set)
   ;
}
```

#### 编译
　　假设上面的c++代码保存为hello.cpp文件。使用如下两行命令可以完成编译：  
```bash
#生成.o临时编译文件
g++ -fpic -c hello.cpp $(pkg-config --cflags python3)
#生成.so工作文件
g++ -shared -o hello.so hello.o -lboost_python37 $(pkg-config --cflags --libs python3)
```
　　上面的两行编译命令中，有两个编译参数可能是需要根据具体版本做调整的，一个是pkg-config库管理工具中的python3，这个名称和版本号可以检查如下路径的配置文件，根据自己需要选择对应的库版本，比如python3对应需要有python3.pc文件：  
```bash
ls /usr/local/lib/pkgconfig/python*pc
```
　　另外一个是第二行命令中的-lboost_python37，这个检查已经安装的库版本来决定，比如-lboost_python37对应需要有libboost_python37.dylib文件，特别注意这个版本同将来运行的python环境版本必须精确一致，小版本也必须相同： 
```bash
ls /usr/local/lib/libboost_python*
```

#### 验证
　　编译完成会在当前目录生成hello.so文件，这时候可以直接使用Python的交互模式来验证扩展模块的使用：  
```bash
$ python3
Python 3.7.0 (default, Sep 18 2018, 18:47:22) 
[Clang 9.1.0 (clang-902.0.39.2)] on darwin
Type "help", "copyright", "credits" or "license" for more information.
>>> import hello
>>> test=hello.World()
>>> test.set("hello 世界");
>>> test.greet()
'hello 世界'
```
#### bjam编译
　　boost官方推荐使用Boost.Build系统bjam来编译，比Makefile之类的确会略微的方便一点，这里介绍出来供参考。  
　　安装bjam：`brew install bjam`。  
　　在当前目录建立一个文本文件Jamroot,内容为：  
```python
import python ;

using python : 3 ;

lib boost_python37 ;

project demo
  : requirements
    <location>.
    <library>boost_python37
  ;	
#注意下面的hello,同cpp文件中最后导出的模块名必须相同
python-extension hello
	: hello.cpp
	: <cxxflags>"`pkg-config --cflags python3`"
	: <linkflags>"`pkg-config --libs python3`"
	;
```
　　在命令行执行bjam命令，会自动编译生成hello.o及hello.dylib文件，.o文件为临时文件可以删除，.dylib文件改名为.so文件就是我们需要的Python扩展库，使用起来是完全相同的。  


#### 参考资料
　　<https://www.boost.org/doc/libs/1_60_0/libs/python/doc/html/tutorial/index.html>


