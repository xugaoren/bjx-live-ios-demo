//
//  ExiuAlertView.m
//  ExiuComponent
//
//  Created by jiangzhan on 15/9/22.
//  Copyright © 2015年 Exiu. All rights reserved.
//

#import "AlertView.h"
#import "Masonry.h"

#define topViewHight 44
#define middleViewHight 80
#define bottomViewHight 40

@interface AlertView()
{
    UIView *_containerView;
    UIButton *_tapBtn;//调整ExiuAlertView手为button
    UIView *_topView;
    UIView *_middleContainerView;
    UIView *_middleView;
    UIView *_bottomView;
    NSString *_title;
    NSString *_message;
    NSString *_cancelTitle;
    NSString *_okTitle;
    
    UIButton *_cancelButton;
    UIButton *_okButton;
    
    NSArray *_phoneArray;
    
    UIColor *_cacelBtnColor;//取消按钮颜色，根据主题色改变
    UIColor *_oKBtnColor;//确定按钮颜色，根据主题色改变
    
    UILabel *_timeLabel;//倒计时5s后弹框小时显示按钮
}

@property(nonatomic, strong) UIButton *closeBtn;

@end

@implementation AlertView
- (id)initWithTitle:(NSString *)title middleView:(UIView *)middleView cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _title = title;
        _middleView = middleView;
        _cancelTitle = cancelTitle;
        _okTitle = okTitle;
        _message = nil;
        [self _setUpFrame];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString*)message cancelTitle:(NSString *)cancelTitle okTitle:(NSString *)okTitle{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _title = title;
        _middleView = nil;
        _cancelTitle = cancelTitle;
        _okTitle = okTitle;
        _message = message;
        [self _setUpFrame];

    }
    return self;
}


- (id)initTelephoneAlertView:(NSArray *)phoneArray{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        _phoneArray = phoneArray;
        [self _setUpTelePhoneAlertView];
        
    }
    return self;
}

- (void)_setUpTelePhoneAlertView{
    if (_phoneArray && [_phoneArray count] > 0) {
        UIView *phoneView = [[UIView alloc] initWithFrame:CGRectMake(0,0, [[UIScreen mainScreen]bounds].size.width*0.6, _phoneArray.count*40+30)];
        phoneView.backgroundColor = [UIColor whiteColor];
        for (NSString *phone in _phoneArray) {
            NSInteger index = [_phoneArray indexOfObject:phone];
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(15, index*40+15, phoneView.bounds.size.width-15, 40);
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [btn setTitle:phone forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(_phoneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [phoneView addSubview:btn];
            
        }
        _title = @"联系方式";
        _middleView = phoneView;
        _touchBlankCanHide = YES;
        [self _setUpFrame];
    }
}

- (void)setThemeColor:(UIColor *)themeColor{
    _themeColor = themeColor;
    if (themeColor) {
//        if ([self _isTheSameColor2:themeColor anotherColor:[UIColor colorWithHexString:@"#D8232C"]]) {//配件商
//            _cacelBtnColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
//            _oKBtnColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
//
//        }
//        if ([self _isTheSameColor2:themeColor anotherColor:[UIColor colorWithHexString:@"#F5651B"]]) {//车主端
//            _cacelBtnColor = [UIColor colorWithRed:240/255.0f green:170/255.0f blue:24/255.0f alpha:1.0f];
//            _oKBtnColor = [UIColor colorWithRed:238/255.0f green:91/255.0f blue:23/255.0f alpha:1.0f];
//        }
//        if ([self _isTheSameColor2:themeColor anotherColor:[UIColor colorWithHexString:@"#0F77CC"]]) {//专家端
//            _cacelBtnColor = [UIColor colorWithRed:240/255.0f green:170/255.0f blue:24/255.0f alpha:1.0f];
//            _oKBtnColor = [UIColor colorWithRed:238/255.0f green:91/255.0f blue:23/255.0f alpha:1.0f];
//
//        }
//        if ([self _isTheSameColor2:themeColor anotherColor:[UIColor colorWithHexString:@"#5EBD2D"]]) {//维修厂
//            _cacelBtnColor = [UIColor colorWithRed:240/255.0f green:170/255.0f blue:24/255.0f alpha:1.0f];
//            _oKBtnColor = [UIColor colorWithRed:238/255.0f green:91/255.0f blue:23/255.0f alpha:1.0f];
//
//        }
        //取消和确定按钮颜色，新版全为灰色
        _cacelBtnColor = OX_COLOR(0xffffff);
        _oKBtnColor = OX_COLOR(0xffffff);

        if (_topView) {
            _topView.backgroundColor = _themeColor;
        }
        if (_cancelButton) {
            _cancelButton.backgroundColor = _cacelBtnColor;
        }
        if (_okButton) {
            _okButton.backgroundColor = _oKBtnColor;
        }

    }
}

- (BOOL)_isTheSameColor2:(UIColor*)color1 anotherColor:(UIColor*)color2
  {
      if (CGColorEqualToColor(color1.CGColor, color2.CGColor)) {
          return YES;
      }
      else {
          return NO;
      }
}

#pragma mark - 关闭按钮
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"photo_del"] forState:UIControlStateNormal];
        _closeBtn.hidden = YES;
        [_closeBtn addTarget:self action:@selector(clickDismis) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)setIsShowCloseBtn:(BOOL)isShowCloseBtn {
    _isShowCloseBtn = isShowCloseBtn;
    self.closeBtn.hidden = isShowCloseBtn;
}

