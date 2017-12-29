---
layout:         page
title:          赶个时髦，给自己的博客添加一个微信二维码
subtitle:       JQuery弹出窗口的使用
card-image:     /assets/images/wechatQR.jpg
date:           2017-12-29
tags:           html
post-card-type: image
---
现在用的这个JellyBlog模板在最下面有自己的联系方式，原来是三个：EMail/Github主页/微博，现在微信这么火，计划增加一个微信的联系方式，想到就动手吧。  
微信不像别的社交软件联系方式，直接给出个账号来让用户输入肯定是体验太差，所以比较好的办法，扫码加微信。而二维码小了影响用户拍照扫描，大了，会影响屏幕紧张的空间。所以点击微信图标后，弹出一个对话框，对话框中有大尺寸的微信二维码供用户扫描添加微信。这样的需求顺利成章。  
多说一句，对于很多前端程序员来讲，本篇的功能实在是太简单了，但对于很多服务器端程序员来讲，这也算新鲜的尝试，所以就当写给初学者吧。  
很多屏幕界面库都有弹出窗口的支持，既美观又方便，因此首选是利用现成的资源库。本博客模板因为原设计已经使用了JQuery，所以就沿用JQuery的界面库，不然为了一个简单的功能，增加几百K的界面库，实在是不划算，话说其实JQuery-UI也不算小啊。
首先打开/_includes/head.html添加css:
```html
<link href="//cdn.bootcss.com/jqueryui/1.12.1/jquery-ui.css" rel="stylesheet">
```
接着在_includes/footer.html中，添加微信的图标和链接，其实模板中原来是有微信图标的，只是被屏蔽了：
```html
<a href="" id="wechatDlgLink" ><li class="wechat"></li></a>
```
随后是打开手机微信，给自己生成一个美观的二维码，保存图片，然后把图片传到电脑上。为了美观，还是要动用一下photoshop简单编辑修剪一下，最后放到/assets/images/下面，比如叫wechatQR.jpg。  
最后是打开/_includes/scripts.html,添加脚本引用、弹出窗脚本和弹出窗本身：
```html
<div id="wechatDlg" title="扫码加微信">
  <img src=/assets/images/wechatQR.jpg width=400 height=400></img>
</div>
<!--   Core JS Files   -->
<script src="//cdn.bootcss.com/jquery/2.1.0/jquery.min.js"></script>
<script src="//cdn.bootcss.com/jqueryui/1.12.1/jquery-ui.js"></script>
<script src="//cdn.bootcss.com/mixitup/2.1.11/jquery.mixitup.min.js"></script>
<script src="{{ "/assets/js/main.js" | prepend: site.baseurl }}"></script>
<script>
  $(function() {
    $( "#wechatDlg" ).dialog({
      autoOpen: false,
      show: {
        effect: "blind",
        duration: 100
      },
      hide: {
        effect: "explode",
        duration: 100
      },
	  width:450
    });
 
    $( "#wechatDlgLink" ).click(function() {
      $( "#wechatDlg" ).dialog( "open" );
	  return (false);
    });
  });
</script>
```
为了省事粘贴了整个文件过来，实际添加的就是jquery-ui.js那一行js库引用。最前面`<div>`块中的弹出窗定义。还有最后面`<script>`块中的脚本，脚本很简单，一是定义一个弹出窗，默认状态是关闭的、以及打开和关闭的动画。最后则是把微信图标链接的事件设置为打开对话框。  
记得很早时候写html代码，js脚本跟css都放到整个html文件的前面，现在则更为规范合理，css还是放在前面，保证页面一边下载一遍就可以渲染。而js脚本放到最后，不影响网页主体内容的下载展示。反正跟用户的互动都会是网页彻底打开之后。  
在本地的Jekyll Server检查检查，没问题上传吧。  
![](/assets/images/wechatQR.jpg)

