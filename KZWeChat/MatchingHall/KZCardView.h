//
//  KZCardView.h
//  KZWeChat
//
//  Created by weiguang on 2019/4/25.
//  Copyright © 2019 duia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KZUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface KZCardView : UIView

@property (nonatomic,strong) KZUser *user;
- (instancetype)initWithFrame:(CGRect)frame user:(KZUser *)user;

@end

NS_ASSUME_NONNULL_END
