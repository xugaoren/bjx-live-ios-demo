//
//  FUDemoBar.m
//  FUAPIDemoBar
//
//  Created by L on 2018/6/26.
//  Copyright © 2018年 L. All rights reserved.
//

#import "FUAPIDemoBar.h"
#import "FUFilterView.h"
#import "FUSlider.h"
#import "FUBeautyView.h"
//#import "MJExtension.h"
//#import "FUMakeupSupModel.h"
#import "FUSquareButton.h"
#import "FUManager.h"
#import "MBProgressHUD+MMCategory.h"

@interface FUAPIDemoBar ()<FUFilterViewDelegate, FUBeautyViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *skinBtn;
@property (weak, nonatomic) IBOutlet UIButton *shapeBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyFilterBtn;
@property (weak, nonatomic) IBOutlet UIButton *mStyleBtn;

// 滤镜页
@property (weak, nonatomic) IBOutlet FUFilterView *filterView;
// 美颜滤镜页
@property (weak, nonatomic) IBOutlet FUFilterView *beautyFilterView;
/* 格式 */
@property (weak, nonatomic) IBOutlet FUBeautyView *mStyleView;

@property (weak, nonatomic) IBOutlet FUSlider *beautySlider;

// 美型页
@property (weak, nonatomic) IBOutlet FUBeautyView *shapeView;
// 美肤页
@property (weak, nonatomic) IBOutlet FUBeautyView *skinView;

@property (weak, nonatomic) IBOutlet FUSquareButton *mRestBtn;

@property (weak, nonatomic) IBOutlet UIView *sqLine;

/* 当前选中参数 */
@property (strong, nonatomic) FUBeautyParam *seletedParam;

@property (assign, nonatomic) BOOL isEnble;
@end

@implementation FUAPIDemoBar

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:5/255.0 green:15/255.0 blue:20/255.0 alpha:0.74];
        NSBundle *bundle = [NSBundle bundleForClass:[FUAPIDemoBar class]];
        self = (FUAPIDemoBar *)[bundle loadNibNamed:@"FUAPIDemoBar" owner:self options:nil].firstObject;
    }
    return self ;
}




-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.filterView.type = FUFilterViewTypeFilter ;
    self.filterView.mDelegate = self ;
    
    self.beautyFilterView.type = FUFilterViewTypeBeautyFilter ;
    self.beautyFilterView.mDelegate = self ;
    
    self.shapeView.mDelegate = self ;
    self.skinView.mDelegate = self;
    
    self.mStyleView.mDelegate = self;
    [self.skinBtn setTitle:@"美肤" forState:UIControlStateNormal];
    [self.shapeBtn setTitle:@"美型" forState:UIControlStateNormal];
    [self.beautyFilterBtn setTitle:@"滤镜" forState:UIControlStateNormal];
    [self.mStyleBtn setTitle:@"风格推荐" forState:UIControlStateNormal];
    [self.mRestBtn setTitle:@"恢复" forState:UIControlStateNormal];
    
    self.skinBtn.tag = 100;
    self.shapeBtn.tag = 101;
    self.beautyFilterBtn.tag = 102 ;
    self.mStyleBtn.tag = 103 ;
    
    _isEnble = YES;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}


