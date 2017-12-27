---
layout:         page
title:          两种方法操作其它mac应用的窗口
subtitle:       Object-c Manager other application's window
card-image:     http://p9.pstatp.com/origin/16880003de1c4ef5ae0c
date:           2017-12-27
tags:           mac
post-card-type: image
---
![](http://p9.pstatp.com/origin/16880003de1c4ef5ae0c)（图文基本无关）  
如果单纯说简单方便，其使用AppleScript更好，特别是现在有了JS的加入，比如：
```applescript
(*

This Apple script will resize any program window to an exact size and the window is then moved to the center of your screen.
Specify the program name, height and width below and run the script.

Written by Amit Agarwal on December 10, 2013

*)

set theApp to "Google Chrome"
set appHeight to 1080
set appWidth to 1920

tell application "Finder"
	set screenResolution to bounds of window of desktop
end tell

set screenWidth to item 3 of screenResolution
set screenHeight to item 4 of screenResolution

tell application theApp
	activate
	reopen
	set yAxis to (screenHeight - appHeight) / 2 as integer
	set xAxis to (screenWidth - appWidth) / 2 as integer
	set the bounds of the first window to {xAxis, yAxis, appWidth + xAxis, appHeight + yAxis}
end tell
```
觉得增加脚本会让你的工程比较繁琐的话，还可以把脚本写入到object-c用对象调用的方法完成,比如：
```c
NSApplescript * as = [[NSApplescript alloc] initWithSource:@"tell application \"TheApplication\"\nclose every window\nend tell"];
NSDictionary * errInfo;
NSAppleEventDescriptor * res = [as executeAndReturnError:&err];
if( !res ){
    // An error occurred. Inspect errInfo and perform necessary actions
}

[as release];
```
但是如果真的开发一个产品，使用纯的c/object-c还是更规范、可控一些，因此上面这个两个脚本的方法不算在内。闲话不说，直接贴代码：
```c
#include <stdio.h>

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import <CoreGraphics/CoreGraphics.h>

typedef int CGSConnection;
extern CGSConnection _CGSDefaultConnection(void);
extern CGError CGSCopyWindowProperty(const CGSConnection cid, NSInteger wid, CFStringRef key, CFStringRef *output);

void getTitleList1(){
	CFStringRef titleValue;
	CGSConnection connection = CGSDefaultConnectionForThread();
	NSInteger windowCount, *windows;
	char cTitle[256] = {0};
	
	NSCountWindows(&windowCount);
	windows = (NSInteger*) malloc(windowCount * sizeof(NSInteger));
	if (windows) {
	    NSWindowList(windowCount, windows);
	    for (int i = 0; i < windowCount; ++i)
	    {
	        CGSCopyWindowProperty(connection, windows[i], CFSTR("kCGSWindowTitle"), &titleValue);
	        if(!titleValue) //Not every window has a title
	            continue;

			//CFStringGetCString(titleValue,cTitle,127,kCFStringEncodingMacRoman);
			CFStringGetCString(titleValue,cTitle,256,kCFStringEncodingUTF8);
			printf("title: %s\n",cTitle);
	    }
	    free(windows);
	}
}

void getTitleList2(){
    @autoreleasepool {
     // Get all the windows
     CFArrayRef windowListAll = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
     NSArray* arr = CFBridgingRelease(windowListAll);
	 NSUInteger count = [arr count]; //CFArrayGetCount(arr);
     // Loop through the windows
     //for (NSMutableDictionary* entry in arr)		//可以直接使用这种面向对象的循环方法，下面采用传统的c语言for循环只是当时调试方便
	 NSLog(@"count:%lu",count);
     for (int i=0;i < count;i++){
		 NSLog(@"entry i:%d",i);
         NSMutableDictionary *entry = arr[i];
		 if (entry == nil){
			 break;
		 }
		 //NSLog(@"enter:%@",entry);
         // Get window PID
         pid_t pid = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
         // Get AXUIElement using PID
         AXUIElementRef appRef = AXUIElementCreateApplication(pid);
         NSLog(@"Ref = %@",appRef);

         // 再次获得该应用的窗口列表，其实跟获取全部窗口列表是重复的，只是为了更多的控制功能
         CFArrayRef windowList;
         AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *)&windowList);
         NSLog(@"WindowList = %@", windowList);
		 CFRelease(appRef);

		 if (!windowList){
			 NSLog(@"windowList is nil");
             continue;
		 }
         if (CFArrayGetCount(windowList)<1){
			 NSLog(@"No windowList");
			 CFRelease(windowList);
             continue;
         }
		 
		 NSString *appTitle = nil;
         AXUIElementCopyAttributeValue(appRef, kAXTitleAttribute, (void *)&appTitle);
         if (!appTitle) {
		     continue;
		 }
         NSLog(@"appTitle = %@", appTitle);
					 
         //只取该应用的第一个窗口
         AXUIElementRef windowRef = (AXUIElementRef) CFArrayGetValueAtIndex( windowList, 0);
		 NSLog(@"windowRef:%@",windowRef);

         CFTypeRef position;
         CGPoint point;

         // Get the position attribute of the window (maybe something is wrong?)
         AXUIElementCopyAttributeValue(windowRef, kAXPositionAttribute, (CFTypeRef *)&position);
         AXValueGetValue(position, kAXValueCGPointType, &point);
		 CFRelease(position);
         // Debugging (always zeros?)
         NSLog(@"point=%f,%f", point.x,point.y);   //当前的坐标
         // Create a point
         CGPoint newPoint;
         newPoint.x = 0;
         newPoint.y = 0;
         NSLog(@"Create new position");
         position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&newPoint));
         // 尝试设置新坐标,注意这会将遍历到的所有窗口都放到屏幕左上角
         //NSLog(@"SetAttribute");
         AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, position);
         sleep(5);
		 CFRelease(position);
		 CFRelease(windowRef);
		 NSLog(@"end a loop ----------------------------");
     }
	 }
 }

int main(int argc, char **argv){
	getTitleList1();	//第一种方法，重点在遍历
	getTitleList2();	//第二种方法，重点在获取窗口后可以进一步控制

	return 0;	
}
```
重点的内容直接看注释，其中的第二种方法可控性要好很多，不过程序也复杂一些。大概流程是先遍历所有屏幕的窗口->然后根据窗口获取该窗口所属的应用->再次获取应用所属的窗口->控制，第二部的确做的重复了，不过从提供的api上这样才能够控制窗口。  
这段代码使用object-c和c混编，后缀为.m,因为只是测试代码，没有建立xcode项目，是在命令行编译的，编译方法可能有的人不太熟悉，也贴出来：  
```bash
clang -fobjc-arc  -o sdljob sdljob.m -framework CoreGraphics -framework AppKit
```

参考链接：  
<https://www.labnol.org/software/resize-mac-windows-to-specific-size/28345/>  
<https://stackoverflow.com/questions/8898430/close-all-windows-of-another-app-using-accessibility-api>  
<https://stackoverflow.com/questions/21069066/move-other-windows-on-mac-os-x-using-accessibility-api>  
