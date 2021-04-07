//
//  VideoVC.m
//  MMRtcKit_Example
//
//  Created by RunX on 2020/12/30.
//  Copyright © 2020 cf_olive@163.com. All rights reserved.
//

#import "VideoVC.h"
#import <MMRtcKit/MMRtcKit.h>
#import <Masonry/Masonry.h>
#import "MBProgressHUD+MMCategory.h"
#import "AlertView.h"
#import "LogMessageVC.h"
#import "MMHttpTools.h"
#import "FUManager.h"
#import "FUAPIDemoBar.h"

static NSString *const kCollectionViewID = @"kCollectionViewID";

@interface VideoVC () <MMRtcEngineDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FUAPIDemoBarDelegate>

// rtc 引擎
@property (nonatomic, strong) MMRtcEngineKit *engine;

// 视频绘制窗口列表
@property (nonatomic, strong) UICollectionView *collectionView;
// 本地视频 Mute/Unmute 按钮
@property (nonatomic, strong) UIButton *localVideoMuteBtn;
// 切换摄像头按钮
@property (nonatomic, strong) UIButton *switchCameraBtn;
// 本地音频 Mute/Unmute 按钮
@property (nonatomic, strong) UIButton *localAudioMuteBtn;
// 本地扬声器 Mute/Unmute 按钮
@property (nonatomic, strong) UIButton *localSpeakerMuteBtn;
// 开启/关闭视频美颜按钮
@property (nonatomic, strong) UIButton *videoFilterBtn;
// 美颜工具栏
@property (strong, nonatomic) FUAPIDemoBar *demoBar;

// 远端视频用户ID集合
@property (nonatomic, strong) NSMutableArray *mCurrentVideoUsers;

// 收到远端音频
@property (nonatomic, strong) NSMutableDictionary *mReceivedRemoteAudioDic;
// 收到远端音频
@property (nonatomic, strong) NSMutableDictionary *mReceivedRemoteVideoDic;
// 日志信息
@property (nonatomic, strong) NSMutableArray *logsArrary;

@end

@implementation VideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupFaceUnity];
    
    [self setupNavgationViews];
    [self setupSubviews];
    
    [self setupRtcEngineKit];
    
    [self joinChannel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.demoBar reloadShapView:[FUManager shareManager].shapeParams];
    [self.demoBar reloadSkinView:[FUManager shareManager].skinParams];
    [self.demoBar reloadFilterView:[FUManager shareManager].filters];
    [self.demoBar reloadStyleView:[FUManager shareManager].styleParams defaultStyle:[FUManager shareManager].currentStyle];
    [self.demoBar setDefaultFilter:[FUManager shareManager].seletedFliter];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    /* 清一下信息，防止快速切换有人脸信息缓存 */
    [FURenderer onCameraChange];
}

- (void)dealloc {
    [MMRtcEngineKit destroy];
}

