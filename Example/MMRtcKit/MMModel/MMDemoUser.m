//
//  MMDemoUser.m
//  RUNXSaas
//
//  Created by max on 2020/5/12.
//  Copyright © 2020 max. All rights reserved.
//

#import "MMDemoUser.h"

@implementation MMDemoUser

+ (MMDemoUser *)createUser:(NSString * _Nonnull)uid{
    MMDemoUser *user = [[MMDemoUser alloc]init];
    user.userId = uid;
    
    return user;
}

@end
