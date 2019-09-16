---
layout:         page
title:          cURL无法访问TLS网站故障解决
subtitle:       手工重新编译openssl和cURL
card-image:		https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1183492921,3025675101&fm=15&gp=0.jpg
date:           2019-09-16
tags:           html
post-card-type: image
---
![](https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=1183492921,3025675101&fm=15&gp=0.jpg)  
大多数人都厌烦使用老旧的系统，无论软件还是硬件。但有的时候又不得不困守其中，坚持延续着系统的寿命，或者还需要点几柱香，祈求神佛的护佑。  
Linux是一个模块化极好的操作系统，得益于此，当其中有组件落伍之时，大多数情况下，还能通过下载源码，手工编译来升级组件，从而保证系统的可用性。  
在这个过程中，cURL工具是必不可少的，特别很多常用的开发平台，都使用了libcurl库作为下载的基础工具。比如PHP/PYTHON/RUST/NPM等。当cURL出现故障的时候，直接就导致很多开发工具的升级或者安装依赖包无法继续。  

今天碰到一个故障，一台有些年头的服务器在升级一个安全组件的时候报了一个错误：
```
cURL error 35: error:14077410:SSL routines:SSL23_GET_SERVER_HELLO:sslv3 alert handshake failure
```
字面意思上看，是ssl3在握手的时候出现了错误。  
但实际上，如果换用一台正常的设备访问同样的网站，再加上-v参数，能看到网站实际是用了TLS的加密方式：
```bash
$ curl -v https://sh.rustup.rs
* Rebuilt URL to: https://sh.rustup.rs/
*   Trying 13.225.103.123...
* TCP_NODELAY set
* Connected to sh.rustup.rs (13.225.103.123) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
* Cipher selection: ALL:!EXPORT:!EXPORT40:!EXPORT56:!aNULL:!LOW:!RC4:@STRENGTH
* successfully set certificate verify locations:
*   CAfile: /etc/ssl/cert.pem
  CApath: none
* TLSv1.2 (OUT), TLS handshake, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Server hello (2):
* TLSv1.2 (IN), TLS handshake, Certificate (11):
* TLSv1.2 (IN), TLS handshake, Server key exchange (12):
* TLSv1.2 (IN), TLS handshake, Server finished (14):
* TLSv1.2 (OUT), TLS handshake, Client key exchange (16):
* TLSv1.2 (OUT), TLS change cipher, Client hello (1):
* TLSv1.2 (OUT), TLS handshake, Finished (20):
* TLSv1.2 (IN), TLS change cipher, Client hello (1):
* TLSv1.2 (IN), TLS handshake, Finished (20):
* SSL connection using TLSv1.2 / ECDHE-RSA-AES128-GCM-SHA256
    ...(略)
```
cURL在https的处理方面，主要依赖openssl的处理，所以实际上单纯重新编译cURL是不起作用的，必须把openssl也下载新版本重新编译。  

