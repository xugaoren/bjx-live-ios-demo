//
//  P2PVideoVC.m
//  MMRtcKit_Example
//
//  Created by RunX on 2020/12/30.
//  Copyright © 2020 cf_olive@163.com. All rights reserved.
//

#import "P2PVideoVC.h"
#import <MMRtcKit/MMRtcKit.h>
#import "MBProgressHUD.h"
#import "AlertView.h"

@interface P2PVideoVC () <MMRtcEngineDelegate,UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) MMRtcEngineKit *engine;
@property (nonatomic, strong) UIView *localVideoView;
@property (nonatomic, strong) UIView *remoteVideoView;
@property (nonatomic, strong) UILabel *localLabel;
@property (nonatomic, strong) UILabel *remoteLabel;
@property (nonatomic, strong) UITableView *p2pTableView;

@end

@implementation P2PVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title =  [NSString stringWithFormat:@"%@:%@", self.p2pUrl, self.p2pPort];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"退出" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 50, 40);
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
    
    [self.view addSubview:self.localVideoView];
    [self.view addSubview:self.remoteVideoView];
    [self.view addSubview:self.localLabel];
    [self.view addSubview:self.remoteLabel];
    [self.view addSubview:self.p2pTableView];
    
    self.engine = [MMRtcEngineKit sharedEngineWithAppKey:CURRENT_APPKEY];
  
    self.engine.delegate = self;
    [self.engine setChannelProfile:MMRtcChannelProfileLiveBroadcasting];
    
    MMRtcVideoCanvas *local = [[MMRtcVideoCanvas alloc] init];
    local.view = self.localVideoView;
    [self.engine setupLocalVideo:local];
    
    MMRtcVideoCanvas *remote = [[MMRtcVideoCanvas alloc] init];
    remote.view = self.remoteVideoView;
    [self.engine setupRemoteVideo:remote];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

// 返回按钮按下
- (void)backBtnClicked:(UIButton *)sender{
    //注意：退出频道调用后，再执行页面退出操作
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    WEAK_SELF
    int code = [self.engine leaveChannel:^(MMRtcErrorCode code) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    if (code != 0) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark MMRtcEngineDelegate

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

-(void)rtcEngine:(MMRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSString * _Nonnull)uid{
    
}

- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSString * _Nonnull)uid reason:(MMRtcUserOfflineReason)reason{
    
}

- (void)rtcEngine:(MMRtcEngineKit *_Nonnull)engine didLoadNew:(NSString * _Nonnull)uid reason:(MMRtcUserOfflineReason)reason {
    [self.p2pTableView reloadData];
}

#pragma mark - lazy
- (UIView *)localVideoView {
    if (!_localVideoView) {
        CGFloat width = (SCREEN_WIDTH - 40) * 0.5;
        CGFloat height = width * 800.0 / 450.0;
        _localVideoView = [[UIView alloc] initWithFrame:CGRectMake(10, 100, width, height)];
        _localVideoView.backgroundColor = [UIColor lightGrayColor];
        _localVideoView.tag = 10000;
    }
    return _localVideoView;
}

- (UIView *)remoteVideoView {
    if (!_remoteVideoView) {
        CGFloat width = (SCREEN_WIDTH - 40) * 0.5;
        CGFloat height = width * 800.0 / 450.0;
        _remoteVideoView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH + 10) * 0.5, 100, width, height)];
        _remoteVideoView.backgroundColor = [UIColor lightGrayColor];
        _remoteVideoView.tag = 20000;
    }
    return _remoteVideoView;
}

- (UILabel *)localLabel {
    if (!_localLabel) {
        _localLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.localVideoView.frame),
                                                                CGRectGetMaxY(self.localVideoView.frame),
                                                                self.localVideoView.frame.size.width, 20)];
        _localLabel.font = [UIFont systemFontOfSize:14];
        _localLabel.textColor = [UIColor blackColor];
        _localLabel.textAlignment = NSTextAlignmentCenter;
        _localLabel.text = @"本地视频";
    }
    return _localLabel;
}

- (UILabel *)remoteLabel {
    if (!_remoteLabel) {
        _remoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.remoteVideoView.frame),
                                                                 CGRectGetMaxY(self.remoteVideoView.frame),
                                                                 self.remoteVideoView.frame.size.width, 20)];
        _remoteLabel.font = [UIFont systemFontOfSize:14];
        _remoteLabel.textColor = [UIColor blackColor];
        _remoteLabel.textAlignment = NSTextAlignmentCenter;
        _remoteLabel.text = @"远端视频";
    }
    return _remoteLabel;
}

- (UITableView *)p2pTableView {
    if (!_p2pTableView) {
        CGFloat posY = CGRectGetMaxY(self.remoteVideoView.frame) + 30;
        _p2pTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, posY , UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - posY) style:UITableViewStylePlain];
        _p2pTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _p2pTableView.backgroundColor = [UIColor yellowColor];
        _p2pTableView.scrollEnabled = NO;
        _p2pTableView.delegate = self;
        _p2pTableView.dataSource = self;
        
    }
    return _p2pTableView;
}


#pragma mark - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSInteger count = [[self.engine getP2pArray] count];
    return 0;//count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"P2PCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
//    NSString *uuid = [[self.engine getP2pArray] objectAtIndex:indexPath.row];
//    if ([self.engine getSender] != nil && [uuid isEqualToString:[self.engine getSender]]) {
//        cell.textLabel.text = [NSString stringWithFormat:@"self %@",uuid];
//    }  else if ([self.engine getTarget] != nil && [uuid isEqualToString:[self.engine getTarget]]) {
//        cell.textLabel.text = [NSString stringWithFormat:@"target %@",uuid];
//    }
//    else {
//        cell.textLabel.text = [NSString stringWithFormat:@"%@",uuid];
//    }
    //NSLog(@"cell:%@ %d", uuid, indexPath.row);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    //NSString *to = [[self.engine getP2pArray] objectAtIndex:indexPath.row];
    //[self.engine setP2PTarget: to];
    
    //MMRtcClientRoleCaller = 3
    //MMRtcClientRoleCallee = 4
    [self.engine setClientRole:3];
}

@end
