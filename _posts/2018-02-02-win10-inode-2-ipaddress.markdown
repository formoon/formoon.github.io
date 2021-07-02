---
layout:         page
title:          iNode环境Windows 10配置固定IP地址
subtitle:       在Win10设置DHCP+静态 双IP
card-image:     /attachments/201802/ipv4.jpg
date:           2018-02-02
tags:           win10
post-card-type: image
---
搬家之后，上网有了一个安全认证，使用的是H3C的iNode。  
软件是个好软件，不过功能上做的比较死板。比如说，已经不支持静态IP。  
对于通常的办公室没有问题的，对于研发类的员工就费劲了，每次重启都要修改一堆的设置，来保证多台实验设备之间的互联。  
这事儿也赖MicroSoft，系统设置中本来是支持多个IP地址设定的，但只要使用了DHCP就不再支持多IP的工作方式。  
所以就跟通常一样，Linux/Mac很快的解决了问题，Win10还是在痛苦中挣扎。  
在网上搜索后，有位国外的网友给出了[方案](https://superuser.com/questions/679134/add-a-static-ip-alias-to-a-dhcp-interface-on-windows-8/1250941)，可惜的就是，在单网卡、英文版本windows中运行还不错。在多网卡或者安装有虚机之类的系统中，本身就存在多个虚拟网卡，再加上中文解析的规律性比较差，脚本就无法执行了。  
但是这种思路还是非常有用的，思考半天，不加入第三方软件配合的话，PowerShell的功能还是比通常的bat脚本更强大，顺利的解决问题。  

下面就是我使用的脚本，可以根据自己的工作情况改成自己的：  
```bash
 #首先打开dhcp
$adapter = gwmi win32_networkadapterconfiguration | ? { $_.index -eq 1 }
$adapter.enabledhcp()
 #等待dhcp稍微稳定，至少清楚掉原有的IP
sleep 5
 #循环等待拿到新的地址
do {
	#每次都要刷新重新拿地址
	$adapter = gwmi win32_networkadapterconfiguration | ? { $_.index -eq 1 }
	echo "wait dhcp ready"
	sleep 1
 #等待拿到正确的IP地址才退出循环，不然一直等待，下面的10.98需要改成自己环境的规则
} while  ( $adapter.IPAddress.Substring(0,5) -ne "10.98" ) 
 #显示一下拿到的IP地址和网关
echo "IP:", $adapter.IPAddress 
echo "gateway:",$adapter.DefaultIPGateway

 #使用获取到的地址和网关，当做静态IP设置到网卡，保证iNode监控下正常上网
 #这里使用netsh设置为了更好的兼容性，注意修改网卡名称为自己系统的	
netsh interface ipv4 set address name="以太网" source=static $adapter.IPAddress[0] 255.255.252.0 $adapter.DefaultIPGateway[0]
netsh interface ipv4 set dns name="以太网" source=static addr=10.100.132.16 
netsh interface ipv4 add dns name="以太网" addr=203.196.1.6 index=2
 #设置一个静态IP地址，用于实验集群正常工作，这个地址不需要上外网，没有网关
netsh interface ip add address name="以太网" 192.168.10.100 255.255.255.0
```

每次电脑重启后，启动iNode，用管理员身份运行PowerShell,执行一下脚本，事情就搞定了。  

备注：  
第一次运行PowerShell脚本的时候，可能会报错：  
```bash
无法加载文件 ******.ps1，因为在此系统中禁止执行脚本。有关详细信息，请参阅 "get-help about_signing"。 
```
这时候可以首先在管理员身份下执行：  
```bash
set-ExecutionPolicy RemoteSigned
```
随后出现的提示中，选择Yes或者All,即可。  


