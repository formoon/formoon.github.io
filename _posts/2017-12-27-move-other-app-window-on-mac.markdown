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
	for (NSMutableDictionary* entry in arr){
		if (entry == nil){
			break;
		}
		NSLog(@"enter:%@",entry);
		NSString *wndName=[entry objectForKey:(id)kCGWindowName];
		NSInteger wndNumber=[[entry objectForKey:(id)kCGWindowNumber] intValue];
		NSLog(@"wndName:%@ number:%ld",wndName,wndNumber);
		if (![wndName isEqualToString: @"~/test.txt"]){
			//不是自己想要的窗口继续下一个循环
			continue;
		}
		//下面这个方法是手册中最先查到的，但仅对属于自己app的窗口有效，其它app的窗口无效，所以不能采用
		//NSWindow * wind=[NSApp windowWithWindowNumber: wndNumber];
		//NSLog(@"wnd:%@",wind);
		CGRect bounds;
	    CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[entry objectForKey:@"kCGWindowBounds"], &bounds);
	    NSLog(@"bounds: %@",NSStringFromRect(bounds));   
		//根据pid获取窗口所属的app
        pid_t pid = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
        AXUIElementRef appRef = AXUIElementCreateApplication(pid);
        NSLog(@"Ref = %@",appRef);
		//获取app所有的窗口
        CFArrayRef windowList;
        AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute, (CFTypeRef *)&windowList);
        //NSLog(@"WindowList = %@", windowList);
		CFRelease(appRef);
		if (!windowList){
			//NSLog(@"windowList is nil");
			continue;
		}
		for (int i=0;i<CFArrayGetCount(windowList);i++){
			//遍历app所有窗口，查找跟全局遍历所获得窗口的实体
			AXUIElementRef windowRef = (AXUIElementRef) CFArrayGetValueAtIndex( windowList, i);
			NSLog(@"windowRef:%@",windowRef);
			CGWindowID application_window_id = 0;
			_AXUIElementGetWindow(windowRef, &application_window_id);
			if (application_window_id == wndNumber){
				//找到
				NSLog(@"Found a wnd that number is:%u",application_window_id);
				//根据需要来操作窗口的位置，仅用作示例，这里可以修改成其它操作
	            CFTypeRef position;
	            CGPoint newPoint;
	            newPoint.x = 0;
	            newPoint.y = 0;
	            NSLog(@"Create new position");
	            position = (CFTypeRef)(AXValueCreate(kAXValueCGPointType, (const void *)&newPoint));
				//setting new position
				AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute, position);
			}
			CFRelease(windowRef);
		}
	 NSLog(@"end a loop ----------------------------");
	} //for windowListAll
	} //autorelease
}

int main(int argc, char **argv){
	getTitleList1();	//第一种方法，重点在遍历
	getTitleList2();	//第二种方法，重点在获取窗口后可以进一步控制

	return 0;	
}
```
重点的内容直接看注释，其中的第二种方法可控性要好很多，不过程序也复杂一些。大概流程是先遍历所有屏幕的窗口->然后根据窗口获取该窗口所属的应用->再次获取应用所属的所有窗口->在这些窗口中找到自己想要的->控制，第二步的确做的会有大量重复遍历，不过从提供的api上看，目前只有这个办法才能够控制窗口。代码中有大量的日志信息，正式使用的话调试完成可以删掉。  
这段代码使用object-c和c混编，后缀为.m,因为只是测试代码，没有建立xcode项目，是在命令行编译的，编译方法可能有的人不太熟悉，也贴出来：  
```bash
clang -fobjc-arc  -o wndjob wndjob.m -framework CoreGraphics -framework AppKit
```

参考链接：  
<https://www.labnol.org/software/resize-mac-windows-to-specific-size/28345/>  
<https://stackoverflow.com/questions/8898430/close-all-windows-of-another-app-using-accessibility-api>  
<https://stackoverflow.com/questions/21069066/move-other-windows-on-mac-os-x-using-accessibility-api>  
