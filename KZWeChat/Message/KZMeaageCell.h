//
//  KZMeaageCell.h
//  KZWeChat
//
//  Created by weiguang on 2019/4/18.
//  Copyright © 2019 duia. All rights reserved.
//

static const float CellBtnWidth = 100.0;

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KZMeaageCellDelegate <NSObject>

//左滑的回调
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)tapGR;
//右滑的回调
- (void)handleSwipeRight:(UISwipeGestureRecognizer *)tapGR;

@end

@interface KZMeaageCell : UITableViewCell<UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIImageView *headerImageView;
@property (nonatomic,strong) UIButton *deleteBtn;
@property (nonatomic,strong) UIView *myContentView;
@property (nonatomic,strong) UISwipeGestureRecognizer *swipeLeft;
@property (nonatomic,strong) UISwipeGestureRecognizer *swipeRight;
@property (nonatomic,strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, weak) id<KZMeaageCellDelegate> delegate;
@property (nonatomic,strong) UILabel *nameLab;
@property (nonatomic,strong) UILabel *messageLab;
@property (nonatomic,strong) UILabel *sendTimeLab;

@property (nonatomic,strong) NSDictionary *infoDict;


@end

NS_ASSUME_NONNULL_END