- (void)setupNavgationViews {
    self.navigationItem.title =  [NSString stringWithFormat:@"频道ID:%@", self.channelId];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"退出" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 50, 40);
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
    
    UIButton *logBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logBtn setTitle:@"日志" forState:UIControlStateNormal];
    [logBtn addTarget:self action:@selector(logBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    logBtn.frame = CGRectMake(0, 0, 50, 40);
    [logBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *logItem = [[UIBarButtonItem alloc]initWithCustomView:logBtn];
    self.navigationItem.rightBarButtonItem = logItem;
}

- (void)setupSubviews {
    self.view.backgroundColor = OX_COLOR(0x2B2B2B);
    
    [self.view addSubview:self.switchCameraBtn];
    [self.view addSubview:self.localVideoMuteBtn];
    [self.view addSubview:self.localAudioMuteBtn];
    [self.view addSubview:self.localSpeakerMuteBtn];
    [self.view addSubview:self.videoFilterBtn];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.demoBar];
    
    [self.demoBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.switchCameraBtn.mas_top).offset(-10);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
}

- (void)setupFaceUnity {
    /* 视频模式 */
    fuSetFaceProcessorDetectMode(1);
    /* 美颜道具 */
    [[FUManager shareManager] loadFilter];
    /* 同步 */
    [[FUManager shareManager] setAsyncTrackFaceEnable:NO];
    /* 最大识别人脸数 */
    [FUManager shareManager].enableMaxFaces = YES;
}

- (void)setupRtcEngineKit {
    self.engine = [MMRtcEngineKit sharedEngineWithAppKey:CURRENT_APPKEY];
    self.engine.delegate = self;
    [self.engine setChannelProfile:MMRtcChannelProfileCommunication];
    [self.engine setLogFilter:MMRtcLogLevelDebug];
    [self.engine setDefaultAudioRouteToSpeakerphone:self.isSpeaker];
    // 设置成主播
    //[self.engine setClientRole:MMRtcClientRoleBroadcaster];
    // 开启视频
    [self.engine enableVideo];
    // 是否开启视频美颜
    [self.engine setVideoFilterEnable:YES];
    
    [self setPublishStreamUrl];
    
    // 先把本地用户加入
    [self.mCurrentVideoUsers addObject:CURRENT_USERID];
    // 设置视频编码配置
    MMRtcVideoConfiguration *videoEncoderConfig = [[MMRtcVideoConfiguration alloc] init];
    
    videoEncoderConfig.dimensions = CGSizeMake([self.resolutionRateWidth integerValue], [self.resolutionRateHeight integerValue]);
    videoEncoderConfig.frameRate = [self.frameRate intValue];
    
    NSLog(@"dimensions: width=%f height=%f frameRate:%ld", videoEncoderConfig.dimensions.width, videoEncoderConfig.dimensions.height, (long)videoEncoderConfig.frameRate);
    
    [self.engine setVideoConfiguration:videoEncoderConfig];
}

- (void)joinChannel {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WEAK_SELF
    [MMHttpTools getAppKeyAndTokenWithUserId:CURRENT_USERID
                                  completion:^(NSString * _Nullable appKey,
                                               NSString * _Nullable token,
                                               NSError * _Nullable error) {
        if (error) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            [MBProgressHUD mm_showError:error.localizedDescription];
        } else {
            if (token.length > 0) {
                [weakSelf toJoinWithToken:token];
            } else {
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                [MBProgressHUD mm_showError:@"Not find token!"];
            }
        }
    }];
}

- (void)toJoinWithToken:(NSString *)token {
    WEAK_SELF
    int code =  [self.engine joinChannelByToken:token
                                      channelId:self.channelId
                                            uid:CURRENT_USERID
                                    joinSuccess:^(NSString * _Nonnull channel, NSString * _Nonnull uid) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
    }];
    
    if (code != 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示" message:@"加入频道失败！" cancelTitle:@"知道了" okTitle:nil];
        [alert show];
    }
}

- (void)setPublishStreamUrl {
    if (!self.isSetPublishUrl) {
        return;
    }
//    NSString *pullUrl = [NSString stringWithFormat:@"rtmp://192.168.88.222:1935/live/%@", self.channelId];
//    NSString *pushUrl = [NSString stringWithFormat:@"rtmp://192.168.88.222:1935/live/%@", self.channelId];
//    NSString *pullUrl = [NSString stringWithFormat:@"rtmp://ssrs.bjx.cloud:1935/live/%@", self.channelId];
//    NSString *pushUrl = [NSString stringWithFormat:@"rtmp://ssrs.bjx.cloud:1935/live/%@", self.channelId];
    NSString *pullUrl = [NSString stringWithFormat:@"rtmp://106.14.122.122:1935/live/%@", self.channelId];
    NSString *pushUrl = [NSString stringWithFormat:@"rtmp://106.14.122.122:1935/live/%@", self.channelId];
    int code = [self.engine setPublishStreamUrl:pushUrl
                                        pullUrl:pullUrl];
    if (code == 0) {
        [MBProgressHUD mm_showSuccess:@"设置推流地址成功"];
    } else {
        [MBProgressHUD mm_showError:@"设置推流地址失败"];
    }
}

