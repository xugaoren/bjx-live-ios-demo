//
//  TableViewInputCell.h
//  MMRtcSample
//
//  Created by RunX on 2021/1/21.
//

#import <UIKit/UIKit.h>
#import <MMRtcKit/MMRtcEnumerates.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TableViewInputCellType) {
    TableViewInputCellType_ChannelName = 0, //频道名称
    TableViewInputCellType_ChannelProfile = 1, //模式选择
};

typedef void(^TableViewInputCellChannelNameBlock)(NSString *name);
typedef void(^TableViewInputCellChannelProfileBlock)(MMRtcChannelProfile profile);

@interface TableViewInputCell : UITableViewCell

@property (nonatomic, assign) TableViewInputCellType cellType;
@property (nonatomic, copy) TableViewInputCellChannelNameBlock channelNameBlock;
@property (nonatomic, copy) TableViewInputCellChannelProfileBlock channelProfileBlock;

+ (NSString *)ID;

@end

NS_ASSUME_NONNULL_END
