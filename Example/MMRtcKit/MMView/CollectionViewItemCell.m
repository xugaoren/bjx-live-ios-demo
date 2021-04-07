//
//  CollectionViewItemCell.m
//  MMRtcSample
//
//  Created by RunX on 2021/1/22.
//

#import "CollectionViewItemCell.h"

@interface CollectionViewItemCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation CollectionViewItemCell

+ (NSString *)ID {
    return @"CollectionViewItemCellID";
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.frame = self.bounds;
}

- (void)setTitle:(NSString *)title isSelected:(BOOL)isSelected {
    self.titleLabel.text = title;
    if (isSelected) {
        self.titleLabel.backgroundColor = [UIColor systemBlueColor];
        self.titleLabel.layer.borderColor = [UIColor systemBlueColor].CGColor;
        self.titleLabel.textColor = [UIColor whiteColor];
    } else {
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.titleLabel.textColor = [UIColor grayColor];
    }
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.layer.cornerRadius = 20;
        _titleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _titleLabel.layer.borderWidth = 1.0;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor grayColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

@end
