//
//  AudioVC.m
//  MMDemo
//
//  Created by max  on 2020/8/21.
//  Copyright © 2020 max. All rights reserved.
//

#import "AudioVC.h"
#import "QiSlider.h"
#import "AlertView.h"
#import "MMDemoUser.h"
#import "MBProgressHUD+MMCategory.h"
#import "MMTools.h"
#import "MMHttpTools.h"
#import "LogMessageVC.h"
@interface AudioVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource,MMRtcEngineDelegate>
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)UIButton *rtmpPushBtn;
@property (nonatomic,strong)UIButton *cancelRtmpPushBtn;
@property (nonatomic,strong)UIButton *speakerOrEarBtn;
@property (nonatomic,strong)UIButton *btnChangeToBroadcaster;
@property (nonatomic,strong)QiSlider *localslider;
@property (nonatomic,strong)QiSlider *allRemoteslider;
@property (nonatomic,strong)QiSlider *firstRemoteslider;
@property (nonatomic,strong)UILabel *localvolume;
@property (nonatomic,strong)UILabel *allRemotevolume;
@property (nonatomic,strong)UILabel *firstRemotevolume;
@property (nonatomic,strong)NSMutableArray *arrHasUserMySelf;
@property (nonatomic,strong)UITextField *txtRemotevolume;
@property (nonatomic,strong)UITableView *msgTableView;
@property (nonatomic,strong)NSMutableArray *msgArray;
// 日志信息
@property (nonatomic, strong) NSMutableArray *logsArrary;
@end

@implementation AudioVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title =  [NSString stringWithFormat:@"频道ID:%@ 角色:%@", self.channelId, self.isBroaster ? @"主播" : @"观众"] ;
    
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
    
    self.msgArray = [NSMutableArray array];
    self.allMembers = [NSMutableArray array];
    
    [self setupRtcEngine];
    [self joinChannel];
}

- (void)dealloc {
    [MMRtcEngineKit destroy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - MMRtcEngineKit
- (void)setupRtcEngine {
    // 根据 appKey 初始化 RTC 引擎对象
    self.engine = [MMRtcEngineKit sharedEngineWithAppKey:CURRENT_APPKEY];
    // 设置代理
    self.engine.delegate = self;
    // 设置调试日志等级
    [self.engine setLogFilter:MMRtcLogLevelDebug];
    
    if (self.isBroaster == YES) {
        [self rtmpPush];
    }
    
    // 设置频道场景
    [self.engine setChannelProfile:MMRtcChannelProfileLiveBroadcasting];
    // 设置默认是否使用扬声器播放音频
    [self.engine setDefaultAudioRouteToSpeakerphone:self.isSpeaker];
    // 设置角色
    if (self.isBroaster) {
        [self.engine setClientRole:MMRtcClientRoleBroadcaster];
    } else {
        [self.engine setClientRole:MMRtcClientRoleAudience];
    }
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
    int code = [self.engine joinChannelByToken:token
                                     channelId:self.channelId
                                           uid:CURRENT_USERID
                                   joinSuccess:^(NSString * _Nonnull channel, NSString * _Nonnull uid) {
        MMDemoUser *user = [MMDemoUser createUser:uid];
        [weakSelf.allMembers addObject:user];
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
//        if (weakSelf.isPushPull == YES) {
//            [weakSelf rtmpPush];
//        }
        [weakSelf addV];
    }];
    
    if (code !=0) {
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"加入频道失败！" cancelTitle:@"知道了"okTitle:nil];
        [alert show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

-(void)addV{
    
    [self.view addSubview:self.collectionView];
    
    [self.view addSubview:self.btnChangeToBroadcaster];
    [self.view addSubview:self.speakerOrEarBtn];
    [self.view addSubview:self.rtmpPushBtn];
    [self.view addSubview:self.cancelRtmpPushBtn];
    
    if (self.isBroaster) {
        [self.btnChangeToBroadcaster setTitle:@"切为观众" forState:UIControlStateNormal];
        [self.engine setClientRole:MMRtcClientRoleBroadcaster];
        [self refreshUI];
    }else{
        [self.btnChangeToBroadcaster setTitle:@"切为主播" forState:UIControlStateNormal];
        [self.engine setClientRole:MMRtcClientRoleAudience];
        [self refreshUI];
    }
    
    [self.view addSubview:self.localvolume];
    [self.view addSubview:self.localslider];
    [self.view addSubview:self.allRemoteslider];
    [self.view addSubview:self.allRemotevolume];
    [self.view addSubview:self.txtRemotevolume];
    [self.view addSubview:self.firstRemoteslider];
    
    [self.view addSubview:self.msgTableView];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.msgArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msg" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    NSString *msg = self.msgArray[indexPath.row];
    UILabel *label = [cell.contentView viewWithTag:2];
    if (!label) {
        label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 40, 20)];
        label.numberOfLines = 0;
        label.tag = 2;
        label.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:label];
    }
    label.text = msg;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.txtRemotevolume resignFirstResponder];
}

