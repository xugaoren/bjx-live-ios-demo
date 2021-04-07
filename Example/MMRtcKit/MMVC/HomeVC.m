//
//  HomeVC.m
//  MMDemo
//
//  Created by max  on 2020/8/21.
//  Copyright © 2020 max. All rights reserved.
//

#import "HomeVC.h"
#import "MMTools.h"
#import "AlertView.h"
#import "P2PVideoVC.h"
#import "JoinAudioChannelVC.h"
#import "JoinVideoChannelVC.h"

#import <MMRtcKit/MMRtcKit.h>
@interface HomeVC ()
@property(nonatomic,strong) UIButton *btnJoinAudioChannel;
@property(nonatomic,strong) UIButton *btnJoinVideoChannel;
@property(nonatomic,strong) UIButton *btnJoinVideoP2PChannel;
@property(nonatomic,strong) UILabel *sdkVersionLabel;
@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)loadAllView{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"首页";
    
    [self.view addSubview:self.btnJoinAudioChannel];
    [self.view addSubview:self.btnJoinVideoChannel];
    [self.view addSubview:self.btnJoinVideoP2PChannel];
    [self.view addSubview:self.sdkVersionLabel];
    
    self.sdkVersionLabel.text = [NSString stringWithFormat:@"Version: %@", [MMRtcEngineKit getSdkVersion]];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"退出登录" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 80, 40);
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
}
// 返回按钮按下
- (void)backBtnClicked:(UIButton *)sender{
    AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"确定要退出登录么？"cancelTitle:@"否"okTitle:@"是"];
       [alert show];
       alert.OKBlock = ^(AlertView *alertView) {
           [alertView dismiss];
           [kUserDefaults setObject:@"NO" forKey:@"loginFlag"];
           [kUserDefaults setObject:@"" forKey:@"token"];
           [kUserDefaults setObject:@"" forKey:@"appKey"];
           [kUserDefaults setObject:@"" forKey:@"userId"];
           [self.navigationController popViewControllerAnimated:YES];
       };
}

- (UIButton *)btnJoinAudioChannel{
    if (!_btnJoinAudioChannel) {
        _btnJoinAudioChannel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnJoinAudioChannel setTitle:@"加入音频频道" forState:UIControlStateNormal];
        [_btnJoinAudioChannel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnJoinAudioChannel.frame = CGRectMake(60, 120, SCREEN_WIDTH-120, 44);
        [_btnJoinAudioChannel setBackgroundColor:OX_COLOR(0X3F73FE)];
        _btnJoinAudioChannel.layer.cornerRadius =5;
        _btnJoinAudioChannel.layer.masksToBounds =YES;
        [_btnJoinAudioChannel addTarget:self action:@selector(btnJoinAudioChannelClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnJoinAudioChannel;
}

- (void)btnJoinAudioChannelClick:(UIButton *)sender{
    JoinAudioChannelVC *joinvc = [[JoinAudioChannelVC alloc]init];
    [self.navigationController pushViewController:joinvc animated:YES];
    
}

- (UIButton *)btnJoinVideoChannel{
    if (!_btnJoinVideoChannel) {
        _btnJoinVideoChannel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnJoinVideoChannel setTitle:@"加入视频多路频道" forState:UIControlStateNormal];
        [_btnJoinVideoChannel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnJoinVideoChannel.frame = CGRectMake(60, 180, SCREEN_WIDTH-120, 44);
        [_btnJoinVideoChannel setBackgroundColor:OX_COLOR(0X3F73FE)];
        _btnJoinVideoChannel.layer.cornerRadius =5;
        _btnJoinVideoChannel.layer.masksToBounds =YES;
        [_btnJoinVideoChannel addTarget:self action:@selector(btnJoinVideoChannelClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnJoinVideoChannel;
}

- (void)btnJoinVideoChannelClick:(UIButton *)sender{
    JoinVideoChannelVC *joinvc = [[JoinVideoChannelVC alloc]init];
    [self.navigationController pushViewController:joinvc animated:YES];
}

- (UIButton *)btnJoinVideoP2PChannel{
    if (!_btnJoinVideoP2PChannel) {
        _btnJoinVideoP2PChannel = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnJoinVideoP2PChannel setTitle:@"加入视频P2P频道" forState:UIControlStateNormal];
        [_btnJoinVideoP2PChannel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnJoinVideoP2PChannel.frame = CGRectMake(60, 180 + 60, SCREEN_WIDTH-120, 44);
        [_btnJoinVideoP2PChannel setBackgroundColor:OX_COLOR(0X3F73FE)];
        _btnJoinVideoP2PChannel.layer.cornerRadius =5;
        _btnJoinVideoP2PChannel.layer.masksToBounds =YES;
        [_btnJoinVideoP2PChannel addTarget:self action:@selector(btnJoinVideoP2PChannelClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnJoinVideoP2PChannel;
}

- (void)btnJoinVideoP2PChannelClick:(UIButton *)sender{
    UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"p2p" message:@"ip" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertV.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    [alertV textFieldAtIndex:0].text = @"192.168.99.169";
    [alertV textFieldAtIndex:1].text = @"8086";
    [alertV textFieldAtIndex:1].secureTextEntry = NO;
    [alertV show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // 获取UIAlertView中第一个输入框
        UITextField *urlTextField = [alertView textFieldAtIndex:0];
        // 获取UIAlertView中的第二个输入框
        UITextField *portTextField = [alertView textFieldAtIndex:1];
        // 拼接TextField字符串
//        NSString *msg = [NSString stringWithFormat:@"ip：%@ port: %@",urlTextField.text, portTextField.text];
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        //[alert show];
        
        P2PVideoVC *joinvc = [[P2PVideoVC alloc]init];
        joinvc.p2pUrl = [NSString stringWithFormat:@"%@",urlTextField.text];
        joinvc.p2pPort = [NSString stringWithFormat:@"%@",portTextField.text];
        [self.navigationController pushViewController:joinvc animated:YES];
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    // 遍历UIalertView包含的全部子控件

    for (UIView *view in alertView.subviews) {
        // 如果该子控件是UILabel控件
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            // 将UILabel的文字对齐方式设为左对齐
            label.textAlignment = NSTextAlignmentLeft;
        }
    }
}

- (UILabel *)sdkVersionLabel {
    if (!_sdkVersionLabel) {
        _sdkVersionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT - SCREEN_SAFE_BOTTOM - 35, SCREEN_WIDTH - 20, 20)];
        _sdkVersionLabel.font = [UIFont systemFontOfSize:14];
        _sdkVersionLabel.textColor = [UIColor blackColor];
        _sdkVersionLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sdkVersionLabel;
}


@end
