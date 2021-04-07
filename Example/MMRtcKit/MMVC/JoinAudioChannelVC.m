//
//  JoinAudioChannelVC.m
//  MMRtcSample
//
//  Created by RunX on 2021/1/21.
//

#import <AVFoundation/AVFoundation.h>
#import "JoinAudioChannelVC.h"
#import "TableViewInputCell.h"
#import "TableViewSwitchCell.h"
#import "AudioVC.h"
#import "MBProgressHUD+MMCategory.h"
#import "AlertView.h"
#import "MMTools.h"

@interface JoinAudioChannelVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, assign) MMRtcChannelProfile channelProfile;
@property (nonatomic, assign) BOOL isBroadcaster;
@property (nonatomic, assign) BOOL isSpeaker;
@property (nonatomic, assign) BOOL isPushPull;

@end

@implementation JoinAudioChannelVC

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.channelProfile = MMRtcChannelProfileCommunication;
    self.isBroadcaster = YES;
    self.isSpeaker = NO;
    self.isPushPull = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"音频直播配置";
    
    [self.view addSubview:self.confirmBtn];
    [self.view addSubview:self.tableView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(viewEndEditing)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF;
    switch (indexPath.row) {
        case 0: {
            TableViewInputCell *cell = [tableView dequeueReusableCellWithIdentifier:[TableViewInputCell ID] forIndexPath:indexPath];
            cell.cellType = TableViewInputCellType_ChannelName;
            cell.channelNameBlock = ^(NSString * _Nonnull name) {
                weakSelf.channelName = name;
            };
            return cell;
        } break;
            
//        case 1: {
//            TableViewInputCell *cell = [tableView dequeueReusableCellWithIdentifier:[TableViewInputCell ID] forIndexPath:indexPath];
//            cell.cellType = TableViewInputCellType_ChannelProfile;
//            cell.channelProfileBlock = ^(MMRtcChannelProfile profile) {
//                weakSelf.channelProfile = profile;
//            };
//            return cell;
//        } break;
            
        case 1: {
            TableViewSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:[TableViewSwitchCell ID] forIndexPath:indexPath];
            [cell setTitle:@"主播角色" switchOn:self.isBroadcaster switchClick:^(BOOL isOpen) {
                weakSelf.isBroadcaster = isOpen;
            }];
            return cell;
        } break;
            
        case 2: {
            TableViewSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:[TableViewSwitchCell ID] forIndexPath:indexPath];
            [cell setTitle:@"扬声器" switchOn:self.isSpeaker switchClick:^(BOOL isOpen) {
                weakSelf.isSpeaker = isOpen;
            }];
            return cell;
        } break;
            
        case 3: {
            TableViewSwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:[TableViewSwitchCell ID] forIndexPath:indexPath];
            [cell setTitle:@"推流" switchOn:self.isSpeaker switchClick:^(BOOL isOpen) {
                weakSelf.isPushPull = isOpen;
            }];
            return cell;
        } break;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            return 100;
        } break;
            
        case 1:
        case 2:
        case 3:{
            return 60;
        } break;
    }
    
    return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self viewEndEditing];
}

#pragma mark - actions
- (void)viewEndEditing {
    [self.view endEditing:YES];
}

- (void)confirmBtnClick {
    if (!self.channelName.length) {
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"
                                                    message:@"频道名称为空"
                                                cancelTitle:@"知道了"
                                                    okTitle:nil];
        [alert show];
        return;
    }
    WEAK_SELF
    [self getMicroAuthorizationStatus:^(AVAuthorizationStatus status) {
        if (status == AVAuthorizationStatusAuthorized) {
            AudioVC *vc = [[AudioVC alloc]init];
            vc.isBroaster = weakSelf.isBroadcaster;
            vc.isSpeaker = weakSelf.isSpeaker;
            vc.channelId = weakSelf.channelName;
            vc.isPushPull = weakSelf.isPushPull;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
        else {
            AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"
                                                        message:@"您没有麦克风使用权限"
                                                    cancelTitle:@"知道了"
                                                        okTitle:nil];
            [alert show];
        }
    }];
}

- (void)getMicroAuthorizationStatus:(void(^)(AVAuthorizationStatus status))callback;{
    AVAuthorizationStatus microPhoneStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (microPhoneStatus) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 被拒绝
            callback ? callback(microPhoneStatus) : nil;
        }
            break;
        case AVAuthorizationStatusNotDetermined: {
            // 没弹窗
            [self requestMicroPhoneAuth:callback];
        }
            break;
        case AVAuthorizationStatusAuthorized: {
            // 有授权
            callback ? callback(microPhoneStatus) : nil;
        }
            break;
            
        default:
            break;
    }
}

- (void)requestMicroPhoneAuth:(void(^)(AVAuthorizationStatus status))callback{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        [MMTools performTaskOnMainThread:^{
            callback ? callback(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied) : nil;
        }];
    }];
}

#pragma mark - lazy
- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(30, SCREEN_HEIGHT - SCREEN_SAFE_BOTTOM - 80, SCREEN_WIDTH - 60, 50);
        _confirmBtn.backgroundColor = [UIColor systemBlueColor];
        _confirmBtn.layer.cornerRadius = 4;
        [_confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, NaviBarHeight, SCREEN_WIDTH, CGRectGetMinY(self.confirmBtn.frame) - NaviBarHeight - 10)
                      style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorColor = OX_COLOR(0xEFEFEF);
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[TableViewInputCell class] forCellReuseIdentifier:[TableViewInputCell ID]];
        [_tableView registerClass:[TableViewSwitchCell class] forCellReuseIdentifier:[TableViewSwitchCell ID]];
    }
    return _tableView;
}

@end