- (IBAction)bottomBtnsSelected:(UIButton *)sender {
    if (!_isEnble && sender != self.mStyleBtn) {
        if(sender == _skinBtn){
            [self showMessage:[NSString stringWithFormat:@"使用%@先取消“风格推荐”",@"美肤"]];
        }
        if (sender == _shapeBtn) {
            [self showMessage:[NSString stringWithFormat:@"使用%@先取消“风格推荐”",@"美型"]];
        }
        if (sender == _beautyFilterBtn) {
            [self showMessage:[NSString stringWithFormat:@"使用%@先取消“风格推荐”",@"滤镜"]];
        }
        
        return;
    }
    

    if (sender.selected) {
        sender.selected = NO ;
        [self hiddenTopViewWithAnimation:YES];
        return ;
    }
    _selBottomIndex = (int)sender.tag - 100;
    self.skinBtn.selected = NO;
    self.shapeBtn.selected = NO;
    self.beautyFilterBtn.selected = NO;
    self.mStyleBtn.selected = NO;
    sender.selected = YES;
    
    self.skinView.hidden = !self.skinBtn.selected ;
    self.shapeView.hidden = !self.shapeBtn.selected ;
    self.beautyFilterView.hidden = !self.beautyFilterBtn.selected ;
    self.mStyleView.hidden = !self.mStyleBtn.selected;
//    self.filterView.hidden = !self.filterBtn.selected ;
    
     // 美型页面
    [self setRestBtnHidden:YES];
    if (self.shapeBtn.selected) {
        /* 修改当前UI */
        [self setRestBtnHidden:NO];
        [self sliderChangeEnd:nil];
        NSInteger selectedIndex = self.shapeView.selectedIndex;
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.shapeView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
        }
    
    if (self.skinBtn.selected) {
        NSInteger selectedIndex = self.skinView.selectedIndex;
        [self setRestBtnHidden:NO];
        [self sliderChangeEnd:nil];
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.skinView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    // slider 是否显示
    if (self.beautyFilterBtn.selected) {
        
        NSInteger selectedIndex = self.beautyFilterView.selectedIndex ;
        self.beautySlider.type = FUFilterSliderType01 ;
        self.beautySlider.hidden = selectedIndex <= 0;
        if (selectedIndex >= 0) {
            FUBeautyParam *modle = self.beautyFilterView.filters[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }

    if (self.mStyleBtn.selected) {
        self.beautySlider.hidden = YES;
    }
    
    [self showTopViewWithAnimation:self.topView.isHidden];
    [self setSliderTyep:_seletedParam];
}

-(void)setSliderTyep:(FUBeautyParam *)param{
    if (param.iSStyle101) {
        self.beautySlider.type = FUFilterSliderType101;
    }else{
        self.beautySlider.type = FUFilterSliderType01 ;
    }
}

-(void)setSelBottomIndex:(int)selBottomIndex{
    _selBottomIndex = selBottomIndex;
    
    if (selBottomIndex < 4 && selBottomIndex >= 0) {
        [self bottomBtnsSelected:[self viewWithTag:100+selBottomIndex]];
    }
}

// 开启上半部分
- (void)showTopViewWithAnimation:(BOOL)animation {
    
    if (animation) {
        self.topView.alpha = 0.0 ;
        self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.frame.size.height / 2.0) ;
        self.topView.hidden = NO ;
        [UIView animateWithDuration:0.35 animations:^{
            self.topView.transform = CGAffineTransformIdentity ;
            self.topView.alpha = 1.0 ;
        }];
        
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(showTopView:)]) {
            [self.mDelegate showTopView:YES];
        }
    }else {
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.alpha = 1.0 ;
    }
}

// 关闭上半部分
-(void)hiddenTopViewWithAnimation:(BOOL)animation {
    
    if (self.topView.hidden) {
        return ;
    }
    if (animation) {
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.hidden = NO ;
        [UIView animateWithDuration:0.35 animations:^{
            self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.frame.size.height / 2.0) ;
            self.topView.alpha = 0.0 ;
        }completion:^(BOOL finished) {
            self.topView.hidden = YES ;
            self.topView.alpha = 1.0 ;
            self.topView.transform = CGAffineTransformIdentity ;
            
            self.skinBtn.selected = NO ;
            self.shapeBtn.selected = NO ;
            self.beautyFilterBtn.selected = NO ;
            self.mStyleBtn.selected = NO;
        }];
        
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(showTopView:)]) {
            [self.mDelegate showTopView:NO];
        }
    }else {
        
        self.topView.hidden = YES ;
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
    }
}

#pragma  mark -  恢复默认参数逻辑

- (IBAction)clickRestBtn:(id)sender {
    if ([[FUManager shareManager] isDefaultShapeValue] && self.shapeBtn.selected) {
        return;
    }
    if ([[FUManager shareManager] isDefaultSkinValue] && self.skinBtn.selected) {
        return;
    }
    
    [self restBeautyDefaultValue];
}

-(void)setRestBtnHidden:(BOOL)hiddle{
    _mRestBtn.hidden = hiddle;
    _sqLine.hidden = hiddle;
}

-(void)restBeautyDefaultValue{
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:nil message:@"是否将所有参数恢复到默认值" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [cancleAction setValue:[UIColor colorWithRed:44/255.0 green:46/255.0 blue:48/255.0 alpha:1.0] forKey:@"titleTextColor"];
    
    UIAlertAction *certainAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.mRestBtn.alpha = 0.7;
        if ([self.mDelegate respondsToSelector:@selector(restDefaultValue:)]) {
            if (self.skinBtn.selected) {
                [self.mDelegate restDefaultValue:1];
                [self.skinView reloadData];
                
                if (!self.beautySlider.hidden && self.skinView.selectedIndex >= 0) {
                    FUBeautyParam *param = self.skinView.dataArray[self.skinView.selectedIndex];
                    self.beautySlider.value = param.mValue;
                }
            }
            if (self.shapeBtn.selected) {
                [self.mDelegate restDefaultValue:2];
                [self.shapeView reloadData];
                
                if (!self.beautySlider.hidden && self.shapeView.selectedIndex >= 0) {
                    FUBeautyParam *param = self.shapeView.dataArray[self.shapeView.selectedIndex];
                    self.beautySlider.value = param.mValue;
                }
            }
        }
    }];
    [certainAction setValue:[UIColor colorWithRed:31/255.0 green:178/255.0 blue:255/255.0 alpha:1.0] forKey:@"titleTextColor"];
    
    [alertCon addAction:cancleAction];
    [alertCon addAction:certainAction];
    
    [[self viewControllerFromView:self]  presentViewController:alertCon animated:YES completion:^{
    }];
}