- (void)clickDismis {
    if(self && self.superview)
    {
        [self dismiss];
    }
}

- (void)setIsShowTimeLabel:(BOOL)isShowTimeLabel {
    _isShowTimeLabel = isShowTimeLabel;
    if (isShowTimeLabel) {
        _timeLabel.hidden = NO;
//        [DFHelper timeoutWithlabel:_timeLabel time:5];
    }else {
        _timeLabel.hidden = YES;
    }
}

- (void)_setUpFrame{
    _themeColor =  OX_COLOR(0xffffff);
    //取消和确定按钮颜色，新版全为灰色
    _cacelBtnColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0f];
    _oKBtnColor = OX_COLOR(0x3F73FE);
    self.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0.7f];
    _tapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _tapBtn.frame = [[UIScreen mainScreen] bounds];
    [_tapBtn setBackgroundColor:[UIColor clearColor]];
    [_tapBtn addTarget:self action:@selector(_backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_tapBtn];
    
    float alertWidth = 270;
    
    if (_middleView) {
        alertWidth = _middleView.bounds.size.width;
    }
    _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertWidth, 300)];
    
    if (_title != nil) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, alertWidth, topViewHight)];
        UILabel *label = [[UILabel alloc] initWithFrame:_topView.bounds];
        label.text = _title;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = OX_COLOR(0x333333);
        [_topView addSubview:label];
        [_containerView addSubview:_topView];
        _topView.backgroundColor = _themeColor;
        
        [_topView addSubview:self.closeBtn];
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_topView.mas_right).offset(6.0f);
            make.bottom.mas_equalTo(_topView.mas_top).offset(23.0f);
            make.size.mas_equalTo(CGSizeMake(30.0f, 30.0f));
        }];
        
    }
    if (_topView) {
        _middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,topViewHight, alertWidth, middleViewHight)];
    }else{
        _middleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, alertWidth, middleViewHight)];
    }
    if (_middleView != nil) {
        CGRect rect1 = _middleView.frame;
        rect1.origin.x = 0;
        rect1.origin.y = _title?topViewHight:0;
        _middleContainerView.frame = rect1;
        rect1.origin.y = 0;
        rect1.origin.x = 0;
        _middleView.frame = rect1;
        [_middleContainerView addSubview:_middleView];
        [_containerView addSubview:_middleContainerView];
    }else{
        if (_message != nil && _middleView == nil) {
            CGRect mesRect =[_message boundingRectWithSize:CGSizeMake(alertWidth-20, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:19]} context:nil];
            CGRect rect = CGRectMake(10, 10, mesRect.size.width, mesRect.size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:rect];
            label.text = _message;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:15.0f];
            label.textColor = [UIColor darkGrayColor];
            label.numberOfLines = mesRect.size.height/15;
            [_middleContainerView addSubview:label];
            if (mesRect.size.height > middleViewHight) {
                CGRect tempRect = _middleContainerView.frame;
                tempRect.size.height = mesRect.size.height;
                _middleContainerView.frame = tempRect;
            }
            rect.origin.x = (_middleContainerView.bounds.size.width-rect.size.width)/2.0f;
            rect.origin.y = (_middleContainerView.bounds.size.height-rect.size.height)/2.0f;
            label.frame = rect;
            _middleContainerView.backgroundColor = [UIColor whiteColor];
            [_containerView addSubview:_middleContainerView];
        }
    }
    
    float height = 0;
    if (_topView) {
        height += _topView.bounds.size.height;
    }
    if (_middleContainerView) {
        height += _middleContainerView.bounds.size.height;
    }
    
    if (_cancelTitle != nil ) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height, alertWidth, bottomViewHight)];
        _bottomView.backgroundColor = OX_COLOR(0xf0f0f0);
        if (_okTitle != nil) {
            _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _cancelButton.frame = CGRectMake(0, 1, alertWidth/2.0f-0.5, _bottomView.bounds.size.height-1);
            _cancelButton.backgroundColor = OX_COLOR(0xffffff);
            [_cancelButton setTitle:_cancelTitle forState:UIControlStateNormal];
            [_cancelButton setTitleColor:OX_COLOR(0x666666) forState:UIControlStateNormal];
            [_cancelButton setTitleColor:OX_COLOR(0x666666) forState:UIControlStateHighlighted];
            _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
            [_cancelButton addTarget:self action:@selector(_cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            _okButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _okButton.frame = CGRectMake(alertWidth/2.0f+0.5, 1, _bottomView.bounds.size.width/2.0f-0.5, _bottomView.bounds.size.height-1);
            _okButton.backgroundColor = OX_COLOR(0xffffff);
            [_okButton setTitle:_okTitle forState:UIControlStateNormal];
            [_okButton setTitleColor: OX_COLOR(0x3F73FE) forState:UIControlStateNormal];
            [_okButton setTitleColor: OX_COLOR(0x3F73FE) forState:UIControlStateHighlighted];
            [_okButton addTarget:self action:@selector(_okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            _okButton.titleLabel.font = [UIFont systemFontOfSize:17];
            [_bottomView addSubview:_cancelButton];
            [_bottomView addSubview:_okButton];


        }else{
            _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _cancelButton.frame = CGRectMake(0, 0, _bottomView.bounds.size.width, _bottomView.bounds.size.height);
            _cancelButton.backgroundColor = OX_COLOR(0xffffff);
            [_cancelButton setTitle:_cancelTitle forState:UIControlStateNormal];
            [_cancelButton setTitleColor:OX_COLOR(0x666666) forState:UIControlStateNormal];
            [_cancelButton setTitleColor:OX_COLOR(0x666666) forState:UIControlStateHighlighted];
            _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
            [_cancelButton addTarget:self action:@selector(_cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:_cancelButton];

        }
    }
    _timeLabel = [UILabel new];
    _timeLabel.hidden = YES;
    _timeLabel.textColor = OX_COLOR(0x333333);
    _timeLabel.userInteractionEnabled = NO;
    _timeLabel.backgroundColor = OX_COLOR(0xffffff);
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:14.0f];
    [_bottomView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(_bottomView);
    }];
    [_containerView addSubview:_bottomView];
    
    
    if (_topView) {
        //添加圆角
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_topView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _topView.bounds;
        maskLayer.path = maskPath.CGPath;
        _topView.layer.mask = maskLayer;
        _topView.clipsToBounds = YES;
    }else{
        //添加圆角
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_middleContainerView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _middleContainerView.bounds;
        maskLayer.path = maskPath.CGPath;
        _middleContainerView.layer.mask = maskLayer;
        _middleContainerView.clipsToBounds = YES;
    }
    if (_bottomView) {
        UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:_bottomView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
        maskLayer1.frame = _bottomView.bounds;
        maskLayer1.path = maskPath1.CGPath;
        _bottomView.layer.mask = maskLayer1;
        _bottomView.clipsToBounds = YES;

    }else{
        if (_middleContainerView) {
            UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:_middleContainerView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
            CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
            maskLayer1.frame = _middleContainerView.bounds;
            maskLayer1.path = maskPath1.CGPath;
            _middleContainerView.layer.mask = maskLayer1;
            _middleContainerView.clipsToBounds = YES;
        }
    }
    
    CGRect containerRect = _containerView.frame;
    containerRect.size.height = 0;
    if (_topView) {
        containerRect.size.height += _topView.frame.size.height;
    }
    if (_middleContainerView) {
        containerRect.size.height += _middleContainerView.frame.size.height;
    }
    if (_bottomView) {
        containerRect.size.height += _bottomView.frame.size.height;
    }
    _containerView.frame = containerRect;
    
    _containerView.center = self.center;
    
    [self addSubview:_containerView];
}

- (void)_cancelButtonClick:(UIButton *)button{
    if (self.CancelBlock) {
        self.CancelBlock(self);
    }
    if(self && self.superview)
    {
        [self dismiss];
    }
}

- (void)_okButtonClick:(UIButton *)button{
    if (self.OKBlock) {
        self.OKBlock(self);
    }
}


- (void)_phoneButtonClick:(UIButton *)button{
    
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",button.titleLabel.text];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

}

- (void)_backBtnClick:(UIButton *)btn{
    if (_touchBlankCanHide) {
        [self dismiss];
    }
}

-(void)show{
    UIViewController *currentVC = [self getCurrentVC];
    [currentVC.view addSubview:self];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_containerView.layer addAnimation:popAnimation forKey:nil];
}

- (void)shakeAlertView
{
    //shaking the self.view
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
    [shake setDuration:0.1];
    [shake setRepeatCount:2];
    [shake setAutoreverses:YES];
    [shake setFromValue:[NSValue valueWithCGPoint:
                         CGPointMake(self.center.x - 5,self.center.y)]];
    [shake setToValue:[NSValue valueWithCGPoint:
                       CGPointMake(self.center.x + 5, self.center.y)]];
    [self.layer addAnimation:shake forKey:@"position"];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}


-(void)dismiss{
    if (self && self.superview) {
        
        
        
        [self removeFromSuperview];
    }
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}


/*
 返回当前VC
 */
- (UIViewController *)getCurrentVC {
    //获得当前活动窗口的根视图
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        //根据不同的页面切换方式，逐步取得最上层的viewController
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
@end
