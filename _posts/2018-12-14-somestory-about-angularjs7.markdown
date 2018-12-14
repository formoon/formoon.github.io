---
layout:         page
title:          AngularJS7那些不得不说的事故
subtitle:       说说那些坑
card-image:		https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=4211384246,3722916525&fm=11&gp=0.jpg
date:           2018-12-14
tags:           angular
post-card-type: image
---
![](https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=4211384246,3722916525&fm=11&gp=0.jpg)
#### 题外话
&emsp;&emsp;最近简直要忙死，所以停更了很久，你们会不会以为我人间蒸发了？  
&emsp;&emsp;正文之前，请允许我先跑个题，就是关于忙的问题。  
&emsp;&emsp;做了Freelance，每天过的比上班还累，这完全不是我想要的生活啊？所以痛定思痛，需要检讨一下自己：  
1. 首先仍然是目标，工作需要确定目标，生活也是一样的。如果你的目标是做一番事业，那不得不说，忙才是正常的状态。如果觉得累了，希望生活和工作能有一个平衡，那就要下决心改变自己的状态。  
2. 关于工作，如果目标是挣大钱，而且从时间上更紧迫。那接单的时候，就考虑优先完成利润高的。排序上利润低的需求，还是要勇敢的说“不”。  
3. 如果你的目标是维护朋友、客户的关系，希望将来能有更好的回报。那现在很多不挣钱的项目，做了也就做了，也没有什么好抱怨的。更需要的，是调整自己的心态，接受现状。  

---
#### 前端
​&emsp;&emsp;工作终于告一段落，今天念叨念叨最近一个项目的小体会。  
​&emsp;&emsp;前端的工具链无比繁荣丰富，也带来了大量的选型、学习的问题，这个在网上吐槽已久，我就不画蛇添足了。  
​&emsp;&emsp;我本身过手的项目比较多，所以挺早就做了一些比较，单纯从个人爱好入手（不代表性能、功能、框架结构的优势）做了如下的划分：  

| 业务类型                           | 选型      |      |
| ---------------------------------- | --------- | ---- |
| 功能性项目，更多偏向HTML层的处理   | JQuery.js |      |
| 小型商业逻辑项目                   | vue.js    |      |
| 大型或者将来可能快速成长的商务逻辑 | AngularJS |      |

&emsp;&emsp;最近的项目使用了AngularJS7，中间有了不少新的体会，分享出来希望能对大家有用。
#### AngularJS版本
&emsp;&emsp;通常AngularJS项目的构建、编译、管理等都是由@angular/cli模块完成的。这个模块简便的安装方法是依赖npm, 而@angular/cli本身也依赖网络，因此当AngularJS有了新版本，所有使用客户端ng建立项目，也就自动使用了AngularJS的新版本。更不要说npm的升级中，也会直接升级了@angular/cli本身。  
&emsp;&emsp;好在从AngularJS2之后，框架和语法糖方面的变化并没有多大，如果类似AngularJS1到2那种剧烈的变化，相信很多人会直接哭死吧:)  
&emsp;&emsp;即便如此，在一个复杂的项目中，不可避免仍然还会有不少版本升级带来的兼容性问题。这时候如果是以前建立的项目，使用保留的package.json直接安装依赖包，自动在老版本下工作就好，不一定必须升级到AngularJS新版本，通常这样能省事不少。  
&emsp;&emsp;有的时候会碰到一些意外，就是某些依赖包，可能在npm的库中已经停止维护了，这时候依赖包的安装将无法成功。这在大公司中通常不是问题，大公司大多都使用自己的包镜像服务器，因此这种情况出现的少。但在中、小型公司，这是个很烦心的问题。我建议对于一些复杂的项目，尽可能的保留下来原有的node_modules 文件夹，毕竟跟硬盘容量比起来，这一点空间不算啥了，能让你将来项目的维护轻松许多。  
&emsp;&emsp;此外还可以考虑搜索多家的包服务器镜像，比如我经常同时安装cnpm、npm两套工具，前者使用阿里云的镜像，后者则是官方的服务器，发现某些包失维的时候，换一个源试试，很可能会有惊喜。  
&emsp;&emsp;有的时候还会碰到一些很特别的情况，必须使用老的AngularJS版本进行开发。这时候可以首先卸载当前的新版本@angular/cli, 然后使用npm 安装制定的老版本，比如1.4版本的客户端对应AngularJS4：  

```bash
npm install @angular/cli@1.4
```
&emsp;&emsp;这样之后使用ng新建的项目，将是AngularJS4的版本。当然这在工作中，也会碰到上面说的依赖包失维的问题，建议常用的功能包，平常自己就留意保留一些吧。  
#### 在AngularJS7中使用JQuery.js/Bootstrap等第三方功能库
&emsp;&emsp;这几个包是在使用传统html页面的时候常用的，JQuery.js在很多的框架中已经不建议使用了，而是使用框架的组件或组件通讯类功能来完成相似的功能。Bootstrap则有很多社区提供的AngularJS化的组件库可以直接使用。  
&emsp;&emsp;对于前者，虽然的确感觉上在AngularJS中使用JQuery没有哲学上那么完美，但你不得不说在很多情况下的确用起来更方便，能大量的简化代码。对于后者，我个人的感觉把BootStrap库AngularJS组件化会带来额外的学习成本，感觉并不划算。所以介绍一下此类扩展库的使用方法：  
&emsp;&emsp;首先使用npm安装需要使用的第三方扩展包：  
```bash
npm install jquery bootstrap@3 bootstrap-switch createjs-module --save
```
&emsp;&emsp;随后打开angular.json文件，在projects一节，找到你的项目名称，随后在其options中，scripts参数后面的数组中添加所有需要引用的js库：  
```bash
"scripts": [
    "node_modules/jquery/dist/jquery.min.js",
    "node_modules/bootstrap/dist/js/bootstrap.js",
    "node_modules/bootstrap-switch/dist/js/bootstrap-switch.js"]

```
&emsp;&emsp;需要注意，如果是AngularJS4, 文件名应当是.angular.json，scripts数组中添加的路径，应当是../node_modules/xxxx这样的路径，因为AngularJS7和4的默认路径是不同的。  
&emsp;&emsp;第三步是为bootstrap这样的UI库添加额外的css，这个比较容易。直接在默认的主css文件：src/styles.css增加额外的引用就可以了,比如：  
```bash
@import "~bootstrap/dist/css/bootstrap.css";
@import "~bootstrap-switch/dist/css/bootstrap3/bootstrap-switch.css";
```
&emsp;&emsp;做完第三步，css可以立即生效，js文件则仍然需要在AngularJS主程序中引用，比如：  

