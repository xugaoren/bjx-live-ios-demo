//
//  JoinVideoChannelVC.m
//  MMRtcSample
//
//  Created by RunX on 2021/1/22.
//

#import "JoinVideoChannelVC.h"
#import <MMRtcKit/MMRtcKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MMTools.h"
#import "AlertView.h"
#import "VideoVC.h"
#import "CollectionViewInputCell.h"
#import "CollectionViewItemCell.h"
#import "CollectionViewSwitchCell.h"

static NSString *const kVideoConfigCollectionHeaderID = @"kVideoConfigCollectionHeaderID";

@interface JoinVideoChannelVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *videoConfigCollection;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, assign) BOOL isSpeaker;
@property (nonatomic, assign) BOOL isSetPublishUrl;
@property (nonatomic, strong) NSArray *videoConfigSections;
@property (nonatomic, strong) NSArray *videoConfigFrameRates;
@property (nonatomic, strong) NSArray<NSDictionary *> *videoConfigResolutionRates;
@property (nonatomic, assign) NSInteger currentSelectedFrameRateIndex;
@property (nonatomic, assign) NSInteger currentSelectedResolutionRateIndex;

@end

@implementation JoinVideoChannelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isSpeaker = NO;
    self.isSetPublishUrl = NO;
    self.currentSelectedFrameRateIndex = 1;
    self.currentSelectedResolutionRateIndex = 2;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"视频配置";
    
    [self.view addSubview:self.confirmBtn];
    [self.view addSubview:self.videoConfigCollection];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(viewEndEditing)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 4;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            return 1;
        } break;
            
        case 1: {
            return self.videoConfigFrameRates.count;
        } break;
            
        case 2: {
            return self.videoConfigResolutionRates.count;
        } break;
            
        case 3: {
            return 2;
        } break;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WEAK_SELF;
    switch (indexPath.section) {
        case 0: {
            CollectionViewInputCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewInputCell ID] forIndexPath:indexPath];
            cell.channelNameBlock = ^(NSString * _Nonnull name) {
                weakSelf.channelName = name;
            };
            return cell;
        } break;
            
        case 1: {
            CollectionViewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewItemCell ID] forIndexPath:indexPath];
            BOOL isSelected = (self.currentSelectedFrameRateIndex == indexPath.item);
            NSNumber *frameRate = self.videoConfigFrameRates[indexPath.item];
            NSString *title = [NSString stringWithFormat:@"%@fps", frameRate];
            [cell setTitle:title isSelected:isSelected];
            return cell;
        } break;
            
        case 2: {
            CollectionViewItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewItemCell ID] forIndexPath:indexPath];
            BOOL isSelected = (self.currentSelectedResolutionRateIndex == indexPath.item);
            NSDictionary *dic = self.videoConfigResolutionRates[indexPath.item];
            NSString *title = [NSString stringWithFormat:@"%@x%@", dic[@"width"], dic[@"height"]];
            [cell setTitle:title isSelected:isSelected];
            return cell;
        } break;
            
        case 3: {
            CollectionViewSwitchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[CollectionViewSwitchCell ID] forIndexPath:indexPath];
            
            switch (indexPath.item) {
                case 0: {
                    [cell setTitle:@"扬声器" switchOn:self.isSpeaker switchClick:^(BOOL isOpen) {
                        weakSelf.isSpeaker = isOpen;
                    }];
                } break;
                    
                case 1: {
                    [cell setTitle:@"设置推流地址" switchOn:self.isSetPublishUrl switchClick:^(BOOL isOpen) {
                        weakSelf.isSetPublishUrl = isOpen;
                    }];
                } break;
                    
                default:
                    break;
            }
            
            return cell;
        } break;
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            return CGSizeMake(SCREEN_WIDTH, 100);
        } break;
            
        case 1: {
            return CGSizeMake((SCREEN_WIDTH - 64) / 4.0, 40);
        } break;
            
        case 2: {
            return CGSizeMake((SCREEN_WIDTH - 54) / 3.0, 40);
        } break;
            
        case 3: {
            return CGSizeMake(SCREEN_WIDTH, 50);
        } break;
    }
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (UICollectionElementKindSectionHeader == kind) {
        UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kVideoConfigCollectionHeaderID forIndexPath:indexPath];
        if (1 == indexPath.section || 2 == indexPath.section) {
            [reusableView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(16, 20, 100, 30)];
            lb.textColor = [UIColor blackColor];
            lb.font = [UIFont systemFontOfSize:16];
            lb.text = self.videoConfigSections[indexPath.section - 1];
            [reusableView addSubview:lb];
        }
        return reusableView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (1 == section || 2 == section) {
        return CGSizeMake(SCREEN_WIDTH, 50);
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (1 == indexPath.section) {
        self.currentSelectedFrameRateIndex = indexPath.item;
    } else if (2 == indexPath.section) {
        self.currentSelectedResolutionRateIndex = indexPath.item;
    }
    [self.videoConfigCollection reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self viewEndEditing];
}