#pragma mark - MMRtcEngineDelegate

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didOccurWarning:(MMRtcWarningCode)warningCode{
    
}

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didOccurError:(MMRtcErrorCode)errorCode{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    switch (errorCode) {
        case MMRtcErrorCodeJoinChannelFailed: {
            
        } break;
            
        case MMRtcErrorCodeLeaveChannelFailed: {
            
        } break;
            
        case MMRtcErrorCodeUnMuteLocalAudioStreamFailed: {
            
        } break;
            
        case MMRtcErrorCodeMuteLocalAudioStreamFailed: {
            
        } break;
            
        case MMRtcErrorCodeUnMuteRemoteAudioStreamFailed: {
            
        } break;
            
        default:
            break;
    }
}

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSString * _Nonnull)uid{
    
}

- (void)rtcEngineDidLeaveChannel:(MMRtcEngineKit * _Nonnull)engine {
    
}

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didClientRoleChanged:(MMRtcClientRole)oldRole newRole:(MMRtcClientRole)newRole{
    
}

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSString * _Nonnull)uid{
    
}

- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSString * _Nonnull)uid reason:(MMRtcUserOfflineReason)reason{
    if ([self.mCurrentVideoUsers containsObject:uid]) {
        [self.mCurrentVideoUsers removeObject:uid];
        [self.mReceivedRemoteAudioDic removeObjectForKey:uid];
        [self.mReceivedRemoteVideoDic removeObjectForKey:uid];
        [self.collectionView reloadData];
    }
}

- (void)rtcEngine:(MMRtcEngineKit *)engine didVideoPublishStateChange:(NSString *)channel oldState:(MMRtcStreamPublishState)oldState newState:(MMRtcStreamPublishState)newState {
    [self.collectionView reloadData];
}

- (void)rtcEngine:(MMRtcEngineKit *)engine didRemoteVideoAddOfUser:(NSString *)uid {
    if ([self.mCurrentVideoUsers containsObject:uid]) {
        [self.mCurrentVideoUsers removeObject:uid];
    }
    [self.mCurrentVideoUsers addObject:uid];
    [self.mReceivedRemoteVideoDic setValue:@YES forKey:uid];
    
    [self.collectionView reloadData];
}

- (void)rtcEngine:(MMRtcEngineKit *)engine didRemoteAudioAddOfUser:(NSString *)uid {
    [self.mReceivedRemoteAudioDic setValue:@YES forKey:uid];
    
    [self.collectionView reloadData];
}

- (CVPixelBufferRef)rtcEngine:(MMRtcEngineKit *)engine didVideoFilterProcess:(CVPixelBufferRef)inputPixelBuffer {
    fuSetDefaultRotationMode([FUManager shareManager].deviceOrientation);
    CVPixelBufferRef outputPixelBuffer = [[FUManager shareManager] renderItemsToPixelBuffer:inputPixelBuffer];
    return outputPixelBuffer;
}

