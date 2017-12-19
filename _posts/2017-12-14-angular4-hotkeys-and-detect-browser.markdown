---
layout:         page
title:          Angular2+的两个小技巧
subtitle:       检测浏览器以及热键绑定
card-image:     https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1513236363921&di=321ac235a6c875971dbd8a384129a30e&imgtype=0&src=http%3A%2F%2F5xruby.tw%2Fuploads%2Fpost%2Fimage%2F6%2Fangularjs.png
date:           2017-12-14
tags:           html
post-card-type: image
---
![](https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1513236363921&di=321ac235a6c875971dbd8a384129a30e&imgtype=0&src=http%3A%2F%2F5xruby.tw%2Fuploads%2Fpost%2Fimage%2F6%2Fangularjs.png)
Angular2以后已经非常充分的面向对象化，所以很多原来在javascript中积累的技巧，都需要做出相应的调整。  
检测当前浏览器类型、版本及设备类型，推荐使用：[https://github.com/KoderLabs/ng2-device-detector](https://github.com/KoderLabs/ng2-device-detector)。github页面的介绍已经写的很详细，请直接阅读原文文档。这里只讲几个重点：

1.当前的AngularJS版本已经是5，已经有人对上面的模块做了优化，更名为ng4-device-detector,所以安装过程应当是：
{% highlight bash %}
cnpm install ng4-device-detector --save
{% endhighlight %}
 使用cnpm安装而不是原来的npm，原因是如果你在国内，因为众所周知的原因，下载国外的包资源可能会很慢并且有被封掉的可能，cnpm是使用阿里的镜像站下载，速度会快很多。
 
2.因为变更了控件包，原有的app.module.ts应当变更为：
{% highlight javascript %}
  import { NgModule } from '@angular/core';
  import { Ng4DeviceDetectorModule } from 'ng4-device-detector';
  ...
  @NgModule({
    declarations: [
      ...
      LoginComponent,
      SignupComponent
      ...
    ],
    imports: [
      CommonModule,
      FormsModule,
      Ng4DeviceDetectorModule.forRoot()
    ],
    providers:[
      AuthService
    ]
    ...
  })
{% endhighlight %}
看出来了吧，所有ng2都变成ng4,没啥难以理解的，其它的源码部分也要做类似的修改，就不详细说了。

3.ng4-device-detector的小坑  
模块提供了以下几个属性用于判断当前浏览器类型：
 * browser
 * os
 * device
 * userAgent
 * os_version
 
这里面有个小bug,比如os属性，如果使用手机浏览，正常应当返回`android`或者`iphone`,但我用iPhone测试的时候，居然也返回`mac`，好在device属性正常返回了`iphone`。换用Mac访问的时候，os返回仍然是`mac`,device返回是`unknow`。所以建议使用如下代码来判断设备类型：
{% highlight javascript %}
	...
  isMobile=false;
	...
  constructor(private deviceService: Ng4DeviceService){
    if (this.deviceInfo.device == 'android' || 
        this.deviceInfo.device=='iphone' ||
        this.deviceInfo.device == 'ipad' ){
      this.isMobile=true;
    };
	...
{% endhighlight %}
得到了isMobile的值，页面中就可以使用这个值来对应不同版本的页面了：
{% highlight html %}
<SourcePage *ngIf="!isMobile"></SourcePage>
<SourcePageMobile *ngIf="isMobile"></SourcePageMobile>
{% endhighlight %}

4.ng4-device-detector的大坑  
都知道正常的ng4项目编译，是使用`ng build`命令。  
这样产生的目标文件比较大，所以如果是为了服务器生产部署，应当是用`ng build -prod`,这样产生的文件，大约只有平常的1/6容量，速度也会快很多。  
但是引入了ng4-device-detector或者ng2-device-detector，使用`ng build -prod`会报错，（使用`ng build`及`ng server`调试没有问题）,错误信息为：
```
ERROR in Error encountered resolving symbol values statically. Calling function 'ɵmakeDecorator', function calls are not supported. Consider replacing the function or lambda with a reference to an exported function, resolving symbol Injectable in /Users/andrew/dev/html/angular/educast-local/node_modules/ng4-device-detector/node_modules/@angular/core/core.d.ts, resolving symbol ɵe in /Users/andrew/dev/html/angular/educast-local/node_modules/ng4-device-detector/node_modules/@angular/core/core.d.ts, resolving symbol ɵe in /Users/andrew/dev/html/angular/educast-local/node_modules/ng4-device-detector/node_modules/@angular/core/core.d.ts

ERROR in ./src/main.ts
Module not found: Error: Can't resolve './$$_gendir/app/app.module.ngfactory' in '/Users/andrew/dev/html/angular/educast-local/src'
 @ ./src/main.ts 4:0-74
 @ multi ./src/main.ts
```
主要是新系统对于lambda函数的使用限制造成的，也有说是angular5的bug,虽然修改代码可以解决问题，但是也可以关闭编译器的aot属性来完成编译：
{% highlight html %}
ng build -prod --aot false
{% endhighlight %}
这样可以顺利完成编译，并且测试没有问题。

————————————————————————————————————————————

接着是捆绑热键的方法，这个也有第三方的模块可以用，比如[angular2-hotkeys](https://www.npmjs.com/package/angular2-hotkeys),可以去官方页面看看介绍。  
这里介绍一个沿用原来javascript的知识，自己写一部分代码来实现的方式：
{% highlight javascript %}
import { Component,ViewChild  } from '@angular/core';
	...
@Component({
  selector: 'SourcePage',
  host: {'(window:keydown)': 'hotkeys($event)'},
	...


  hotkeys(event){
    if (event.keyCode == 13){  //ENTER
      console.log("ENTER pressed");
    }
  }
	
{% endhighlight %}
代码应当没有啥好解释的吧，用起来也不错，效率高，还省了额外的附加包。



