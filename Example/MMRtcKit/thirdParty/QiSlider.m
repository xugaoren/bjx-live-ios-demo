//
//  QiSlider.m
//  QiSlider
//
//  Created by QiShare on 2018/7/31.
//  Copyright © 2018年 QiShare. All rights reserved.
//

#import "QiSlider.h"

@interface QiSlider ()


/*! @brief 显示value的label */
@property (nonatomic, strong) UILabel *valueLabel;
@end

@implementation QiSlider

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self addTarget:self action:@selector(sliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - Overwrite functions

- (CGRect)trackRectForBounds:(CGRect)bounds {
    /*! @brief 重写方法-返回进度条的bounds-修改进度条的高度 */
    bounds = [super trackRectForBounds:bounds];
    return CGRectMake(bounds.origin.x, bounds.origin.y + (bounds.size.height - 3.0) / 2, bounds.size.width, 3.0);
}

- (void)setValue:(float)value animated:(BOOL)animated {
    
    [super setValue:value animated:animated];
    [self sliderValueChanged:self];
}

- (void)setValue:(float)value {
    [super setValue:value];
    [self sliderValueChanged:self];
    
}

#pragma mark - Setter functions

- (void)setValueText:(NSString *)valueText {
    _valueText = valueText;
    
    self.valueLabel.text = valueText;
    [self.valueLabel sizeToFit];
    self.valueLabel.center = CGPointMake(self.thumbView.bounds.size.width / 2, -self.valueLabel.bounds.size.height / 2);
    
    if (!self.valueLabel.superview) {
        if (self.showNum !=nil &&[self.showNum isEqualToString:@"yes"]) {
            [self.thumbView addSubview:self.valueLabel];
        }
        
        if (self.Numvertical!=nil &&[self.Numvertical isEqualToString:@"yes"]) {
            self.valueLabel.transform = CGAffineTransformMakeRotation(90*M_PI/180);
        }
    }
}

#pragma mark - Getter functions

- (UIView *)thumbView {
    
    if (!_thumbView && self.subviews.count > 2) {
        _thumbView = self.subviews[2];
    }
    
    _valueLabel.center = CGPointMake(_thumbView.bounds.size.width / 2, -_valueLabel.bounds.size.height / 2);
    return _thumbView;
}

- (UILabel *)valueLabel {
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textColor = _valueTextColor ?: self.thumbTintColor;
        _valueLabel.font = _valueFont ?: [UIFont systemFontOfSize:14.0];
        _valueLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _valueLabel;
}


#pragma mark - Action functions

- (void)sliderTouchDown:(QiSlider *)sender {
    
    if (_touchDown) {
        _touchDown(sender);
    }
}

- (void)sliderValueChanged:(QiSlider *)sender {
    
    if (_valueChanged) {
        _valueChanged(sender);
    } else {
    }
//    NSString *strValue =[NSString stringWithFormat:@"%ld", (long)sender.value];
    
    
    if (self.leftOrRight !=nil &&[self.leftOrRight isEqualToString:@"left"]) {
        if (self.showNum !=nil &&[self.showNum isEqualToString:@"yes"]) {
            sender.valueText =[NSString stringWithFormat:@"%ld",100- (long)sender.value];
        }else if (self.showNum !=nil &&[self.showNum isEqualToString:@"no"]) {
            sender.valueText =[NSString stringWithFormat:@"%ld%%",100- (long)sender.value];
        }
    }else if (self.leftOrRight !=nil &&[self.leftOrRight isEqualToString:@"right"]){
        if (self.showNum !=nil &&[self.showNum isEqualToString:@"yes"]) {
            sender.valueText=[NSString stringWithFormat:@"%ld", (long)sender.value];
        }else if (self.showNum !=nil &&[self.showNum isEqualToString:@"no"]) {
            sender.valueText=[NSString stringWithFormat:@"%ld%%", (long)sender.value];
        }
    }
}

- (void)sliderTouchUpInside:(QiSlider *)sender {
    
    if (_touchUpInside) {
        _touchUpInside(sender);
    }
}


#pragma mark -

- (void)dealloc {
    
    NSLog(@"%s", __FUNCTION__);
}

@end
