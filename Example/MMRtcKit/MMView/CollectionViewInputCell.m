//
//  CollectionViewInputCell.m
//  MMRtcSample
//
//  Created by RunX on 2021/1/22.
//

#import "CollectionViewInputCell.h"
#import "MMTools.h"

@interface CollectionViewInputCell ()<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation CollectionViewInputCell

+ (NSString *)ID {
    return @"CollectionViewInputCellID";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.textField];
    }
    return self;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.channelNameBlock) {
        self.channelNameBlock(textField.text);
    }
}

#pragma mark - lazy
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, SCREEN_WIDTH - 32, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.text = @"频道ID";
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
