//
//
//  Created by max on 2020/12/8.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,MMRequestType) {
    MM_GET,
    MM_POST,
    MM_DELETE,
    MM_PUT,
};

@interface MMHttpTools : NSObject

+ (NSString *_Nullable)urlEncode:(NSString *_Nullable)url;

//http请求方法封装。回调都在主线程执行
+ (void)sendRequsetByURLString:(NSString *_Nullable)urlString
withDataDictionary:(NSDictionary *_Nullable)dictionary
   queryDictionary:(NSDictionary *_Nullable)queryDictionary
              type:(MMRequestType)type
   timeoutInterval:(float)interval
         needToken:(BOOL)needToken
      containsBool:(BOOL)containsBool
          response:(void(^_Nullable)(NSHTTPURLResponse * _Nullable response))res
           success:(void(^_Nullable)(NSDictionary * _Nullable responseDictionary))suc
              fail:(void(^_Nullable)(NSError * _Nullable error,NSDictionary * _Nullable returnDic,NSString * _Nullable msg))fail;

//md5
+ (nullable NSString *)md5:(nullable NSString *)str;

+ (BOOL)checkTokenInvalid:(NSDictionary *_Nullable)dic;

+ (void)getAppKeyAndTokenWithUserId:(nonnull NSString *)uid
                         completion:(void (^_Nullable)(NSString *_Nullable appKey,
                                              NSString *_Nullable token,
                                              NSError *_Nullable error))completion;

@end


