---
layout:         page
title:          RS232串口的Windows编程纪要
subtitle:      	VC6 AND RS232
card-image:		http://blog.17study.com.cn/attachments/201805/232cable1.jpg
date:           2018-05-10
tags:           seven win
post-card-type: image
---
![](http://blog.17study.com.cn/attachments/201805/232cable1.jpg)  
再次是一篇入门文，各路神仙退散。  
直接进入主题，又不是历史课，关于RS232那些前世今生的故事就不摆了。  

#### 硬件链接
首先以9针小口为例（大口应当只能去博物馆看了吧）看一下管脚排布，其实RS232本身没进博物馆都已经够让我惊讶了。  
![](http://blog.17study.com.cn/attachments/201805/232pic1.jpg)
(图片来自互联网)  

通常使用的接线图：  
![](http://blog.17study.com.cn/attachments/201805/232pic2.jpg)
(图片来自互联网)  


硬件接口部分的重点：  
* 绝大多数情况下，我们只需要接2号、3号、5号，RXD/TXD/SG三根线就能正常工作。（顺便多说一句，古老的大串口是2、3、7号）  
* 直连模式一般用于延长线或者大小口的转换线。
* 交叉线是用于连接电脑之间、电脑与设备之间，是最主要的应用方式。
* 通常三根线就能工作，但并不表示其它信号就没用，甚至像某些书上说的都没有定义。  

#### 硬件支持
当前我们常用的电脑，在台式机上一般都会有串口，可以直接使用。  
绝大多数的笔记本电脑都已经没有了串口，想使用串口通常都是使用USB接口的适配器。顺便说一句，USB实际也是另外一种串口，SATA也是，只是未成文的约定俗称上，串口特指了RS232接口或者485接口。  
USB适配器通常也分两种，一种是内置于外置设备中的适配器，比如外置GPS模块、烧录机。另外一种则是仅有串口功能的独立适配器，今天的实验中我们会使用后者。  

#### 驱动程序
本身主板已经具有的串口都已经有了良好的设备驱动，鲜见不可用者。  
USB外置的串口则绝大多数都需要另外安装驱动，Windows/Linux/macOS都是如此，依据适配器的芯片不同，所使用的驱动也不一样。这个在采购的时候就需要了解好。比如我测试的这款是PL2302芯片，使用win10内置的微软2017版驱动（不不不，不是你想的那样免驱动，继续看）。  
因为串口无论如何算是一个比较有历史的技术，所以在x64的系统中大多支持不好，PL2302为例，在win10x64系统中会自动识别并安装驱动，但驱动安装完成仍然会有一个叹号表示设备不能正常工作，错误代码10。  
搜索互联网能找到第三方提供的补丁，原厂商已经发布通知说PL2302已经停止支持了。补丁程序安装后运行还会先下载.net的运行时间库，随后才能完成驱动的补丁工作。  
此仅为举例，不同的适配器，需要的驱动、安装方式都不会一样。  

#### 实验环境准备
串口作为通讯设备，实验需要发送、接受两个端。所以最好的实验方法是一台电脑上，用两个串口，一个模拟接收，一个模拟发送。当然如果你不缺电脑、不缺空间、不缺时间，使用两台电脑看上去肯定会更高大上。  
各类操作系统都支持多个USB串口适配器同时工作，并识别为不同的串口设备和串口编号。  
所以你要做的是：  
1. 在不连接USB串口适配器的情况下（通常要求如此）安装正确的设备驱动。  
2. 根据驱动安装的要求，看是否需要重启系统。  
3. 在没有安装适配器的情况下，Windows到设备管理工具中，macOS则记录/dev路径下tty开头的设备。
4. 连接USB串口适配器，再次到上述相应位置，查看是否增加了串口设备，如果没有增加，返回检查驱动程序甚至适配器硬件。如果有增加，记录下来端口号，以供后续编程使用。  
5. 使用带接线端子的杜邦线，用上图中交叉连接的方式，连接两个适配器的GND-GND/RX-TX/TX-RX。如果感觉插在电脑上不好接线，也可以先将两个适配器接好线再插入电脑USB。  
6. 要么你的两个USB口离的足够近，要么你的杜邦线足够长，总之要保证连接稳定可靠。顺便，如果USB不够多，使用USB集线器也可以正常工作。  

开发工具部分，因为学校的教学限定，使用VC6。作为一个追求时尚的unix fans，被逼回到这个太祖级的编程环境我也是有够纠结:(  

#### RS232编程之旅
通常的教程都会从底层写起，细致的构建起整个的系统。而我比较相反，首先从c语言的main主函数的代码讲起：  
```cpp
// 为了清晰结构，代码有删减，但能正常运行
//
#include "serialport.h"
#include<string.h>

int main(int argc, char* argv[])
{
	//定义两个句柄，用来报错打开后的两个串口相关资源信息
	//句柄是编程中常用的说法，通常都表示指向一堆数据的标志
	HANDLE h1,h2;
	//定义一个字符串，字符串的内容其实无所谓，用于演示串口通讯的内容
	char *msg="Hello, human!\n";
	//要传输的数据的长度
	int n=strlen(msg);
	//一个串口接受用的缓冲区，100是随意给出的，只要大于通讯对端一次传输的数据量即可
	char buf[100];

	//首先将接受缓冲区清空，在正常、确定长度的数据传输中，这一步并不必要
	//但在字符串传输的演示中，还是需要清空的，以保证在串味没有乱字符出现
	memset(buf,0,100);
	//给用户一个提示，表示传输测试开始了，因为至少以今天的眼光看，串口速度还是很慢的
	printf("Serial port test begin ...!\n");
	//打开并设置发送端串口，后面的串口编号是在设备管理器中查询到的
	//在正式的系统中，这个串口通常会由用户在参数设置中修改
	//Uart是英文中对串口的另外一个称呼，serial port/com也是同义
	SetupUart(&h1,"com7");
	//打开并设置接收端串口
	SetupUart2(&h2,"com8");
	//在发送端口写出数据，也就是我们准备的字符串
	//串口通讯可以容纳的内容范围很广，不仅是字符串，所以使用unsigned char类型
	WriteUart((unsigned char*)msg,n,h1);
	//在接受端口读取数据，注意因为接收是阻塞式的，所以读取的长度要<=发送的数据包长度，
	//否则会让程序阻塞在这里一直等待读取
	ReadUart((unsigned char*)buf,n,h2);
	//显示接收到的数据内容
	printf("Loop received:%s",buf);
	//关闭两个打开的串口
	CloseUart2();
	CloseUart();

	return 0;
}
```
上面代码的注释非常详细，归纳串口操作的步骤为：  
1. 打开并设置串口。
2. 写入或者读取数据。  
3. 关闭串口。  

接下来看细节，也就是串口操作的部分：  
```cpp
//以下代码原型来自MSDN官方示例，为了保持原始代码的风格，尽量不做改动
//代码中有很多东西超出一般学习的范围，比如多线程的事件同步等，可以先大概了解即可
//对于不熟悉的代码，初期可以抄过来用，了解对外的API即可，有时间再去下功夫了解细节
#include "serialPort.h"

DCB            PortDCB; 
COMMTIMEOUTS   CommTimeouts; 
HANDLE         hPort1,hPort2;
char           lastError[1024];

//以下是一些端口设置使用的常量，在正常项目中应当也是归集于配置系统中的
//串口顾名思义是将数据串流化通讯，因此需要定义发送、接收方都完全相同的速度、位长、校验模式等
//另外因为我们只用了三根数据线，其它控制位的设置我们就省略掉了
//这些常量参数使用index*这样的方式是为了同传统界面上的各项设置做的对应，变量命名嘛，不用过于纠结。
int	index1=4,//9600
	index2=3,//8
	index3=2,//NOPARITY
	index4=0,//ONSTOPBIT
	index5=-1;
//打开并且设置串口
int SetupUart(HANDLE *hPort,char *port1)
{
	//打开串行端口，也是把端口当做一个文件来对待
	//对于新手，为什么用这个函数之类的问题，只能先死记了
	hPort1 = CreateFile (TEXT(port1),			            // Name of the port 
						GENERIC_READ | GENERIC_WRITE,     // Access (read-write) mode 
						0,                                  
						NULL,                             
						OPEN_EXISTING,
						FILE_ATTRIBUTE_NORMAL,                     
			            NULL);                             
             
	//打开失败就报个警并退出后续操作
	if ( hPort1 == INVALID_HANDLE_VALUE )
	{ 
		MessageBox (NULL, "Port Open Failed" ,"Error", MB_OK);
		return 0;
	}   
	*hPort = hPort1;
	  //读取当前串口的状态
      PortDCB.DCBlength = sizeof (DCB); 
      GetCommState (hPort1, &PortDCB);
	  //在当前串口状态的基础上设置串口速率等参数
	  configure();

	  //读取当前超时设置
	  GetCommTimeouts (hPort1, &CommTimeouts); 
	  //根据当前超时设置，设置自己期望的值
	  configuretimeout();
	
   

	//Re-configure the port with the new DCB structure. 
	//上面的configure只是设置了参数结构，下面函数才是真正将之设置到串口
	if (!SetCommState (hPort1, &PortDCB)) 
	{ 
        MessageBox (NULL, "1.Could not create the read thread.(SetCommState Failed)" ,"Error", MB_OK);
		CloseHandle(hPort1);   
		return 0; 
	 } 

	// Set the time-out parameters for all read and write operations on the port. 
	//同样设置configuretimeout输出的结果
	if (!SetCommTimeouts (hPort1, &CommTimeouts)) 
	{ 
        MessageBox (NULL, "Could not create the read thread.(SetCommTimeouts Failed)" ,"Error", MB_OK);
		CloseHandle(hPort1);  
		return 0; 
	} 

	// Clear the port of any existing data. 
	//如果串口还有以前通讯积累的未完结数据，清理掉
	if(PurgeComm(hPort1, PURGE_TXCLEAR | PURGE_RXCLEAR)==0) 
	{   MessageBox (NULL, "Clearing The Port Failed" ,"Message", MB_OK);
		CloseHandle(hPort1); 
		return 0; 
	} 
    
	//MessageBox (NULL, "Port1 SETUP OK." ,"Message", MB_OK);
	return 1;
}
//下面函数功能同上面的完全一样，其实设置一个函数就好，这里保持原状
int SetupUart2(HANDLE *hPort,char *port2)
{
	//int STOPBITS;

	hPort2 = CreateFile (TEXT(port2),				       // Name of the port 
						GENERIC_READ | GENERIC_WRITE,     // Access (read-write) mode 
						0,                                  
						NULL,                             
						OPEN_EXISTING,
						FILE_ATTRIBUTE_NORMAL,                     
			            NULL);                             
             
	if ( hPort2 == INVALID_HANDLE_VALUE ) 
	{ 
		
		MessageBox (NULL, "Port Open Failed" ,"Error", MB_OK);
		return 0;
	}
	*hPort = hPort2;
	
	 // Initialize the DCBlength member. 
     PortDCB.DCBlength = sizeof (DCB); 
      
      // Get the default port setting information.
      GetCommState (hPort2, &PortDCB);
	  configure();

	  // Retrieve the time-out parameters for all read and write operations  
	GetCommTimeouts (hPort2, &CommTimeouts);
	configuretimeout();

	//Re-configure the port with the new DCB structure. 
	if (!SetCommState (hPort2, &PortDCB)) 
	{ 
        MessageBox (NULL, "1.Could not create the read thread.(SetCommState Failed)" ,"Error", MB_OK);
		CloseHandle(hPort2);   
		return 0; 
	 } 
	
	// Set the time-out parameters for all read and write operations on the port. 
	if (!SetCommTimeouts (hPort2, &CommTimeouts)) 
	{ 
        MessageBox (NULL, "Could not create the read thread.(SetCommTimeouts Failed)" ,"Error", MB_OK);
		CloseHandle(hPort2);  
		return 0; 
	} 

	// Clear the port of any existing data. 
	if(PurgeComm(hPort2, PURGE_TXCLEAR | PURGE_RXCLEAR)==0) 
	{   MessageBox (NULL, "Clearing The Port Failed" ,"Message", MB_OK);
		CloseHandle(hPort2); 
		return 0; 
	} 
    
	//MessageBox (NULL, "Port2 SETUP OK." ,"Message", MB_OK);
	return 1;
}


//PortDCB是全局变量，这里根据读取到的端口状态，设置自己希望的通讯参数
int configure()
{
	// Change the DCB structure settings
	PortDCB.fBinary = TRUE;                         // Binary mode; no EOF check
	PortDCB.fParity = TRUE;                         // Enable parity checking 
	PortDCB.fDsrSensitivity = FALSE;                // DSR sensitivity 
	PortDCB.fErrorChar = FALSE;                     // Disable error replacement 
	PortDCB.fOutxDsrFlow = FALSE;                   // No DSR output flow control 
	PortDCB.fAbortOnError = FALSE;                  // Do not abort reads/writes on error
	PortDCB.fNull = FALSE;                          // Disable null stripping 
	PortDCB.fTXContinueOnXoff = TRUE;                // XOFF continues Tx 
	//设置波特率
	switch(index1)                                  // BAUD Rate
		{
		case 0:
			PortDCB.BaudRate= 115200;            
		break;
		case 1:
			PortDCB.BaudRate = 19200;            
		break;
		case 2:
			PortDCB.BaudRate= 38400;            
		break;
		case 3:
			 PortDCB.BaudRate = 57600;            
		break;
		case 4:
			 PortDCB.BaudRate = 9600;            
		break;
		default:
			break;
		}
		//设置通讯字节位长
		switch(index2)                                     // Number of bits/byte, 5-8 
		{
		case 0:
			PortDCB.ByteSize = 5;            
		break;
		case 1:
			PortDCB.ByteSize = 6;            
		break;
		case 2:
			PortDCB.ByteSize= 7;            
		break;
		case 3:
			PortDCB.ByteSize=8;            
		break;
		default:
			break;
		}
		//校验方式
		switch(index3)                                     // 0-4=no,odd,even,mark,space 
		{
		case 0:
			PortDCB.Parity= EVENPARITY;                
		break;
		case 1:
			 PortDCB.Parity = MARKPARITY;               
		break;
		case 2:
			  PortDCB.Parity = NOPARITY;                   
		break;
		case 3:
			 PortDCB.Parity = ODDPARITY;           
		break;
		case 4:
			 PortDCB.Parity = SPACEPARITY;           
		break;
		default:
			break;
		}
		//停止位
		switch(index4)                       
		{
		case 0:
			PortDCB.StopBits =  ONESTOPBIT;          
		break;
		case 1:
			PortDCB.StopBits =  TWOSTOPBITS;        
		break;
		
		default:
			break;
		}
		//是否使用硬件流控制等
		switch(index5)                       
		{
		case 0:
			PortDCB.fOutxCtsFlow = TRUE;                        // CTS output flow control 
			PortDCB.fDtrControl = DTR_CONTROL_ENABLE;           // DTR flow control type 
			PortDCB.fOutX = FALSE;                              // No XON/XOFF out flow control 
			PortDCB.fInX = FALSE;                               // No XON/XOFF in flow control 
			PortDCB.fRtsControl = RTS_CONTROL_ENABLE;           // RTS flow control 
			 
			
		break;
		case 1:
			PortDCB.fOutxCtsFlow = FALSE;                      // No CTS output flow control 
			PortDCB.fDtrControl = DTR_CONTROL_ENABLE;          // DTR flow control type 
			PortDCB.fOutX = FALSE;                             // No XON/XOFF out flow control 
			PortDCB.fInX = FALSE;                              // No XON/XOFF in flow control 
			PortDCB.fRtsControl = RTS_CONTROL_ENABLE;          // RTS flow control 
		break;
		case 2:
			PortDCB.fOutxCtsFlow = FALSE;                      // No CTS output flow control 
			PortDCB.fDtrControl = DTR_CONTROL_ENABLE;          // DTR flow control type 
			PortDCB.fOutX = TRUE;                              // Enable XON/XOFF out flow control 
			PortDCB.fInX = TRUE;                               // Enable XON/XOFF in flow control 
			PortDCB.fRtsControl = RTS_CONTROL_ENABLE;          // RTS flow control 
		break;
		
		default:
			break;
		}

	return 1;
}
int configuretimeout()
{	//超时设置，放置读写端口时时间过长程序挂起
	//memset(&CommTimeouts, 0x00, sizeof(CommTimeouts)); 
	CommTimeouts.ReadIntervalTimeout = 50; 
	CommTimeouts.ReadTotalTimeoutConstant = 50; 
	CommTimeouts.ReadTotalTimeoutMultiplier=10;
	CommTimeouts.WriteTotalTimeoutMultiplier=10;
	CommTimeouts.WriteTotalTimeoutConstant = 50; 
   return 1;
}
int WriteUart(unsigned char *buf1, int len,HANDLE hPort)
{
	DWORD dwNumBytesWritten;
	//使用写文件的方式向串口输出数据
	//因为串口芯片及驱动程序都有缓存，所以一般小数据量的写出都不会阻塞
	WriteFile (hPort,buf1, len,&dwNumBytesWritten,NULL);			

	if(dwNumBytesWritten > 0)
	{
		//MessageBox (NULL, "Transmission Success" ,"Success", MB_OK);
		return 1;
	}
	
	else 
	   {
		MessageBox (NULL, "Transmission Failed" ,"Error", MB_OK);
		return 0;	
	   }
}


int ReadUart(unsigned char *buf2,int len,HANDLE hPort)
{
	//BOOL ret;
	DWORD dwRead;
    BOOL fWaitingOnRead = FALSE;
    OVERLAPPED osReader = {0};
    unsigned long retlen=0;

   // Create the overlapped event. Must be closed before exiting to avoid a handle leak.
	//读取串口的时候，如果对方尚未发送指定长度的数据，会导致读取串口阻塞
	//这里使用线程同步的事件响应方式，防止读取数据阻塞
	//所以读取串口可能返回0表示没有读取到数据
	//或者小于期望读取的字节表示数据尚未完全到来
   osReader.hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
   if (osReader.hEvent == NULL)
       MessageBox (NULL, "Error in creating Overlapped event" ,"Error", MB_OK);
   if (!fWaitingOnRead)
   {
	   	//具体的读取数据
          if (!ReadFile(hPort, buf2, len, &dwRead,  &osReader)) 
          {
          FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                        NULL,
                        GetLastError(),
                        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
                        lastError,
                        1024,
                        NULL);
		   MessageBox (NULL, lastError ,"MESSAGE", MB_OK);
           }
           else
		   {
	         // MessageBox (NULL, "ReadFile Suceess" ,"Success", MB_OK);
           }
    }
	
	if(dwRead > 0)	
	{
		//MessageBox (NULL, "Read DATA Success" ,"Success", MB_OK);//If we have data
		return (int) retlen;
	}
	     //return the length
    
	else return 0;     //else no data has been read
 }

//关闭端口，同样有一个就够了
int CloseUart()
{
	CloseHandle(hPort1); 
	return 1;
}
int CloseUart2()
{
	CloseHandle(hPort2);
	return 1;
}
```
在串口的编程中，打开串口、读写串口、关闭串口都是通常的文件操作，也就是把串口当做一个文件的方式进行处理。  
只有串口的设置部分（本程序中是跟打开串口放在一起）是同传统文件操作不相同的。  
第二个不同则是，通常的硬盘文件读写，速度都很快，不需要考虑阻塞问题。而串口是非常慢的设备，需要考虑阻塞问题的额外处理。  
一般的初学者在这部分不需要太过纠结具体的过程，做到一般了解后。把良好运行的样本程序按照自己习惯封装、保存起来，用到的时候抄过来用即可。  