- (void)rtcEngine:(MMRtcEngineKit *)engine didPrintLog:(NSString *)log {
    [self.logsArrary addObject:log];
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mCurrentVideoUsers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (self.mCurrentVideoUsers.count == 0) {
        return cell;
    }
    NSString *uid = self.mCurrentVideoUsers[indexPath.item];
    if ([uid isEqualToString:CURRENT_USERID]) {
        UIView *localVideoView = [[UIView alloc] initWithFrame:cell.bounds];
        [cell.contentView addSubview:localVideoView];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:localVideoView.bounds];
        imgv.contentMode = UIViewContentModeScaleAspectFill;
        imgv.image = [UIImage imageNamed:@"video_canvas_default_icon"];
        [localVideoView addSubview:imgv];
        UILabel *uidLb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(localVideoView.frame) - 20, localVideoView.bounds.size.width, 20)];
        uidLb.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        uidLb.font = [UIFont systemFontOfSize:12];
        uidLb.textColor = [UIColor whiteColor];
        uidLb.text = [NSString stringWithFormat:@"本地：%@", CURRENT_USERID];
        [cell.contentView addSubview:uidLb];
        MMRtcVideoCanvas *local = [[MMRtcVideoCanvas alloc] init];
        local.view = localVideoView;
        local.uid = CURRENT_USERID;
        [self.engine setupLocalVideo:local];
    } else {
        UIView *remoteVideoView = [[UIView alloc] initWithFrame:cell.bounds];
        [cell.contentView addSubview:remoteVideoView];
        UIImageView *imgv = [[UIImageView alloc] initWithFrame:remoteVideoView.bounds];
        imgv.contentMode = UIViewContentModeScaleAspectFill;
        imgv.image = [UIImage imageNamed:@"video_canvas_default_icon"];
        [remoteVideoView addSubview:imgv];
        UILabel *uidLb = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(remoteVideoView.frame) - 20, remoteVideoView.bounds.size.width, 20)];
        uidLb.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        uidLb.font = [UIFont systemFontOfSize:12];
        uidLb.textColor = [UIColor whiteColor];
        uidLb.text = [NSString stringWithFormat:@"远端：%@", uid];
        [cell.contentView addSubview:uidLb];
        if ([self.mReceivedRemoteAudioDic valueForKey:uid]) {
            UILabel *audioLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(remoteVideoView.frame) - 20, CGRectGetMinY(uidLb.frame), 20, 20)];
            audioLb.layer.masksToBounds = YES;
            audioLb.layer.cornerRadius = 10;
            audioLb.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            audioLb.font = [UIFont systemFontOfSize:12];
            audioLb.textColor = [UIColor whiteColor];
            audioLb.textAlignment = NSTextAlignmentCenter;
            audioLb.text = @"A";
            [cell.contentView addSubview:audioLb];
        }
        if ([self.mReceivedRemoteVideoDic valueForKey:uid]) {
            UILabel *videoLb = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(remoteVideoView.frame) - 45, CGRectGetMinY(uidLb.frame), 20, 20)];
            videoLb.layer.masksToBounds = YES;
            videoLb.layer.cornerRadius = 10;
            videoLb.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            videoLb.font = [UIFont systemFontOfSize:12];
            videoLb.textColor = [UIColor whiteColor];
            videoLb.textAlignment = NSTextAlignmentCenter;
            videoLb.text = @"V";
            [cell.contentView addSubview:videoLb];
        }
        MMRtcVideoCanvas *local = [[MMRtcVideoCanvas alloc] init];
        local.view = remoteVideoView;
        local.uid = uid;
        [self.engine setupRemoteVideo:local];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = collectionView.bounds.size.width;
    CGSize size = CGSizeZero;
    switch (self.mCurrentVideoUsers.count) {
        case 1:
            size = CGSizeMake(width, width);
            break;
        case 2:
        case 3:
        case 4:
            size = CGSizeMake(width / 2.0, width / 2.0);
            break;
        default:
            size = CGSizeMake(width / 3.0, width / 3.0);
            break;
    }
    return size;
}

#pragma mark - FUAPIDemoBarDelegate
-(void)showTopView:(BOOL)shown{
    float h = shown?190:49;
    [self.demoBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.switchCameraBtn.mas_top).offset(-10);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(h);
    }];
}

-(void)filterShowMessage:(NSString *)message{
    [MBProgressHUD mm_showMessage:message];
}

-(void)filterValueChange:(FUBeautyParam *)param{
    int handle = [[FUManager shareManager] getHandleAboutType:FUNamaHandleTypeBeauty];
    [FURenderer itemSetParam:handle withName:@"filter_name" value:[param.mParam lowercaseString]];
    [FURenderer itemSetParam:handle withName:@"filter_level" value:@(param.mValue)]; //滤镜程度
    
    [FUManager shareManager].seletedFliter = param;
}

-(void)beautyParamValueChange:(FUBeautyParam *)param{
    if (_demoBar.selBottomIndex == 3) {//风格栏
        if (param.beautyAllparams) {
            [[FUManager shareManager] setStyleBeautyParams:param.beautyAllparams];
            [FUManager shareManager].currentStyle = param;
        }else{// 点击无
            [FUManager shareManager].currentStyle = param;
            [[FUManager shareManager] setBeautyParameters];
        }

        return;
    }
    
    if ([param.mParam isEqualToString:@"cheek_narrow"] || [param.mParam isEqualToString:@"cheek_small"]){//程度值 只去一半
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 0.5];
    }else if([param.mParam isEqualToString:@"blur_level"]) {//磨皮 0~6
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue * 6];
    }else{
        [[FUManager shareManager] setParamItemAboutType:FUNamaHandleTypeBeauty name:param.mParam value:param.mValue];
    }
}