-(void)localsliderTouchUp:(QiSlider *)sender{
    NSInteger setvolume = (int)sender.value;
    [self.engine adjustRecordingSignalVolume:setvolume];
}

-(void)allRemotesliderTouchUp:(QiSlider *)sender{
    NSInteger setvolume = (int)sender.value;
    [self.engine adjustPlaybackSignalVolume:setvolume];
}

-(void)firstRemotesliderTouchUp:(QiSlider *)sender{
    if ([_txtRemotevolume.text isEqualToString:@""]) {
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"输入要控制音量的远端用户！" cancelTitle:@"知道了"okTitle:nil];
        [alert show];
        return;
    }
    int setvolume = (int)sender.value;
    [self.engine adjustUserPlaybackSignalVolume:_txtRemotevolume.text volume:setvolume];
}

-(void)btnChangeToBroadcasterClick{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.isBroaster) {
        int code =  [self.engine setClientRole:MMRtcClientRoleAudience];
        if (code != 0) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD mm_showError:@"切换为观众失败"];
        }
    } else {
        int code = [self.engine setClientRole:MMRtcClientRoleBroadcaster];
        if (code != 0) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD mm_showError:@"切换为主播失败"];
        }
    }
    
}

-(void)rtmpPush {
    //NSString *pullUrl = [NSString stringWithFormat:@"rtmp://ssrs.bjx.cloud:1935/live/%@", self.channelId];
    //NSString *pushUrl = [NSString stringWithFormat:@"rtmp://ssrs.bjx.cloud:1935/live/%@", self.channelId];
    NSString *pullUrl = [NSString stringWithFormat:@"rtmp://106.14.122.122:1935/live/%@", self.channelId];
    NSString *pushUrl = [NSString stringWithFormat:@"rtmp://106.14.122.122:1935/live/%@", self.channelId];
    int code = [self.engine setPublishStreamUrl:pushUrl pullUrl:pullUrl];
    if (code == 0) {
        [MBProgressHUD mm_showSuccess:@"设置推流地址成功"];
    } else {
        [MBProgressHUD mm_showError:@"设置推流地址失败"];
    }
}

-(void)rtmpPushBtnClick{
//    NSString *pullUrl = [NSString stringWithFormat:@"rtmp://192.168.88.222:1935/live/%@", self.channelId];
//    NSString *pushUrl = [NSString stringWithFormat:@"rtmp://192.168.88.222:1935/live/%@", self.channelId];
    [self rtmpPush];
}

-(void)cancelRtmpPushBtnClick{
    int code = [self.engine setPublishStreamUrl:@"" pullUrl:@""];
    if (code == 0) {
        [MBProgressHUD mm_showSuccess:@"取消推流地址成功"];
    } else {
        [MBProgressHUD mm_showError:@"取消推流地址失败"];
    }
}

-(void)speakerOrEarBtnClick{
    BOOL isEnable = [self.engine isSpeakerphoneEnabled];
    int code = [self.engine setEnableSpeakerphone:!isEnable];
    if (code == 0) {
        NSString *title = !isEnable ? @"切换听筒" : @"切扬声器";
        [self.speakerOrEarBtn setTitle:title forState:UIControlStateNormal];
        [MBProgressHUD mm_showSuccess:@"切换成功"];
    } else {
        [MBProgressHUD mm_showError:@"切换失败"];
    }
}