- (UIViewController *)viewControllerFromView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}


#pragma mark ---- FUFilterViewDelegate
// 开启滤镜
-(void)filterViewDidSelectedFilter:(FUBeautyParam *)param{
    _seletedParam = param;
    if (_beautyFilterView.selectedIndex > 0 && _beautyFilterBtn.selected) {
        self.beautySlider.value = param.mValue;
        self.beautySlider.hidden = NO;
        [self setSliderTyep:_seletedParam];
    }else{
        self.beautySlider.hidden = YES;
    }
    
    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(filterShowMessage:)]) {
        [self.mDelegate filterShowMessage:param.mTitle];
    }

    if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
        [_mDelegate filterValueChange:_seletedParam];
    }
}

-(void)beautyCollectionView:(FUBeautyView *)beautyView didSelectedParam:(FUBeautyParam *)param{
    if (beautyView == _mStyleView) {
        self.beautySlider.hidden = YES;
        if (_mDelegate && [_mDelegate respondsToSelector:@selector(beautyParamValueChange:)]) {
            [_mDelegate beautyParamValueChange:param];
        }
        [self changeBottomView];

        return;
    }
    _seletedParam = param;
    self.beautySlider.value = param.mValue;
    self.beautySlider.hidden = NO;
    
     [self setSliderTyep:_seletedParam];
}


-(void)changeBottomView{
    if (_mStyleView.selectedIndex == 0) {
        self.shapeBtn.alpha = 1.0;
        self.skinBtn.alpha = 1.0;
        self.beautyFilterBtn.alpha = 1.0;
        _isEnble = YES;
    }else{
        self.shapeBtn.alpha = 0.6;
        self.skinBtn.alpha = 0.6;
        self.beautyFilterBtn.alpha = 0.6;
        _isEnble = NO;
    }
}

// 滑条滑动
- (IBAction)filterSliderValueChange:(FUSlider *)sender {
    _seletedParam.mValue = sender.value;
    
    if (_beautyFilterBtn.selected) {
        if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
            [_mDelegate filterValueChange:_seletedParam];
        }
    }else{
        if (_mDelegate && [_mDelegate respondsToSelector:@selector(beautyParamValueChange:)]) {
            [_mDelegate beautyParamValueChange:_seletedParam];
        }
    }

}

- (IBAction)sliderChangeEnd:(FUSlider *)sender {

    if (self.shapeBtn.selected) {
        if ([[FUManager shareManager] isDefaultShapeValue]) {
            self.mRestBtn.alpha = 0.7;
        }else{
            self.mRestBtn.alpha = 1.0;
        }
        [self.shapeView reloadData];
    }
    
    if (self.skinBtn.selected) {
        if ([[FUManager shareManager] isDefaultSkinValue]) {
            self.mRestBtn.alpha = 0.7;
        }else{
            self.mRestBtn.alpha = 1.0;
        }
         [self.skinView reloadData];
    }
    
    [self.filterView reloadData];

}

-(void)reloadSkinView:(NSArray<FUBeautyParam *> *)skinParams{
    _skinView.dataArray = skinParams;
    _skinView.selectedIndex = 0;
//    FUBeautyParam *modle = skinParams[0];
//    if (modle) {
//        _beautySlider.hidden = NO;
//        _beautySlider.value = modle.mValue;
//    }
    [_skinView reloadData];
}

-(void)reloadShapView:(NSArray<FUBeautyParam *> *)shapParams{
    _shapeView.dataArray = shapParams;
    _shapeView.selectedIndex = 1;
    [_shapeView reloadData];
}

-(void)reloadFilterView:(NSArray<FUBeautyParam *> *)filterParams{
    _beautyFilterView.filters = filterParams;
    [_beautyFilterView reloadData];
}

-(void)reloadStyleView:(NSArray<FUBeautyParam *> *)styleParams defaultStyle:(FUBeautyParam *)selStyle{
    _mStyleView.dataArray = styleParams;
    if (selStyle) {
        int indexa = (int)[styleParams indexOfObject:selStyle];
        [self.mStyleView setSelectedIndex:indexa];
        [self changeBottomView];
    }else{
        [self.mStyleView setSelectedIndex:0];
    }
    [_mStyleView reloadData];
}


-(void)setDefaultFilter:(FUBeautyParam *)filter{
    [self.beautyFilterView setDefaultFilter:filter];
}



-(BOOL)isTopViewShow {
    return !self.topView.hidden ;
}


- (void)showMessage:(NSString *)string{
    [MBProgressHUD mm_showMessage:string];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}
@end