-(void)restDefaultValue:(int)type{
    if (type == 1) {//美肤
       [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeSkin];
    }
    
    if (type == 2) {
       [[FUManager shareManager] setBeautyDefaultParameters:FUBeautyModuleTypeShape];
    }
}

#pragma mark - actions
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

// 返回按钮按下
- (void)backBtnClicked:(UIButton *)sender{
    //注意：退出频道调用后，再执行页面退出操作
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WEAK_SELF
    int code = [self.engine leaveChannel:^(MMRtcErrorCode code) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    if (code != 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }
}

- (void)logBtnClicked:(UIButton *)sender {
    LogMessageVC *vc = [[LogMessageVC alloc] init];
    vc.logsArray = [self.logsArrary copy];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)switchCameraBtnClicked:(UIButton *)sender {
    /* 清一下信息，防止快速切换有人脸信息缓存 */
    [FURenderer onCameraChange];
    // 切换摄像头
    [self.engine switchCamera];
}

- (void)localVideoMuteBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    // mute/unmute 本地视频
    [self.engine muteLocalVideoStream:sender.selected];
}

- (void)localAudioMuteBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    // mute/unmute 本地音频
    [self.engine muteLocalAudioStream:sender.selected];
}

- (void)localSpeakerMuteBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    // 是否使用扬声器
    [self.engine setEnableSpeakerphone:sender.selected];
}

- (void)videoFilterBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.demoBar.hidden = sender.selected;
    // 是否开启视频美颜
    [self.engine setVideoFilterEnable:!sender.selected];
}