- (NSInteger)allBroastersCount {
    NSInteger count = 0;
    for (MMDemoUser *user in self.allMembers) {
        if (user.publishing) {
            count++;
        }
    }
    return count;
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5,5, 5);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.allMembers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    
    UILabel *label = [cell.contentView viewWithTag:2];//显示底部操作标签
    UILabel *ownerLabel = [cell.contentView viewWithTag:3];//显示中部文字标签，显示用户uid
    UILabel *topLabel = [cell.contentView viewWithTag:4];//显示特殊任务的顶部标签（目前特殊任务有我自己和房主）
    if (!label) {
        
        label = [[UILabel alloc]initWithFrame:CGRectMake(0, 55, 80, 25)];
        label.tag = 2;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:10];
        [cell.contentView addSubview:label];
        
        ownerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 65/2, 80, 25)];
        ownerLabel.tag = 3;
        ownerLabel.textColor = [UIColor blackColor];
        ownerLabel.textAlignment = NSTextAlignmentCenter;
        ownerLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:ownerLabel];
        
        topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 80, 15)];
        topLabel.tag = 4;
        topLabel.textColor = [UIColor blackColor];
        topLabel.textAlignment = NSTextAlignmentCenter;
        topLabel.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:topLabel];
    }
    
    
    MMDemoUser *user = self.allMembers[indexPath.item];//找到这个用户
    BOOL isMe = [user.userId isEqualToString:CURRENT_USERID];//判断是否是我
    
    ownerLabel.text = user.userId;
    if (isMe) {
        //是我自己
        topLabel.hidden = NO;
        topLabel.text = @"我";
        cell.backgroundColor =OX_COLOR(0Xff6fa6);
        
        if (self.myPublishStatus > 0) {
            //我正在上麦
            //            imgV.image = [UIImage imageNamed:@"head_icon_6"];
            label.text = @"点击下麦";
        }
        else {
            //我没有上麦
            //            imgV.image = [UIImage imageNamed:@"head_icon_6"];
            label.text = @"点击上麦";
        }
        
        if (self.isBroaster) {
            label.hidden =NO;
        }else{
            label.hidden =YES;
        }
    }
    else {
        //是别人
        topLabel.hidden = YES;
        
        cell.backgroundColor =OX_COLOR(0X9266bf);
        if (user.isSubscribed) {
            label.text = @"点击静音";
        }
        else {
            label.text = @"点击取消静音";
        }
    }
    
    if (user.isSpeak) {
        cell.backgroundColor = [UIColor redColor];
    }else{
        cell.backgroundColor =OX_COLOR(0X9266bf);
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MMDemoUser *user = self.allMembers[indexPath.item];//找到这个用户
    BOOL isMe = [user.userId isEqualToString:CURRENT_USERID];//判断是否是我
    
    if (isMe) {
        //是我
        if (self.myPublishStatus > 0) {
            WEAK_SELF
            AlertView *alert = [[AlertView alloc] initWithTitle:@"下麦确认"message:@"您正在上麦，是否要下麦？"cancelTitle:@"否"okTitle:@"是"];
            [alert show];
            alert.OKBlock = ^(AlertView *alertView) {
                [alertView dismiss];
                [weakSelf unPublish];
            };
            
        }
        else {
            //我没有上麦
            [self publish];
            
        }
    }
    else {
        //是别人
        if (user.publishing) {
            //这个人正在上麦
            if (user.isSubscribed) {
                [self unSubscribe:user];
            }
            else{
                [self subscribe:user];
            }
        }
        else {
            AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"该用户未上麦" cancelTitle:@"知道了"okTitle:nil];
            [alert show];
        }
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}


- (MMDemoUser *)findMemberInAllMembersFromUid:(NSString *)uid{
    if (!uid) {
        return nil;
    }
    for (MMDemoUser *user in self.allMembers) {
        if ([user.userId isEqualToString:uid]) {
            return user;
        }
    }
    return nil;
}

