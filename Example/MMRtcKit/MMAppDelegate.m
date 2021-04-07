//
//  MMAppDelegate.m
//  MMRtcKit
//
//  Created by cf_olive@163.com on 12/07/2020.
//  Copyright (c) 2020 cf_olive@163.com. All rights reserved.
//

#import "MMAppDelegate.h"
#import "LoginVC.h"
#import <Bugly/Bugly.h>

@implementation MMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Bugly startWithAppId:@"261813c167"];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[LoginVC new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