首先在目标服务器上卸载掉原有的curl和openssl，并且安装基本的编译系统:  
```bash
$ sudo apt-get purge curl libcurl3 libcurl3-gnutls libcurl4-openssl-dev openssl libssl-dev
$ sudo apt-get autoremove -y

$ sudo apt-get install build-essential libtool make
```  
libtool make 正常情况下其实已经包含在build-essential，但仍然有个别发行版本需要单独安装，不过不用担心，已经安装过的组件反正是会自动跳过的，耽误不了什么时间。  
在这个过程中应当庆幸apt工具并没有依赖cURL，不然那才是一场灾难 :)  
不过接下来就只能换到一台正常的电脑上工作了，因为openssl和cURL源码的下载必须通过可用的下载工具，而通常如果openssl的版本过低，即便不用cURL，常用的wget一般也是无法工作的。  
在openssl源码的选择上是个小坑。如果是一台新的服务器，当然会希望使用最新的版本，很少会有什么兼容性问题。  
但在一台老的服务器上，操作系统版本也比较低，使用最新的版本就不一定好了。经常会碰到各种各样的问题。这个过程很可能需要自己来尝试，找一个尽量新，但运行没有问题的版本。  
当前在openssl官网提供下载的有三个稳定版本：1.0.2t/1.1.0l/1.1.1d，三个版本都已经支持tls，我经过测试选择了1.1.0l，在这台服务器能正常工作。  
下载的源码文件可以通过scp的方式拷贝到目标服务器：  
```bash
$ scp openssl-1.1.0l.tar.gz master@211.100.34.33:~/
```
随后登陆到目标服务器上：  
```bash
$ tar xvf openssl-1.1.0l.tar.gz
$ cd openssl-1.1.0l
$ ./config
$ make
$ sudo make install
$ sudo echo "/usr/local/ssl/lib" >> /etc/ld.so.conf
```
安装之后的测试可以通过openssl内置的s_client:  
```bash
$ openssl s_client -tls1_2 -connect  sh.rustup.rs:443
CONNECTED(00000005)
depth=2 C = US, O = Amazon, CN = Amazon Root CA 1
verify return:1
depth=1 C = US, O = Amazon, OU = Server CA 1B, CN = Amazon
verify return:1
depth=0 CN = sh.rustup.rs
verify return:1
---
Certificate chain
 0 s:CN = sh.rustup.rs
   i:C = US, O = Amazon, OU = Server CA 1B, CN = Amazon
 1 s:C = US, O = Amazon, OU = Server CA 1B, CN = Amazon
   i:C = US, O = Amazon, CN = Amazon Root CA 1
 2 s:C = US, O = Amazon, CN = Amazon Root CA 1
   i:C = US, ST = Arizona, L = Scottsdale, O = "Starfield Technologies, Inc.", CN = Starfield Services Root Certificate Authority - G2
 3 s:C = US, ST = Arizona, L = Scottsdale, O = "Starfield Technologies, Inc.", CN = Starfield Services Root Certificate Authority - G2
   i:C = US, O = "Starfield Technologies, Inc.", OU = Starfield Class 2 Certification Authority
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFYDCCBEigAwIBAgIQCYiHqMAcId0Jd6fEfXdC8jANBgkqhkiG9w0BAQsFADBG
MQswCQYDVQQGEwJVUzEPMA0GA1UEChMGQW1hem9uMRUwEwYDVQQLEwxTZXJ2ZXIg
Q0EgMUIxDzANBgNVBAMTBkFtYXpvbjAeFw0xOTA1MjkwMDAwMDBaFw0yMDA2Mjkx
MjAwMDBaMBcxFTATBgNVBAMTDHNoLnJ1c3R1cC5yczCCASIwDQYJKoZIhvcNAQEB
BQADggEPADCCAQoCggEBAN7D4NF6MP8rKvehZtNeSH19cqW5DFD+o8S3rywcyWvo
jkDrdbgxrVhCBf6DY9IlVantRrSJr3N+vmd64y13riRhZC/Q4dqL7S6lyqEtOoj+
   ...(略)
```
能拿到服务器发出的公钥表示编译的openssl版本可以正常的工作和支持tls加密。  
然后可以继续下面编译cURL，否则编译完白费时间，仍然不能用。  

cURL通常使用最新版就可以，极少碰到不兼容的情况。仍然在工作电脑下载，完成后scp拷贝到目标服务器，过程略。  
然后登录到目标服务器上：  
```bash
$ tar xvf curl-7.66.0.tar.gz
$ cd curl-7.66.0
# 下面一行显示的指名了ssl安装的路径，采用默认编译的话，openssl1.1.0l是安装在这个目录
# openssl1.1.1d是安装在/usr/local，请根据自己的版本确认一下安装路径
# 如果确认当前只有安装的这一个版本openssl,只需要--with-ssl参数，不附加目录参数也是可以的
# 但通常系统中因为其它依赖openssl的软件存在，经常有其他版本的libssl,没有被彻底删除，
# 这时候必须制定一个准确路径
$ ./configure --with-ssl=/usr/local/ssl
$ make
$ sudo make install
```  
此时的cURL已经支持TLS加密的服务器了，但使用仍会报错：  
```bash
curl: (60) SSL certificate problem: unable to get local issuer certificate
```  
这是因为没有安装ssl加密的根证书。  
根证书可以在`https://curl.haxx.se/ca/cacert.pem`下载，建议仍在工作机下载，之后拷贝到目标服务器。  
根证书放到openssl的配置目录，一般是：`/usr/local/ssl/certs/`或者`/etc/ssl/certs/`。  

之后可以正常使用了。  



