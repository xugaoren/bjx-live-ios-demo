//
//  CollectionViewSwitchCell.h
//  MMRtcSample
//
//  Created by RunX on 2021/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CollectionViewSwitchCellClick)(BOOL isOpen);

@interface CollectionViewSwitchCell : UICollectionViewCell

+ (NSString *)ID;

- (void)setTitle:(NSString *)title switchOn:(BOOL)isOn switchClick:(CollectionViewSwitchCellClick)switchClick;

@end

NS_ASSUME_NONNULL_END
