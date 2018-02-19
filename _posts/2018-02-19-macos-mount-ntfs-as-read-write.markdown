---
layout:         page
title:          macOS使用内置驱动加载可读写NTFS分区
subtitle:       可读写加载NTFS分区的小脚本
card-image:     https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=297268984,957200906&fm=27&gp=0.jpg
date:           2018-02-19
tags:           mac
post-card-type: image
---
macOS插入NTFS格式的U盘，都会自动加载为只读格式，拷贝文件出来没有问题，写文件就不允许了。  
流行有两个商业软件可以将NTFS格式的U盘加载为读写模式，它们是:Paragon NTFS for Mac和Tuxera NTFS for Mac，很像的两个软件，很好用，但也都是收费的商业软件。  
实际上macOS的内置NTFS驱动支持读写模式，只是容错性不佳，网上有过在macOS读写NTFS分区造成U盘数据损坏及Windows下读写HPF+苹果格式磁盘造成U盘数据损坏的先例。  
我使用U盘次数不多，但一般的使用及应急，看起来是没有问题的。  
上述两个商业版本的软件，号称有内置了比较好的NTFS驱动，但看起来就是在加载U盘的时候做了更严格的限制，比如若发现U盘存在没有修复的错误，则不允许被加载。在没有大量样本测试的情况下，似乎也没有明显的证据证明商业软件NTFS格式的读写就更可靠。  

不管怎样吧，应急情况优先使用内置的驱动来试试还是一个不错的选择。  
建议通过以下步骤：  
1. 首先建立一个脚本，名为`lsusb`  
```bash
#!/bin/sh 
system_profiler SPUSBDataType
```
2. 执行这个脚本将列出所有插入在USB口的外置设备，从其中可以看到你要加载的U盘，这里注意，如果NTFS的U盘已经被加载为只读模式，请先将U盘卸载。  
比如执行后的信息如下：  
```bash
            Ultra Fit:

              Product ID: 0x5583
              Vendor ID: 0x0781  (SanDisk Corporation)
              Version: 1.00
              Serial Number: 4C530001321231115151
              Speed: Up to 5 Gb/sec
              Manufacturer: SanDisk
              Location ID: 0x01210000 / 9
              Current Available (mA): 900
              Current Required (mA): 896
              Extra Operating Current (mA): 0
              Media:
                Ultra Fit:
                  Capacity: 15.38 GB (15,376,000,000 bytes)
                  Removable Media: Yes
                  BSD Name: disk2
                  Logical Unit: 0
                  Partition Map Type: MBR (Master Boot Record)
                  USB Interface: 0
                  Volumes:
                    disk2s1:
                      Capacity: 15.38 GB (15,375,998,976 bytes)
                      File System: NTFS
                      BSD Name: disk2s1
                      Content: Windows_NTFS
```
这说明有一个设备名为/dev/disk2s1，是一个NTFS格式的外置U盘。  
3. 再建立一个脚本，比如名为mountNtfs.sh:  
```bash
#!/bin/sh
sudo mkdir /Volumes/NTFS
sudo mount_ntfs -o rw,nobrowse $1 /Volumes/NTFS/
```
4. 随后执行：`mountNtfs.sh /dev/disk2s1`，就可以将该U盘以读写方式，加载到/Volumes/NTFS目录。  
5. 唯一的小缺陷是这样装载的U盘不会自动在Finder中显示图标，可以使用COMMAND+SHIFT+G跳转到/Volumes/NTFS目录去访问U盘的内容。  