- (void)updateMemberInAllMembersFromUid:(NSString *)uid member:(MMDemoUser *)currentuser{
    if (!uid) {
        return;
    }
    if (!currentuser) {
        return;
    }
    
    for (int i = 0; i < self.allMembers.count; i++) {
        MMDemoUser *user = self.allMembers[i];
        if ([user.userId isEqualToString:uid]) {
            [self.allMembers replaceObjectAtIndex:i withObject:currentuser];
        }
    }
}

//上麦。
- (void)publish{
    int code = [self.engine muteLocalAudioStream:NO];
    if (code == 0) {
        
    }else if (code ==-1) {
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"上麦失败！" cancelTitle:@"知道了"okTitle:nil];
        [alert show];
    }
}

//下麦
- (void)unPublish{
    int code = [self.engine muteLocalAudioStream:YES];
    if (code == 0) {
        
    }else if (code ==-1) {
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"下麦失败！" cancelTitle:@"知道了"okTitle:nil];
        [alert show];
    }
}

//订阅。订阅某个user的流。user可能是房主，也可能是普通观众
- (void)subscribe:(MMDemoUser *)user{
    int code = [self.engine muteRemoteAudioStream:user.userId mute:NO];
    if (code == 0) {
        MMDemoUser *currentuser = [self findMemberInAllMembersFromUid:user.userId];
        currentuser.isSubscribed = YES;
        [self updateMemberInAllMembersFromUid:user.userId member:currentuser];
        [self refreshUI];
    }
}
//取消订阅
- (void)unSubscribe:(MMDemoUser *)user{
    int code = [self.engine muteRemoteAudioStream:user.userId mute:YES];
    if (code == 0) {
        MMDemoUser *currentuser = [self findMemberInAllMembersFromUid:user.userId];
        currentuser.isSubscribed = NO;
        [self updateMemberInAllMembersFromUid:user.userId member:currentuser];
        [self refreshUI];
    }
}


#pragma mark MMRtcEngineDelegate

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didOccurWarning:(MMRtcWarningCode)warningCode{
    
}

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSString * _Nonnull)uid{
    [self.msgArray addObject:[NSString stringWithFormat:@"%@ 加入频道", uid]];
    [self.msgTableView reloadData];
}

- (void)rtcEngineDidLeaveChannel:(MMRtcEngineKit * _Nonnull)engine {
    
}

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didClientRoleChanged:(MMRtcClientRole)oldRole newRole:(MMRtcClientRole)newRole{
    
    if (newRole == MMRtcClientRoleBroadcaster) {
        self.isBroaster = YES;
        [self.msgArray addObject:@"我的角色切换为主播"];
        [self.msgTableView reloadData];
        [self.btnChangeToBroadcaster setTitle:@"切为观众" forState:UIControlStateNormal];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD mm_showSuccess:@"切换为主播成功"];
    }
    else {
        self.isBroaster = NO;
        [self.msgArray addObject:@"我的角色切换为观众"];
        [self.msgTableView reloadData];
        [self.btnChangeToBroadcaster setTitle:@"切为主播" forState:UIControlStateNormal];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD mm_showSuccess:@"切换为观众成功"];
    }
    self.navigationItem.title  =  [NSString stringWithFormat:@"频道ID:%@ 角色:%@",self.channelId ,self.isBroaster?@"主播":@"观众"] ;
    [self refreshUI];
}

-(void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSString * _Nonnull)uid{
    MMDemoUser *user = [self findMemberInAllMembersFromUid:uid];
    if (!user){
        user = [MMDemoUser createUser:uid];
        user.publishing = YES;
        user.isSubscribed = YES;
        [self.allMembers addObject:user];
        [self.msgArray addObject:[NSString stringWithFormat:@"主播:%@ 加入频道！",uid]];
        [self.msgTableView reloadData];
    }else {
        user.publishing = YES;
        user.isSubscribed = YES;
        [self updateMemberInAllMembersFromUid:uid member:user];
    }
    [self refreshUI];
}

- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSString * _Nonnull)uid reason:(MMRtcUserOfflineReason)reason{
    MMDemoUser *user = [self findMemberInAllMembersFromUid:uid];
    if (user){
        [self.allMembers removeObject:user];
        [self.msgArray addObject:[NSString stringWithFormat:@"主播:%@ 离开频道！",uid] ];
        [self.msgTableView reloadData];
    }
    [self refreshUI];
}

