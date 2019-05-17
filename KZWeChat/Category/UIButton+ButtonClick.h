//
//  UIButton+ButtonClick.h
//  KZWeChat
//
//  Created by weiguang on 2019/4/26.
//  Copyright © 2019 duia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 避免button重复点击
#define defaultInterval 0.5//默认时间间隔

@interface UIButton (ButtonClick)


@property(nonatomic,assign)NSTimeInterval timeInterval;//用这个给重复点击加间隔
@property(nonatomic,assign)BOOL isIgnoreEvent;//YES不允许点击NO允许点击

@end

NS_ASSUME_NONNULL_END
