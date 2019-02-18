---
layout:         page
title:          Metal并行计算
subtitle:      	命令行编译、执行Metal Performance Shaders
card-image:		http://img.itools.hk/upload/77/27/8b543124-66a9-4372-ab5e-99fd841f7382.jpg
date:           2018-06-15
tags:           mac
post-card-type: image
---
![](http://img.itools.hk/upload/77/27/8b543124-66a9-4372-ab5e-99fd841f7382.jpg)
本来Cuda用的挺好，为了Apple，放弃Cuda，改投OpenCl。好不容易OpenCl也算熟悉了，WWDC2018又宣布了Metal2，建议大家放弃OpenCl，使用Metal Performance Shaders。  
Apple是一个富有“革命性”创新力的公司，很多创新，会彻底的放弃原有的积累。不断带来新能力的同时，也让人又爱又恨。  

下面是一个例子，用于演示如何使用Metal+Shader来加速mac的大规模数据计算。  
主程序使用swift。随机生成一个大规模的整数数组，然后分配到GPU内核上并行对数组进行求和。  
Metal部分的各项逻辑建议看官方文档<https://developer.apple.com/metal/>，只重点说一下计算部分。计算是由Shader子程序（核函数）完成的，Shader编程所使用的语言衍生自c++14，所以跟cpu通讯所使用的数据结构基本都是使用c语言可以接受的类型。可以把Shader语言理解为c++的一个子集。官方的建议是可以有大量的计算，但尽力减少逻辑语句之类需要GPU核进行预判从而降低速度的内容。大多情况下单个内核的计算速度并不快，使用GPU加速计算的原因是GPU都具有很多个计算单元进行并行的计算。  
通常在Shader函数的参数中，至少包含3个部分：输入、输出、进程的ID。前两个参数好理解，第三个参数就是因为该核函数可能随机的运行在某个GPU内核上进行计算工作，应当根据这个唯一的ID分配出来唯一的任务在程序中来计算，从而达到并发的效果。所以核函数都应当是支持并发、支持数据切割分块计算。  
Metal对并发的支持首先是线程组数量threadgroupsPerGrid，这个基本上是跟GPU核心数相关的，另一个是批次数量threadsPerThreadgroup，这个要求是线程组数量的整倍数。  
其它的内容请看代码中的注释。主程序命名为testCompute.swift  
```swift
import Metal

//定义数据集长度，总共count个数据求和
//swift数字立即数中可以添加下划线表现出来科学计数法的方式，很有特色
let count = 10_000_000
//每elementsPerSum个数据分配到一个核汇总一次
let elementsPerSum = 10_000

//每个数据的类型，必须使用C兼容的类型，
//因为GPU运行的shader语言是从C++14衍生来的
typealias DataType = CInt

//设备，就是GPU
let device = MTLCreateSystemDefaultDevice()!
//载入当前目录下的default.metallib(编译后的shader),使用其中的parsum核函数
let parsum = device.makeDefaultLibrary()!.makeFunction(name:"parsum")!
//如果shader文件不是默认名称，可以使用下面的方法载入指定文件
//let lib = try! dev.makeLibrary(filepath:"default.metallib")!.newFunctionWithName("parsum")!
//建立GPU运算的流水线
let pipeline = try! device.makeComputePipelineState(function:parsum)
//生成随机数据集
var data = (0..<count).map{ _ in DataType(arc4random_uniform(100)) }
//传递给核函数的数据总数，所以也用C兼容方式
var dataCount = CUnsignedInt(count)
//传递给核函数的每组汇总数量，同上
var elementsPerSumC = CUnsignedInt(elementsPerSum)
//返回的分批汇总的结果数
let resultsCount = (count + elementsPerSum - 1) / elementsPerSum

//建立两个同GPU通信的缓冲区，一个用于输入给核函数，一个用用于核函数返回结果
let dataBuffer = device.makeBuffer(bytes:&data, length: MemoryLayout<CInt>.size * count, options: []) // Our data in a buffer (copied)
let resultsBuffer = device.makeBuffer(length:MemoryLayout<CInt>.size * resultsCount, options: []) // A buffer for individual results (zero initialized)
//返回结果是c指针，要转换成swift可访问的数据类型
let results = UnsafeBufferPointer<DataType>(
    start: resultsBuffer!.contents().assumingMemoryBound(to:CInt.self), count: resultsCount)
//建立GPU命令队列
let queue = device.makeCommandQueue()
//GPU命令缓冲区，一般有多个运算会都放置到缓冲区，一次性提交执行
let cmds = queue!.makeCommandBuffer()
//命令编码器是用于将一条GPU核函数调用的函数、参数等打包到一起
let encoder = cmds!.makeComputeCommandEncoder()!

//设置一条GPU核函数调用的函数及其相关参数，如前所述，必须使用C兼容的类型
encoder.setComputePipelineState(pipeline)
encoder.setBuffer(dataBuffer, offset: 0, index: 0)
encoder.setBytes(&dataCount, length: MemoryLayout<CUnsignedInt>.size, index: 1)
encoder.setBuffer(resultsBuffer, offset: 0, index: 2)
encoder.setBytes(&elementsPerSumC, length: MemoryLayout<CUnsignedInt>.size, index: 3)

//设定每组任务数量
let threadgroupsPerGrid = MTLSize(width: (resultsCount + pipeline.threadExecutionWidth - 1) / pipeline.threadExecutionWidth, height: 1, depth: 1)
//设定每批次任务数量，必须是上面组数量的整倍数
let threadsPerThreadgroup = MTLSize(width: pipeline.threadExecutionWidth, height: 1, depth: 1)
//分配任务线程
encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
//完成一个调用的所有设置
encoder.endEncoding()

var start, end : UInt64
var result : DataType = 0

start = mach_absolute_time()
//真正提交任务
cmds!.commit()
//等待完成GPU计算
cmds!.waitUntilCompleted()
//GPU计算式分批次汇总的，数量已经很少了，最后用CPU进行完整的汇总
for elem in results {
    result += elem
}
end = mach_absolute_time()
//显示GPU计算结果及所用时间
print("Metal result: \(result), time: \(Double(end - start) / Double(NSEC_PER_SEC))")
result = 0

//下面是使用CPU完整的计算一次，并显示结果、耗费时间
start = mach_absolute_time()
data.withUnsafeBufferPointer { buffer in
    for elem in buffer {
        result += elem
    }
}
end = mach_absolute_time()
print("CPU result: \(result), time: \(Double(end - start) / Double(NSEC_PER_SEC))")

```
shade程序命名为：shader.metal  
```c
//各项数据类型必须跟Swift中定义的相同
#include <metal_stdlib>
typedef unsigned int uint; 
typedef int DataType;

kernel void parsum(const device DataType* data [[ buffer(0) ]],
                   const device uint& dataLength [[ buffer(1) ]],
                   device DataType* sums [[ buffer(2) ]],
                   const device uint& elementsPerSum [[ buffer(3) ]],

                   const uint tgPos [[ threadgroup_position_in_grid ]],
                   const uint tPerTg [[ threads_per_threadgroup ]],
                   const uint tPos [[ thread_position_in_threadgroup ]]) {
    //根据组索引、批次索引、组中位置计算总的索引值，这个是唯一的
    uint resultIndex = tgPos * tPerTg + tPos;
    //计算本批次数据的开始结束位置
    uint dataIndex = resultIndex * elementsPerSum; // Where the summation should begin
    uint endIndex = dataIndex + elementsPerSum < dataLength ? dataIndex + elementsPerSum : dataLength; // The index where summation should end
    //对本批次数据求和
    for (; dataIndex < endIndex; dataIndex++)
        sums[resultIndex] += data[dataIndex];
}
```
给一个在命令行使用的编译脚本：
```bash
#!/bin/bash
xcrun metal -o shader.air shader.metal
xcrun metal-ar rcs shader.metal-ar shader.air
xcrun metallib -o default.metallib shader.metal-ar
swiftc testCompute.swift⏎   
```
在我的笔记本上运行效果如下:  
```bash
metal> ./testCompute 
Metal result: 495056208, time: 0.017362745
CPU result: 495056208, time: 1.210801891
```
作为一个比较片面的比较，GPU计算速度，比CPU快121倍。  
测试环境：  
MacBook Pro (13-inch, 2017, Four Thunderbolt 3 Ports)  
CPU:3.1 GHz Intel Core i5  
Graphics:Intel Iris Plus Graphics 650 1536 MB  
Memory:8 GB 2133 MHz LPDDR3  
Xcode:9.4.1  

参考资料：  
<https://stackoverflow.com/questions/38164634/compute-sum-of-array-values-in-parallel-with-metal-swift>

