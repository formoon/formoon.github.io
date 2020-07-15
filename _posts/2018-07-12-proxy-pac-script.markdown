---
layout:         page
title:          代理自动配置文件PAC的使用方法
subtitle:      	编写PAC脚本
card-image:		http://115.182.41.123/files/201807/proxy.jpg
date:           2018-07-12
tags:           javascript
post-card-type: image
---
![](http://115.182.41.123/files/201807/proxy.jpg)
我通常上网使用两个浏览器，safari用于一般上网；Chrome安装SwitchyOmega插件，在不同的代理中切换，来保证某些网站的上网速度。  
但是这种方式到了手机上就有点懵，几乎所有的iPhone浏览器都不支持代理的自动切换和设置，所以只能选一个相对兼容性比较好的网络方式一直用下去。很不爽利。。。  
后来发现代理自动配置文件PAC是个好东西，跟SwitchyOmega类似，能够比较智能的切换所需，所以给大家推荐一下。  

通常设备上网的设置，都有3个选项，1是直接连接，不使用代理；2是自行设置http代理；3是使用代理自动配置文件URL。  
这个URL指向的就需要是一个PAC文件。如果在电脑上，可以是file:///这种形式指向本地的文件。如果是手机上，则只能放到一个可以http访问的服务器上。  
PAC文件本质是js的一个子集，其中必须实现一个函数：
```js
function FindProxyForURL(url, host)
```
两个参数，url是将要访问的网络地址，host是从url中分离出来的主机名。  
每次浏览器访问任何一个网址的时候，都会调用这个脚本，根据脚本的返回值，选择浏览器使用哪个代理来访问互联网。  
FindProxyForURL函数返回的访问方式，可以支持三种：  
```js
DIRECT
	直接访问，不适用任何代理
PROXY host:port
	设置http代理，host是代理主机，port是代理端口
SOCKS host:port
	使用SOCKS代理模式，后面是主机及端口号
```
这三种方式，前两种是所有浏览器都支持的。第三种SOCKS，有的浏览器会解释为SOCKS5，有的浏览器会解释为SOCKS4，还有的浏览器还另外提供了SOCKS5方式。在mac Safari浏览器上及iPhone中是将SOCKS解释为SOCKS5协议。  

对于PAC所使用的js语言的语法，不同浏览器的支持也不一样。IE支持完整的js语法，甚至alert命令弹出窗口都支持。Safari则严格遵循PAC的规范，仅支持简单局部变量的赋值和if语句及return语句。  
所以通常安全起见，如果你的PAC文件会用在很多场合，最好考虑兼容性然后再编写。  
PAC所支持的函数并非通常浏览器中的函数，详细内容可以参考这个[网址](http://findproxyforurl.com/pac-functions/)。

具体PAC脚本的编写方法我们参考完成的脚本来解释：  
```js
function FindProxyForURL(url, host)
{
    url  = url.toLowerCase();
    host = host.toLowerCase();

    if (shExpMatch(url,"*twitter*")  ||
        shExpMatch(url,"*facebook*") ||
        shExpMatch(url,"*fb*") ||
        shExpMatch(url,"*messenger*")) {
	        return "PROXY 192.168.1.1:8080; DIRECT";
		};
	
    if (shExpMatch(url,"*youtube*") ||
        shExpMatch(url,"*google*")){
	        return "PROXY 192.168.1.2:8080; DIRECT";
		};
		
    if (shExpMatch(url,"*wikipedia*") ||
        shExpMatch(url,"*blogspot*") ||
       ){
        return "PROXY 192.168.1.3:8080; DIRECT";
    }
    return "DIRECT";
}
```

shExpMatch是PAC专用的函数之一，判断url中是否包含某个网址，"*"是通配符的意思，表示url两端可以有任意字符，只要中间部位匹配成功即可。3组条件各自返回一个代理，都不能匹配，使用DIRECT直连。  
`PROXY 192.168.1.1:8080; DIRECT`是用分号隔开的两个代理模式，如果前面的代理协议本浏览器不支持的话，使用后面的协议。  
所以类似SOCKS的协议，可以写成：  
```bash
SOCKS5 192.168.1.1:8081; SOCKS 192.168.1.1:8082; DIRECT
```
这表示如果浏览器支持SOCKS5命令，则使用第一个协议；如果不支持SOCKS5命令，使用第二个SOCKS协议，实际在iPhone这就代表SOCKS5；前面两个都不支持，则DIRECT。  
PAC中支持的函数有好几个，另外两个可能常用到的是：isInNet和dnsResolve，来看一个例子：  
```js
	if (isInNet(dnsResolve(host), "192.168.0.0", "255.255.0.0") ||
        isInNet(dnsResolve(host), "127.0.0.0", "255.255.255.0"))){
			return "DIRECT"
		}
```
刚才说过了，host是自url中分离出来的主机网址，首先使用dns解析为IP地址，然后判断是否属于给定的网段。如果是，则返回直连，表示这个网段不通过代理来访问。  
上面举例的PAC完整文件的例子，是我使用的PAC文件，其中使用了相反的逻辑。是某几个网站则使用相应代理，否则全部直连。所以没有使用isInNet和dnsResolve函数。但很多人习惯的时候还是会用到。  

使用这种方式后，在iPhone可以愉快的上网，当然仍然有些情况没办法解决。比如facebook app，并没有使用http/https类的协议，而是直接使用tcp/ssl的链接获取数据。这种情况下设置代理和使用PAC都是无效的，目前没有什么好办法。着急的时候可以使用手机浏览器访问https://m.facebook.com来对付对付，体验方面，肯定差多了。  

参考资料：  
<https://zhiwei.li/text/2015/08/16/用代理自动配置文件pac给iphone和ipad设备添加socks代理/>


