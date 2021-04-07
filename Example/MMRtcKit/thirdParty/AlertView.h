//
//  ExiuAlertView.h
//  ExiuComponent
//
//  Created by jiangzhan on 15/9/22.
//  Copyright © 2015年 Exiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
/**
 *  弹框组件，变化形势较多，使用方法见示例
 */
@interface AlertView : TPKeyboardAvoidingScrollView
@property (nonatomic, copy) void (^OKBlock)(AlertView *alertView);
@property (nonatomic, copy) void (^CancelBlock)(AlertView *alertView);
@property (nonatomic, retain) UIView *middleView;//middleView由调用者实现，默认为空
@property (nonatomic, strong) UIColor *themeColor;//支持主题色改变，默认车主端的颜色
@property (nonatomic, assign) BOOL touchBlankCanHide;//点击空白处是否可隐藏弹框，默认为NO
@property(nonatomic, assign) BOOL isShowCloseBtn;//是否限时关闭按钮

@property(nonatomic, assign) BOOL isShowTimeLabel;//是否显示倒计时时间


/**
 *  初始化一个弹框，类似系统弹框，如果某个参数不填则不会显示相应内容
 *
 *  @param title       标题，不填则无标题
 *  @param middleView     中部视图，不能为空，整个AlertView的宽度会根据middleView的宽度改变
 *  @param cancelTitle 取消标题，不能为空
 *  @param okTitle     确定标题，为空则没有确定按钮
 *
 *  @return 弹框实例
 */

- (id)initWithTitle:(NSString *)title middleView:(UIView *)middleView cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle;
/**
 *  初始化一个弹框，类似系统弹框，如果某个参数不填则不会显示相应内容
 *
 *  @param title       标题，不填则无标题
 *  @param message     内容，不能为空
 *  @param cancelTitle 取消标题，不能为空
 *  @param okTitle     确定标题，为空则没有确定按钮
 *
 *  @return 弹框实例
 */
- (id)initWithTitle:(NSString *)title message:(NSString*)message cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle;

//初始化一个打电话的弹框,phoneArray为电话的String数组
- (id)initTelephoneAlertView:(NSArray *)phoneArray;

/**
 *  与系统弹框一样，调用该方法进行展示
 */
-(void)show;

/**
 *  调用该方法隐藏该实例对象
 */
-(void)dismiss;

@end