#pragma mark - lazy
- (UIButton *)switchCameraBtn {
    if (!_switchCameraBtn) {
        _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _switchCameraBtn.bounds = CGRectMake(0, 0, 50, 50);
        _switchCameraBtn.layer.masksToBounds = YES;
        _switchCameraBtn.layer.cornerRadius = 25;
        _switchCameraBtn.center = CGPointMake(SCREEN_WIDTH * 0.1, SCREEN_HEIGHT - SCREEN_SAFE_BOTTOM - 30);
        _switchCameraBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [_switchCameraBtn setImage:[UIImage imageNamed:@"ic_switch_camera"] forState:UIControlStateNormal];
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCameraBtn;
}

- (UIButton *)localVideoMuteBtn {
    if (!_localVideoMuteBtn) {
        _localVideoMuteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _localVideoMuteBtn.bounds = self.switchCameraBtn.bounds;
        _localVideoMuteBtn.layer.masksToBounds = YES;
        _localVideoMuteBtn.layer.cornerRadius = 25;
        _localVideoMuteBtn.center = CGPointMake(SCREEN_WIDTH * 0.1 * 3, CGRectGetMidY(self.switchCameraBtn.frame));
        _localVideoMuteBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [_localVideoMuteBtn setImage:[UIImage imageNamed:@"ic_video_enabled"] forState:UIControlStateNormal];
        [_localVideoMuteBtn setImage:[UIImage imageNamed:@"ic_video_disabled"] forState:UIControlStateSelected];
        [_localVideoMuteBtn addTarget:self action:@selector(localVideoMuteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _localVideoMuteBtn;
}

- (UIButton *)localAudioMuteBtn {
    if (!_localAudioMuteBtn) {
        _localAudioMuteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _localAudioMuteBtn.bounds = self.switchCameraBtn.bounds;
        _localAudioMuteBtn.layer.masksToBounds = YES;
        _localAudioMuteBtn.layer.cornerRadius = 25;
        _localAudioMuteBtn.center = CGPointMake(SCREEN_WIDTH * 0.1 * 5, CGRectGetMidY(self.switchCameraBtn.frame));
        _localAudioMuteBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [_localAudioMuteBtn setImage:[UIImage imageNamed:@"ic_audio_enabled"] forState:UIControlStateNormal];
        [_localAudioMuteBtn setImage:[UIImage imageNamed:@"ic_audio_disabled"] forState:UIControlStateSelected];
        [_localAudioMuteBtn addTarget:self action:@selector(localAudioMuteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _localAudioMuteBtn;
}

- (UIButton *)localSpeakerMuteBtn {
    if (!_localSpeakerMuteBtn) {
        _localSpeakerMuteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _localSpeakerMuteBtn.bounds = self.switchCameraBtn.bounds;
        _localSpeakerMuteBtn.layer.masksToBounds = YES;
        _localSpeakerMuteBtn.layer.cornerRadius = 25;
        _localSpeakerMuteBtn.center = CGPointMake(SCREEN_WIDTH * 0.1 * 7, CGRectGetMidY(self.switchCameraBtn.frame));
        _localSpeakerMuteBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        [_localSpeakerMuteBtn setImage:[UIImage imageNamed:@"ic_speaker_enabled"] forState:UIControlStateNormal];
        [_localSpeakerMuteBtn setImage:[UIImage imageNamed:@"ic_speaker_disabled"] forState:UIControlStateSelected];
        [_localSpeakerMuteBtn addTarget:self action:@selector(localSpeakerMuteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _localSpeakerMuteBtn;
}

- (UIButton *)videoFilterBtn {
    if (!_videoFilterBtn) {
        _videoFilterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _videoFilterBtn.bounds = self.switchCameraBtn.bounds;
        _videoFilterBtn.layer.masksToBounds = YES;
        _videoFilterBtn.layer.cornerRadius = 25;
        _videoFilterBtn.center = CGPointMake(SCREEN_WIDTH * 0.1 * 9, CGRectGetMidY(self.switchCameraBtn.frame));
        _videoFilterBtn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        _videoFilterBtn.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [_videoFilterBtn setImage:[UIImage imageNamed:@"ic_videoFilter_enabled"] forState:UIControlStateNormal];
        [_videoFilterBtn setImage:[UIImage imageNamed:@"ic_videoFilter_disabled"] forState:UIControlStateSelected];
        [_videoFilterBtn addTarget:self action:@selector(videoFilterBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoFilterBtn;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat width = SCREEN_WIDTH - 20;
        CGFloat height = CGRectGetMinY(self.switchCameraBtn.frame) - NaviBarHeight - 20;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, NaviBarHeight + 10, width, height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewID];
    }
    return _collectionView;
}

- (FUAPIDemoBar *)demoBar {
    if (!_demoBar) {
        _demoBar = [[FUAPIDemoBar alloc] init];
        _demoBar.mDelegate = self;
        _demoBar.backgroundColor = [UIColor clearColor];
        _demoBar.bottomView.backgroundColor = [UIColor clearColor];
        _demoBar.topView.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        [_demoBar addSubview:effectview];
        [_demoBar sendSubviewToBack:effectview];
        /* 磨玻璃 */
        [effectview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(_demoBar);
        }];
    }
    return _demoBar;
}

- (NSMutableArray *)mCurrentVideoUsers {
    if (!_mCurrentVideoUsers) {
        _mCurrentVideoUsers = [NSMutableArray array];
    }
    return _mCurrentVideoUsers;
}

- (NSMutableArray *)logsArrary {
    if (!_logsArrary) {
        _logsArrary = [NSMutableArray array];
    }
    return _logsArrary;
}

- (NSMutableDictionary *)mReceivedRemoteAudioDic {
    if (!_mReceivedRemoteAudioDic) {
        _mReceivedRemoteAudioDic = [NSMutableDictionary dictionary];
    }
    return _mReceivedRemoteAudioDic;
}

- (NSMutableDictionary *)mReceivedRemoteVideoDic {
    if (!_mReceivedRemoteVideoDic) {
        _mReceivedRemoteVideoDic = [NSMutableDictionary dictionary];
    }
    return _mReceivedRemoteVideoDic;
}

@end
