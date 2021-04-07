//
//  MMRtcEnumerates.h
//  MMRtcKit
//
//  Created by max on 2020/7/6.
//  Copyright © 2020 max. All rights reserved.
//

#ifndef MMRtcEnumerates_h
#define MMRtcEnumerates_h

/*
 *  本地发送的RTC类型
 */
typedef enum{
    MMWEBRTCTypeNone = 0,
    MMWEBRTCTypeAudio,
    MMWEBRTCTypeVideo,
    MMWEBRTCTypeAudioAndVideo,
}MMWEBRTCType;

/*
 *  push/pull类型
 */
typedef enum{
    MMRtmpStreamModeAudio,
    MMRtmpStreamModeVideo,
}MMRtmpStreamMode;

typedef NS_ENUM(NSInteger, MMRtcRtmpStreamingErrorCode) {
    /** 8: The specified view is invalid. Specify a view when using the video call function. */
    MMRtcRtmpStreamingErrorCodeNoError = 0,
    
    MMRtcRtmpStreamingErrorCodeNoInternet,
    
};

typedef NS_ENUM(NSInteger, MMRtcWarningCode) {
    /** 8: The specified view is invalid. Specify a view when using the video call function. */
    MMRtcWarningCodeInvalidView = 8,
    
};

typedef NS_ENUM(NSInteger, MMRtcErrorCode) {
    /** 0: No error occurs. */
    MMRtcErrorCodeOK                                = 0,
    
    MMRtcErrorCodeFailed                            = -1,
    
    MMRtcErrorCodeInvaildArgument                   = -2,
    
    MMRtcErrorCodeWebSocketFailed                   = -3,
    
    MMRtcErrorCodeError                             = -4,
    
    MMRtcErrorCodeSetClientRoleFailed               = 20010,
    
    MMRtcErrorCodeJoinChannelFailed                 = 20020,
    
    MMRtcErrorCodeJoinChannelModeAtypismFailed      = 20021,
    
    MMRtcErrorCodeJoinChannelNotReadyFailed         = 20022,
    
    MMRtcErrorCodeLeaveChannelFailed                = 20030,
    
    MMRtcErrorCodeUnMuteLocalAudioStreamFailed      = 20060,
    
    MMRtcErrorCodeMuteLocalAudioStreamFailed        = 20050,
    
    MMRtcErrorCodeUnMuteRemoteAudioStreamFailed     = 20070,

    
    MMRtcErrorCodeSetRole                           = 30010,
    
    MMRtcErrorCodeChannelJoin                       = 30020,
    
    // system error
    MMRtcErrorCodeSystemError                       = 500000,
    
    // request without argument
    MMRtcErrorCodeRequestWithOutArgument            = 510000,
    
    // request invaild argument
    MMRtcErrorCodeRequestInvaildArgument            = 510100,
    
    // uid is empty error
    MMRtcErrorCodeUidIsEmpty                        = 510200,
    
    // uid is mismatch
    MMRtcErrorCodeUidIsMismatch                     = 510201,
    
    // token is invalid
    MMRtcErrorCodeTokenIsInvalid                    = 510202,
    
    // sid doesn't match token-claims %s → %#v
    MMRtcErrorCodeSIDDontMatchToken                 = 510203,
        
    // msg is empty
    MMRtcErrorCodeMsgIsEmpty                        = 510300,
    
    // join to sfu error
    MMRtcErrorCodeJoinToSfu                         = 510301,
    
    // not join sfu
    MMRtcErrorCodeNotJoinSfu                        = 510302,
    
    // send offer to sfu Error
    MMRtcErrorCodeSendOfferToSfu                    = 510303,
    
    // trickle to %s error
    MMRtcErrorCodeTrickleError                      = 510304,
    
    // avp node is not found
    MMRtcErrorCodeAvpNodeIsNotFound                 = 510305,
    
    // set live-url error
    MMRtcErrorCodeSetLiveUrlError                   = 510306,
    
    // nats 连接超时
    MMRtcErrorCodeNatsTimeOut = 40000,
   
};


/** Channel profile. */
typedef NS_ENUM(NSInteger, MMRtcChannelProfile) {
    /** 0: (Default) The Communication profile.
     <p>Use this profile in one-on-one calls or group calls, where all users can talk freely.</p>
     */
    MMRtcChannelProfileCommunication = 0,
    /** 1: The Live-Broadcast profile.
     <p>Users in a live-broadcast channel have a role as either broadcaster or audience. A broadcaster can both send and receive streams; an audience can only receive streams.</p>
     */
    MMRtcChannelProfileLiveBroadcasting = 1,
    /** 2: The Gaming profile.
     <p>This profile uses a codec with a lower bitrate and consumes less power. Applies to the gaming scenario, where all game players can talk freely.</p>
     */
    //MMRtcChannelProfileGame = 2,
};

