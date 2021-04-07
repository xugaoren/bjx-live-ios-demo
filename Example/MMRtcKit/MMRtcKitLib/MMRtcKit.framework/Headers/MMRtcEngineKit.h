//
//  MMRtcEngineKit.h
//  MMRtcKit
//
//  Created by max on 2020/7/6.
//  Copyright © 2020 max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MMRtcKit/MMRtcEnumerates.h>
#import <MMRtcKit/MMRtcUser.h>
#import <MMRtcKit/MMRtcVideoConfiguration.h>
#import <MMRtcKit/MMRtcVideoCanvas.h>

@class MMRtcEngineKit;
@protocol MMRtcEngineDelegate <NSObject>
@optional
#pragma mark Core Delegate Methods
//需要给app报告警告时回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didOccurWarning:(MMRtcWarningCode)warningCode message:(NSString * _Nonnull)message;
//需要给app报告错误时回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didOccurError:(MMRtcErrorCode)errorCode message:(NSString * _Nonnull)message;
//当前用户加入channel成功后回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSString * _Nonnull)uid;
//当前用户离开channel成功后回调
- (void)rtcEngineDidLeaveChannel:(MMRtcEngineKit * _Nonnull)engine ;
//当前用户角色改变时回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didClientRoleChanged:(MMRtcClientRole)oldRole newRole:(MMRtcClientRole)newRole;
//远端主播加入channel时回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSString * _Nonnull)uid;
//远端主播离开channel时回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSString * _Nonnull)uid reason:(MMRtcUserOfflineReason)reason;
//本地流状态变化时回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine localAudioStateChange:(MMRtcStreamPublishState)state error:(MMRtcAudioLocalError)error;
//语音路由切换回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didAudioRouteChanged:(MMRtcAudioOutputRouting)routing;
//rtmp状态回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine rtmpStreamingChangedToState:(NSString *_Nonnull)url state:(MMRtcRtmpStreamingState)state;
//vad检测回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine speaker:(NSString *_Nonnull)speakerUid active:(bool)active;
//音频发布状态回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didAudioPublishStateChange:(NSString *_Nonnull)channel oldState:(MMRtcStreamPublishState)oldState newState:(MMRtcStreamPublishState)newState;
//视频发布状态回调
- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didVideoPublishStateChange:(NSString *_Nonnull)channel oldState:(MMRtcStreamPublishState)oldState newState:(MMRtcStreamPublishState)newState;
//接收到远端视频流回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didRemoteVideoAddOfUser:(NSString *_Nonnull)uid;
//处理视频帧数据
- (CVPixelBufferRef _Nullable)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didVideoFilterProcess:(CVPixelBufferRef _Nonnull)inputPixelBuffer;
#pragma mark Internal Delegates
//日志信息回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didPrintLog:(NSString *_Nonnull)log;
//接收到远端视频流回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didRemoteAudioAddOfUser:(NSString *_Nonnull)uid;

@end

@interface MMRtcEngineKit : NSObject

@property (weak,nonatomic) id<MMRtcEngineDelegate> _Nullable delegate;

@property (assign,nonatomic) MMRtcChannelProfile engine_profile;

@property (assign,nonatomic) MMRtcClientRole engine_role;

/* **********************************核心方法****************************** */

+ (instancetype _Nonnull)sharedEngineWithAppKey:(NSString * _Nonnull)appKey;

+ (void)destroy;

- (int)setChannelProfile:(MMRtcChannelProfile)profile;

- (int)setClientRole:(MMRtcClientRole)newRole;

- (int)joinChannelByToken:(NSString *_Nullable)token channelId:(NSString *_Nonnull)channelId uid:(NSString *_Nonnull)uid joinSuccess:(void ( ^ _Nullable ) ( NSString *_Nonnull channel , NSString *_Nonnull uid))joinSuccessBlock;

- (int)leaveChannel:(void (^_Nullable) (MMRtcErrorCode code))leaveChannelBlock;

