
//
//  Created by max on 2020/12/8.
//  Copyright © 2020 max. All rights reserved.
//

#import "MMTools.h"
#import "MMHelperInstance.h"
//#import "MMAPPMacrosHeader.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@implementation MMTools

//获取当前屏幕顶层显示的viewcontroller。
+ (UIViewController *)getCurrentRootVC{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    if (window.subviews && window.subviews.count > 0) {
        UIView *frontView = [[window subviews] objectAtIndex:0];
        id nextResponder = [frontView nextResponder];
        
        if ([nextResponder isKindOfClass:[UIViewController class]])
            result = nextResponder;
        else
            result = window.rootViewController;
        
    }
    else {
        result = window.rootViewController;
    }

    
    return result;
}

+ (UIViewController *)getCurrentTopVC{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (true) {
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = [(UINavigationController *)vc visibleViewController];
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = [(UITabBarController *)vc selectedViewController];
        } else if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else {
            break;
        }
    }
    return vc;
}


+ (UIColor*)toUIColorByStr:(NSString*)colorStr{
    
    NSString *cString = [[colorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

//获取当前的太平洋时间
+ (NSString *)getPSTDate{
    NSDate *date = [NSDate date];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    NSInteger offset = [sourceTimeZone secondsFromGMTForDate:date];
    NSTimeInterval interval = (NSTimeInterval)offset;
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:date] ;
    NSString *str = [NSString stringWithFormat:@"%@",destinationDateNow];
    return str;
}

//获取当前系统的时区，例如GMT+8
+ (NSString *)getTimeZone{
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    if(zone.abbreviation){
        return zone.abbreviation;
    }
    return @"unknown";
}

//获取当前时间戳，例如1488164802.277952
+ (NSString *)getTimeStamp{
    NSString *time = [NSString stringWithFormat:@"%f",[NSDate date].timeIntervalSince1970];
    return time?time:@"unknown";
}

//获取当前毫秒时间戳
+ (NSString *)getTimeStampToMS{
    NSTimeInterval interval = ([NSDate date].timeIntervalSince1970) * 1000;
    NSString *time = [NSString stringWithFormat:@"%f",interval];
    NSArray *arr = [time componentsSeparatedByString:@"."];
    if (arr.count == 0) {
        return time?time:@"unknown";
    }
    NSString *timesta = [arr firstObject];
    return timesta?timesta:@"unknown";
}

//将任务提交到主线程执行
+ (void)performTaskOnMainThread:(void(^)(void))task{
    if (!task) {
        return;
    }
    if ([NSThread isMainThread]) {
        task();
    }
    else {
        dispatch_async(dispatch_get_main_queue(), task);
    }
}

//将任务提交到常驻线程执行
+ (void)performTaskOnFGThread:(void(^)(void))task{
    if (!task) {
        return;
    }
    if ([[NSThread currentThread].name isEqualToString:@"MMBackThread"]) {
        task();
    }
    else {
        [self performSelector:@selector(performTask:) onThread:[MMHelperInstance sharedHelper].back_thread withObject:task waitUntilDone:NO];
    }
}
+ (void)performTask:(void(^)(void))task{
    task();
}


+ (void)requestMicroPhoneAuth:(void(^)(AVAuthorizationStatus status))callback{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        [self performTaskOnMainThread:^{
            callback(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied);
        }];
    }];
}

+ (void)goToSetFromVC:(UIViewController *)vc title:(NSString *)title{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:@"去设置一下吧" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }];
    UIAlertAction * setAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {

            }];
        });
    }];

    [alert addAction:cancelAction];
    [alert addAction:setAction];
    [vc presentViewController:alert animated:YES completion:nil];
}


//验证ID类型数据合法性
//长度在 64 字节以内的字符串，以下为支持的字符集范围：
//26 个小写英文字母 a-z
//26 个大写英文字母 A-Z
//10 个数字 0-9
//"-", "_", "#", "=", "@", "."
+ (BOOL) validateIdTypeStr:(NSString *)idTypeStr{
    if (!idTypeStr || [idTypeStr isEqualToString:@""]) {
        return NO;
    }
    
    NSString *regex = @"^[A-Za-z0-9#=@,._-]*$";
    NSError *error;
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    if(error) return NO ;
    NSRange matchrange = [regular rangeOfFirstMatchInString:idTypeStr options:NSMatchingReportCompletion range:NSMakeRange(0, idTypeStr.length)];
    
    return (matchrange.length >0);
}



@end
