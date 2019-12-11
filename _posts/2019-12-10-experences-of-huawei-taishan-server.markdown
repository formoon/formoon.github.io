---
layout:         page
title:          华为ARM64服务器上手体验
subtitle:       不吹不黑，用实际应用来看看TaiShan鲲鹏的表现
card-image:		http://files.17study.com.cn/201912/hw/huawei-kunpeng920.jpeg
date:           2019-12-10
tags:           html
post-card-type: image
---
![](http://files.17study.com.cn/201912/hw/huawei-kunpeng920.jpeg)  
#### 背景
中美贸易冲突以来，相信最大的感受，并不是我对你加多少关税，而是我有，可我不卖给你。“禁售”成了市场经济中最大的竞争力。  
相信也是因为这个原因，华为“备胎转正”的鲲鹏系列芯片，一经推出，就吸引了业界的眼球。  
经过漫长的等待，基于鲲鹏920，代表高端计算能力的华为服务器已经开始大量出货。不过，限于专业壁垒，服务器用的芯片，无论如何也比不上5G和MATE30更令人瞩目。  
今天偶然发现，华为云上正在进行“鲲鹏弹性云服务器”免费试用活动，于是迅速的申请了一台尝鲜。  
![](http://files.17study.com.cn/201912/hw/huawei-event.png)  

#### 基本环境
最基本的试用套餐中，包括一台1核、1G内存、1M带宽的弹性服务器；一个100G的云硬盘还有一个动态的公网IP。个人用户可以免费试用15天。  
![](http://files.17study.com.cn/201912/hw/huawei-order.png)  

服务器可选多种操作系统，华为推荐的是自有的欧拉操作系统(EulerOS)。这是华为基于CentOS定制的版本，包含了多种服务器场景的优化，对于ARM64芯片也有更好的支持。其它还有10余种选择，都是Linux类的各种发行版本。  
严重依赖Windows系列的话...你现在可以退散了，除了Windows操作系统当前还绑定在X86系列CPU之上，微软系列也属禁售之列。  
作为试用，首先要“玩”起来方便，我选择了Ubuntu18.04系统。  
![](http://files.17study.com.cn/201912/hw/huawei-panel.png)  

跟常见的云端系统一样，购买完成，服务器会快速的自己完成配置、启动。华为云提供了基于浏览器的终端界面： ![](http://files.17study.com.cn/201912/hw/huawei-console.png)  

一开始只有一个root，利用浏览器的终端，新建一个日常使用的账号，升级各项更新和补丁，重启，然后可以放心安全的在远程使用ssh登陆了。有一个动态公网IP，还是方便很多。  
整个过程流畅、稳定，第一印象跟通常使用的服务器并没有什么不同。如果不使用uname检查内核，完全感觉不到是一台ARM服务器。  
```js
$ uname -a
Linux ecs-kc1-small-1-linux-20191209185931 4.15.0-72-generic #81-Ubuntu SMP Tue Nov 26 12:21:09 UTC 2019 aarch64 aarch64 aarch64 GNU/Linux
```
先来看看配置，CPU:  
```js
$ cat /proc/cpuinfo
processor	: 0
BogoMIPS	: 200.00
Features	: fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm jscvt fcma dcpop asimddp asimdfhm
CPU implementer	: 0x48
CPU architecture: 8
CPU variant	: 0x1
CPU part	: 0xd01
CPU revision	: 0
```
接着是内存：  
```js
$ cat /proc/meminfo
MemTotal:        1006904 kB
MemFree:          387044 kB
MemAvailable:     671300 kB
Buffers:           33604 kB
Cached:           296076 kB
SwapCached:         1148 kB
Active:           217232 kB
Inactive:         275692 kB
Active(anon):      59824 kB
Inactive(anon):   119960 kB
Active(file):     157408 kB
Inactive(file):   155732 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       1762696 kB
SwapFree:        1729472 kB
Dirty:             28632 kB
Writeback:             0 kB
AnonPages:        162892 kB
Mapped:            61680 kB
Shmem:             16508 kB
Slab:              96464 kB
SReclaimable:      60696 kB
SUnreclaim:        35768 kB
KernelStack:        2464 kB
PageTables:         3824 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     2266148 kB
Committed_AS:    1049036 kB
VmallocTotal:   135290290112 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
CmaTotal:              0 kB
CmaFree:               0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
```

虽说只是一个体验，但如果没有对比，我们很难对“体验”结果做出一个公正的评价。  
所以我又在国内三甲的云服务商（这里就不提名字了，反正没有打擂台的意思）另外借用了一台生产用传统Intel至强的服务器。  
同样使用Ubuntu 18:  
```js
$ uname -a
Linux ebs-31389 4.15.0-72-generic #81-Ubuntu SMP Tue Nov 26 12:20:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```
CPU：  
```js
$ cat /proc/cpuinfo 
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 63
model name	: Intel(R) Xeon(R) CPU E5-2678 v3 @ 2.50GHz
stepping	: 2
microcode	: 0x1
cpu MHz		: 2494.224
cache size	: 4096 KB
physical id	: 0
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 13
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm invpcid_single pti fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt arat
bugs		: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds swapgs itlb_multihit
bogomips	: 4988.44
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 6
model		: 63
model name	: Intel(R) Xeon(R) CPU E5-2678 v3 @ 2.50GHz
stepping	: 2
microcode	: 0x1
cpu MHz		: 2494.224
cache size	: 4096 KB
physical id	: 1
siblings	: 1
core id		: 0
cpu cores	: 1
apicid		: 1
initial apicid	: 1
fpu		: yes
fpu_exception	: yes
cpuid level	: 13
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon rep_good nopl cpuid tsc_known_freq pni pclmulqdq ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm invpcid_single pti fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt arat
bugs		: cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds swapgs itlb_multihit
bogomips	: 4988.44
clflush size	: 64
cache_alignment	: 64
address sizes	: 40 bits physical, 48 bits virtual
power management:
```
内存：  
```js
$ cat /proc/meminfo 
MemTotal:        4039500 kB
MemFree:         1083580 kB
MemAvailable:    3561040 kB
Buffers:          206180 kB
Cached:          2326624 kB
SwapCached:          296 kB
Active:          1394884 kB
Inactive:        1213580 kB
Active(anon):      40644 kB
Inactive(anon):    53080 kB
Active(file):    1354240 kB
Inactive(file):  1160500 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       4038652 kB
SwapFree:        4033008 kB
Dirty:                20 kB
Writeback:             0 kB
AnonPages:         75392 kB
Mapped:            88396 kB
Shmem:             18068 kB
Slab:             305188 kB
SReclaimable:     251528 kB
SUnreclaim:        53660 kB
KernelStack:        2704 kB
PageTables:         8312 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     6058400 kB
Committed_AS:     597368 kB
VmallocTotal:   34359738367 kB
VmallocUsed:           0 kB
VmallocChunk:          0 kB
HardwareCorrupted:     0 kB
AnonHugePages:         0 kB
ShmemHugePages:        0 kB
ShmemPmdMapped:        0 kB
CmaTotal:              0 kB
CmaFree:               0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:      106368 kB
DirectMap2M:     4087808 kB
DirectMap1G:     2097152 kB
```
从硬件参数上看，“鲲鹏”很不利啊，可怜的1核1G内存。另一台Intel XEON虽说也不是啥高级货色，但2核4G内存，任谁看起来也是碾压式的对手。如果知道我只能借到这样一台对比的服务器，在华为云就应当开一台配置更高的机器。可惜免费机会仅有一次，也只能硬起头皮继续了。  

|  主机 |  TaiShan | 竞品品牌未知 | 
|-------|----------|------------|  
| CPU  |  鲲鹏920  | Intel Xeon |
| 核心数量 | 1 | 2 |
| 内存 | 1G | 4G |

其它配置就不拉出来看了，因为剩下的硬件对本次对比影响不大；软件配置，都是默认的基础系统，两边都没有做任何专门的设定和调优。如果有区别，那也是云端工作人员水平的发挥，也得算加分项。  

#### 体验内容和环境准备
早先还是很喜欢看跑分，后来时间长了，发现跑分的内容，跟实际工作区别还是比较大。往往跑分的指标很漂亮，真正用起来，满不是那么回事。  
所以今天我们搞的稍微复杂一点，选择从前端开发、后端开发及服务、容器三个方面，对鲲鹏服务器做一个深度体验。我想从云服务的角度上说，这三类应用，怎么也能涵盖80%的常见需求吧。  
（文中沿用口头习惯混用了芯片品牌和服务器品牌，相信你看的懂，就不再改了。）  

首先我们准备相应的工具和环境。  
前端开发选用node.js/npm/yarn工具链，vue框架。两台机器的版本完全相同：  
```js
$ node -v
v12.13.1
$ npm -v
6.12.1
$ yarn -v
1.21.0
```
后端选用PostgreSQL数据库，两端版本相同：  
```js
$ psql --version
psql (PostgreSQL) 10.10 (Ubuntu 10.10-0ubuntu0.18.04.1)
```
后端工具链使用Rust nightly编译，两端相同：  

```js
$ rustc -V
rustc 1.41.0-nightly (59947fcae 2019-12-08)
```
这里补充一句，nightly只适合开发和实验，请勿在生产环境使用。这里考虑既然是体验，当然要有适度的超前，所以选用nightly版本。因为毕竟等到你用的时候，今天的nightly版本估计已经转正了。  
在后端开发的过程中，还会使用到gcc/git/openssl等开源工具链。都使用了Ubuntu内置的版本，两台服务器相同。因为这些工具并非主要开发环境，这里节省篇幅，就不一一列出版本了。  

容器方面，因为更多是兼容性体验，并不需要什么指标数据，所以只安装了鲲鹏服务器，版本如下：  
```js
$ sudo docker version
Client:
 Version:           18.09.7
 API version:       1.39
 Go version:        go1.10.1
 Git commit:        2d0083d
 Built:             Fri Aug 16 14:20:24 2019
 OS/Arch:           linux/arm64
 Experimental:      false

Server:
 Engine:
  Version:          18.09.7
  API version:      1.39 (minimum version 1.12)
  Go version:       go1.10.1
  Git commit:       2d0083d
  Built:            Wed Aug 14 19:41:23 2019
  OS/Arch:          linux/arm64
  Experimental:     false
```
本文不是教学，所以安装过程都忽略。值得一提的是，两台服务器在环境搭建的过程中，表现的都很流畅快捷，操作完全相同。常常需要专门看一眼主机名才能想的起来这是哪一台服务器。跟以往操作一些异构服务器的时候沟沟坎坎密布完全不可同日而语。  
此外，各工具链国内的镜像站点对于环境搭建帮助很大，显著的提高了搭建速度。  

#### 试用项目
有习惯使然的因素，这里用来测试服务器的项目选用了Gothinkster的RealWorld。RealWorld是一个极简的微型博客系统，号称“应用型演示之母”。是一个麻雀虽小，五脏俱卷的小应用。  
在其[项目网站](https://github.com/gothinkster/realworld)上，提供了22种前端和50种后端的开源代码，任一种前端，都可以配合任一种后端组合工作。  
看了前面的环境配置，估计你已经猜到了，我在这里选择了Vue的前端和rust-rocket-diesel后端的组合方式。  
#### 前端开发
我们先从前端看起，首先把源码下载下来：  
```bash
$ git clone https://github.com/gothinkster/vue-realworld-example-app
```
然后下载相关的依赖包：  
```bash
$ cd vue-realworld-example-app
$ yarn install
```
我们需要对源码做4处修改：  
1. 在项目根目录增加`vue.config.js`文件，配置项目在网站中的子路径，毕竟虽然是试用，直接把根目录开放给RealWorld也太不讲究了。  
2. Vue写的前端，使用了单网页结构。不同功能之间，看上去是不同的网页，实际是Vue截获URL地址，在屏幕组件之间的切换。为了让Vue路由工作准确，我们需要修改`src/router/index.js`文件，设置路由模式和基础网页文件URL。  
3. 前端同后端之间，使用Restful的接口通讯，我们需要在`src/common/config.js`文件中设置这个API基础地址。  
4. `src/store/auth.module.js`文件，UPDATE_USER方法中，有一处BUG。这一处问题同大多数后端配合中体现不出来，但同Rust这种严格的后端配合，会导致用户无法编辑个人资料。需要修改函数中的数据提交部分。  

本文不做教学，相信大家也没兴趣看教学，所以具体的修改、配置方法都略过。我们只来看编译的过程。  
首先是在鲲鹏服务器上：  
```bash
$ time yarn build
yarn run v1.21.0
$ cross-env BABEL_ENV=dev vue-cli-service build

⠇  Building for production...

  File                                      Size             Gzipped

  dist/js/chunk-vendors.dcd10e99.js         172.11 KiB       58.87 KiB
  dist/js/chunk-52fabea2.8d54de7e.js        35.24 KiB        10.74 KiB
  dist/js/app.5e06b01a.js                   19.41 KiB        5.56 KiB
  dist/js/chunk-8ab06c80.0691ea34.js        13.74 KiB        4.53 KiB
  dist/js/chunk-fee37f4e.962c341f.js        5.50 KiB         1.80 KiB
  dist/js/chunk-2d0b3289.4ecc4d5e.js        3.68 KiB         1.17 KiB
  dist/js/chunk-2d217357.a492fd23.js        3.20 KiB         1.15 KiB
  dist/js/chunk-704fe663.1eb6fa07.js        2.94 KiB         1.14 KiB
  dist/js/chunk-2d0d6d35.3e7333df.js        2.92 KiB         1.15 KiB
  dist/js/chunk-2d2086b7.9e172229.js        2.57 KiB         1.12 KiB
  dist/precache-manifest.d3673753a0030f7    1.66 KiB         0.55 KiB
  ef7bc3318dfea2bf8.js
  dist/service-worker.js                    0.95 KiB         0.54 KiB
  dist/js/chunk-2d0bd246.4cab42ec.js        0.58 KiB         0.40 KiB
  dist/js/chunk-2d0f1193.580d39c8.js        0.57 KiB         0.40 KiB
  dist/js/chunk-2d0cedd0.a32d9392.js        0.53 KiB         0.38 KiB
  dist/js/chunk-2d207fb4.d8669731.js        0.48 KiB         0.35 KiB
  dist/js/chunk-2d0bac97.f736bcaf.js        0.48 KiB         0.35 KiB

  Images and other types of assets omitted.

 DONE  Build complete. The dist directory is ready to be deployed.
 INFO  Check out deployment instructions at https://cli.vuejs.org/guide/deployment.html
                                  
Done in 23.57s.

real	0m23.889s
user	0m19.927s
sys	0m0.965s
```
为了减少篇幅，日志信息删除了个别源码格式的警告信息。一切都很正常，没有什么不兼容的现象发生。再来看看Intel的表现：  
```bash
$ time yarn build
yarn run v1.21.0
$ cross-env BABEL_ENV=dev vue-cli-service build

⠇  Building for production...

  File                                      Size             Gzipped

  dist/js/chunk-vendors.dcd10e99.js         172.11 KiB       58.87 KiB
  dist/js/chunk-52fabea2.c34912e7.js        35.24 KiB        10.74 KiB
  dist/js/app.348e5166.js                   19.35 KiB        5.53 KiB
  dist/js/chunk-8ab06c80.3fa2c5de.js        13.74 KiB        4.53 KiB
  dist/js/chunk-fee37f4e.55893266.js        5.50 KiB         1.80 KiB
  dist/js/chunk-2d0b3289.7b3abcbe.js        3.68 KiB         1.17 KiB
  dist/js/chunk-2d217357.e2eb7ad1.js        3.20 KiB         1.14 KiB
  dist/js/chunk-704fe663.25958462.js        2.94 KiB         1.14 KiB
  dist/js/chunk-2d0d6d35.ddc63fdd.js        2.92 KiB         1.15 KiB
  dist/js/chunk-2d2086b7.35190064.js        2.57 KiB         1.12 KiB
  dist/precache-manifest.049c26b68ee8b9c    1.55 KiB         0.53 KiB
  603c4f04a6cd8e3c8.js
  dist/service-worker.js                    0.95 KiB         0.54 KiB
  dist/js/chunk-2d0bd246.b354ca7f.js        0.58 KiB         0.40 KiB
  dist/js/chunk-2d0f1193.12c44839.js        0.57 KiB         0.40 KiB
  dist/js/chunk-2d0cedd0.ea949ae4.js        0.53 KiB         0.38 KiB
  dist/js/chunk-2d207fb4.245dc458.js        0.48 KiB         0.35 KiB
  dist/js/chunk-2d0bac97.74e3c28d.js        0.48 KiB         0.35 KiB

  Images and other types of assets omitted.

 DONE  Build complete. The dist directory is ready to be deployed.
 INFO  Check out deployment instructions at https://cli.vuejs.org/guide/deployment.html
                                  
Done in 16.27s.

real	0m16.548s
user	0m20.435s
sys	0m1.223s
```
到底多一颗核心和4倍的内存，编译速度快了约30%。  
考虑到双方的硬件配置，我主观觉得算两家平手说得上公平。  

#### 后端开发
首先也是自[仓库](https://github.com/TatriX/realworld-rust-rocket)下载源码。  
接着要做这样几件事情：  
1. 后端原来只有一组Restful接口的服务，我们需要让它能直接提供静态文件服务，否则还要另外配置一个静态文件服务来容纳刚才编译好的前端文件。我修改了`src/lib.rs`程序，增加了处理函数，将`./static/`文件夹开放为静态文件路径。  
2. 将Vue前端编译的结果，是在Vue项目的`dist/`路径中，完整拷贝到当前项目的`static/`目录。  
3. 根据代码仓库网页的说明，配置PostgreSQL服务，和使用Diesel ORM工具初始化realworld数据库。  
  
接下来我们使用Rust的开发模式，来做一个试运行：  
```bash
$ cargo run
```
在Intel的服务器上，这个过程一切正常。而在鲲鹏上，不幸的事情发生了，发生了报错，日志过程很长，下面只截取了错误信息的一行：  
```bash
undefined reference to `rust_crypto_util_fixed_time_eq_asm'
```
不出乎意料，这是跟汇编有关的东西。  
技术发展到今天，在万能的Linux帮助下，大多的异构系统都能蓬勃发展，前提是，如果不涉及到汇编部分。  
为了测试能够继续，根据出错信息，检查rust-crypto工具箱源码。  
很快发现，在`rust-crypto-0.2.36/src/util_helpers.c`文件中，只有X64/ARM两种架构的汇编语言。鲲鹏虽然也是ARM，但是aarch64架构，对应的汇编语言代码并不存在。  
因为我对汇编也不熟悉，所以开始在互联网上各种搜索。功夫不负有心人，经过大概一小时的努力，在网上找到了一段本函数aarch64的实现：  
```c
#ifdef __aarch64__
uint32_t rust_crypto_util_fixed_time_eq_asm(uint8_t* lhsp, uint8_t* rhsp, size_t count) {
    if (count == 0) {
        return 1;
    }
    uint8_t result = 0;
    asm(
        " \
            1: \
            \
            ldrb w4, [%1]; \
            ldrb w5, [%2]; \
            eor w4, w4, w5; \
            orr %w0, %w0, w4; \
            \
            add %w1, %w1, #1; \
            add %w2, %w2, #1; \
            subs %w3, %w3, #1; \
            bne 1b; \
        "
        : "+&r" (result), "+&r" (lhsp), "+&r" (rhsp), "+&r" (count) // all input and output
        : // input
        : "w4", "w5", "cc" // clobbers
    );
    
    return result;
}
#endif
```
把这段代码放进`util_helpers.c`，再次执行`cargo run`，realworld运行成功了。  
![](http://files.17study.com.cn/201912/hw/realworld1.png)  
随便发一个博文：  
![](http://files.17study.com.cn/201912/hw/realworld2.png)  
试运行正常，接下来让两家再次展现一下编译的实力吧。 首先请鲲鹏出场：  
```bash
$ time cargo build --release
   Compiling libc v0.2.66
   Compiling autocfg v0.1.7
   Compiling cfg-if v0.1.10
    ...(略去)...
   Compiling rocket_cors v0.4.0
   Compiling rocket_contrib v0.4.2
   Compiling realworld v0.4.0 (/home/andrew/dev/realworld-rust-rocket)
    Finished release [optimized] target(s) in 18m 28s

real	18m28.666s
user	18m8.184s
sys	0m10.982s
```
一共是191个源码包，日志节省篇幅，只列出了其中的6个，编译耗费时间18分28秒，生成的可执行文件8.4M。  
```bash
$ ls -lh target/release/
total 15M
drwxrwxr-x 64 andrew andrew 4.0K Dec 10 09:27 build
drwxrwxr-x  2 andrew andrew  32K Dec 10 09:45 deps
drwxrwxr-x  2 andrew andrew 4.0K Dec 10 09:27 examples
drwxrwxr-x  2 andrew andrew 4.0K Dec 10 09:27 incremental
-rw-rw-r--  1 andrew andrew 1.2K Dec 10 09:45 librealworld.d
-rw-rw-r--  2 andrew andrew 6.2M Dec 10 09:45 librealworld.rlib
-rwxrwxr-x  2 andrew andrew 8.4M Dec 10 09:45 realworld
-rw-rw-r--  1 andrew andrew 1.2K Dec 10 09:45 realworld.d
```
接着来看Intel的速度：  
```bash
$ time cargo build --release
   Compiling libc v0.2.65
   Compiling autocfg v0.1.7
   Compiling cfg-if v0.1.10
    ...(略去)...
   Compiling rocket_cors v0.4.0
   Compiling rocket_contrib v0.4.2
   Compiling realworld v0.4.0 (/home/andrew/dev/rust/realworld-rust-rocket)
    Finished release [optimized] target(s) in 7m 39s

real	7m39.088s
user	15m1.126s
sys	0m13.470s

$ ls -lh target/release/
total 16M
drwxrwxr-x 64 andrew andrew 4.0K Dec 10 01:38 build
drwxrwxr-x  2 andrew andrew  36K Dec 10 01:45 deps
drwxrwxr-x  2 andrew andrew 4.0K Dec 10 01:38 examples
drwxrwxr-x  2 andrew andrew 4.0K Dec 10 01:38 incremental
-rw-rw-r--  1 andrew andrew 1.3K Dec 10 01:45 librealworld.d
-rw-rw-r--  2 andrew andrew 6.3M Dec 10 01:45 librealworld.rlib
-rwxrwxr-x  2 andrew andrew 9.0M Dec 10 01:45 realworld
-rw-rw-r--  1 andrew andrew 1.3K Dec 10 01:45 realworld.d
```
（手动扶额）Intel只花了略超鲲鹏1/3的时间完成编译，生成的可执行文件9M。这一次，鲲鹏大比分落后了。  

#### 性能测试工具
互联网应用不同于桌面应用，为了完整对性能进行检测，我们需要一款独立的测试工具。  
Ubuntu的软件源中已经集成了一些，不过我选用了Wrk，从源码开始编译一遍，这样，C/C++的编译速度和兼容情况，也就顺便看到了。  
以下步骤执行在鲲鹏服务器上：  
```bash
# 下载源码
$ git clone https://github.com/wg/wrk
# 编译
$ cd wrk
$ make
$ time make
Building LuaJIT...
make[1]: Entering directory '/home/andrew/dev/wrk/obj/LuaJIT-2.1.0-beta3'
==== Building LuaJIT 2.1.0-beta3 ====
make -C src
make[2]: Entering directory '/home/andrew/dev/wrk/obj/LuaJIT-2.1.0-beta3/src'
HOSTCC    host/minilua.o
HOSTLINK  host/minilua
DYNASM    host/buildvm_arch.h
HOSTCC    host/buildvm.o
HOSTCC    host/buildvm_asm.o
HOSTCC    host/buildvm_peobj.o
HOSTCC    host/buildvm_lib.o
HOSTCC    host/buildvm_fold.o
HOSTLINK  host/buildvm
BUILDVM   lj_vm.S
ASM       lj_vm.o
CC        lj_gc.o
BUILDVM   lj_ffdef.h
CC        lj_err.o
CC        lj_char.o
BUILDVM   lj_bcdef.h
CC        lj_bc.o
  ...
gcc  -I. -Icrypto/include -Iinclude -fPIC -pthread -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_BN_ASM_MONT -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DVPAES_ASM -DECP_NISTZ256_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -MMD -MF crypto/ec/ec_check.d.tmp -MT crypto/ec/ec_check.o -c -o crypto/ec/ec_check.o crypto/ec/ec_check.c
gcc  -I. -Icrypto/include -Iinclude -fPIC -pthread -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_BN_ASM_MONT -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DVPAES_ASM -DECP_NISTZ256_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -MMD -MF crypto/ec/ec_curve.d.tmp -MT crypto/ec/ec_curve.o -c -o crypto/ec/ec_curve.o crypto/ec/ec_curve.c
  ...
gcc  -I. -Iinclude -fPIC -pthread -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_BN_ASM_MONT -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DVPAES_ASM -DECP_NISTZ256_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -MMD -MF ssl/t1_trce.d.tmp -MT ssl/t1_trce.o -c -o ssl/t1_trce.o ssl/t1_trce.c
gcc  -I. -Iinclude -fPIC -pthread -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_BN_ASM_MONT -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DVPAES_ASM -DECP_NISTZ256_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -MMD -MF ssl/tls13_enc.d.tmp -MT ssl/tls13_enc.o -c -o ssl/tls13_enc.o ssl/tls13_enc.c
gcc  -I. -Iinclude -fPIC -pthread -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_BN_ASM_MONT -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DVPAES_ASM -DECP_NISTZ256_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -MMD -MF ssl/tls_srp.d.tmp -MT ssl/tls_srp.o -c -o ssl/tls_srp.o ssl/tls_srp.c
  ...(略去)...
make depend && make _build_engines
make[2]: Entering directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Entering directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Nothing to be done for '_build_engines'.
make[2]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
created directory `/home/andrew/dev/wrk/obj/lib/engines-1.1'
*** Installing engines
make depend && make _build_programs
make[2]: Entering directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Entering directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Nothing to be done for '_build_programs'.
make[2]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
*** Installing runtime programs
install apps/openssl -> /home/andrew/dev/wrk/obj/bin/openssl
install ./tools/c_rehash -> /home/andrew/dev/wrk/obj/bin/c_rehash
make[1]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
CC src/wrk.c
CC src/net.c
CC src/ssl.c
CC src/aprintf.c
CC src/stats.c
CC src/script.c
CC src/units.c
CC src/ae.c
CC src/zmalloc.c
CC src/http_parser.c
LUAJIT src/wrk.lua
LINK wrk

real	3m31.575s
user	3m6.914s
sys	0m22.147s
```
这个小工具包含了大量的c语言源码和部分汇编代码，少量的lua脚本当做数据文件存在。  
鲲鹏的编译过程耗时3分32秒。  
接着是Intel至强：  
```bash
$ time make
Building LuaJIT...
make[1]: Entering directory '/home/andrew/dev/wrk/obj/LuaJIT-2.1.0-beta3'
==== Building LuaJIT 2.1.0-beta3 ====
make -C src
make[2]: Entering directory '/home/andrew/dev/wrk/obj/LuaJIT-2.1.0-beta3/src'
HOSTCC    host/minilua.o
HOSTLINK  host/minilua
DYNASM    host/buildvm_arch.h
HOSTCC    host/buildvm.o
HOSTCC    host/buildvm_asm.o
HOSTCC    host/buildvm_peobj.o
HOSTCC    host/buildvm_lib.o
HOSTCC    host/buildvm_fold.o
HOSTLINK  host/buildvm
BUILDVM   lj_vm.S
ASM       lj_vm.o
CC        lj_gc.o
BUILDVM   lj_ffdef.h
CC        lj_err.o
CC        lj_char.o
  ......
CC="gcc" /usr/bin/perl crypto/aes/asm/aesni-mb-x86_64.pl elf crypto/aes/aesni-mb-x86_64.s
gcc -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPADLOCK_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -c -o crypto/aes/aesni-mb-x86_64.o crypto/aes/aesni-mb-x86_64.s
CC="gcc" /usr/bin/perl crypto/aes/asm/aesni-sha1-x86_64.pl elf crypto/aes/aesni-sha1-x86_64.s
gcc -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPADLOCK_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -c -o crypto/aes/aesni-sha1-x86_64.o crypto/aes/aesni-sha1-x86_64.s
  ......
gcc  -I. -Icrypto/include -Iinclude -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPADLOCK_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -MMD -MF crypto/asn1/x_pkey.d.tmp -MT crypto/asn1/x_pkey.o -c -o crypto/asn1/x_pkey.o crypto/asn1/x_pkey.c
gcc  -I. -Icrypto/include -Iinclude -fPIC -pthread -m64 -Wa,--noexecstack -Wall -O3 -DOPENSSL_USE_NODELETE -DL_ENDIAN -DOPENSSL_PIC -DOPENSSL_CPUID_OBJ -DOPENSSL_IA32_SSE2 -DOPENSSL_BN_ASM_MONT -DOPENSSL_BN_ASM_MONT5 -DOPENSSL_BN_ASM_GF2m -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DKECCAK1600_ASM -DRC4_ASM -DMD5_ASM -DAES_ASM -DVPAES_ASM -DBSAES_ASM -DGHASH_ASM -DECP_NISTZ256_ASM -DX25519_ASM -DPADLOCK_ASM -DPOLY1305_ASM -DOPENSSLDIR="\"/home/andrew/dev/wrk/obj/ssl\"" -DENGINESDIR="\"/home/andrew/dev/wrk/obj/lib/engines-1.1\"" -DNDEBUG  -MMD -MF crypto/asn1/x_sig.d.tmp -MT crypto/asn1/x_sig.o -c -o crypto/asn1/x_sig.o crypto/asn1/x_sig.c
  ...(略)...
make depend && make _build_programs
make[2]: Entering directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Entering directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
make[2]: Nothing to be done for '_build_programs'.
make[2]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
*** Installing runtime programs
install apps/openssl -> /home/andrew/dev/wrk/obj/bin/openssl
install ./tools/c_rehash -> /home/andrew/dev/wrk/obj/bin/c_rehash
make[1]: Leaving directory '/home/andrew/dev/wrk/obj/openssl-1.1.1b'
CC src/wrk.c
CC src/net.c
CC src/ssl.c
CC src/aprintf.c
CC src/stats.c
CC src/script.c
CC src/units.c
CC src/ae.c
CC src/zmalloc.c
CC src/http_parser.c
LUAJIT src/wrk.lua
LINK wrk

real	3m48.678s
user	3m9.735s
sys	0m37.941s
andrew@ebs-31389:~/dev/wrk$ 
```
咦？3分48秒，居然略慢于鲲鹏。  
其实认真分析一下，我觉得也是正常的。从官方公布的数据来看，鲲鹏的核心性能并不差，如果任务比较小，在内存中就能完成，那鲲鹏的速度显然就应当快。  
而如果任务比较大，导致了大量的磁盘交换，我们选用的这台低配鲲鹏就撑不住了，再加上只有一颗核心的配置。最终的结果，任务越大，这台鲲鹏被落下就越多。  

好了，测试工具准备完毕，我们分别对两台服务器的Web服务性能做一个测试吧。相信对于云端主机来讲，这个才是硬杠杠啊。  
把两边的服务器都启动起来：  
![](http://files.17study.com.cn/201912/hw/realworld-server.png)  

首先来看鲲鹏的测试数据：  
```bash 
$ wrk -t1 -c50 -d5s --latency --timeout 2s http://localhost:8000/index.html
Running 5s test @ http://localhost:8000/index.html
  1 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.97ms    1.04ms   4.58ms   57.80%
    Req/Sec     8.79k   228.58     9.09k    70.00%
  Latency Distribution
     50%    1.97ms
     75%    2.87ms
     90%    3.41ms
     99%    3.78ms
  44400 requests in 5.08s, 120.47MB read
  Socket errors: connect 0, read 44400, write 0, timeout 0
Requests/sec:   8745.40
Transfer/sec:     23.73MB
```
两台服务器的配置区别比较大，公平起见，我们在参数上只启用了一个线程。连接数选择50个，我想对于一个小型网站，这可能是比较典型的数量。  
鲲鹏服务器在5.08秒的测试中，承受了44400个请求，一共发送数据120.47MB。  

接着Intel站上前台：  
```bash
$ wrk -t1 -c50 -d5s --latency --timeout 2s http://localhost:8000/index.html
Running 5s test @ http://localhost:8000/index.html
  1 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    32.32ms    5.00ms  64.20ms   75.23%
    Req/Sec     1.52k   176.64     1.91k    72.00%
  Latency Distribution
     50%   31.52ms
     75%   34.64ms
     90%   38.67ms
     99%   48.04ms
  7552 requests in 5.00s, 21.97MB read
  Socket errors: connect 0, read 7550, write 0, timeout 0
Requests/sec:   1509.75
Transfer/sec:      4.39MB
```
哇咔咔...有没有惊掉眼球？真是没有对比就没有伤害。在5秒的测试中，Intel Xeon只承受了7552个请求，发送数据21.97MB。作为一个老牌的CPU大厂，Intel你丢不丢“芯”？  

`index.html`只是一个静态页面，我们换一个动态链接再来看看，这样数据库的部分也就能一起体现了。  
下面测试的就是一个Restful接口，用于列出文章内容的：  
```bash
$ curl http://127.0.0.1:8000/api/articles
{"articles":[{"author":{"bio":null,"email":"andrewwang@sina.com","id":1,"image":null,"username":"andrew"},"body":"苹果公司近日宣布，新的Mac Pro和Pro Display XDR将于12月10日开始订购。新的Mac Pro起价为5,999美元（约合人民币42202元），而Pro Display XDR起价为4,999美元（约合人民币35167元）。\n5,999美元的基本款Mac Pro搭载了8核Intel Xeon处理器，256 GB SSD，32GB RAM等配置。最高配置支持28核Intel Xeon处理器，4块Vega显卡，1.5TB的超大容量内存。而其首次引入的Apple Afterburner加速卡，这使得Mac Pro可实时解码最多达 3 条 8K ProRes RAW 视频流和最多达 12 条 4K ProRes RAW 视频流。\n而新款的 Pro Display XDR则配置了分辨率达到6016 x 3384的32英寸显示屏，这款显示器的参数达到了静态 1000nit / 峰值 1600nits 的亮度，同时还有着1000000：1的对比度。如果用户追求低反射率和低眩光，可以多加1000美元（约合人民币7000元）给显示器添加一个“纳米纹理”哑光涂层。","createdAt":"2019-12-10T02:05:38.758Z","description":"nothing but test","favorited":false,"favoritesCount":0,"id":1,"slug":"test-sqzxyV","tagList":[],"title":"test","updatedAt":"2019-12-10T02:05:38.758Z"}],"articlesCount":1}
```
同样，先看看鲲鹏的表现：  
```bash
$ wrk -t1 -c50 -d5s --latency --timeout 2s http://127.0.0.1:8000/api/articles
Running 5s test @ http://127.0.0.1:8000/api/articles
  1 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    40.03ms    2.37ms  41.82ms   99.15%
    Req/Sec     1.25k    11.16     1.27k    66.00%
  Latency Distribution
     50%   40.21ms
     75%   40.48ms
     90%   40.75ms
     99%   41.34ms
  6199 requests in 5.00s, 8.92MB read
  Socket errors: connect 0, read 6198, write 0, timeout 0
Requests/sec:   1239.54
Transfer/sec:      1.78MB
```
Intel登场：  
```bash
$ wrk -t1 -c50 -d5s --latency --timeout 2s http://127.0.0.1:8000/api/articles
Running 5s test @ http://127.0.0.1:8000/api/articles
  1 threads and 50 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    62.63ms    9.18ms  96.45ms   72.66%
    Req/Sec   787.82     95.11     1.01k    72.00%
  Latency Distribution
     50%   62.32ms
     75%   68.07ms
     90%   74.42ms
     99%   85.25ms
  3921 requests in 5.01s, 5.64MB read
  Socket errors: connect 0, read 3920, write 0, timeout 0
Requests/sec:    783.09
Transfer/sec:     1.13MB
```
发的帖子太短了，数据流很小，时间全消耗在链接上了，有点体现不出来实力。....不过...鲲鹏再次大比分领先。同时你还别忘了，这台测试的鲲鹏服务器，内存只有Intel竞品的1/4，以及1/2CPU核心。  
从这些数据，我想负责任的说，国产芯片和国产服务器的云端实力，稳了。  

#### 容器体验
以容器为基础的微服务已经是今天服务器运营的主流模式。在这方面鲲鹏服务器应当说很幸运。毕竟只是在Linux内核就能实现的cgroup和namespace比需要模拟指令集的VM技术容易的多。可说是与生俱来。  
但问题也并不这么简单，比如你随便搜索一个应用:  
```bash
# docker search mariadb
NAME                                   DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
mariadb                                MariaDB is a community-developed fork of MyS…   3135                [OK]                
bitnami/mariadb                        Bitnami MariaDB Docker Image                    107                                     [OK]
linuxserver/mariadb                    A Mariadb container, brought to you by Linux…   95                                      
toughiq/mariadb-cluster                Dockerized Automated MariaDB Galera Cluster …   41                                      [OK]
colinmollenhour/mariadb-galera-swarm   MariaDb w/ Galera Cluster, DNS-based service…   26                                      [OK]
panubo/mariadb-galera                  MariaDB Galera Cluster                          23                                      [OK]
lsioarmhf/mariadb                      ARMHF based Linuxserver.io image of mariadb     18                                      
mariadb/server                         MariaDB Server is a modern database for mode…   18                                      [OK]
webhippie/mariadb                      Docker images for MariaDB                       16                                      [OK]
bianjp/mariadb-alpine                  Lightweight MariaDB docker image with Alpine…   12                                      [OK]
centos/mariadb-101-centos7             MariaDB 10.1 SQL database server                10                                      
severalnines/mariadb                   A homogeneous MariaDB Galera Cluster image t…   7                                       [OK]
centos/mariadb-102-centos7             MariaDB 10.2 SQL database server                6                                       
tutum/mariadb                          Base docker image to run a MariaDB database …   4                                       
wodby/mariadb                          Alpine-based MariaDB container image with or…   4                                       [OK]
circleci/mariadb                       CircleCI images for MariaDB                     3                                       [OK]
tiredofit/mariadb-backup               MariaDB Backup image to backup MariaDB/MySQL…   2                                       [OK]
kitpages/mariadb-galera                MariaDB with Galera                             2                                       [OK]
rightctrl/mariadb                      Mariadb with Galera support                     2                                       [OK]
jonbaldie/mariadb                      Fast, simple, and lightweight MariaDB Docker…   2                                       [OK]
demyx/mariadb                          Non-root Docker image running Alpine Linux a…   0                                       
ccitest/mariadb                        CircleCI test images for MariaDB                0                                       [OK]
jelastic/mariadb                       An image of the MariaDB SQL database server …   0                                       
ansibleplaybookbundle/mariadb-apb      An APB which deploys RHSCL MariaDB              0                                       [OK]
alvistack/mariadb                       Docker Image Packaging for MariaDB             0        
```
嗯嗯，看起来跟x86服务器没有什么区别。但是想拉一个下来试试？亲，你还是算了吧。容器映像中打包的可是二进制的执行文件，是要区别CPU的，拉下来你也用不了。  
看起来，这个世界还没有为ARM服务器的到来做好准备，至少也应当像APT/YUM之类的工具一样，自动区分架构来准备资源池不是？  

所以想要找适合鲲鹏服务器的映像文件，需要手动添加关键字搜索。  
当前Docker Hub有两个分类适用64位ARM服务器架构，分别是`aarch64`和`arm64v8`，其中`aarch64`分类已经不再使用，新上架的映像都归类到了`arm64v8`。但因为兼容性考虑，`aarch64`分类原有映像仍然都存在。换句话说，如果两个分类都有你需要的映像，你应当优先选择`arm64v8`分类下面的。  
接着，第二个小问题就来了，使用这两个关键字来搜索：  
```bash
# docker search aarch64
NAME                                      DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
homeassistant/aarch64-homeassistant                                                       15                                      
aarch64/ubuntu                            Ubuntu is a Debian-based Linux operating sys…   14                                      
homeassistant/aarch64-hassio-supervisor                                                   5                                       
balenalib/aarch64-ubuntu-node             This image is part of the balena.io base ima…   1                                       
balenalib/aarch64-alpine-python           This image is part of the balena.io base ima…   1                                       
resin/aarch64-alpine-python               This repository is deprecated.                  1                                       
resin/aarch64-python                      This repository is deprecated.                  1                                       
resin/aarch64-alpine-buildpack-deps       This repository is deprecated.                  0                                       
resin/aarch64-ubuntu-golang               This repository is deprecated.                  0                                       
resin/aarch64-fedora-buildpack-deps       This repository is deprecated.                  0                                       
resin/aarch64-fedora-python               This repository is deprecated.                  0                                       
resin/aarch64-alpine-openjdk              This repository is deprecated.                  0                                       
balenalib/aarch64-alpine-node             This image is part of the balena.io base ima…   0                                       
resin/aarch64-fedora-golang               This repository is deprecated.                  0                                       
resin/aarch64-golang                      This repository is deprecated.                  0                                       
resin/aarch64-fedora-openjdk              This repository is deprecated.                  0                                       
resin/aarch64-alpine-golang               This repository is deprecated.                  0                                       
balenalib/aarch64-node                    This image is part of the balena.io base ima…   0                                       
balenalib/aarch64-debian-node             This image is part of the balena.io base ima…   0                                       
resin/aarch64-fedora-node                 This repository is deprecated.                  0                                       
resin/aarch64-node                        This repository is deprecated.                  0                                       
resin/aarch64-ubuntu-python               This repository is deprecated.                  0                                       
balenalib/aarch64-ubuntu-golang           This image is part of the balena.io base ima…   0                                       
resin/aarch64-alpine-node                 This repository is deprecated.                  0                                       
balenalib/aarch64-debian-python           This image is part of the balena.io base ima…   0       

# docker search arm64v8
NAME                                   DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
arm64v8/alpine                         A minimal Docker image based on Alpine Linux…   45                                      
arm64v8/ubuntu                         Ubuntu is a Debian-based Linux operating sys…   30                                      
arm64v8/debian                         Debian is a Linux distribution thats compos…   21                                      
arm64v8/nginx                          Official build of Nginx.                        18                                      
arm64v8/python                         Python is an interpreted, interactive, objec…   18                                      
arm64v8/nextcloud                      A safe home for all your data                   15                                      
arm64v8/node                           Node.js is a JavaScript-based platform for s…   12                                      
arm64v8/openjdk                        OpenJDK is an open-source implementation of …   9                                       
arm64v8/redis                          Redis is an open source key-value store that…   7                                       
arm64v8/php                            While designed for web development, the PHP …   7                                       
arm64v8/mongo                          MongoDB document databases provide high avai…   6                                       
arm64v8/golang                         Go (golang) is a general purpose, higher-lev…   6                                       
arm64v8/docker                         Docker in Docker!                               6                                       
arm64v8/ros                            The Robot Operating System (ROS) is an open …   5                                       
arm64v8/buildpack-deps                 A collection of common build dependencies us…   3                                       
arm64v8/busybox                        Busybox base image.                             3                                       
arm64v8/ruby                           Ruby is a dynamic, reflective, object-orient…   2                                       
arm64v8/tomcat                         Apache Tomcat is an open source implementati…   2                                       
arm64v8/erlang                         Erlang is a programming language used to bui…   1                                       
arm64v8/wordpress                      The WordPress rich content management system…   1                                       
arm64v8/joomla                         Joomla! is an open source content management…   0                                       
arm64v8/haxe                           Haxe is a modern, high level, static typed p…   0                                       
troyfontaine/arm64v8_min-alpinelinux   Minimal 64-bit ARM64v8 Alpine Linux Image       0                                       
arm64v8/hylang                         Hy is a Lisp dialect that translates express…   0                                       
arm64v8/perl                           Perl is a high-level, general-purpose, inter…   0                             
```
你会发现，比起来丰饶的x86社区，arm服务器的资源实在是少的可怜，而且大多是基础性的映像。  
这恐怕是没有办法的事情了，用户少，资源也就少。好在，有了基础映像，自己添加应用，也没有什么不能接受。想一想，哪一个关键应用你敢直接完整使用社区映像？  
同样因为Docker Hub在架构区分上准备不足的问题，现在使用`docker search`命令直接搜索映像已经很不方便了。因为除了映像的关键字，我们又多了一个架构的限定。  
所以建议直接到对应网页搜索：  
<https://hub.docker.com/u/aarch64>还有  <https://hub.docker.com/u/arm64v8>  

下面我们试验用arm64v8分类的Docker映像，执行一个常见的WordPress应用，来体验一下鲲鹏服务器在容器方面的表现。  
WordPress应用需要两个容器，一个部署了Apache/PHP和WordPress本身；另外还需要一个MySQL兼容的数据库，我们使用其社区开源版本MariaDB。  
首先把映像拉下来：  
```bash
# docker pull arm64v8/wordpress
Using default tag: latest
latest: Pulling from arm64v8/wordpress
a4f3dd4087f9: Pull complete 
e54f8c59bdae: Pull complete 
6ae19fe01dd7: Pull complete 
939a6e43e07c: Pull complete 
c7bc60aacdf3: Pull complete 
c1e1bedfb04e: Pull complete 
8332b8441264: Pull complete 
012fa89ca2bc: Pull complete 
c0dfb13372af: Pull complete 
3cbeabdc4805: Pull complete 
8e492268eedf: Pull complete 
db2ddafb0478: Pull complete 
a02565d248c3: Pull complete 
7e8259639516: Pull complete 
3efb6c94a4c9: Pull complete 
77f6d83e6c7a: Pull complete 
3601f2116010: Pull complete 
4ec7c7d8a180: Pull complete 
b834909e81a9: Pull complete 
72c2b2a88763: Pull complete 
d77d0ee96a04: Pull complete 
Digest: sha256:28e7d4a7b3ba0d55f151e718e84de5f186b0c65adaac2da9005a64cb6ad82de8
Status: Downloaded newer image for arm64v8/wordpress:latest

# docker pull arm64v8/mariadb
Using default tag: latest
latest: Pulling from arm64v8/mariadb
6531af355894: Pull complete 
82f7942d2fb7: Pull complete 
fdce94e690d5: Pull complete 
a96a89ada1c3: Pull complete 
9bcef89e3002: Pull complete 
06115e3e56a0: Pull complete 
5712e955a6d4: Pull complete 
afd2dc9f5e8f: Pull complete 
07ef8ef990de: Pull complete 
ae55899885f1: Pull complete 
9c16c03a30d3: Pull complete 
5f1431dbf111: Pull complete 
58fecc1c9379: Pull complete 
1c94839aac8b: Pull complete 
Digest: sha256:c67410e8deeb6e165c867131c7669155e43b532d441120df2bbf4f12a3710cd7
Status: Downloaded newer image for arm64v8/mariadb:latest
```
随后先执行数据库映像，执行的时候在环境参数设定root账号密码、新建普通用户账号、还有为WordPress单独建一个库。我们不会在宿主机操作数据库，所以就不再映射端口出来了：  
```bash
# docker run -e MYSQL_ROOT_PASSWORD=rootpassword -e MYSQL_USER=wpuser -e MYSQL_PASSWORD=wpuserpassword -e MYSQL_DATABASE=wordpressdb --name wordpressdb -d arm64v8/mariadb
51e6d43af860e00c45cce81bed1918ae3c2a5c91bdcfca18203b0486d8f2783d
```
接着执行WordPress容器，在环境变量中把刚才创建的普通数据库用户账号传递进去，同时把WordPress容器连接到刚才的数据库容器，这是为了让它们之间直接使用Docker内部网络连接起来，不用通过宿主机中转：  
```bash
# docker run -e WORDPRESS_DB_USER=wpuser -e WORDPRESS_DB_PASSWORD=wpuserpassword -e WORDPRESS_DB_NAME=wordpressdb -p 8080:80 --link wordpressdb:mysql --name wordpress -d arm64v8/wordpress
83cad21cf2a057273440cb919885c061b77711b4baedb64fd7bff683a1a30177
```
这样，一个微型博客就搭建好了。开浏览器来看看：  
![](http://files.17study.com.cn/201912/hw/wp-setup.png)  
先要进行一些必要的基础设置，只是站点信息类的。因为刚才执行容器的时候就把数据库的设置传递了进去，所以数据库设置的Web页面根本就不会出现。  
设置完成打开网站首页：    
![](http://files.17study.com.cn/201912/hw/wp-home.png)  
工作的挺好。  

整个搭建的过程，除了两个映像的名字多了arm64v8前缀，其它从配置、到使用，跟X86服务器没有任何不同。  
#### 总结
几个体量不大的应用，显然无法代表全部，但自认为比通常的测试软件表现的要更丰满。  
说一说自己的体会：  
* 鲲鹏920表现亮眼，很有惊喜。在常见的云端企业级应用中完全能担当主力。  
* 常规的脚本语言、虚机类语言完全不用担心兼容性，上手即用，开机就能跑。  
* 常规的C/C++/Rust这些编译到二进制的语言，也不用有压力，我相信99%的企业级应用都能兼容。  
* 涉及到汇编的部分，aarch64汇编是个障碍，无论是自己新研发还是社区找资源，都需要慢慢积累。
* 容器社区资源明显不足，对依赖社区资源的小团队稍有打击，对企业应用影响不大。

试用完成，最后祝TaiShan服务器和鲲鹏芯片越来越好。  










