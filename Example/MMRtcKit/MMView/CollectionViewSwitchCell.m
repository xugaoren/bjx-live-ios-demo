//
//  CollectionViewSwitchCell.m
//  MMRtcSample
//
//  Created by RunX on 2021/1/22.
//

#import "CollectionViewSwitchCell.h"

@interface CollectionViewSwitchCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, copy) CollectionViewSwitchCellClick switchClickBlock;

@end

@implementation CollectionViewSwitchCell

+ (NSString *)ID {
    return @"CollectionViewSwitchCellID";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.switchView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(16, self.frame.size.height * 0.5 - 10, SCREEN_WIDTH - 32, 20);
    self.switchView.frame = CGRectMake(SCREEN_WIDTH - 66, self.frame.size.height * 0.5 - 15, 50, 44);
}

#pragma mark - public
- (void)setTitle:(NSString *)title switchOn:(BOOL)isOn switchClick:(CollectionViewSwitchCellClick)switchClick {
    self.titleLabel.text = title;
    self.switchView.on = isOn;
    self.switchClickBlock = switchClick;
}

#pragma mark - actions
- (void)switchViewClick:(UISwitch *)sender {
    if (self.switchClickBlock) {
        self.switchClickBlock(sender.isOn);
    }
}

#pragma mark - lazy
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        [_switchView addTarget:self action:@selector(switchViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchView;
}

@end