- (void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine localAudioStateChange:(MMRtcStreamPublishState)state error:(MMRtcAudioLocalError)error{
    if (error == MMRtcAudioLocalErrorOk) {
        if (state == MMRtcStreamPublishNoPublished) {
            self.myPublishStatus = 0;
            [self.msgArray addObject:[NSString stringWithFormat:@"我下麦了"] ];
            [self.msgTableView reloadData];
        }
        else if (state == MMRtcStreamPublishPublished){
            self.myPublishStatus = 1;
            [self.msgArray addObject:[NSString stringWithFormat:@"我上麦了"] ];
            [self.msgTableView reloadData];
        }
    }
    [self refreshUI];
}

-(void)rtcEngine:(MMRtcEngineKit *)engine didAudioRouteChanged:(MMRtcAudioOutputRouting)routing{
    
}

//rtmp状态回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine rtmpStreamingChangedToState:(NSString *_Nonnull)url state:(MMRtcRtmpStreamingState)state{
    if (state == MMRtcRtmpStreamingStateRunning) {
        [self.msgArray addObject:@"rtmp Running"];
        [self.msgTableView reloadData];
    }else if (state == MMRtcRtmpStreamingStateIdle) {
        [self.msgArray addObject:@"rtmp Idle"];
        [self.msgTableView reloadData];
    }else if (state == MMRtcRtmpStreamingStateRecovering) {
        [self.msgArray addObject:@"rtmp Recovering"];
        [self.msgTableView reloadData];
    }else if (state == MMRtcRtmpStreamingStateConnecting) {
        [self.msgArray addObject:@"rtmp Connecting"];
        [self.msgTableView reloadData];
    }
}

//vad检测回调
- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine speaker:(NSString *_Nonnull)speakerUid active:(bool)active{
    MMDemoUser *user = [self findMemberInAllMembersFromUid:speakerUid];
    user.isSpeak = active;
    [self refreshUI];
}

- (void)rtcEngine:(MMRtcEngineKit *)engine didPrintLog:(NSString *)log {
    [self.logsArrary addObject:log];
}

- (void)refreshUI{
    [MMTools performTaskOnMainThread:^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        BOOL canRtmp = ([self allBroastersCount] <= 1 && self.isBroaster);
        self.rtmpPushBtn.enabled = canRtmp;
        self.cancelRtmpPushBtn.enabled = canRtmp;
        self.rtmpPushBtn.backgroundColor = canRtmp ? OX_COLOR(0X3F73FE) : [UIColor lightGrayColor];
        self.cancelRtmpPushBtn.backgroundColor = canRtmp ? OX_COLOR(0X3F73FE) : [UIColor lightGrayColor];
        [self.collectionView reloadData];
    }];
}

#pragma mark - lazy
- (NSMutableArray *)logsArrary {
    if (!_logsArrary) {
        _logsArrary = [NSMutableArray array];
    }
    return _logsArrary;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(80,80);
        layout.minimumLineSpacing = 5.0;
        layout.minimumInteritemSpacing = 5.0;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetMinY(self.msgTableView.frame)) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.alwaysBounceVertical=YES;
        _collectionView.bounces = YES;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([self class])];
    }
    return _collectionView;
}

- (UITableView *)msgTableView {
    if (!_msgTableView) {
        _msgTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(self.txtRemotevolume.frame) - 210, SCREEN_WIDTH, 200)
                                                    style:UITableViewStylePlain];
        _msgTableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _msgTableView.delegate = self;
        _msgTableView.dataSource = self;
        _msgTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _msgTableView.showsVerticalScrollIndicator = NO;
        [_msgTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"msg"];
    }
    return _msgTableView;
}

