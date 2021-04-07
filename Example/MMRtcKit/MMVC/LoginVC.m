//
//  LoginVC.m
//  MMDemo
//
//  Created by max  on 2020/8/21.
//  Copyright © 2020 max. All rights reserved.
//

#import "LoginVC.h"
#import "MMTools.h"
#import "HomeVC.h"
#import "MMHttpTools.h"
#import "AlertView.h"
#import "MBProgressHUD+MMCategory.h"
#import <MMRtcKit/MMRtcKit.h>
@interface LoginVC ()
@property(nonatomic,strong) UITextField *txtUserId;
@property(nonatomic,strong) UIButton *btnLogin;
@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
     UITapGestureRecognizer *tap= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(HiddenKeyboardClick)];
    [self.view addGestureRecognizer:tap];
}

-(void) HiddenKeyboardClick{
    [self.txtUserId resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated{
    if ([kUserDefaults objectForKey:@"loginFlag"]!=nil &&[[NSString stringWithFormat:@"%@",[kUserDefaults objectForKey:@"loginFlag"]] isEqualToString:@"YES"]) {
        
        HomeVC *homevc= [[HomeVC alloc]init];
        [self.navigationController pushViewController:homevc animated:NO];
    }
}

- (void)loadAllView{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"登录";
    
    [self.view addSubview:self.txtUserId];
    [self.view addSubview:self.btnLogin];
}

- (UITextField *)txtUserId{
    if(!_txtUserId){
        _txtUserId = [[UITextField alloc]initWithFrame:CGRectMake(60, 150, SCREEN_WIDTH-120, 50)];
        _txtUserId.textColor = [UIColor blackColor];
        _txtUserId.placeholder = @"请输入用户名";
        _txtUserId.layer.cornerRadius =5;
        _txtUserId.textAlignment = NSTextAlignmentCenter;
        _txtUserId.layer.masksToBounds =YES;
        _txtUserId.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
    }
    return _txtUserId;
}

- (UIButton *)btnLogin{
    if (!_btnLogin) {
        _btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnLogin setTitle:@"登录" forState:UIControlStateNormal];
        [_btnLogin setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnLogin.frame = CGRectMake(60, 250, SCREEN_WIDTH-120, 44);
        [_btnLogin setBackgroundColor:OX_COLOR(0x3F73FE)];
        _btnLogin.layer.cornerRadius =5;
        _btnLogin.layer.masksToBounds =YES;
        [_btnLogin addTarget:self action:@selector(btnLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnLogin;
}

- (void)btnLoginClick:(UIButton *)sender{
    if (!self.txtUserId.text.length) {
         AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"请输入用户名" cancelTitle:@"知道了"okTitle:nil];
        [alert show];
        return;
    }
    ;
    
    if (![MMTools validateIdTypeStr:self.txtUserId.text]) {
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"用户名不合法" cancelTitle:@"知道了"okTitle:nil];
        [alert show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [MMHttpTools getAppKeyAndTokenWithUserId:self.txtUserId.text
                                  completion:^(NSString * _Nullable appKey,
                                               NSString * _Nullable token,
                                               NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        if (error) {
            [MBProgressHUD mm_showError:error.localizedDescription];
        } else {
            if (appKey.length > 0) {
                HomeVC *homevc= [[HomeVC alloc]init];
                [self.navigationController pushViewController:homevc animated:YES];
            } else {
                [MBProgressHUD mm_showError:@"Not find appKey!"];
            }
        }
    }];
}

@end
