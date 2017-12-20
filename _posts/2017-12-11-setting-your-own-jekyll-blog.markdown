---
layout:         page
title:          使用Jekyll和github搭建自己的个人博客
subtitle:       不断更新的Jekyll入门帖
card-image:     http://n.sinaimg.cn/news/1_img/upload/cf3881ab/w1200h674/20171208/1Lw0-fypnsip0186049.jpg
date:           2017-12-11
tags:           jekyll
post-card-type: image
---
![](http://n.sinaimg.cn/news/1_img/upload/cf3881ab/w1200h674/20171208/1Lw0-fypnsip0186049.jpg)
(图文无关)

如你所见，终于用Jekyll在github搭建了自己一个新的栖身空间。独乐乐不如众乐乐，这里把相关的环节、技术、注意事项等做一个总结，希望能帮助更多人顺利上手。  
#### 相关资源
首先是几个推荐链接：  
[jekyll中文官方网站](https://www.jekyll.com.cn)，官方网站的介绍还是最全面也是最权威的，无论如何，你都应当在这里花费你最多的时间。当然，官方的介绍比较系统，但可能还是太细致了，如果你耐心不够，也可以从下面一些文章入手：  
[《搭建一个免费的，无限流量的Blog----github Pages和Jekyll入门》](http://www.ruanyifeng.com/blog/2012/08/blogging_with_jekyll.html),这个入门简单清晰，屏蔽了很多暂时用不到的复杂概念，从这里开始入手应当非常轻松。注意一点，虽然这个博文很简单，但只建议你多读几遍掌握基本概念，先不建议你入手，因为直接从这里开始建立你的个人博客有很多东西将来你必定要修改，会多费很多力气。  
[《在Github上搭建Jekyll博客和创建主题》](http://yansu.org/2014/02/12/how-to-deploy-a-blog-on-github-by-jekyll.html)，这一篇更贴紧最终实用，忍不住的话，边看边动手尝试尝试是可以的。  
[jekyll模板站](http://jekyllthemes.org),实际上除非你是设计师，大多数人在阅读、掌握了基本的概念之后，都应当从挑选一套自己喜欢的模板入手才是最靠谱的，除了在搜索引擎寻找，这个模板站包含了很多不错的设计作品。

#### 概念解释
实际上对于一个有经验的技术人员，看上面的资料足够你入门了，不断的自己重复造轮子是我等不齿的事情，所以下面，只是根据我在建站过程中碰到的问题进行一下补充说明，因为这些点散布在建站的过程中，并不连贯，所以我也就流水账一样的写在这里以供查询，并且根据使用过程中碰到的情况不断更新，也欢迎你补充进来自己碰到的问题。  
首先解释jekyll/Liquid/gem/github/markdown都是什么意思，之间是什么关系？  
* jekyll是一套软件包或者说是一种软件技术，用于将一组文本文件转化围由静态页面组成的小型网站及博客。这些文本可以是Markdown语言、HTML静态页面及配套的CSS样式表文件。jekyll使用ruby语言编写，所以运行jekyll需要有ruby开发环境。
* 实际上使用HTML和CSS本身我们就可以建立一个静态页面组成的网站或者博客，为什么还要使用jekyll呢？因为维护一个网站要做很多工作，比如你新增加了一篇博文，除了这篇博文之外，你的首页可能要修改以增加这篇博文；你的栏目首页可能要修改同样增加这篇博文和；上一页、下一页可能要做出对应的修改；还有很多其它类似的枯燥问题，这些功能通常在一个网站系统中我们使用CMS系统来解决的，但是CMS太复杂繁重了。在一个只是想写一写博客的轻量用户、小型的文本系统中，jekyll是一个容易上手的技术，通过Liquid模板语言在文本中加入简单的标记，从而自动化的将文本形成静态网页。如果不仅仅想写一些博文，还希望能为自己的博客增加更多复杂的功能或者自己出品一些jekyll模板，建议你更多的熟悉[Liquid模板语言](https://github.com/shopify/liquid/wiki/liquid-for-designers)。  
* 刚才提到了jekyll是用ruby语言编写的，作为不断更新的博客，尽管我们只是jekyll的用户，但是实际上我们是工作在ruby开发模式的，因为我们会不断的增加新页面。所以上面说了需要ruby开发环境，而不是通常mac os已经具备的ruby运行环境。根据我们所采用的模板不同，或者我们自己使用的jekyll插件不同，我们可能需要为ruby增加不同的模块。而ruby的包管理器就是gem，甚至还需要bundle包管理器。当然如果你完全使用了静态页面，自己全手工操作已经打造了一个静态页面组成的网站，不需要jekyll帮忙把文本翻译成静态网页，那不安装jekyll系统也是可以的，只不过这种情况可能太少见了。  
* 有了网页，传统上我们需要有一块网络空间来保存自己的网页，以供所有人访问浏览。在这里我们的托管方就是github, github大名鼎鼎，我想我就不用多解释了吧。大多数人只熟悉github的代码托管功能，实际上在个人网站托管的方面也有很多优势，比如有1G免费的空间，每个月100G的免费流量等等，实在是良心商家。几个值得你了解的内容：[GitHub Pages项目官方网站](https://pages.github.com),[GitHub Pages使用限制](https://help.github.com/articles/what-is-github-pages/)。挺不好意思，都是英文的，可能有中文翻译我没费心思去找，我想说的是，如果真的想在这一行混，学好英语是必须的，别听那些什么人工智能让翻译失业的说法。---扯远了，再补充一句，GitHub Pages已经内置了jekyll来把你上传的文本翻译成html静态网页系统，所以技术上说，你本地不安装jekyll也是完全可能的，只是不能实时边修改边看到最终效果实在是太不方便了。  
* Markdown跟HTML一样是一种文本标记语言，可以参考一下[Markdown的百度百科](https://baike.baidu.com/item/markdown/3245829?fr=aladdin)，特点是非常轻量，即便不经过渲染只看文本文件，也能看出来大体的效果，对于一个普通用户来讲，一遍写作，一边顺手给文本加上Markdown标记非常轻松自然。随后有很多工具，包括jekyll可以将Markdown文本翻译成HTML页面从而实现格式化的效果。在搜索引擎搜索Markdown可以得到很多入门文章，基本上10分钟可以上手，1天可以精通。  

#### 入门流程
虽然上面那么多文章都写了建站指导，这里仍然再总结一遍在Mac上建站的一般流程：  
* 如果已经有了github账号，跳过这步，否则使用浏览器，访问[github](https://github.com),注册(sign up)你的github账号。
* 注册成功后，登陆(sign in)进入github,点击右上角+加号，建立你的第一个代码仓库(repository),特别注意，仓库的名字必须是username.github.io，这里的username是你注册的github用户名。这样将来你提交的页面，自动可以使用https://username.github.io这样的形式来访问，否则只能使用http://username.github.io/REPONAME这样的形式才能访问你的网站。  
* 默认情况下，mac电脑的ruby/gem都是安装好的，如果使用windows或者Linux电脑，请仔细搜索相关文章，安装相应软件。
* 因为国内访问限制问题，修改gem的源地址为：https://gems.ruby-china.org ，方法：  
```bash
gem source -l    #看看当前有哪些源，如果不是gems.ruby-china.org建议删除
gem sources --remove https://ruby.taobao.org/	#删除一个当前源，一定要全部删除
gem sources --add https://gems.ruby-china.org/  #增加我们需要的gems源
sudo gem update --system	#刷新gem系统
```
* 安装jekyll系统及相关包管理器
```bash
sudo gem install jekyll bundler
```
这时候实际上可以使用jekyll从头建站了，不过我仍然建议你上网选择一个心仪的模板，然后使用模板开始建立自己的个人博客。
比如你喜欢我当前使用这个模板，则可以：
```bash
git clone https://github.com/formoon/formoon.github.io.git		#将模板克隆到本地
cd formoon.github.io	#进入工作目录
git remote rm origin	#删除原有的远端库依赖
git remote add origin https://github.com/formoon/formoon.github.io.git		#添加自己的库路径，注意一定要换成你自己的地址哈
```
 * 在工作目录使用bundle install 安装本模板Gemfile中指定的依赖库。bundle跟gem一样是一个包管理器，层级要略高一点，相当于gem批处理，会自动下载传递依赖包，比如a依赖b,b依赖c,使用gem安装a,会告诉你需要b包，然后就停止了，而bundle会自动把b也安装上。  
 * 在工作目录执行jekyll serve会自动在4000端口启动一个web服务器，用于预览本地的网站，大多数修改都可以即刻看到结果，个别对_config.yaml等系统文件的修改，可能重新启动jekyll serve。  
 * 好了可以回到建站的正题上了，先在项目根目录建立一个.gitignore文件，其中填入：
```bash
_site/
.DS_Store
```
这里_site目录是jekyll的输出目录，会将你所有的文本文件，渲染成html文件后输出到这个目录，用于你在本地的预览，这个目录github是不需要的，github会重新渲染所有的文件。.DS_Store是mac电脑自动生成的图标缓存文件，也是无需上传到github的，还有什么你不需要上传的文件，都可以填写到.gitignore文件中，来让git跳过管理。  
* 修改_config.yaml文件，这个文件是jekyll的主要设置文件，以及package.json文件，这个是前端设计时候所产生的文件，如果不对前端做改动可以不修改，但习惯上，还是一次修改到位比较好。主要修改的内容是网站名称、作者名字、简介、网站路径、联系方式等基本内容，打开文件按图索骥一般的替换就足矣。
* _posts文件夹中是所有的博文，注意一下命名规则，所有的博文都要严格按照这个规则来命名，建议新手可以把原有的博文移出来暂时保留当做发布博文的模板。现在开始就可以把原有的某一篇改个日期和名字，写上自己喜欢的内容，当做自己的第一篇博文。
* 以我采用的博客模板为例，右上角的PHOTOS是硬链接，可以在_includes/nav.html中修改。不同的模板肯定不一样，根据自己的情况修改。左上角及左下角的图标实际是同一个文件，位于/assets/images/logo.png文件，可以制作一个自己的网站logo来替换。
* CNAME文件，如果你设置dns指向了github pages,要把这个文件的内容写上自己的域名。如果没有设置dns,记着这个文件要置空，来保证username.github.io域名正常工作。
* 好了，作为一个基本框架，现在已经可以正常工作了，建议你使用浏览器访问http://127.0.0.1:4000/，检查检查是否工作正常，如果正常的话，下面把我们的blog部署到github pages:
```bash
git add .
git commit -m "fist blog"
git push
```
这个操作，在每次修改完，本地检查无误后，都要做一遍，用于同步到github pages服务器。其中git命令的操作，如果你不熟悉的话，推荐你尽快阅读[git指南文档](https://git-scm.com/doc)。也可以在搜索引擎寻找大量的入门文档。  
* 提交到github之后，需要过几分钟等github pages渲染完你的页面，就可以使用https://你的用户名.github.io/来访问你的博客了。

#### 语法高亮
首先，当前版本（jekyll 3)的语法高亮在github只支持[rouge](https://github.com/jneen/rouge),所以第一个设置就是要把_config.yaml中的高亮设置调整成：
{% highlight html %}
highlighter: rouge
{% endhighlight %}
随后页面markdown文件中，当然仍然可以使用原来的markdown代码语法  
{% highlight html %}
'''ruby  
  这里是你的源代码  
'''
{% endhighlight %}
但是建议你改成jekyll内置的方式：  
```html
{% raw %}
{% highlight html %}
你的源代码
{% endhighlight %}
{% endraw %}
```
这种形式对于多种语言的支持明显要更好一点。  
最后一点，要使用rouge命令行工具生成一个css文件，并且引用到自己的页面中，生成方法：
{% highlight bash %}
rougify style github > syntax.css
{% endhighlight %}
命令行中的github是指使用github风格的代码高亮，rouge官网的例子是使用一种暗色背景效果更好的：monokai.sublime，用哪中完全是自己的喜好，可以参考rouge官网的文档。  
生成的css文件要引入到自己的页面模板中，高亮效果才能显示出来，每个人用的模板不同，但一般的语法都是： 
{% highlight html %}
	<link rel="stylesheet" type="text/css" href="/assets/css/syntax.css">
{% endhighlight %}


#### 那些爬过的坑
* ruby的坑，事实上几乎建站过程中出现的问题，跟ruby及ruby包管理相关的占到90%。
	* 最常见的一个是比如你安装了某个包的某个新版本，而jekyll需要老的一个版本，这种情况非常多。通常的做法是使用gem uninstall 卸载然后，gem install 使用-v指定安装对应的版本。不过对于一个有大量依赖包的应用，这样的工作非常繁重，这时候可以在工作目录执行：bundle update刷新一次，就可以解决jekyll的版本依赖问题。  
	* 运行jekyll serve的时候，可能会有很多的依赖包警告信息，大多是安装了多个不同版本造成的，可以置之不理，不影响使用。也可以在工作目录使用sudo gem cleanup来清理掉没用的包。  
	* 有的时候按照上面说明安装了jekyll和bundle，但执行jekyll仍然报错找不到这个命令，这时候有可能是因为gem没有给jekyll建立可执行文件的软连接造成的，通常是因为本地安装了ruby的多个版本造成的。熟悉mac的可以自己找一下安装的路径，一般是在/usr/local/lib/ruby/gems/2.3.0/gems/jekyll，然后在可执行目录比如/usr/local/bin中建立软连接。也可以直接使用bundle exec jekyll serve来启动jekyll本地服务器。
	 
* Markdown的坑
	* jekyll内部使用的Markdown渲染器会强制要求Markdown标记同正文之间有一个空格，否则会当做正文一起渲染，比如标题的#标记，*的列表标记，都要跟后面的正文有一个空格，否则在本地的Markdown编辑器中看起来正常，渲染出来的页面则失去了所有的效果。
* site.baseurl变量的使用
	* 一般来说，直接建立了“用户名.github.io”代码库，使用https://用户名.github.io域名访问博客的方式，是不用在_config.yaml中设置baseurl参数的，这个值回默认为空。
	* 如果采用了https://用户名.github.io/blog或类似这样的形式来访问的博客，则需要在_config.yaml中设置baseurl参数，以此为例应当设置为"/blog"。
	* 如果baseurl非空，那页面中所有对本站绝对路径资源的访问，都应当使用类似下面这样的形式，否则都会报404错：  
```jekyll
{% raw %} {{ "/assets/css/main.css" | prepend: site.baseurl }} {% endraw %}
```
	* css文件中不接受Liquid变量，也即{% raw %}`{{varname}}`{% endraw %}这种方式，这时候只能把其中对资源的引用，明文的写成“/blog/assets/...”这样的形式，/blog是你的baseurl。
	* 正文中如果有跟jekyll转义符冲突的地方，可以用jekyll的转义符函数raw即endraw，参考这篇文章：http://xiaohuang.rocks/2016/03/16/b-jekyll/  
* git commit 注意事项
	* 尽量使用git add .之后接着git commit -m,而不是习惯上的git commit -am,因为每次添加博文，实际上增加了一个新文件，而这个文件没有在git stage中，所以git commit -am并不能像我们平常维护代码那样直接提交入库，这种情况下，git add命令实际是不能省略的，直接git commit -am就没意义了。

#### 其它
* jekyll可以接受那些文件？  
当前可以支持HTML文件（后缀html或者htm)以及markdown文件（后缀md或者markdown)。事实上markdown文件中也可以嵌入html代码来表现一些更复杂的效果，比如插入一个表格。比如使用\<br>来代表换行，看起来可能比markdown中最后加两个空格代表换行更直观。

* 不使用jekyll，可以自己做网站吗？  
当然可以，使用一些本地运行的CMS系统，甚至手工，甭管怎么做，只要本地有了一个完整的静态页面系统，都可以使用github pages托管你的个人网站。只是这样就失去了github pages的优势。

	
	