-(UIButton *)btnChangeToBroadcaster{
    if (!_btnChangeToBroadcaster) {
        _btnChangeToBroadcaster = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnChangeToBroadcaster.frame = CGRectMake(16, SCREEN_HEIGHT - SCREEN_SAFE_BOTTOM - 60, (SCREEN_WIDTH - 50) / 4.0, 40);
        [_btnChangeToBroadcaster setBackgroundColor:OX_COLOR(0X3F73FE)];
        [_btnChangeToBroadcaster setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnChangeToBroadcaster setTitle:@"切为主播" forState:UIControlStateNormal];
        _btnChangeToBroadcaster.titleLabel.font = [UIFont systemFontOfSize:14];
        _btnChangeToBroadcaster.layer.cornerRadius = 10;
        _btnChangeToBroadcaster.layer.masksToBounds = YES;
        [_btnChangeToBroadcaster addTarget:self action:@selector(btnChangeToBroadcasterClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnChangeToBroadcaster;
}

-(UIButton *)rtmpPushBtn{
    if (!_rtmpPushBtn) {
        _rtmpPushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rtmpPushBtn.frame = CGRectMake(CGRectGetMaxX(self.speakerOrEarBtn.frame) + 6,
                                        CGRectGetMinY(self.btnChangeToBroadcaster.frame),
                                        CGRectGetWidth(self.btnChangeToBroadcaster.frame),
                                        CGRectGetHeight(self.btnChangeToBroadcaster.frame));
        [_rtmpPushBtn setBackgroundColor:OX_COLOR(0X3F73FE)];
        [_rtmpPushBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rtmpPushBtn setTitle:@"设置推流" forState:UIControlStateNormal];
        _rtmpPushBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _rtmpPushBtn.layer.cornerRadius = 10;
        _rtmpPushBtn.layer.masksToBounds = YES;
        [_rtmpPushBtn addTarget:self action:@selector(rtmpPushBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rtmpPushBtn;
}

-(UIButton *)cancelRtmpPushBtn{
    if (!_cancelRtmpPushBtn) {
        _cancelRtmpPushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelRtmpPushBtn.frame = CGRectMake(CGRectGetMaxX(self.rtmpPushBtn.frame) + 6,
                                              CGRectGetMinY(self.btnChangeToBroadcaster.frame),
                                              CGRectGetWidth(self.btnChangeToBroadcaster.frame),
                                              CGRectGetHeight(self.btnChangeToBroadcaster.frame));
        [_cancelRtmpPushBtn setBackgroundColor:OX_COLOR(0X3F73FE)];
        [_cancelRtmpPushBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelRtmpPushBtn setTitle:@"取消推流" forState:UIControlStateNormal];
        _cancelRtmpPushBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelRtmpPushBtn.layer.cornerRadius = 10;
        _cancelRtmpPushBtn.layer.masksToBounds =YES;
        [_cancelRtmpPushBtn addTarget:self action:@selector(cancelRtmpPushBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelRtmpPushBtn;
}

-(UIButton *)speakerOrEarBtn{
    if (!_speakerOrEarBtn) {
        _speakerOrEarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _speakerOrEarBtn.frame = CGRectMake(CGRectGetMaxX(self.btnChangeToBroadcaster.frame) + 6,
                                            CGRectGetMinY(self.btnChangeToBroadcaster.frame),
                                            CGRectGetWidth(self.btnChangeToBroadcaster.frame),
                                            CGRectGetHeight(self.btnChangeToBroadcaster.frame));
        [_speakerOrEarBtn setBackgroundColor:OX_COLOR(0X3F73FE)];
        [_speakerOrEarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_speakerOrEarBtn setTitle:@"切扬声器" forState:UIControlStateNormal];
        _speakerOrEarBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _speakerOrEarBtn.layer.cornerRadius = 10;
        _speakerOrEarBtn.layer.masksToBounds =YES;
        [_speakerOrEarBtn addTarget:self action:@selector(speakerOrEarBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerOrEarBtn;
}


-(UITextField *)txtRemotevolume{
    if (!_txtRemotevolume) {
        _txtRemotevolume = [[UITextField alloc]initWithFrame:CGRectMake(16, CGRectGetMinY(self.localvolume.frame) - 35,
                                                                        CGRectGetWidth(self.allRemotevolume.frame), 30)];
        _txtRemotevolume.placeholder = @"输入用户名";
        _txtRemotevolume.font = [UIFont systemFontOfSize:14.0f];
        _txtRemotevolume.layer.borderWidth = 1.0;
        _txtRemotevolume.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _txtRemotevolume.textAlignment = NSTextAlignmentCenter;
    }
    return _txtRemotevolume;
}

- (QiSlider *)firstRemoteslider{
    if (_firstRemoteslider == nil) {
        _firstRemoteslider = [[QiSlider alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.allRemoteslider.frame),
                                                                       CGRectGetMinY(self.txtRemotevolume.frame),
                                                                       CGRectGetWidth(self.allRemoteslider.frame),
                                                                       CGRectGetHeight(self.allRemoteslider.frame))];
        _firstRemoteslider.minimumValue = 0;
        _firstRemoteslider.maximumValue = 400;
        _firstRemoteslider.value = 100;
        _firstRemoteslider.maximumTrackTintColor = [UIColor lightGrayColor];
        _firstRemoteslider.minimumTrackTintColor = [UIColor blueColor];
        _firstRemoteslider.leftOrRight = @"right";
        _firstRemoteslider.showNum =@"yes";
        //添加事件
        [_firstRemoteslider addTarget:self action:@selector(firstRemotesliderTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        
    }
    return _firstRemoteslider;
}

-(UILabel *)localvolume{
    if (!_localvolume) {
        _localvolume = [[UILabel alloc]initWithFrame:CGRectMake(16, CGRectGetMinY(self.allRemotevolume.frame) - 35,
                                                                CGRectGetWidth(self.allRemotevolume.frame), 30)];
        _localvolume.text = @"本地音量";
        _localvolume.font =[UIFont systemFontOfSize:14.0f];
    }
    return _localvolume;
}


- (QiSlider *)localslider{
    if (_localslider == nil) {
        _localslider = [[QiSlider alloc]initWithFrame:CGRectMake(CGRectGetMinX(self.allRemoteslider.frame),
                                                                 CGRectGetMinY(self.localvolume.frame),
                                                                 CGRectGetWidth(self.allRemoteslider.frame),
                                                                 CGRectGetHeight(self.allRemoteslider.frame))];
        //设置当前slider的值，默认是0
        _localslider.minimumValue = 0;
        _localslider.maximumValue = 400;
        _localslider.value = 100;
        _localslider.maximumTrackTintColor = [UIColor lightGrayColor];
        _localslider.minimumTrackTintColor = [UIColor blueColor];
        _localslider.leftOrRight = @"right";
        _localslider.showNum = @"yes";
        //添加事件
        [_localslider addTarget:self action:@selector(localsliderTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        
    }
    return _localslider;
}

-(UILabel *)allRemotevolume{
    if (!_allRemotevolume) {
        _allRemotevolume = [[UILabel alloc]initWithFrame:CGRectMake(16, CGRectGetMinY(self.btnChangeToBroadcaster.frame) - 40, 80, 30)];
        _allRemotevolume.text = @"远端音量";
        _allRemotevolume.font =[UIFont systemFontOfSize:14.0f];
    }
    return _allRemotevolume;
}

- (QiSlider *)allRemoteslider{
    if (_allRemoteslider == nil) {
        CGFloat allRemoteVolumeMaxX = CGRectGetMaxX(self.allRemotevolume.frame);
        _allRemoteslider = [[QiSlider alloc]initWithFrame:CGRectMake(allRemoteVolumeMaxX,
                                                                     CGRectGetMinY(self.allRemotevolume.frame),
                                                                     SCREEN_WIDTH - allRemoteVolumeMaxX - 16, 20)];
        //设置当前slider的值，默认是0
        _allRemoteslider.minimumValue = 0;
        _allRemoteslider.maximumValue = 400;
        _allRemoteslider.value = 100;
        _allRemoteslider.maximumTrackTintColor = [UIColor lightGrayColor];
        _allRemoteslider.minimumTrackTintColor = [UIColor blueColor];
        _allRemoteslider.leftOrRight = @"right";
        _allRemoteslider.showNum =@"yes";
        //添加事件
        [_allRemoteslider addTarget:self action:@selector(allRemotesliderTouchUp:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
        
    }
    return _allRemoteslider;
}

@end
