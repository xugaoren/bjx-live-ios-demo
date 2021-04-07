//
//  CollectionViewInputCell.h
//  MMRtcSample
//
//  Created by RunX on 2021/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CollectionViewInputCellChannelNameBlock)(NSString *name);

@interface CollectionViewInputCell : UICollectionViewCell

@property (nonatomic, copy) CollectionViewInputCellChannelNameBlock channelNameBlock;

+ (NSString *)ID;

@end

NS_ASSUME_NONNULL_END
