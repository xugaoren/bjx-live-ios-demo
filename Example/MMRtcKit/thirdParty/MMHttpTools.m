
//
//  Created by max on 2020/12/8.
//  Copyright © 2020 max. All rights reserved.
//

#import "MMHttpTools.h"
#import <CommonCrypto/CommonCrypto.h>
#import "NSDictionary+XMNullReplace.h"
#import "MMTools.h"
@implementation MMHttpTools

+ (NSString *)urlEncode:(NSString *)url{
    //NSString *str2 = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, nil, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8));
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];

    return encodedUrl;
}

//请求方法。
+ (void)sendRequsetByURLString:(NSString *_Nullable)urlString
            withDataDictionary:(NSDictionary *_Nullable)dictionary
               queryDictionary:(NSDictionary *_Nullable)queryDictionary
                          type:(MMRequestType)type
               timeoutInterval:(float)interval
                     needToken:(BOOL)needToken
                  containsBool:(BOOL)containsBool
                      response:(void(^_Nullable)(NSHTTPURLResponse * _Nullable response))res
                       success:(void(^_Nullable)(NSDictionary * _Nullable responseDictionary))suc
                          fail:(void(^_Nullable)(NSError * _Nullable error,NSDictionary * _Nullable returnDic,NSString * _Nullable msg))fail{
    NSURLSession *session = [NSURLSession sharedSession];
//    if (needToken && (!CURRENT_APPKEY || !CURRENT_TOKEN)) {
//        fail ? fail([NSError errorWithDomain:@"token或appkey不存在" code:111 userInfo:nil],nil,@"token或appkey不存在") : nil;
//        return;
//    }
    if (type == MM_GET) {
        NSString *dataStr = [self getFullURLStringBy:urlString withDictionary:queryDictionary];
        NSURL *url = [NSURL URLWithString:dataStr];
        if (!url) {
            dataStr = [self urlEncode:dataStr];
            url = [NSURL URLWithString:dataStr];
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(interval > 0 ? interval : 10)];
//        if (needToken) {
//            [request setValue:CURRENT_APPKEY forHTTPHeaderField:@"X-AppKey"];
//            [request setValue:CURRENT_TOKEN forHTTPHeaderField:@"X-Token"];
//        }
//        if (needToken) {
//            [req setValue:[NSString stringWithFormat:@"Bearer %@",[MMEngine sharedEngine].accountManager.currentToken] forHTTPHeaderField:@"Authorization"];
//        }
        //[req setValue:@"application/json" forHTTPHeaderField:@"Content­-Type"];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self requestDidGetResponse:(NSHTTPURLResponse *)response data:data error:error response:res success:suc fail:fail urlString:urlString];
        }];
        [dataTask resume];
    }
    else {
        NSString *dataStr = urlString;
        if (queryDictionary) {
            dataStr = [self getFullURLStringBy:urlString withDictionary:queryDictionary];
        }
        NSURL *url = [NSURL URLWithString:dataStr];
        if (!url) {
            dataStr = [self urlEncode:dataStr];
        }
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:dataStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:(interval > 0 ? interval : 10)];
//        if (needToken) {
//            [request setValue:CURRENT_APPKEY forHTTPHeaderField:@"X-AppKey"];
//            [request setValue:CURRENT_TOKEN forHTTPHeaderField:@"X-Token"];
//        }
//        if (needToken) {
//            [request setValue:[NSString stringWithFormat:@"Bearer %@",XM_CURRENT_TOKEN] forHTTPHeaderField:@"Authorization"];
//        }
        
        [request setHTTPMethod:(type == MM_POST ? @"POST" :(type == MM_PUT ? @"PUT" : @"DELETE"))];
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        NSData *bodyData = [self getHTTPBodyWithDictionary:dictionary];
        if (containsBool) {
            NSString *str = [[NSString alloc]initWithData:bodyData encoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@"\"true\"" withString:@"true"];
            str = [str stringByReplacingOccurrencesOfString:@"\"false\"" withString:@"false"];
            bodyData = [str dataUsingEncoding:NSUTF8StringEncoding];
        }
        if (bodyData) {
            [request setHTTPBody:bodyData];
        }
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self requestDidGetResponse:(NSHTTPURLResponse *)response data:data error:error response:res success:suc fail:fail urlString:urlString];
        }];
        [dataTask resume];
    }
}