//- (int)renewToken:(NSString * _Nonnull)token;


/* **********************************音频核心方法****************************** */

/// 调节音频采集信号音量
/// @param volume 音频采集信号音量，可在 0～400 范围内进行调节：
/// 0 ： 静音
/// 100 ：原始音量
/// 400 ：最大可为原始音量的 4 倍（自带溢出保护）
/// Note ：为避免回声并提升通话质量，建议将 volume 值设为 [0,100]。
- (int)adjustRecordingSignalVolume:(NSInteger)volume;

/// 调节本地播放的所有远端用户的信号音量
/// @param volume 播放音量，可在 0～400 范围内进行调节：
/// 0 ： 静音
/// 100 ：原始音量
/// 400 ：最大可为原始音量的 4 倍（自带溢出保护）
/// Note ：为避免回声并提升通话质量，建议将 volume 值设为 [0,100]。
- (int)adjustPlaybackSignalVolume:(NSInteger)volume;

/// 调节本地播放的指定远端用户的信号音量
/// @param uid 远端用户 ID，需和远端用户加入频道时用的 uid 一致
/// @param volume 播放音量，可在 0～400 范围内进行调节：
/// 0 ： 静音
/// 100 ：原始音量
/// 400 ：最大可为原始音量的 4 倍（自带溢出保护）
/// Note ：为避免回声并提升通话质量，建议将 volume 值设为 [0,100]。
- (int)adjustUserPlaybackSignalVolume:(NSString *_Nonnull)uid volume:(int)volume;

/// 取消或恢复发布本地音频流
/// @param muted 是否取消发布本地音频流（YES: 取消发布，NO: （默认）发布）
- (int)muteLocalAudioStream:(BOOL)muted;

/// 取消或恢复订阅指定远端用户的音频流
/// @param uid 指定用户的用户 ID
/// @param muted 是否取消订阅指定远端用户的音频流（YES: 取消订阅，NO: （默认）订阅）
- (int)muteRemoteAudioStream:(NSString *_Nonnull)uid mute:(BOOL)muted;

/// 取消或恢复订阅所有远端用户的音频流
/// @param muted 是否取消订阅所有远端用户的音频流（YES: 取消订阅，NO: （默认）订阅）
- (int)muteAllRemoteAudioStreams:(BOOL)muted;

/* **********************************音频播放路由****************************** */

- (int)setDefaultAudioRouteToSpeakerphone:(BOOL)defaultToSpeaker;

- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;

- (BOOL)isSpeakerphoneEnabled;

/* **********************************视频核心方法****************************** */
// 开启视频（仅 joinChannel 前调用）
- (int)enableVideo;
// 禁用视频（仅 joinChannel 前调用）
- (int)disableVideo;
// 设置视频配置
- (int)setVideoConfiguration:(MMRtcVideoConfiguration *_Nonnull)config;
// 初始化本地视图
- (int)setupLocalVideo:(MMRtcVideoCanvas *_Nullable)local;
// 初始化远端用户视图
- (int)setupRemoteVideo:(MMRtcVideoCanvas *_Nonnull)remote;
// 切换摄像头
- (int)switchCamera;
// joinChannel 成功后调用，且开启 video
- (int)muteLocalVideoStream:(BOOL)mute;
// 是否开启视频美颜
- (int)setVideoFilterEnable:(BOOL)isEnable;

// ---------- 旁路推流 ----------
// 该方法仅适用直播场景
// 成功加入频道后才能调用该接口
// pushUrl: 服务器推流地址
// pullUrl: 客户端拉流地址
// mode:类型 video/audio
- (int)setPublishStreamUrl:(NSString*_Nonnull)pushUrl
                   pullUrl:(NSString*_Nonnull)pullUrl;

/* **********************************其他****************************** */
// 获取 SDK 版本号
+ (NSString *_Nonnull)getSdkVersion;
// 设置日志等级
- (int)setLogFilter:(MMRtcLogLevel)filter;

/* **********************************内部调试使用****************************** */

@end