/** Client role in a live broadcast. */
typedef NS_ENUM(NSInteger, MMRtcClientRole) {
    /** Host. */
    MMRtcClientRoleBroadcaster = 1,
    /** Audience. */
    MMRtcClientRoleAudience = 2,
};

/** Reason for the user being offline. */
typedef NS_ENUM(NSUInteger, MMRtcUserOfflineReason) {
    /** The user left the current channel. */
    MMRtcUserOfflineReasonQuit = 0,
    /** The SDK timed out and the user dropped offline because no data packet is received within a certain period of time. If a user quits the call and the message is not passed to the SDK (due to an unreliable channel), the SDK assumes the user dropped offline. */
    MMRtcUserOfflineReasonDropped = 1,
    /** (Live broadcast only.) The client role switched from the host to the audience. */
    MMRtcUserOfflineReasonBecomeAudience = 2,
};


/** Connection states. */
typedef NS_ENUM(NSInteger, MMRtcConnectionStateType) {
    /** <p>1: The SDK is disconnected from MM's edge server.</p>
     This is the initial state before [joinChannelByToken]([MMRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]).<br>
     The SDK also enters this state when the app calls [leaveChannel]([MMRtcEngineKit leaveChannel:]).
     */
    MMRtcConnectionStateDisconnected = 1,
    /** <p>2: The SDK is connecting to MM's edge server.</p>
     When the app calls [joinChannelByToken]([MMRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]), the SDK starts to establish a connection to the specified channel, triggers the [connectionChangedToState]([MMRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback, and switches to the `MMRtcConnectionStateConnecting` state.<br>
     <br>
     When the SDK successfully joins the channel, the SDK triggers the [connectionChangedToState]([MMRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback and switches to the `MMRtcConnectionStateConnected` state.<br>
     <br>
     After the SDK joins the channel and when it finishes initializing the media engine, the SDK triggers the [didJoinChannel]([MMRtcEngineDelegate rtcEngine:didJoinChannel:withUid:elapsed:]) callback.
     */
    MMRtcConnectionStateConnecting = 2,
    /** <p>3: The SDK is connected to MM's edge server and joins a channel. You can now publish or subscribe to a media stream in the channel.</p>
     If the connection to the channel is lost because, for example, the network is down or switched, the SDK automatically tries to reconnect and triggers:
     <li> The [rtcEngineConnectionDidInterrupted]([MMRtcEngineDelegate rtcEngineConnectionDidInterrupted:])(deprecated) callback
     <li> The [connectionChangedToState]([MMRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback, and switches to the `MMRtcConnectionStateReconnecting` state.
     */
    MMRtcConnectionStateConnected = 3,
    /** <p>4: The SDK keeps rejoining the channel after being disconnected from a joined channel because of network issues.</p>
     <li>If the SDK cannot rejoin the channel within 10 seconds after being disconnected from MM's edge server, the SDK triggers the [rtcEngineConnectionDidLost]([MMRtcEngineDelegate rtcEngineConnectionDidLost:]) callback, stays in the `MMRtcConnectionStateReconnecting` state, and keeps rejoining the channel.
     <li>If the SDK fails to rejoin the channel 20 minutes after being disconnected from MM's edge server, the SDK triggers the [connectionChangedToState]([MMRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callback, switches to the `MMRtcConnectionStateFailed` state, and stops rejoining the channel.
     */
    MMRtcConnectionStateReconnecting = 4,
    /** <p>5: The SDK fails to connect to MM's edge server or join the channel.</p>
     You must call [leaveChannel]([MMRtcEngineKit leaveChannel:]) to leave this state, and call [joinChannelByToken]([MMRtcEngineKit joinChannelByToken:channelId:info:uid:joinSuccess:]) again to rejoin the channel.<br>
     <br>
     If the SDK is banned from joining the channel by MM's edge server (through the RESTful API), the SDK triggers the [rtcEngineConnectionDidBanned]([MMRtcEngineDelegate rtcEngineConnectionDidBanned:])(deprecated) and [connectionChangedToState]([MMRtcEngineDelegate rtcEngine:connectionChangedToState:reason:]) callbacks.
     */
    MMRtcConnectionStateFailed = 5,
};


/** The state of the local audio. */
typedef NS_ENUM(NSUInteger, MMRtcStreamPublishState) {
    /** 0: The local audio is in the initial state. */
    MMRtcStreamPublishIdle                  = 0,
    MMRtcStreamPublishNoPublished           = 1,
    MMRtcStreamPublishPublishing            = 2,
    /** 3: The local audio fails to start. */
    MMRtcStreamPublishPublished             = 3,
};

