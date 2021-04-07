//
//  MBProgressHUD+MMCategory.m
//  MMRtmKit_Example
//
//  Created by RunX on 2020/12/22.
//  Copyright © 2020 cf_olive@163.com. All rights reserved.
//

#import "MBProgressHUD+MMCategory.h"

@implementation MBProgressHUD (MMCategory)

#pragma mark - 在指定的view上显示hud
#pragma mark 显示一条信息
+ (void)mm_showMessage:(NSString *_Nullable)message toView:(UIView *_Nullable)view{
    [self mm_show:message icon:nil view:view];
}

#pragma mark 显示带图片或者不带图片的信息
+ (void)mm_show:(NSString *_Nullable)text icon:(NSString *_Nullable)icon view:(UIView *_Nullable)view{
    if (view == nil) view = [UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 判断是否显示图片
    if (icon == nil) {
        hud.mode = MBProgressHUDModeText;
    }else{
        // 设置图片
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]];
        img = img == nil ? [UIImage imageNamed:icon] : img;
        hud.customView = [[UIImageView alloc] initWithImage:img];
        // 再设置模式
        hud.mode = MBProgressHUDModeCustomView;
    }
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 指定时间之后再消失
    [hud hideAnimated:YES afterDelay:kHudShowTime];
}

#pragma mark 显示成功信息
+ (void)mm_showSuccess:(NSString *_Nullable)success toView:(UIView *_Nullable)view{
    [self mm_show:success icon:@"success.png" view:view];
}

#pragma mark 显示错误信息
+ (void)mm_showError:(NSString *_Nullable)error toView:(UIView *_Nullable)view{
    [self mm_show:error icon:@"error.png" view:view];
}

#pragma mark 显示警告信息
+ (void)mm_showWarning:(NSString *_Nullable)Warning toView:(UIView *_Nullable)view{
    [self mm_show:Warning icon:@"warn" view:view];
}

#pragma mark 显示自定义图片信息
+ (void)mm_showMessageWithImageName:(NSString *_Nullable)imageName message:(NSString *_Nullable)message toView:(UIView *_Nullable)view{
    [self mm_show:message icon:imageName view:view];
}

#pragma mark 加载中
+ (MBProgressHUD *)mm_showActivityMessage:(NSString *_Nullable)message view:(UIView *_Nullable)view{
    if (view == nil) view = [UIApplication sharedApplication].delegate.window;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 细节文字
    //    hud.detailsLabelText = @"请耐心等待";
    // 再设置模式
    hud.mode = MBProgressHUDModeIndeterminate;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

+ (MBProgressHUD *)mm_showProgressBarToView:(UIView *_Nullable)view{
    if (view == nil) view = [UIApplication sharedApplication].delegate.window;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"加载中...";
    return hud;
}

#pragma mark - 在window上显示hud

+ (void)mm_showMessage:(NSString *_Nullable)message{
    [self mm_showMessage:message toView:nil];
}

+ (void)mm_showSuccess:(NSString *_Nullable)success{
    [self mm_showSuccess:success toView:nil];
}

+ (void)mm_showError:(NSString *_Nullable)error{
    [self mm_showError:error toView:nil];
}

+ (void)mm_showWarning:(NSString *_Nullable)Warning{
    [self mm_showWarning:Warning toView:nil];
}

+ (void)mm_showMessageWithImageName:(NSString *_Nullable)imageName message:(NSString *_Nullable)message{
    [self mm_showMessageWithImageName:imageName message:message toView:nil];
}

+ (MBProgressHUD *)mm_showActivityMessage:(NSString *_Nullable)message{
    return [self mm_showActivityMessage:message view:nil];
}

#pragma mark - hide
+ (void)mm_hideHUDForView:(UIView *_Nullable)view{
    if (view == nil) view = [UIApplication sharedApplication].delegate.window;
    [self hideHUDForView:view animated:YES];
}

+ (void)mm_hideHUD{
    [self mm_hideHUDForView:nil];
}

@end
