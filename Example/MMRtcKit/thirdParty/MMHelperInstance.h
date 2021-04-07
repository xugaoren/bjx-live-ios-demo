//
//
//  Created by max on 2020/12/8.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,MM_Mode) {
    MM_DEV_MODE,                  //开发环境
    MM_TEST_MODE,                 //测试环境
    MM_PRODUCT_MODE,              //线上环境
};

@interface MMHelperInstance : NSObject

+ (instancetype)sharedHelper;

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

@property (assign,nonatomic) MM_Mode mode;

//全局串行队列
@property (retain,nonatomic) dispatch_queue_t serial_queue;
+ (BOOL)isOnSerial_queue;//当前方法是否是在serial_queue上执行
//后台常驻线程
@property (retain,nonatomic) NSThread *back_thread;

@property (retain,nonatomic)NSString *networkType_str;
@end


