---
layout:         page
title:          Rocket框架多文件上传
subtitle:       rocket_upload crate使用
card-image:		http://115.182.41.123/files/201912/wood-crate.jpg
date:           2019-12-04
tags:           html
post-card-type: image
---
![](http://115.182.41.123/files/201912/wood-crate.jpg)  
不知道你的体会是什么，我从C切换到Rust以来，最大的感受并不是语法方面的---那些方面已经有足够多人抱怨而又享受着了。我最大的感受是终于把Web编程工具，同系统编程工具统一了起来。  
C/C++其实也有很多不错的Web编程框架，只是依然总感觉味道不对。所以平常Node.Js / Golang /Python都会穿插在工作中。无论是开发效率，还是维护的方便程度，C/C++在Web开发方面还是弱项。  

Rust让这种情况彻底改观。Rust本身在系统开发方面就有不错的表现，社区中又出现了不少优秀的开源框架提供Web编程支持。  
这其中老牌的Actix和新秀Rocket是用的比较多的两个。个人其实用Actix多一些，毕竟出来时间长，性能评测得分又比较高，社区还有比较好的支持。比如解决MultiPart FormData上传已经有了好用的工具箱awmp。  
但作为万年不变的乙方代表，很多时候对于开发环境的选择还是做不到完全自主。Rocket也是不时的会用一下，Rocket易用性更好，上手容易。对于文件上传，工具本身也提供了一些粗糙的支持，但跟awmp比还是差了很多。  

在对网上各种资源仔细搜索寻找之后，决定还是自己来写一个，这就是今天的rocket_upload。  

工具背后做了很多事情来解析MultiPart FormData, 但用起来还是非常容易。  
要做的事情只有三个，首先，在Cargo.toml文件中加入rocket-upload依赖：  
```rust
rocket_upload = "*"
```
第二，是在程序一开始对rocket_upload做引用：  
```rust
use rocket_upload::MultipartDatas;
```
最后，则是在请求处理函数中使用了，来看代码：  
```rust
#[post("/upload/<userid>", data = "<data>")]
fn upload(userid: String, content_type: &ContentType, data: MultipartDatas) -> Html<String>
{
  // 获取在路径中嵌入的用户参数，只是演示同原有系统之间的兼容性，无实际意义
  let mut result=format!("UserID:{}<br>",userid);
  // content_type在这里并没有使用，所以实际可以在函数声明中取消这个变量，但如果想了解MultiPart的更多信息，还是可以用
  result = format!("{}{:?}<br>",result,content_type);
  // 获取用户网页表单中其它的字段值
  for t in data.texts {
    result = format!("{}FieldName:{} --- FieldValue:{}<br>",result,t.key,t.value);
  }
  // 获取用户表单中上传的文件，支持多个文件的上传
  for f in data.files {
    result = format!("{}FieldName:{} --- FileName:{} --- StoragePath:{}<br>",
      result,f.name,f.filename,f.path);
    // 文件在rocket-upload处理后，会保存在/tmp目录，下面的命令把文件拷贝到自己定义的上传文件夹
    f.persist(Path::new("upload"));
  }
  // 在反馈的网页中显示所有获取到的数据信息
  Html(format!("<html><head></head><body>upload coming...<br>{}</body></html>",result))
}
```
就我当前找遍全网的经历来看，这算最简单的MultiPart处理工具了吧。  
对应的，把网页表单的代码也贴出来对比来看一下：  
```html
<html>
    <head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta http-equiv="content-type" content="text/html;charset=utf-8">
    <meta content="always" name="referrer">
<title>upload</title>
<body link="#0000cc" style="">
        <form id="data" enctype="multipart/form-data" method="post" action="/upload/334445566">
            <div class="row">
              name:<input type="text" name="name"><br/>
              information:<input type="text" name="info"><br/>
              Select files wanna upload , and click at "UPLOAD" button.<br /><br/>
                <input type="file" name="files" multiple>
            </div>
            <div class="row">
                    <button type="submit" value="UPLOAD">UPLOAD</button>
            </div>
        </form>
</body>
</html>
```
简单来说，在请求处理函数中，原有Restful风格，在URL中嵌入的变量，仍然采用Rocket原有的方式来声明和处理。  
随后是MultipartDatas类型的变量，在本例中是`data`。  
变量结构类型分为两个部分，成员`texts`中包含表单中除上传文件之外的字段，字段名称保存在key成员变量中，值保存在value成员变量中。  
`files`则包含表单中上传的文件，如果只有一个文件上传，那就是files[0]。表单字段名称保存在name成员，单独的文件名，也就是来自于MultiPart数据中的，保存在成员filename，缓存文件的完整路径保存在path成员。  
因为缓存的文件在请求处理函数完成后就超出了作用域，从而被自动删除。所以如果想把文件长久保存下来，可以自己建立一个文件夹比如upload，然后使用`f.persist(Path::new("upload"));`把文件拷贝过去。  
这是使用拷贝而不是移动，是因为在很多系统中，`/tmp`文件夹往往是内存卷，跟硬盘并不是同一个存储设备，直接移动的话，在某些系统中可能会报错，也无法真正将文件保存起来。  

源码仓库地址：<https://github.com/formoon/rocket-upload>  

本工具编写的时候，参考了原有的一个rocket扩展：<https://crates.io/crates/rocket-multipart-form-data>  

