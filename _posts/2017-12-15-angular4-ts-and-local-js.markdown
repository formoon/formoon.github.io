---
layout:         page
title:          AngularJS2+调用原有的js脚本
subtitle:       AngularJS脚本跟本地原有脚本之间的关系
card-image:     http://115.182.41.123/files/201712/angular.jpeg
date:           2017-12-14
tags:           html
post-card-type: image
---
![](http://115.182.41.123/files/201712/angular.jpeg)
昨天一个话题说关于AngularJS2以后版本的两个小技巧，不料引出了另外一个话题，话题起始很简单：  
“很多的前端框架并不复杂，比如JQuery,引入即用，实时看到效果，多好。到了Angular2一直到现在的版本5，一点改进没有，还要编译，还要部署，原有的JS脚本也不能用了。”  
细想起来，这个话题的帽子并不小，至少牵扯出来一个关键，AngularJS2及以后的版本，其框架之下的JS代码，跟HTML中`<script>`块之中的JS代码，到底是什么关系？  
我试着来回答一下：
* 首先，在AngularJS2框架之中实际使用的是ES6,全称ECMAScript6，是Javascript的下一个版本。官方的例子则是基本采用TS,全称TypeScript,是JS的一个超集。之所以用起来没有明显区别的感觉，因为的确从常用语法上，跟当前使用的JS,或者叫ES5 JS,差别很小，但即便再小，那也算的上不同的语言了。
* 为什么采用新的语言，而不是沿用当前的ES5，官网和社区已经有了很多解释了，新语言当然有新语言的优势，比如定义变量，可以指定类型，而在程序中用错类型，则会在编译过程中就给出警告，不至于等到上线了才发现BUG。这些优势非常多，这里就不画蛇添足了。反正你肯定能理解，新当然有新的好处。
* 既然采用了新的语言，为了跟当前的浏览器系统兼容，当然就有一个翻译过程，准确的说，甭管是TS还是ES6,甚至将来可能的ES7,在当下，都要翻译成ES5,才能在当前流行的浏览器之中运行。这个翻译，行话上讲，也就是“编译”。
* 事实上，编译不仅仅干这么一点事，很多的优化工作、查错工作，也是在这个阶段完成的，比如你使用了没有定义的变量、函数；比如你用错了函数类型；比如你使用了某个函数库但只是用了其中一小部分，那么多没用的部分应当排除掉避免占用宝贵的下载带宽，这些都是在编译过程做到的。
* 好了，既然经过了这么复杂的动作，这个编译也必不可少，那么实际上答案已经出来了：那就是，很多原有理所应当存在的东西，就比如你在HTML中定义的JS对象、变量、函数，那些都是在执行环节，浏览器中才存在的。而在编译阶段，那些东西还只是停留在字符状态，AngularJS当然并不知道他们存在，也就无法直接的、像原来我们使用HTML-JS一样来使用它们了，这就如同上面那张图，看上去海天一色，互相映衬，但在根本上，它们是在两个世界。

上面是从技术实现上的限制原因，实际上还有一个设计哲学逻辑上的原因：
* AngularJS设计之初就不是为了单纯的在桌面浏览器中运行，还希望能够在手机、移动设备甚至其它设备上执行。你可能会说，现在的手机浏览器也很发达啊，至少比很多IE6/IE7之流要强多了，稍等，这里说的移动设备、其它设备，可不一定是指仅仅浏览器，从这种设计逻辑出发，AngularJS成为一种跨平台的开发框架，直接编译成各种系统原生的代码，完全是有可能实现的。试想，在那种情况下，你原来的JS代码很可能是连存在的空间都没有，又如何让AngularJS访问到呢？

————————————————————————————————————————————

那是不是原有的JS代码和技术都要作废掉，无法再使用了呢？  
当然不是，你肯定早看到了，大量的第三方模块和代码库，通过NPM的管理，共存于这个架构中，彼此友好的相处。你原有的工作，完全可以用同样的方式来工作。  
你也可能会说，可我有很多代码没有做到那么好的面向对象化包装，也不想做那么复杂，该怎么办呢？AngularJS也提供了至少3个方法，来完成两个世界的打通工作。  
第一个方法，使用declare来预声明：  
我们来先看一个例子，使用`ng new testExtJS`来新建一个工程，接着`cd testJS`进入项目目录，使用`cnpm install`来初始化依赖包。用cnpm的原因是如果在中国，速度会快很多，这个在上一篇文章也说了。  
接着修改index.html，这里只贴出最后的结果：
{% highlight html %}
<head>
    <meta charset="utf-8">
    <title>TestExtJs</title>
    <base href="/">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/x-icon" href="favicon.ico">
</head>
<body>
<script>
	var webGlObject = (function() {
	    return {
	        init: function() {
	            alert('webGlObject initialized');
	        }
	    }
	})(webGlObject || {})	
</script>
    <app-root>Loading...</app-root>
</body>

</html>
{% endhighlight %}
注意中间的`<script>`块是我们增加的部分，来模拟我们在html本地已经有了一段js代码。  
然后在app.component.ts中增加声明和调用的部分：  
```ts
import { Component } from '@angular/core';

declare var webGlObject: any;

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  title = 'app works!';
  constructor() {
    this.title="constructor works!"
    webGlObject.init();
  }

}
```
注意上面代码中的declare声明，和下面添加的constructor构造函数和其中对js对象的调用。  
declare的意思就是告诉AngularJS，相信我，虽然现在你看不到对象webGlObject，但相信我，或早或晚，反正你一定会看到它的存在的，你正常编译、正常执行就好啦。当然这里的潜台词和副作用就是：诺，AngularJS,这部分代码我负责啦，你不用管它的对错，反正错了我也不会怪你。    
使用这种方法，类似上一篇文章的问题，你也完全可以声明一个window对象，然后直接访问其中的userAgent:  
```ts
	...
declare var window:any;
	...
    console.log(window.navigator.userAgent);
```
问题又来了，既然直接能访问到window对象，那还用什么ng4-device-detector组件，直接从userAgent中判断设备类型不好吗？  
这就牵涉到我上面解释的最后一条，将来这段AngularJS代码，很可能不是运行在一个浏览器，其中可能根本没有window/document对象，那时候，这段代码就出错了。当然你可能会说，不不不，我就是在浏览器运行，不考虑别的。OK,我也不较劲，你当我没说，你完全可以就这么用。  
但是比较规范的办法，应当是把window对象以及你需要的其它类似对象，写成一个服务，然后注入到app.component之中，这样，即便将来运行环境有变化，只修改服务部分代码，你的主程序完全可以不用修改。  
落实到代码，大致是这样，首先把window对象包装成一个服务：  
```ts
import { Injectable } from '@angular/core';

function _window() : any {
   // return the global native browser window object
   return window;
}

@Injectable()
export class WindowRef {
   get nativeWindow() : any {
      return _window();
   }
}
```
注册到provider:
```ts
import { WindowRef } from './WindowRef';

...

@NgModule({
    ...
    providers: [ WindowRef ]
})
export class AppModule{}
```
在需要的组件中，引用这个服务，然后就可以使用了：
```ts
...
import { WindowRef } from './WindowRef';
...
@Component({...})
class MyComponent {
...
    constructor(private winRef: WindowRef) {
        // 得到window对象
        console.log('Native window obj', winRef.nativeWindow);
    }
...
}
```
我得承认，这样是麻烦了不少，不过规范、可复用的代码，本身的确就多了很多限制。  
参考资料：<https://juristr.com/blog/2016/09/ng2-get-window-ref/>

————————————————————————————————————————————

AngularJS也一直在努力，尽力弥合这种鸿沟，其中HostListener和HostBinding就是具体的两个实现，也是我们开始所说的3个方法中的后两个。  
HostListener 是属性装饰器，用来为宿主元素添加事件监听，这个行为表示html端某个元素的事件，产生到达TS脚本的调用动作。比如：
```ts
import { Directive, HostListener } from '@angular/core';

@Directive({
    selector: 'button[counting]'
})
class CountClicks {
    numberOfClicks = 0;

    @HostListener('click', ['$event.target'])
    onClick(btn: HTMLElement) {
        console.log('button', btn, 'number of clicks:', this.numberOfClicks++);
    }
}
```
使用counting装饰的button按钮，每次点击，都会产生一次计数行为，并且打印到控制的日志中去。  
HostBinding 是属性装饰器，用来动态设置宿主元素的属性值，这个跟上面的动作相反，表示首先标记在html某元素的某属性，然后在TS脚本端，对这个属性进行设置、赋值。比如：
```ts
import { Directive, HostBinding, HostListener } from '@angular/core';

@Directive({
    selector: '[exeButtonPress]'
})
export class ExeButtonPress {
    @HostBinding('attr.role') role = 'button';
    @HostBinding('class.pressed') isPressed: boolean;

    @HostListener('mousedown') hasPressed() {
        this.isPressed = true;
    }
    @HostListener('mouseup') hasReleased() {
        this.isPressed = false;
    }
}
```
上面的代码表示，如果某个html元素用exeButtonPress属性修饰之后，会有一个.pressed属性，可以监控到鼠标按下、抬起的事件，这表现了html元素到ts端双向的互动。  
HostListener和HostBinding有一个简写的形式host,如下所示：
```ts
import { Directive, HostListener } from '@angular/core';

@Directive({
    selector: '[exeButtonPress]',
    host: {
      'role': 'button',
      '[class.pressed]': 'isPressed'
    }
})
export class ExeButtonPress {
    isPressed: boolean;

    @HostListener('mousedown') hasPressed() {
        this.isPressed = true;
    }
    @HostListener('mouseup') hasReleased() {
        this.isPressed = false;
    }
}
```
看看，跟上一篇中快捷键绑定的方法很相似了？  
这一部分的代码使用了<https://segmentfault.com/a/1190000008878888>的资料，这篇文章写的很细致，想详细了解的建议及早阅读。


