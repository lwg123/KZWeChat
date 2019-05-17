//
//  UIColor+Utils.h
//  DuiFuDao
//
//  Created by weiguang on 2018/7/24.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utils)

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
+ (UIColor *)colorWithHexString: (NSString *)color;
+ (NSString *)hexValuesFromUIColor:(UIColor *)color;

-(BOOL)isEqualColor:(UIColor*)otherColor;
@end
