---
layout:         page
title:          分享一个很通用的Makefile
subtitle:       自动化程度比较高的c语言Makefile
card-image:     http://blog.17study.com.cn/attachments/201712/makefile.png
date:           2017-12-19
tags:           mac
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201712/makefile.png)

编写Makefile是一个苦乐交织的事情，快乐是因为从一堆需要手工逐个处理的编译过程，进步到一条命令完成，看着代码顺畅的在屏幕上滚动，编译为最终的产品，那个过程无比愉悦；而痛苦则是，写代码已经很累了，写完代码还要编写Makefile,这多出来的一点工作，很有点最后一根稻草的感觉。  
最近整理手头的几个项目，把C语言类的Makefile抽象、合并了一下，形成了一个比较通用的编译脚本，这里分享一下：  
```make
#定义编译器
CC=gcc
#自己特定的编译参数，这里仅为示例，这个参数是消除mac编译openssl类程序用的
CFLAGS += -Wno-deprecated-declarations

#定义输出文件夹，outs默认等于是./outs
OUTSDIR = outs
#定义.o中间文件的路径，这个路径编译完成可以清除
TMPSDIR = objs

#源代码路径
VPATH=src

#扫描所有的c源码，这里默认src中所有文件都是相当于库文件，最终编译为.o
#搜索出来的文件包含了src路径，这里也去掉，便于后面编译到临时目录
OBJSSOURCE = $(notdir $(wildcard src/*.c))  
OBJS = $(patsubst %.c,%.o,$(OBJSSOURCE))  

#主程序名
KEYS = main
DEPS  = $(addprefix $(TMPSDIR)/,$(OBJS))  

.PHONY : all
all:$(OBJS) $(KEYS) 

#编译所有的库文件由.c至.o
#因为VPATH的存在，源文件会自动检索src目录
$(filter %.o,$(OBJS)) : %.o : %.c
	$(CC) $(CFLAGS) -c -o $(TMPSDIR)/$@ $<

#利用所有的库文件编译主程序		
$(KEYS): $(DEPS)
	$(CC) $(CFLAGS) -o $(OUTSDIR)/$(notdir $@) $(notdir $@).c $(DEPS)

#清理	
.PHONY : clean 
clean:
	-rm $(OUTSDIR)/* $(TMPSDIR)/*

```
这个编译脚本的主要特点是自动扫描所有的源文件，然后逐个编译，对于大多c类的项目，基本只需要定义一下主程序就可以完成编译了，其实根据同样的原理连主程序都一起扫描、编译也是可以的，只是似乎自由度太差了。  
脚本简单修改可以适应各种环境，比如下面再贴一个ios使用的，ios如果非越狱的话，直接编译成可执行文件是没有意义的，这里我们假设编译成.a库文件，供xcode来调用：  
```make
#ios交叉编译器
CC=$(shell xcrun --sdk iphoneos --find clang)
_SFLAG=$(shell xcrun --sdk iphoneos --show-sdk-path)
#iphone6以后都是arm64了，所以这里不再考虑armv7,另外也不考虑模拟器运行了
#如果有需要可以根据自己的需求修改
CFLAGS += -Wno-deprecated-declarations -isysroot $(_SFLAG) -arch arm64 -mios-version-min=9.3 -fembed-bitcode

OUTSDIR = outs
TMPSDIR = objs

VPATH=src

OBJSSOURCE = $(notdir $(wildcard src/*.c))  
OBJS = $(patsubst %.c,%.o,$(OBJSSOURCE))  
DEPS  = $(addprefix $(TMPSDIR)/,$(OBJS))  

#最后生成的库
KEYS = libcallfunctions.a

.PHONY : all
all:$(OBJS) $(KEYS) 

#编译所有的库文件由.c至.o
$(filter %.o,$(OBJS)) : %.o : %.c
	$(CC) $(CFLAGS) -c -o $(TMPSDIR)/$@ $<

#将.o文件打包为库
libcallfunctions.a : $(DEPS)
	ar -r $(OUTSDIR)/libcallfunctions.a $(DEPS)

#清理	
.PHONY : clean 
clean:
	-rm $(OUTSDIR)/* $(TMPSDIR)/*

```
在主要的编译环节，还有下面这种常用的办法,只是自己运算得到了源文件名而没有用Make系统的自动搜索功能而已：  
```make
%.o:
	$(CC) $(CFLAGS) -c -o $(TMPSDIR)/$@ src/$(patsubst %.o,%.c,$@)
```
对于更复杂的编译模式，建议把每个编译环节定义成子程序来执行，可以具备更多的灵活性。另外当前这个脚本有一个bug就是每次编译实际上所有的.o文件都会完整重新编译一遍，而没有判断源文件是否更新并忽略没有更新的源文件，所以不适合大的系统。  
