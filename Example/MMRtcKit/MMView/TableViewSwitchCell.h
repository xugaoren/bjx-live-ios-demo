//
//  TableViewSwitchCell.h
//  MMRtcSample
//
//  Created by RunX on 2021/1/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TableViewSwitchCellClick)(BOOL isOpen);

@interface TableViewSwitchCell : UITableViewCell

+ (NSString *)ID;

- (void)setTitle:(NSString *)title switchOn:(BOOL)isOn switchClick:(TableViewSwitchCellClick)switchClick;

@end

NS_ASSUME_NONNULL_END
