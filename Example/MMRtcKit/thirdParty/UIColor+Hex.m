//
//  UIColor+Hex.m
//  zuhaowan
//
//  Created by chenhui on 2018/3/21.
//  Copyright © 2018年 chenhui. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)
+ (UIColor *)colorWithHex:(unsigned long)col
{
    unsigned char r, g, b;
    b = col & 0xFF;
    
    g = (col >> 8) & 0xFF;
    
    r = (col >> 16) & 0xFF;
    
    return [UIColor colorWithRed:(double)r / 255.0f green:(double)g / 255.0f blue:(double)b / 255.0f alpha:1];
}
@end
