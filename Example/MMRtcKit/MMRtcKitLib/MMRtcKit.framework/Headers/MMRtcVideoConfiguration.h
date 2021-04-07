//
//  MMRtcVideoConfiguration.h
//  MMRtcKit
//
//  Created by 牛超 on 2021/1/11.
//

#import <Foundation/Foundation.h>

@interface MMRtcVideoConfiguration : NSObject

// 视频编码的分辨率
@property (nonatomic, assign) CGSize dimensions;
// 视频编码的帧率（fps）
@property (nonatomic, assign) NSInteger frameRate;

@end