+ (void)requestDidGetResponse:(NSHTTPURLResponse *)response
                         data:(NSData *)data
                        error:(NSError *)error
                     response:(void(^)(NSHTTPURLResponse * _Nullable resp))res
                      success:(void(^)(NSDictionary * _Nullable responseDictionary))suc
                         fail:(void(^)(NSError * _Nullable error,NSDictionary * _Nullable returnDic,NSString *msg))fail
                    urlString:(NSString *)urlString{
    dispatch_async(dispatch_get_main_queue(), ^{
        res ? res(response) : nil;
        if (error) {
            NSLog(@"%@接口返回error：\n%@",urlString,error);
            fail ? fail(error,nil,error.localizedDescription) : nil;
            return;
        }
        if (response && (response.statusCode != 200)) {
//            if (response.statusCode == 401) {
//                //token失效
//
//                return;
//            }
//            fail ? fail(nil,nil,[NSString stringWithFormat:@"response status = %ld",response.statusCode]) : nil;
//            return;
        }
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (!dic) {
            NSLog(@"%@",response);
            NSLog(@"%@接口返回字典为空，尝试转化为字符串",urlString);
            NSString *msg = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            fail ? fail([NSError errorWithDomain:msg code:-1 userInfo:nil],nil,msg) : nil;
            return;
        }
        if (dic[@"token"] && dic[@"appKey"]){
            suc ? suc([NSDictionary changeType:dic]) : nil;
        }else if (dic[@"success"] && [dic[@"success"]integerValue] == 1){
            suc ? suc([NSDictionary changeType:dic]) : nil;
        }
        else if (dic[@"code"]){
            NSInteger code = [dic[@"code"]integerValue];
            if (code) {
                NSString *msg = [NSString stringWithFormat:@"%@",dic[@"message"]];
                if (code == 401 && [msg containsString:@"token"]) {//要单独处理token失效事件
                    //XM_SAVE_USER_TO_SANDBOX(nil);
//                    MM_CURRENT_USER = nil;
//                    [[NSNotificationCenter defaultCenter]postNotificationName:MMNotificationUserTokenInValid object:nil userInfo:nil];
                    return;
                }
                NSLog(@"%@接口返回code不为0：\n%@",urlString,dic);
                fail ? fail(nil,dic,msg.length ? msg : dic.description) : nil;
                return;
            }
            suc ? suc([NSDictionary changeType:dic]) : nil;
        }
        else {
            fail ? fail(nil,dic,@"无法识别的返回报文") : nil;
        }
    });
    
}

//get请求专用。将基本的urlstring和字典拼接成完成的urlstring
+ (NSString *)getFullURLStringBy:(NSString *)urlString
                  withDictionary:(NSDictionary *)dictionary{
    if (!dictionary || dictionary.count == 0) {
        return urlString;
    }
    NSArray *array = [dictionary allKeys];
    NSMutableString *fullURLString = [NSMutableString stringWithString:[urlString stringByAppendingString:@"?"]];
    NSString *str = nil;
    for (NSString *key in array) {
        str = [NSString stringWithFormat:@"%@",dictionary[key]];
        [fullURLString appendString:[NSString stringWithFormat:@"%@=%@&",[self urlEncode:key],[self urlEncode:str]]];
    }
    [fullURLString deleteCharactersInRange:NSMakeRange(fullURLString.length - 1, 1)];
    return fullURLString;
}

