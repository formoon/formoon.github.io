---
layout:         page
title:          不使用插件建立jekyll网站sitemap
subtitle:       解决一件事情，总是有很多方法可选
card-image:     http://www.yixieshi.com/uploads/allimg/140414/095559CA-0.jpg
date:           2017-12-29
tags:           jekyll
post-card-type: image
---
![](http://www.yixieshi.com/uploads/allimg/140414/095559CA-0.jpg)

作为一个网站，加强搜索引擎的优化，俗称SEO优化总是很重要的事情。而重要手段之一就是建立自己网站的sitemap.xml。  
原本jekyll有一个插件：jekyll-sitemap,但到了jekyll3.5版本以后，居然取消了，我还曾经奇怪为什么。直到后来发现，的确这个插件也没有什么太大的必要。  
其实建立自己的sitemap.xml非常容易，不过就是在根目录增加一个sitemap.xml文件，其中使用liquid脚本语言把自己网站所有链接遍历一下成为xml文件即可，这里转载了别人的一个代码：  
```xml
---
layout: null
sitemap:
  exclude: 'yes'
---
{% raw %}
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  {% for post in site.posts %}
    {% unless post.published == false %}
    <url>
      <loc>{{ site.url }}{{ post.url }}</loc>
      {% if post.sitemap.lastmod %}
        <lastmod>{{ post.sitemap.lastmod | date: "%Y-%m-%d" }}</lastmod>
      {% elsif post.date %}
        <lastmod>{{ post.date | date_to_xmlschema }}</lastmod>
      {% else %}
        <lastmod>{{ site.time | date_to_xmlschema }}</lastmod>
      {% endif %}
      {% if post.sitemap.changefreq %}
        <changefreq>{{ post.sitemap.changefreq }}</changefreq>
      {% else %}
        <changefreq>monthly</changefreq>
      {% endif %}
      {% if post.sitemap.priority %}
        <priority>{{ post.sitemap.priority }}</priority>
      {% else %}
        <priority>0.5</priority>
      {% endif %}
    </url>
    {% endunless %}
  {% endfor %}
  {% for page in site.pages %}
    {% unless page.sitemap.exclude == "yes" %}
    <url>
      <loc>{{ site.url }}{{ page.url | remove: "index.html" }}</loc>
      {% if page.sitemap.lastmod %}
        <lastmod>{{ page.sitemap.lastmod | date: "%Y-%m-%d" }}</lastmod>
      {% elsif page.date %}
        <lastmod>{{ page.date | date_to_xmlschema }}</lastmod>
      {% else %}
        <lastmod>{{ site.time | date_to_xmlschema }}</lastmod>
      {% endif %}
      {% if page.sitemap.changefreq %}
        <changefreq>{{ page.sitemap.changefreq }}</changefreq>
      {% else %}
        <changefreq>monthly</changefreq>
      {% endif %}
      {% if page.sitemap.priority %}
        <priority>{{ page.sitemap.priority }}</priority>
      {% else %}
        <priority>0.3</priority>
      {% endif %}
    </url>
    {% endunless %}
  {% endfor %}
</urlset>
{% endraw %}
```
同时为了预定义一些参数，在_config.yml中再增加下面这样一节：
```yml
sitemap:
  lastmod: 2017-12-31
  priority: 0.7
  changefreq: 'weekly'
  exclude: 'yes'
```
其实这些参数，写到上面脚本中也是一样的，这样还是更规范一些吧。  
因为修改了_config.yml,所以本地的jekyll server要重启动一下，然后你就会看到在_site文件夹中生成的sitemap.xml。  
参考链接：  
<http://www.uberobert.com/generate-a-jekyll-sitemap/>
<https://stackoverflow.com/questions/13544241/generate-sitemap-in-jekyll-without-plugin>


