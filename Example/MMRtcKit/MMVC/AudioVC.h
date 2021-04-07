//
//  AudioVC.h
//  MMDemo
//
//  Created by max  on 2020/8/21.
//  Copyright © 2020 max. All rights reserved.
//

#import "BaseController.h"
#import <MMRtcKit/MMRtcKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface AudioVC : BaseController

@property (nonatomic,strong) MMRtcEngineKit *engine;

@property (assign, nonatomic)  NSInteger myPublishStatus;//SDK新增属性，标记我自己的发布状态

@property (nonatomic,assign)BOOL isBroaster;
@property (nonatomic,assign)BOOL isAutoSub;
@property (nonatomic,assign)BOOL isSpeaker;
@property (nonatomic,assign)BOOL isPushPull;
@property (nonatomic,strong)NSMutableArray *allMembers;
@property (nonatomic,strong)NSString *channelId;

@end

NS_ASSUME_NONNULL_END
