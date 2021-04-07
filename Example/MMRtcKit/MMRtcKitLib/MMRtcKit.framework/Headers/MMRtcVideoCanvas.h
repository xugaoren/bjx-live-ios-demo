//
//  MMRtcVideoCanvas.h
//  MMRtcKit
//
//  Created by RunX on 2020/12/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMRtcVideoCanvas : NSObject

// 视频显示视窗
@property (nonatomic, strong) UIView *view;
// 用户 ID，指定需要显示视窗的 uid
@property (nonatomic, copy) NSString *uid;

@end

NS_ASSUME_NONNULL_END
