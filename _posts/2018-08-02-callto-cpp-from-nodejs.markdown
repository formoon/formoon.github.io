---
layout:         page
title:          简单上手nodejs调用c++
subtitle:       c++和js的混合编程
card-image:		https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1533220702787&di=8378a2181c3d109458dd80312569c07d&imgtype=jpg&src=http%3A%2F%2Fimg3.imgtn.bdimg.com%2Fit%2Fu%3D3228023448%2C1527078593%26fm%3D214%26gp%3D0.jpg
date:           2018-08-02
tags:           javascript
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1533220702787&di=8378a2181c3d109458dd80312569c07d&imgtype=jpg&src=http%3A%2F%2Fimg3.imgtn.bdimg.com%2Fit%2Fu%3D3228023448%2C1527078593%26fm%3D214%26gp%3D0.jpg)
因为项目的原因，最近经常使用node.js搭RESTful接口。  
性能还是很不错啦，感觉比Spring Boot之类的要快。而且在不错的性能之外，只要程序结构组织好，别让太多的回调把程序结构搞乱，整体开发效率比Java快的就太多了。  

如果想进一步提高效率，使用c++来优化部分模块是不错的选择。尤其可贵的是nodejs对于同c++的混合编程支持的很好，个人感觉跟写Python的扩展模块处于同样的易用水平。  

我们从Hello World开始：  
首先要有一个空白的工作目录，在其中建立一个node包管理文件package.json，内容为：  
```js
{
  "name": "test-cpp-module",
  "version": "0.1.0",
  "private": true,
  "gypfile": true
}
```
随后在目录中执行命令：`npm install node-addon-api --save`安装nodejs扩展模块的开发支持包。这里假设你已经安装配置好了nodejs和相应的npm包管理工具，还有xcode的相关命令行编译工具。我们不重复这些基本工具的安装配置，需要的话请参考官网相关文档。  
上面命令执行完成，我们就完成了基本开发环境的配置。  

c++的模块由binding.gyp文件描述，并完成自动编译的相关配置工作，我们新建一个binding.gyp文件，内容为：  
```javascript
{
  "targets": [
    {
      "target_name": "democpp",
      "sources": [
        "democpp.cc"
      ],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "dependencies": [
        "<!(node -p \"require('node-addon-api').gyp\")"
      ],
      "cflags!": ["-fno-exceptions"],
      "cflags_cc!": ["-fno-exceptions"],
      "defines": ["NAPI_CPP_EXCEPTIONS"],
      "xcode_settings": {
        "GCC_ENABLE_CPP_EXCEPTIONS": "YES"
      }
    }
  ]
}
```
* 文件中首先使用target_name指定了编译之后模块的名称。  
* sources指明c++的源文件，如果有多个文件，需要用逗号隔开，放到同一个数组中。  
* include_dirs是编译时使用的头文件引入路径，这里使用node -p执行node-addon-api模块中的预置变量。  
* dependencies是必须的，不要改变。  
* 后面部分，cflags!/cflags_cc!/defines三行指定如果c++程序碰到意外错误的时候，由NAPI接口来处理，而不是通常的由c++程序自己处理。这防止因为c++部分程序碰到意外直接就退出了程序，而是由nodejs程序来捕获处理。如果是在Linux中编译使用，有这三行就够了。  
* 但如果是在macOS上编译使用，则还要需要最后一项xcode-settings设置，意思相同，就是关闭macOS编译器的意外处理功能。  
最后是c++的源码，democpp.cc文件：  

```cpp
#include <napi.h>

using namespace Napi;

String Hello(const CallbackInfo& info) {
  return String::New(info.Env(), "world");
}
Napi::Object  Init(Env env, Object exports) {
  exports.Set("hello", Function::New(env, Hello));
  return exports;
}
NODE_API_MODULE(addon, Init)

```
程序中引入napi.h头文件，使用Napi的namespace还有最后的NODE_API_MODULE(addon,Init)都是模板化的，照抄过来不用动。  
Init函数中，使用`exports.Set()`引出要暴露给nodejs调用的函数。如果有多个需要引出的函数，就写多行。  
Hello函数式我们主要演示的部分，这里很简单，只是用字符串的方式返回一个“hello”。  

