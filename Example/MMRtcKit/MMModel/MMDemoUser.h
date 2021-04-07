//
//  MMDemoUser.h
//  RUNXSaas
//
//  Created by max on 2020/5/12.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMDemoUser: NSObject

@property (nonatomic,copy) NSString *ID;
@property (nonatomic,copy) NSString *userId;//这个是用户的imId。
@property (nonatomic,copy) NSString *nickname;
@property (nonatomic,copy) NSString *headImg;
@property (nonatomic,copy) NSString *username;

@property (nonatomic,assign) BOOL publishing;
@property (nonatomic,assign) BOOL isSubscribed;//我是否订阅过这个用户。

@property (nonatomic,assign) BOOL isSpeak;
+ (MMDemoUser *)createUser:(NSString * _Nonnull)uid;

@end



