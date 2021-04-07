
//
//  Created by max on 2020/6/1.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MMRtcKit/MMRtcEnumerates.h>

@interface MMRtcUser : NSObject
//用户id
@property (nonatomic,strong) NSString *uid;
//用户角色
@property (nonatomic,assign) MMRtcClientRole role;
//用户info
@property (nonatomic,strong) NSString *info;
//用户streamid
@property (nonatomic,strong) NSString *streamid;
//房间id
@property (nonatomic,strong) NSString *sid;
@end