```js
...
import * as _ from 'lodash';
import * as $ from 'jquery';
import 'bootstrap-switch';
import * as createjs from 'createjs-module';
...
    $('.url1').attr('href', '/home');

```
&emsp;&emsp;注意这里面的引用并没有指定js的路径，路径实际是由angular.json文件中我们刚才修改的scripts一节决定的。此外就是通常我们使用import都是标准的typescript的形式，比如：  
```js
import { Component, OnInit } from '@angular/core';
```
&emsp;&emsp;而我们对于JQuery.js库的引用，则使用了引用非结构化js的方法，重点是引用“*”也就是所有内容，然后用“as $”命名成平常我们喜欢的样子。对于bootstrap-switch库因为是直接在bootstrap原型上添加功能，所以干脆连“ * as ”也省略了。  
#### 使用自己积累的js库
&emsp;&emsp;在日常的工作中，大多程序员肯定都保存了不少的函数库、功能库。这些库可以直接在typescript中引用，不需要改名字，引用的时候也不需要添加后缀。引用时候的路径，使用当前typescript文件的相对路径就可以。比如：  
```js
import { Lists } from '../jslib/lists';
```
&emsp;&emsp;在使用的时候，跟原来在js中引用也完全一致。通常说，比上面介绍的引用JQuery.js之类的引用会更容易。其实这大多是因为npm所管理的node_modules路径规则太复杂所致，相比较npm模块管理带来的好处，你还是忍受的好:)  
#### 编译中报错的问题
&emsp;&emsp;通常AngularJS的编译都能给出来比较清晰的错误提示，按图索骥，能够比较容易的解决问题。  
&emsp;&emsp;但也有很多时候，AngularJS并不能给出清晰的提示，比如UglifyJS处理中所出现的Unexpected token: punc (() - ES6 parsing errors。  
&emsp;&emsp;这时候可以在编译的时候增加参数：  
```bash
ng build -prod --source-map
```
&emsp;&emsp;此时编译过程中，虽然信息仍然不够完整，但能够比较清楚的界定到时哪一个文件的哪一行出现了问题。相信再找错误，就容易多了。当然既然开发模式编译时通过的，这时候的报错往往也是兼容性问题或者更严格的语法限制。  
#### 编译结果，在老版本ios设备无法使用的问题
&emsp;&emsp;为了支持更多的设备，兼容早期的ios浏览器是很有必要的。但原本运行良好的项目，移植到AngularJS后就无法 在早期ios浏览器中使用了。现象是屏幕全白，没有任何内容和功能。  
​&emsp;&emsp;使用ios的联机功能，可以检查在浏览器中的报错信息。ios联机调试不是今天的重点，这里就跳过了。通常能得到错误信息为：  
```bash
SyntaxError: Use of const in strict mode.
```
&emsp;&emsp;其实主要还是老版本浏览器不能很好支持新的js语法的问题。在AngularJS中呈现出来，是因为AngularJS默认使用typescript编译。而通常的开发工具链是使用babel编译，而后者的编译结果，从向前兼容上，显然做的更好一些。  
&emsp;&emsp;解决办法有很多，网上有很多使用babel替代typescript的方法，但总体都比较麻烦,如果不是特别必要，就别折腾了。  
&emsp;&emsp;或者你还可以把js改写到ts文件，估计你更不愿意了，如果积累的库比较多，真的会累死人:)  
&emsp;&emsp;我的建议是，所有你自己添加的js包，集中存放在同一个目录下，比如我例子中的jslib。然后在另外的工作目录中，安装babel的工作环境：  
```bash
npm install -g babel-cli
npm init
npm install --save-dev babel-preset-es2015
```
&emsp;&emsp;在工作目录中，新建一个.babelrc的文件，内容为：  
```js
{
  "presets": [
    "es2015"
  ],
  "plugins": []
}
```
&emsp;&emsp;随后就可以将原有的js文件都编译一遍了（ts文件typescript处理的挺好，完全不需要使用babel），编译方法示例：  
```bash
babel ../some_dir/jslib -d ../some_angular_dir/jslib
```
&emsp;&emsp;这会编译jslib中的所有文件，文件夹结构也会保留，所以编译完成，直接用生成的jslib替换原来的文件夹。然后再使用AngularJS编译就完全正常了。  
---
#### 最后
&emsp;&emsp;最后决定选择一个更开心的生活，所以给自己放个假。头一次，看着星光下闪烁的大海，听着潮水细微而深邃的波动，感觉微微腥咸的海风轻柔的拂面。然后手指在键盘上跳动，心情也变得轻快了。所谓幸福，不过如此。