以上democpp.cc/binding.gyp/package.json三个文件准备好之后，在命令行执行：`npm install`，顺利的话会得到这样的输出信息：  
```bash
$ npm install

> test-cpp-module@0.1.0 install /home/andrew/Documents/dev/html/nodejs/callcpp
> node-gyp rebuild

  SOLINK_MODULE(target) Release/nothing.node
  CXX(target) Release/obj.target/democpp/democpp.o
  SOLINK_MODULE(target) Release/democpp.node
```
这表示编译顺利完成了，如果碰到错误，可以根据错误信息去判断解决方案。通常都是环境配置缺少相关程序或者上述的三个文件有打字错误。  
下面我们验证一下模块的编译结果，在命令行使用nodejs，引入编译的模块文件，然后调用hello函数来看看：  
```bash
> $ node
> democpp=require("./build/Release/democpp.node")
{ hello: [Function] }
> democpp.hello()
'world'
> 
```

上面是最简单的一个范例，下面我们增加一点难度。在GNU的环境下，通常我们的程序都会包含很多第三方的扩展库，我们这里再举一个调用openssl的例子：  
package.json文件不用修改，我们不需要在nodejs层面增加新的依赖包。  
编译带第三方扩展库的c++程序，通常需要在编译时指定额外的头文件包含路径和链接第三方库，这些都是在binding.gyp中指定的，这些指定在nodejs自动编译的时候，会解析并应用在命令行的编译工具中。  
```javascript
{
  "targets": [
    {
      "target_name": "democpp",
      "sources": [
        "democpp.cc"
      ],
      "include_dirs": [
        "<!@(node -p \"require('node-addon-api').include\")"
      ],
      "libraries": [ 
        '-lssl -lcrypto',
      ],
      "dependencies": [
        "<!(node -p \"require('node-addon-api').gyp\")"
      ],
      "cflags!": ["-fno-exceptions"],
      "cflags_cc!": ["-fno-exceptions"],
      "defines": ["NAPI_CPP_EXCEPTIONS"],
      "xcode_settings": {
        "GCC_ENABLE_CPP_EXCEPTIONS": "YES"
      }
    }
  ]
}
```
在macOS和常用linux版本中，openssl的头文件会自动安装在系统的头文件路径中，比如/usr/local/include,所以这里头文件的引入路径并没有增加。如果使用了自己安装的扩展库，需要在include_dirs一节增加新的头文件包含路径。  
接着增加了libraries一节，指定了Openssl扩展库的链接参数`-lssl -lcrypto`，这个是必须的。  
最后是修改democpp.cc文件，添加一个使用openssl中的md5算法对字符串进行md5编码的函数：  
```cpp
#include <napi.h>
#include <openssl/md5.h>

using namespace Napi;

void openssl_md5(const char *data, int size, unsigned char *buf){
	MD5_CTX c;
	MD5_Init(&c);
	MD5_Update(&c,data,size);
	MD5_Final(buf,&c);
}

String GetMD5(const CallbackInfo& info) {
  Env env = info.Env();
  std::string password = info[0].As<String>().Utf8Value();
  //printf("md5 in str:%s %ld\n",password.c_str(),password.size());
  unsigned char hash[16];
  memset(hash,0,16);
  openssl_md5(password.c_str(),password.size(),hash);
  char tmp[3];
  char md5str[33]={};
  int i;
	for (i = 0; i < 16; i++){
	  sprintf(tmp,"%02x",hash[i]);
	  strcat(md5str,tmp);
	}
  return String::New(env, md5str,32);
}

String Hello(const CallbackInfo& info) {
  return String::New(info.Env(), "world");
}
Napi::Object  Init(Env env, Object exports) {
  exports.Set("hello", Function::New(env, Hello));
  exports.Set("md5", Function::New(env, GetMD5));
  return exports;
}
NODE_API_MODULE(addon, Init)
```
为了工作方便，源码中增加了一个没有引出的openssl_md5函数，仅供程序内部使用。因为没有引出，nodejs并不知道这个函数的存在。  
从nodejs传递参数给c++的函数，是使用`info[0].As<String>().Utf8Value()`这样的形式。返回值到nodejs在hello函数中就已经看过了。  
各项修改完成，同样回到命令行使用`npm install`重新编译。编译的过程和信息略，我们直接看调用的测试：  
```bash
> $ node
> democpp=require("./build/Release/democpp.node")
{ hello: [Function], md5: [Function] }
> democpp.hello()
'world'
> democpp.md5("abc")
'900150983cd24fb0d6963f7d28e17f72'
> 
```
想验证一下计算的正确性？可以直接执行openssl试试：  
```bash
$ echo -n "abc" | openssl md5
900150983cd24fb0d6963f7d28e17f72
```
嗯，无悬念的相同。  

#### 参考文档
<https://github.com/kriasoft/nodejs-api-starter>  
<https://github.com/nodejs/node-addon-api/blob/master/doc/node-gyp.md>