/** The error information of the local audio. */
typedef NS_ENUM(NSUInteger, MMRtcAudioLocalError) {
    /** 0: The local audio is normal. */
    MMRtcAudioLocalErrorOk = 0,
    /** 1: No specified reason for the local audio failure. */
    MMRtcAudioLocalErrorFailure = 1,
    /** 2: No permission to use the local audio device. */
    MMRtcAudioLocalErrorDeviceNoPermission = 2,
    /** 3: The microphone is in use. */
    MMRtcAudioLocalErrorDeviceBusy = 3,
    /** 4: The local audio recording fails. Check whether the recording device is working properly. */
    MMRtcAudioLocalErrorRecordFailure = 4,
    /** 5: The local audio encoding fails. */
    MMRtcAudioLocalErrorEncodeFailure = 5,
};

/** Audio output routing. */
typedef NS_ENUM(NSInteger, MMRtcAudioOutputRouting) {
    /** Default. */
    MMRtcAudioOutputRoutingDefault = -1,
    /** Headset.*/
    MMRtcAudioOutputRoutingHeadset = 0,
    /** Earpiece. */
    MMRtcAudioOutputRoutingEarpiece = 1,
    /** Headset with no microphone. */
    MMRtcAudioOutputRoutingHeadsetNoMic = 2,
    /** Speakerphone. */
    MMRtcAudioOutputRoutingSpeakerphone = 3,
    /** Loudspeaker. */
    MMRtcAudioOutputRoutingLoudspeaker = 4,
    /** Bluetooth headset. */
    MMRtcAudioOutputRoutingHeadsetBluetooth = 5
};

/** Network type. */
typedef NS_ENUM(NSInteger, MMRtcNetworkType) {
    /** -1: The network type is unknown. */
    MMRtcNetworkTypeUnknown = -1,
    /** 0: The SDK disconnects from the network. */
    MMRtcNetworkTypeDisconnected = 0,
    /** 1: The network type is LAN. */
    MMRtcNetworkTypeLAN = 1,
    /** 2: The network type is Wi-Fi (including hotspots). */
    MMRtcNetworkTypeWIFI = 2,
    /** 3: The network type is mobile 2G. */
    MMRtcNetworkTypeMobile2G = 3,
    /** 4: The network type is mobile 3G. */
    MMRtcNetworkTypeMobile3G = 4,
    /** 5: The network type is mobile 4G. */
    MMRtcNetworkTypeMobile4G = 5,
};

typedef NS_ENUM(NSUInteger, MMRtcRtmpStreamingState ) {
    MMRtcRtmpStreamingStateIdle = 0,
    MMRtcRtmpStreamingStateConnecting = 1,
    MMRtcRtmpStreamingStateRunning = 2,
    MMRtcRtmpStreamingStateRecovering = 3,
};


typedef NS_ENUM(NSUInteger, MMRtcLogLevel) {
    MMRtcLogLevelDebug = 0,
    MMRtcLogLevelInfo  = 1,
    MMRtcLogLevelWarn  = 2,
    MMRtcLogLevelError = 3,
    MMRtcLogLevelNone  = 4,
};

/** Video frame rate */
typedef NS_ENUM(NSInteger, MMRtcVideoFrameRate) {
    /** 1 fps. */
    MMRtcVideoFrameRateFps1 = 1,
    /** 7 fps. */
    MMRtcVideoFrameRateFps7 = 7,
    /** 10 fps. */
    MMRtcVideoFrameRateFps10 = 10,
    /** 15 fps. */
    MMRtcVideoFrameRateFps15 = 15,
    /** 24 fps. */
    MMRtcVideoFrameRateFps24 = 24,
    /** 30 fps. */
    MMRtcVideoFrameRateFps30 = 30,
    /** 60 fps (macOS only). */
    MMRtcVideoFrameRateFps60 = 60,
};

typedef NS_ENUM(NSInteger, MMRtcVideoDimension) {
    /** 120 * 120
     */
    MMRtcVideoDimension120x120 = 0,
    /** 160 * 120
     */
    MMRtcVideoDimension160x120,
    /** 180 * 180
     */
    MMRtcVideoDimension180x180,
    /** 240 * 180
     */
    MMRtcVideoDimension240x180,
    /** 320 * 180
     */
    MMRtcVideoDimension320x180,
    /** 240 * 240
     */
    MMRtcVideoDimension240x240,
    /** 320 * 240
     */
    MMRtcVideoDimension320x240,
    /** 424 * 240
     */
    MMRtcVideoDimension424x240,
    /** 360 * 360
     */
    MMRtcVideoDimension360x360,
    /** 480 * 360
     */
    MMRtcVideoDimension480x360,
    /** 640 * 360
     */
    MMRtcVideoDimension640x360,
    /** 480 * 480
     */
    MMRtcVideoDimension480x480,
    /** 640 * 480
     */
    MMRtcVideoDimension640x480,
    /** 840 * 480
     */
    MMRtcVideoDimension840x480,
    /** 960 * 720 (Hardware dependent)
     */
    MMRtcVideoDimension960x720,
    /** 1280 * 720 (Hardware dependent)
     */
    MMRtcVideoDimension1280x720,
};

#endif /* MMRtcEnumerates_h */
