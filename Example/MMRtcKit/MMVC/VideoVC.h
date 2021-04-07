//
//  VideoVC.h
//  MMRtcKit_Example
//
//  Created by RunX on 2020/12/30.
//  Copyright © 2020 cf_olive@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoVC : UIViewController

@property (nonatomic, copy) NSString *channelId;
// 帧率
@property (nonatomic, strong) NSNumber *frameRate;
// 分辨率宽度
@property (nonatomic, strong) NSNumber *resolutionRateWidth;
// 分辨率高度
@property (nonatomic, strong) NSNumber *resolutionRateHeight;
// 默认扬声器
@property (nonatomic, assign) BOOL isSpeaker;
// 设置推流地址
@property (nonatomic, assign) BOOL isSetPublishUrl;

@end

NS_ASSUME_NONNULL_END
