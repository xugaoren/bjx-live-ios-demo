//
//  NetWorkReachability.h
//  SECC01
//
//  Created by Harvey on 16/6/29.
//  Copyright © 2016年 Haley. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MMNetWorkStatus) {
    MMNetWorkStatusNotReachable = 0,
    MMNetWorkStatusUnknown = 1,
    MMNetWorkStatusWWAN2G = 2,
    MMNetWorkStatusWWAN3G = 3,
    MMNetWorkStatusWWAN4G = 4,
    
    MMNetWorkStatusWiFi = 9,
};

extern NSString *kNetWorkReachabilityChangedNotification;

@interface NetWorkReachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

- (BOOL)startNotifier;

- (void)stopNotifier;

- (MMNetWorkStatus)currentReachabilityStatus;

@end
