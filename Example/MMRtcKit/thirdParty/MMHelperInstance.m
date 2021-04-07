
//
//  Created by max on 2020/12/8.
//  Copyright © 2020 max. All rights reserved.
//

#import "MMHelperInstance.h"
//#import "MMHelperHeader.h"
#import "NetWorkReachability.h"
#import <AVFoundation/AVFoundation.h>
//#import "MMLog.h"
#import "MMTools.h"
@interface MMHelperInstance()
{
    void *_IsOnSerialQueueOrTargetQueueKey;
}

@property (nonatomic,strong) NetWorkReachability *hostReachability;

@end


@implementation MMHelperInstance


+ (instancetype)sharedHelper{
    static MMHelperInstance *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
        
        instance.mode = MM_PRODUCT_MODE;

        
        //创建一个串行队列，用来执行后台任务
        instance.serial_queue = dispatch_queue_create("XM_serial_queue", DISPATCH_QUEUE_SERIAL);
        //将这个串行队列设置一个标示，key为self的_IsOnSerialQueueOrTargetQueueKey指针的地址，value为self
        instance->_IsOnSerialQueueOrTargetQueueKey = &(instance->_IsOnSerialQueueOrTargetQueueKey);
        dispatch_queue_set_specific(instance.serial_queue, instance->_IsOnSerialQueueOrTargetQueueKey, (__bridge void *)instance, NULL);
        

        
        instance.back_thread = [[NSThread alloc]initWithTarget:instance selector:@selector(initDataInBackThread) object:nil];
        [instance.back_thread start];
        
        
    });
    return instance;
}



+ (BOOL)isOnSerial_queue{
    if (dispatch_get_specific([MMHelperInstance sharedHelper]->_IsOnSerialQueueOrTargetQueueKey) == (__bridge void *)[MMHelperInstance sharedHelper]) {
        return YES;
    }
    return NO;
}

- (void)initDataInBackThread{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kNetWorkReachabilityChangedNotification object:nil];
    self.hostReachability = [NetWorkReachability reachabilityWithHostName:@"www.apple.com"];
    [self.hostReachability startNotifier];
    
    // 添加下边两句代码，就可以开启RunLoop，之后self.thread就变成了常驻线程，可随时添加任务，并交于RunLoop处理
    [NSThread currentThread].name = @"MMBackThread";
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];//添加一个端口，这个RunLoop就不会自动退出了
    [[NSRunLoop currentRunLoop] run];
    
    //写在这里的代码不会运行，因为run之后就进入无限循环了。
}


- (void)reachabilityChanged:(NSNotification *)notification{
    //这个监听方法是异步在分线程执行的。
    NetWorkReachability *curReach = [notification object];
    MMNetWorkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus) {
        case MMNetWorkStatusNotReachable:{// NSLog(@"网络不可用");
            [MMTools performTaskOnMainThread:^{
                self.networkType_str = @"disconnected";
            }];
        }
            break;
        case MMNetWorkStatusUnknown:{//NSLog(@"未知网络");
            [MMTools performTaskOnMainThread:^{
                self.networkType_str = @"unknown";
            }];
        }
            break;
        case MMNetWorkStatusWWAN2G:{
            [MMTools performTaskOnMainThread:^{
                self.networkType_str = @"2G";
            }];
        }
            break;
        case MMNetWorkStatusWWAN3G:{
            [MMTools performTaskOnMainThread:^{
                self.networkType_str = @"3G";
            }];
        }
            break;
        case MMNetWorkStatusWWAN4G:{
            [MMTools performTaskOnMainThread:^{
                self.networkType_str = @"4G";
            }];
        }
            break;
        case MMNetWorkStatusWiFi:{// NSLog(@"WiFi");
            [MMTools performTaskOnMainThread:^{
                self.networkType_str = @"WIFI";
            }];
        }
            break;
            
        default:
        {
            [MMTools performTaskOnMainThread:^{
                self.networkType_str = @"unknown";
            }];
        }
            break;
    }
    

}



@end
