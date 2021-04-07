//
//  LogMessageVC.m
//  MMRtcKit_Example
//
//  Created by RunX on 2021/1/15.
//  Copyright © 2021 cf_olive@163.com. All rights reserved.
//

#import "LogMessageVC.h"

static NSString *const kTableViewID = @"kTableViewID";

@interface LogMessageVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LogMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(0, 0, 50, 40);
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = item;
    
    [self.view addSubview:self.tableView];
}

- (void)backBtnClicked:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    NSString *log = self.logsArray[indexPath.row];
    cell.textLabel.text = log;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 0;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *log = self.logsArray[indexPath.row];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2];//设置行间距
    //最大宽度为300，最大高度为200
    CGSize size = [log boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 32, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17] ,NSParagraphStyleAttributeName:paragraphStyle} context:nil].size;
    return size.height;
}

#pragma mark - lazy
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NaviBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NaviBarHeight - SCREEN_SAFE_BOTTOM) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorColor = [UIColor whiteColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewID];
    }
    return _tableView;
}

@end
