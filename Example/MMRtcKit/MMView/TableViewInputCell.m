//
//  TableViewInputCell.m
//  MMRtcSample
//
//  Created by RunX on 2021/1/21.
//

#import "TableViewInputCell.h"
#import "MMTools.h"

@interface TableViewInputCell () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, assign) MMRtcChannelProfile channelProfile;

@end

@implementation TableViewInputCell

+ (NSString *)ID {
    return @"TableViewInputCellID";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.channelProfile = MMRtcChannelProfileCommunication;
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

#pragma mark - public
- (void)setCellType:(TableViewInputCellType)cellType {
    _cellType = cellType;
    
    switch (_cellType) {
        case TableViewInputCellType_ChannelName: {
            self.titleLabel.text = @"频道ID";
            self.textField.text = nil;
        } break;
            
        case TableViewInputCellType_ChannelProfile: {
            self.titleLabel.text = @"模式选择";
        } break;
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.cellType == TableViewInputCellType_ChannelProfile) {
        [self showChannelProfileSelect];
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.channelNameBlock) {
        self.channelNameBlock(textField.text);
    }
}

#pragma mark - private
- (void)setChannelProfile:(MMRtcChannelProfile)channelProfile {
    _channelProfile = channelProfile;
    
    switch (_channelProfile) {
        case MMRtcChannelProfileCommunication: {
            self.textField.text = @"通讯模式";
        } break;
            
        case MMRtcChannelProfileLiveBroadcasting: {
            self.textField.text = @"直播模式";
        } break;
    }
    
    if (self.channelProfileBlock) {
        self.channelProfileBlock(_channelProfile);
    }
}

- (void)showChannelProfileSelect {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *commAction = [UIAlertAction actionWithTitle:@"通讯模式"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
        self.channelProfile = MMRtcChannelProfileCommunication;
    }];
    [alert addAction:commAction];
    UIAlertAction *broadAction = [UIAlertAction actionWithTitle:@"直播模式"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * _Nonnull action) {
        self.channelProfile = MMRtcChannelProfileLiveBroadcasting;
    }];
    [alert addAction:broadAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];
    [[MMTools getCurrentTopVC] presentViewController:alert animated:YES completion:nil];
}

#pragma mark - lazy
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, SCREEN_WIDTH - 32, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(self.titleLabel.frame) + 10, CGRectGetWidth(self.titleLabel.frame), 50)];
        _textField.backgroundColor = OX_COLOR(0xEFEFEF);
        _textField.layer.cornerRadius = 4;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.textColor = [UIColor blackColor];
        _textField.placeholder = @"请输入";
        _textField.delegate = self;
        // 输入框的左侧view
        UIView *paddingLeftView = [[UIView alloc] init];
        CGRect frame = _textField.frame;
        frame.size.width = 12;
        paddingLeftView.frame = frame;
        _textField.leftViewMode = UITextFieldViewModeAlways;
        _textField.leftView = paddingLeftView;
    }
    return _textField;
}

@end
