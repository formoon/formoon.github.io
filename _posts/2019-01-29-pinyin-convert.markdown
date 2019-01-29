---
layout:         page
title:          拼音转换小工具
subtitle:       给教拼音的语文老师
card-image:		https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2237095752,3252876322&fm=26&gp=0.jpg
date:           2019-01-29
tags:           html
post-card-type: image
---
<script src="https://cdn.jsdelivr.net/npm/vue"></script>
![](https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2237095752,3252876322&fm=26&gp=0.jpg)  
试过的人都知道，电脑输入拼音很麻烦，特别是再加上音调。  
网上搜一搜，帮助输入拼音工具很多，最简单的是直接汉字查拼音，可惜多音字或者断句容易有歧义的情况下，电脑的人工智能往往会给出错误的答案。  
这个小工具没有那么高的智能，仍然要求输入拼音的英文简写，但不会出现上面说的错误。对输入效率也有明显提升。  

使用方法：  
1. 直接使用英文字母来表示拼音。  
2. 如果想输入“ü”，使用字母“v”。  
3. 一个汉字的完整拼音结束后，紧跟1个数字来表示读音，数字跟前面的字母之间没有空格。  
4. 数字1、2、3、4分别表示一至四声，5表示轻声。  

<hr> 

输入拼音+数字的简写:   
<textarea id='ins' rows="10" cols="50" placeholder="zhe4 shi4 yi1 duan4 pin1 yin1">
</textarea>
拼音结果：  
<textarea id='ous' rows="10" cols="50" placeholder="zhè shì yī duàn pīn yīn">
</textarea>
<button onclick="trans()">转换</button>

<script>
    function trans(){
        if ($('#ins').val().length == 0){
            alert("请输入拼音简写！");
            return;
        }
        url='http://47.107.113.23:1080/pinyin/'+encodeURI($('#ins').val())+'/';
		$.get(url,function(data,status){
			//console.log(data);
            $('#ous').val(JSON.parse(data).rs);
		});

		return false;
    }
</script>
