//
//
//  Created by max on 2020/12/8.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MMTools : NSObject

//获取当前rootViewController
+ (UIViewController *)getCurrentRootVC;

//获取当前最顶层的vc
+ (UIViewController *)getCurrentTopVC;

//从16进制字符串获取颜色
+ (UIColor*)toUIColorByStr:(NSString*)colorStr;

//获取当前的太平洋时间
+ (NSString *)getPSTDate;

//获取当前时区
+ (NSString *)getTimeZone;

//获取当前时间戳，例如1488164802.277952
+ (NSString *)getTimeStamp;

//获取当前毫秒时间戳
+ (NSString *)getTimeStampToMS;


//将任务提交到主线程执行
+ (void)performTaskOnMainThread:(void(^)(void))task;

//将任务提交到常驻线程执行
+ (void)performTaskOnFGThread:(void(^)(void))task;

//验证ID类型数据合法性
//长度在 64 字节以内的字符串，以下为支持的字符集范围：
//26 个小写英文字母 a-z
//26 个大写英文字母 A-Z
//10 个数字 0-9
//"-", "_", "#", "=", "@", "."
+ (BOOL) validateIdTypeStr:(NSString *)idTypeStr;

@end


