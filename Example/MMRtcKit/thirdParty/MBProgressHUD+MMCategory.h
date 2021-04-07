//
//  MBProgressHUD+MMCategory.h
//  MMRtmKit_Example
//
//  Created by RunX on 2020/12/22.
//  Copyright © 2020 cf_olive@163.com. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

// 统一的显示时长
#define kHudShowTime 1.5

@interface MBProgressHUD (MMCategory)

#pragma mark - 在指定的view上显示hud
+ (void)mm_showMessage:(NSString *_Nullable)message toView:(UIView *_Nullable)view;
+ (void)mm_showSuccess:(NSString *_Nullable)success toView:(UIView *_Nullable)view;
+ (void)mm_showError:(NSString *_Nullable)error toView:(UIView *_Nullable)view;
+ (void)mm_showWarning:(NSString *_Nullable)Warning toView:(UIView *_Nullable)view;
+ (void)mm_showMessageWithImageName:(NSString *_Nullable)imageName message:(NSString *_Nullable)message toView:(UIView *_Nullable)view;
+ (MBProgressHUD *)mm_showActivityMessage:(NSString *_Nullable)message view:(UIView *_Nullable)view;
+ (MBProgressHUD *)mm_showProgressBarToView:(UIView *_Nullable)view;


#pragma mark - 在window上显示hud
+ (void)mm_showMessage:(NSString *_Nullable)message;
+ (void)mm_showSuccess:(NSString *_Nullable)success;
+ (void)mm_showError:(NSString *_Nullable)error;
+ (void)mm_showWarning:(NSString *_Nullable)Warning;
+ (void)mm_showMessageWithImageName:(NSString *_Nullable)imageName message:(NSString *_Nullable)message;
+ (MBProgressHUD *)mm_showActivityMessage:(NSString *_Nullable)message;


#pragma mark - 移除hud
+ (void)mm_hideHUDForView:(UIView *_Nullable)view;
+ (void)mm_hideHUD;

@end

NS_ASSUME_NONNULL_END