//post请求专用。将字典拼接成字符串，并转化为data
+ (NSData *)getHTTPBodyWithDictionary:(NSDictionary *)dictionary{
    if (!dictionary || dictionary.count == 0) {
        return nil;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingFragmentsAllowed error:nil];
 
    return data;
//    NSArray *array = [dictionary allKeys];
//    NSMutableString *fullString = [NSMutableString string];
//    NSString *str = nil;
//    for (NSString *key in array) {
//        str = [NSString stringWithFormat:@"%@",dictionary[key]];
//        [fullString appendString:[NSString stringWithFormat:@"%@=%@&",[self urlEncode:key],[self urlEncode:str]]];
//    }
//    [fullString deleteCharactersInRange:NSMakeRange(fullString.length - 1, 1)];
//
//    return [fullString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (nullable NSString *)md5:(nullable NSString *)str {
    if (!str) return nil;
    const char *cStr = str.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    
    NSMutableString *md5Str = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [md5Str appendFormat:@"%02x", result[i]];
    }
    return md5Str;
}


+ (BOOL)checkTokenInvalid:(NSDictionary *)dic{
    if (!dic[@"code"]) {
        return NO;
    }
    NSInteger code = [dic[@"code"]integerValue];
    if (code) {
        NSString *msg = [NSString stringWithFormat:@"%@",dic[@"message"]];
        if (code == 401 && [msg containsString:@"token"]) {//要单独处理token失效事件
            //XM_SAVE_USER_TO_SANDBOX(nil);
//            MM_CURRENT_USER = nil;
//            [[NSNotificationCenter defaultCenter]postNotificationName:MMNotificationUserTokenInValid object:nil userInfo:nil];
            return YES;
        }
    }
    return NO;
}

+ (void)getAppKeyAndTokenWithUserId:(NSString *)uid
                         completion:(void (^)(NSString *_Nullable appKey,
                                              NSString *_Nullable token,
                                              NSError *_Nullable error))completion {
    // NSString *tokenUrl = @"http://mmnode.bjx.cloud:9888/api/v1/tokens/generate";
    // dev环境
    //NSString *tokenUrl = @"http://192.168.88.222:8888/api/v1/appserver/token";
    //NSString *tokenUrl = @"http://192.168.99.203:8888/api/v1/appserver/token";
    NSString *tokenUrl = @"https://rtcauth.bjx.cloud/api/v1/appserver/token";
    //NSString *tokenUrl = @"http://srtcauth.bjx.cloud/api/v1/appserver/token";
    //NSString *tokenUrl = @"http://192.168.99.36:8888/api/v1/appserver/token";
    [MMHttpTools sendRequsetByURLString:tokenUrl
                     withDataDictionary:nil
                        queryDictionary:@{ @"userID" : uid ?: @"" }
                                   type:MM_GET
                        timeoutInterval:10
                              needToken:NO
                           containsBool:NO
                               response:^(NSHTTPURLResponse * _Nullable response) {
    } success:^(NSDictionary * _Nullable responseDictionary) {
        NSDictionary *dateDict = responseDictionary[@"data"];
        [MMTools performTaskOnMainThread:^{
            NSString *strtoken = [NSString stringWithFormat:@"%@", dateDict[@"token"]];
            NSString *strappkey = [NSString stringWithFormat:@"%@", dateDict[@"appKey"]];
            if (strappkey.length > 0) {
                [kUserDefaults setObject:strappkey forKey:@"appKey"];
                [kUserDefaults setObject:uid forKey:@"userId"];
                [kUserDefaults synchronize];
            }
            !completion ?: completion(strappkey, strtoken, nil);
        }];
        
    } fail:^(NSError * _Nullable error,NSDictionary *returnDic,NSString *msg) {
        [MMTools performTaskOnMainThread:^{
            !completion ?: completion(nil, nil, error);
        }];
    }];
}


@end
