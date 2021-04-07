//
//  ChatRoomVC.m
//  MMDemo
//
//  Created by max  on 2020/8/21.
//  Copyright © 2020 max. All rights reserved.
//

#import "ChatRoomVC.h"
#import <MMRtcKit/MMRtcKit.h>
#import "AlertView.h"
#import "MBProgressHUD.h"
@interface ChatRoomVC ()<UITableViewDelegate,UITableViewDataSource>
//@property(nonatomic,strong)UITableView *msgTable;
//@property (nonatomic,strong) NSMutableArray *msgArray;
//@property (nonatomic,strong) UITextField *txtmesgbottom;
//@property (nonatomic,strong) UIButton *btnMesgbottom;
//@property (nonatomic,strong) MMRtmKit *enginertm;
//@property (strong, nonatomic) UIView *textInputView;
//@property (strong, nonatomic) UITextField *txtMessage;
@end

@implementation ChatRoomVC

//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    self.msgArray = [NSMutableArray array];
//    //sdk rtm消息服务初始化
//    self.enginertm = [[MMRtcEngineKit sharedEngineWithAppKey:CURRENT_APPKEY] getMMRtmKit];
//
//    self.enginertm.mmRtmkitDelegate = self;
//    //加入聊天室
//    [self.enginertm joinRoomWithRoomId:self.liveRoomID onResult:^(MMRtmErrorCode code) {
//        if (code == MMRtmErrorCodeNoError) {
//
//        }
//    }];
//
//    self.navigationItem.title =  [NSString stringWithFormat:@"聊天室ID:%@",self.liveRoomID] ;
//
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
//}
//
//- (void)keyboardWillChangeFrame:(NSNotification *)noti{
//    NSDictionary *info = noti.userInfo;
//    NSValue *beforeValue = info[UIKeyboardFrameBeginUserInfoKey];
//    NSValue *afterValue = info[UIKeyboardFrameEndUserInfoKey];
//    //NSNumber *curveNumber = info[UIKeyboardAnimationCurveUserInfoKey];
//    NSNumber *durationNumber = info[UIKeyboardAnimationDurationUserInfoKey];
//
//    CGRect before = beforeValue.CGRectValue;
//    CGRect after = afterValue.CGRectValue;
//    //UIViewAnimationCurve curve = curveNumber.integerValue;
//    NSTimeInterval duration = durationNumber.doubleValue;
//
//    if (before.origin.y > after.origin.y) {
//        //键盘弹出
//    }
//    else {
//        //键盘收起
//        if (self.textInputView.frame.origin.y >= SCREEN_HEIGHT - 50 ) {
//            return;
//        }
//    }
//    CGFloat offset = before.origin.y - after.origin.y;
//    [self.textInputView.superview bringSubviewToFront:self.textInputView];
//    [UIView animateWithDuration:duration animations:^{
//        self.textInputView.frame = CGRectMake(self.textInputView.frame.origin.x, self.textInputView.frame.origin.y - offset, self.textInputView.frame.size.width, self.textInputView.frame.size.height);
//        if (before.origin.y < after.origin.y) {
//            self.textInputView.alpha = 0;
//        }
//        else {
//            self.textInputView.alpha = 1;
//        }
//    } completion:^(BOOL finished) {
//
//    }];
//}
//
//- (void)loadAllView{
//    self.view.backgroundColor = [UIColor systemBlueColor];
//    [self.view addSubview:self.msgTable];
//    [self.view addSubview:self.textInputView];
//    [self.view addSubview:self.txtmesgbottom];
//    [self.view addSubview:self.btnMesgbottom];
//
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setTitle:@"退出" forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    backBtn.frame = CGRectMake(0, 0, 50, 40);
//    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
//    self.navigationItem.leftBarButtonItem = item;
//}
//// 返回按钮按下
//- (void)backBtnClicked:(UIButton *)sender{
//    //注意：退出频道调用后，再执行页面退出操作
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    WEAK_SELF
//    [self.enginertm leaveRoomOnResult:^(MMRtmErrorCode code) {
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
//        [weakSelf.navigationController popViewControllerAnimated:YES];
//    }];
//}
//
//
//- (UITableView *)msgTable{
//    if (!_msgTable) {
//        _msgTable = [[UITableView alloc]initWithFrame:CGRectMake(0, NaviBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NaviBarHeight - 120) style:UITableViewStylePlain];
//        _msgTable.backgroundColor = [UIColor clearColor];
//        _msgTable.delegate = self;
//        _msgTable.dataSource = self;
//        _msgTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _msgTable.showsVerticalScrollIndicator = NO;
//        [_msgTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"msg"];
//    }
//    return _msgTable;
//}
//
//- (UITextField *)txtmesgbottom{
//    if (!_txtmesgbottom) {
//        _txtmesgbottom = [[UITextField alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
//        _txtmesgbottom.font = [UIFont systemFontOfSize:16];
//        _txtmesgbottom.textColor = [UIColor blackColor];
//        _txtmesgbottom.backgroundColor = [UIColor whiteColor];
//        _txtmesgbottom.placeholder = @"    请输入要发送的内容";
//    }
//    return _txtmesgbottom;
//}
//
//-(UIButton *)btnMesgbottom{
//    if (!_btnMesgbottom) {
//        _btnMesgbottom = [UIButton buttonWithType:UIButtonTypeCustom];
//        _btnMesgbottom.frame =CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50);
//        [_btnMesgbottom addTarget:self action:@selector(btnMesgBeginClick) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _btnMesgbottom;
//}
//
//- (void)btnMesgBeginClick{
//    [self.txtMessage becomeFirstResponder];
//}
//
//- (UIView *)textInputView{
//    if (!_textInputView) {
//        _textInputView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50)];
//        _textInputView.backgroundColor = [UIColor whiteColor];
//        _textInputView.alpha = 0;
//
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setTitle:@"发送" forState:UIControlStateNormal];
//        btn.backgroundColor = [UIColor lightGrayColor];
//        btn.frame = CGRectMake(SCREEN_WIDTH-60, 0, 60, 50);
//        [btn addTarget:self action:@selector(btnSendMsgClick) forControlEvents:UIControlEventTouchUpInside];
//        [_textInputView addSubview:btn];
//
//        _txtMessage = [[UITextField alloc]initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-80, 50)];
//        _txtMessage.font = [UIFont systemFontOfSize:16];
//        _txtMessage.textColor = [UIColor blackColor];
//        _txtMessage.placeholder = @"请输入要发送的内容";
//        [_textInputView addSubview:_txtMessage];
//    }
//    return _textInputView;
//}
//
////发送消息
//- (void)btnSendMsgClick{
//    if (!self.txtMessage.text.length) {
//        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"消息为空，无法发送！" cancelTitle:@"知道了"okTitle:nil];
//        [alert show];
//        return;
//    }
//
//    [self.enginertm sendMessage:self.txtMessage.text toRoom:self.liveRoomID sendSuccess:^(MMRtmErrorCode code) {
//        if (code == MMRtmErrorCodeNoError) {
//            [self.txtMessage resignFirstResponder];
//            self.txtMessage.text = @"";
//        }
//    }];
//}
//
//
//#pragma mark --------------------- UITableViewDelegate -------------------------
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.msgArray.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSString *msg = self.msgArray[indexPath.row];
//    CGFloat msgheight = [msg boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, 20000) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]} context:nil].size.height;
//    return msgheight + 15;
//}
//
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"msg" forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.backgroundColor = [UIColor clearColor];
//
//    NSString *msg = self.msgArray[indexPath.row];
//    CGFloat msgheight = [msg boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, 20000) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]} context:nil].size.height;
//    CGFloat msgWidth =  [msg boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 40, msgheight) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]} context:nil].size.width;
//    UIView *view = [cell.contentView viewWithTag:1];
//    UILabel *label = [cell.contentView viewWithTag:2];
//    if (!view) {
//        view = [[UIView alloc]initWithFrame:CGRectMake(10, 5, msgWidth+30, msgheight + 5)];
//        view.layer.cornerRadius = 10;
//        view.backgroundColor = [UIColor whiteColor];
//        view.alpha = 0.4;
//        [cell.contentView addSubview:view];
//        view.tag = 1;
//
//        label = [[UILabel alloc]initWithFrame:CGRectMake(20, 7.5, msgWidth+10, msgheight)];
//        label.numberOfLines = 0;
//        label.tag = 2;
//        label.textColor = [UIColor blackColor];
//        label.lineBreakMode = NSStringDrawingUsesLineFragmentOrigin;
//        [cell.contentView addSubview:label];
//    }
//    view.frame = CGRectMake(10, 5, msgWidth+30, msgheight + 5);
//    label.frame = CGRectMake(20, 7.5, msgWidth+10, msgheight);
//    label.font = [UIFont systemFontOfSize:16.0f];
//    label.text = msg;
//
//    return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//
//}
//
//#pragma mark -------------------- MMRtmKitDelegate -----------------
//
//- (void)rtmKit:(MMRtmKit *_Nonnull)kit userMessageReceived:(NSString *_Nonnull)message fromUser:(NSString *_Nonnull)uid{
//
//}
//
////messageType 1 上麦 2 下麦 3 普通文本消息 4销毁房间
//- (void)rtmKit:(MMRtmKit *_Nonnull)kit roomMessageReceived:(NSString *_Nonnull)message fromUser:(NSString *_Nonnull)uid{
//    [self.msgArray addObject:[NSString stringWithFormat:@"%@: %@",uid,message]];
//    [self.msgTable reloadData];
//
//
//}
//
//- (void)rtmKit:(MMRtmKit *_Nonnull)kit connectionStateChanged:(MMRtmConnectionState)state{
//
//}

@end
