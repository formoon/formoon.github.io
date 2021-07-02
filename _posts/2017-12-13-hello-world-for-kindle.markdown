---
layout:         page
title:          在Ubuntu上搭建kindle gtk开发环境
subtitle:       以及kindle gtk样本程序
card-image:     http://blog.17study.com.cn/attachments/201712/gtk.png
date:           2017-12-13
tags:           linux
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201712/gtk.png)

某个角度上说，kindle很类似android,同样的Linux内核，同样的Java用户层。不过kindle更注重简单、节能、稳定。Amazon一向认为，功能过多会分散人们阅读时候的注意力。  
Kindle底层的Linux比Android保持了更多的linux兼容性，可以使用GTK或者QT编写程序。QT适合编写大的、独占界面性的应用，比如多看就曾经发布过一个Kindle之上的版本，现在还有很多人用，可惜因为公司战略调整的原因，这个产品被废弃了。GTK及最基本的Linux应用更适合开发一些补丁性的小程序，来补充Kindle的基本功能。在Ubuntu上搭建kindle的gtk开发环境非常简单,只需要一条命令：
```bash
sudo apt-get install pkg-config gcc-arm-linux-gnueabi libgtk2.0-dev
```
接着我们来写一个hello world来验证功能：(文件名:testGtk.c)  
{% highlight c %}
#include <gtk/gtk.h>

static void hello( GtkWidget *widget,gpointer data ) {
    gtk_main_quit ();
}

static gboolean delete_event( GtkWidget *widget, GdkEvent  *event, gpointer   data ) {
    g_print ("delete event occurred\n");
    return FALSE; // we do want to quit
}

static void destroy( GtkWidget *widget, gpointer   data ) {
    gtk_main_quit ();
}

int main( int   argc, char *argv[] ) {

    GtkWidget *window;
    GtkWidget *button;

    gtk_init (&argc, &argv);

    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
    g_signal_connect (window, "delete-event", G_CALLBACK (delete_event), NULL);
    g_signal_connect (window, "destroy", G_CALLBACK (destroy), NULL);
    gtk_container_set_border_width (GTK_CONTAINER (window), 10);
    button = gtk_button_new_with_label ("Hello World");
    g_signal_connect (button, "clicked", G_CALLBACK (hello), NULL);
    gtk_container_add (GTK_CONTAINER (window), button);
    gtk_window_set_title ( GTK_WINDOW(window) , "L:A_N:application_ID:test");
    gtk_widget_show_all (window);

    gtk_main ();
    return 0;
}
{% endhighlight %}
接着先在桌面Linux电脑上编译来试一下：
```bash
gcc -o testGtk testGtk.c `pkg-config gtk+-2.0 --cflags --libs`
```
在电脑上执行./testGtk，可以看到结果正确。  
交叉编译kindle的版本则相对比较复杂，我们还是直接写一个Makefile吧，避免手工输入太长容易出错，同时Makefile中也增加了macos的编译部分。gtk虽然看上去很陈旧、落伍，但是跨平台用起来，其实比很多主流应用还要顺畅。  
{% highlight Makefile%}
GCC=gcc
ARMGCC=arm-linux-gnueabi-gcc
ARMLIBS=`pkg-config gtk+-2.0 --cflags` -L/usr/arm-linux-gnueabi/lib/ -L/home/andrew/dev/kindleLib/ -lgtk-x11-2.0 -lgdk-x11-2.0 -lXrender -lXinerama -lXext -lgdk_pixbuf-2.0 -lpangocairo-1.0 -lXdamage -lXfixes -latk-1.0 -lcairo -lpixman-1 -lpng12 -lxcb-shm -lxcb-render -lX11 -lxcb -lXau -lXdmcp -lgio-2.0 -lpangoft2-1.0 -lpango-1.0 -lfontconfig -lfreetype -lz -lexpat -lgobject-2.0 -lffi -lgmodule-2.0 -lgthread-2.0 -lglib-2.0

keys = testKindleGtk

all:$(keys) $(objs)


testKindleGtk:testGtk.c
	$(ARMGCC) -o testKindleGtk testGtk.c $(ARMLIBS)
	
x86:
	gcc -o testGtk testGtk.c `pkg-config gtk+-2.0 --cflags --libs` 
osx:
	export PKG_CONFIG_PATH=/usr/X11/lib/pkgconfig && gcc -o testGtk testGtk.c `pkg-config gtk+-2.0 --cflags --libs` 
clean:
	rm $(keys) testGtk
{% endhighlight %}
项目的源码已经上传到[github](https://github.com/formoon/kindleGtkDemo),有兴趣的可以下载试试。  
咳。。。不好意思，原谅我把最重要的放到最后说，在kindle上测试这个程序，需要越狱kindle,在KPW2之间的版本，在网上搜索，有软件的方法越狱。之后的版本就复杂了，可能还需要拆机引串口线的方式。  
不过总感觉kindle的越狱还是很有意义的，主要是原生系统对于纯文本的排版水平实在太差，我就是越狱后装了再也见不到更新的多看系统。

	 
	
 	





