//
//  CollectionViewItemCell.h
//  MMRtcSample
//
//  Created by RunX on 2021/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewItemCell : UICollectionViewCell

+ (NSString *)ID;

- (void)setTitle:(NSString *)title isSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