#pragma mark - actions
- (void)viewEndEditing {
    [self.view endEditing:YES];
}

- (void)confirmBtnClick {
    if (!self.channelName.length) {
        AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"
                                                    message:@"频道名称为空"
                                                cancelTitle:@"知道了"
                                                    okTitle:nil];
        [alert show];
        return;
    }
    WEAK_SELF
    [self getMicroAuthorizationStatus:^(AVAuthorizationStatus status) {
        if (status == AVAuthorizationStatusAuthorized) {
            VideoVC *vc = [[VideoVC alloc] init];
            vc.channelId = weakSelf.channelName;
            vc.frameRate = self.videoConfigFrameRates[self.currentSelectedFrameRateIndex];
            NSDictionary *dic = self.videoConfigResolutionRates[self.currentSelectedResolutionRateIndex];
            vc.resolutionRateWidth = dic[@"width"];
            vc.resolutionRateHeight = dic[@"height"];
            vc.isSpeaker = weakSelf.isSpeaker;
            vc.isSetPublishUrl = weakSelf.isSetPublishUrl;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
        else {
            AlertView *alert = [[AlertView alloc] initWithTitle:@"提示"message:@"您没有麦克风使用权限" cancelTitle:@"知道了"okTitle:nil];
            [alert show];
        }
    }];
}

- (void)getMicroAuthorizationStatus:(void(^)(AVAuthorizationStatus status))callback;{
    AVAuthorizationStatus microPhoneStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (microPhoneStatus) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            // 被拒绝
            callback ? callback(microPhoneStatus) : nil;
        }
            break;
        case AVAuthorizationStatusNotDetermined: {
            // 没弹窗
            [self requestMicroPhoneAuth:callback];
        }
            break;
        case AVAuthorizationStatusAuthorized: {
            // 有授权
            callback ? callback(microPhoneStatus) : nil;
        }
            break;
            
        default:
            break;
    }
}

- (void)requestMicroPhoneAuth:(void(^)(AVAuthorizationStatus status))callback{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        [MMTools performTaskOnMainThread:^{
            callback ? callback(granted ? AVAuthorizationStatusAuthorized : AVAuthorizationStatusDenied) : nil;
        }];
    }];
}

#pragma mark - lazy
- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(30, SCREEN_HEIGHT - SCREEN_SAFE_BOTTOM - 80, SCREEN_WIDTH - 60, 50);
        _confirmBtn.backgroundColor = [UIColor systemBlueColor];
        _confirmBtn.layer.cornerRadius = 4;
        [_confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (UICollectionView *)videoConfigCollection {
    if (!_videoConfigCollection) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width, 50);
        _videoConfigCollection = [[UICollectionView alloc]
                                  initWithFrame:CGRectMake(0, NaviBarHeight, SCREEN_WIDTH,
                                                           CGRectGetMinY(self.confirmBtn.frame) - NaviBarHeight - 10)
                                  collectionViewLayout:layout];
        _videoConfigCollection.backgroundColor = [UIColor whiteColor];
        _videoConfigCollection.dataSource = self;
        _videoConfigCollection.delegate = self;
        [_videoConfigCollection registerClass:[UICollectionReusableView class]
                   forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                          withReuseIdentifier:kVideoConfigCollectionHeaderID];
        [_videoConfigCollection registerClass:[CollectionViewInputCell class]
                   forCellWithReuseIdentifier:[CollectionViewInputCell ID]];
        [_videoConfigCollection registerClass:[CollectionViewItemCell class]
                   forCellWithReuseIdentifier:[CollectionViewItemCell ID]];
        [_videoConfigCollection registerClass:[CollectionViewSwitchCell class]
                   forCellWithReuseIdentifier:[CollectionViewSwitchCell ID]];
    }
    return _videoConfigCollection;
}

- (NSArray *)videoConfigSections {
    if (!_videoConfigSections) {
        _videoConfigSections = @[@"帧率", @"分辨率"];
    }
    return _videoConfigSections;
}

- (NSArray *)videoConfigFrameRates {
    if (!_videoConfigFrameRates) {
        _videoConfigFrameRates = @[@7, @10, @15, @20, @24, @30];
    }
    return _videoConfigFrameRates;
}

- (NSArray<NSDictionary *> *)videoConfigResolutionRates {
    if (!_videoConfigResolutionRates) {
        _videoConfigResolutionRates = @[@{@"width" : @240, @"height" : @240},
                                        @{@"width" : @240, @"height" : @320},
                                        @{@"width" : @360, @"height" : @480},
                                        @{@"width" : @480, @"height" : @480},
                                        @{@"width" : @480, @"height" : @640},
                                        @{@"width" : @540, @"height" : @960},
                                        @{@"width" : @720, @"height" : @1280},];
    }
    return _videoConfigResolutionRates;
}

@end
