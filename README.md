### 前提条件：

- iOS 11.0 及以上 



### 添加权限：

```html
<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
<key>NSCameraUsageDescription</key>
	<string>应用需要获取相机权限</string>
<key>NSMicrophoneUsageDescription</key>
	<string>应用需要获取麦克风权限</string>
<key>UIBackgroundModes</key>
	<array>
		<string>audio</string>
		<string>voip</string>
	</array>
```



### 开始使用：

**获取 RtcEngine 实例：**

```objective-c
+ (instancetype _Nonnull)sharedEngineWithAppKey:(NSString * _Nonnull)appKey;
```



**设置事件回调代理对象：**

```objective-c
@property (weak,nonatomic) id<MMRtcEngineDelegate> _Nullable delegate;
```



**设置频道场景：**

```objective-c
- (int)setChannelProfile:(MMChannelProfile)profile;
```

相同频道内的用户必须使用同一种频道场景

支持的场景：

- 通讯场景：*MMChannelProfileCommunication*
- 直播场景：*MMChannelProfileLiveBroadcasting* （默认）



**设置角色（仅限于直播场景）：**

```objective-c
- (int)setClientRole:(MMClientRole)role;
```

支持的角色：

- 主播：*MMClientRoleBroadcaster*
- 观众：*MMClientRoleAudience*（默认）



**加入频道：**

```objective-c
- (int)joinChannelByToken:(NSString *_Nullable)token channelId:(NSString *_Nonnull)channelId uid:(NSString *_Nonnull)uid joinSuccess:(void ( ^ _Nullable ) ( NSString *_Nonnull channel , NSString *_Nonnull uid))joinSuccessBlock;
```

加入同一个频道内的用户可以互相通话，多个用户加入同一个频道，可以群聊。
如果已在通话中，用户必须调用 leaveChannel 退出当前通话，才能进入下一个频道。
成功调用该方加入频道后，本地会触发 joinChannelSuccessBlock 回调。
主播加入频道后，远端会触发 didJoinedOfUid 回调。

channelId 为频道的标识，长度在 64 以内的字符串，以下为支持的字符集范围：

- 26 个小写英文字母 a-z
- 26 个大写英文字母 A-Z
- 10 个数字 0-9
- "-", "_", "#", "=", "@", "."

uid 为用户的唯一标识，由开发者自己维护，长度在 64 以内的字符串，以下为支持的字符集范围：

- 26 个小写英文字母 a-z
- 26 个大写英文字母 A-Z
- 10 个数字 0-9
- "-", "_", "#", "=", "@", "."

**离开频道：**

```objective-c
- (int)leaveChannel:(void (^_Nullable) (MMErrorCode))leaveChannelBlock;
```

离开频道后，本地会触发 *leaveChannelBlock*，主播离开频道后，远端会触发 *didOfflineOfUid*。



**停止/恢复发送本地语音流：**

```objective-c
- (int)muteLocalAudioStream:(BOOL)mute;
```



**停止/恢复接收指定音频流：**

```objective-c
- (int)muteRemoteAudioStream:(NSString *_Nonnull)uid mute:(BOOL)mute;
```



**设置音频播放路由：**

```objective-c
- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;
```

参数 enableSpeaker ：

- true：扬声器
- false：听筒




