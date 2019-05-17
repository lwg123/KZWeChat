//
//  DAUtils.h
//  DuiFuDao
//
//  Created by weiguang on 2018/7/26.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KZUtils : NSObject<UIScrollViewDelegate,UIAlertViewDelegate>

//单例
SINGLETON_FOR_HEADER(KZUtils)


- (NSString *)getMacAddress1;

+ (NSString *)getCurrentTime;
+ (NSString *)getMacAddress; // ios7.0以后失效
+ (NSString *)getIPAddress;
+ (NSString *)uuid;
// 获取手机型号
+ (NSString *)getCurrentDeviceModel;


+ (NSArray *)gradualColors;

+ (UITextField *)createTextFieldWithFrame:(CGRect)frame
                              placeholder:(NSString *)placeholder;

/**
  创建button
 */
+ (UIButton *)createButtonWithFrame:(CGRect)frame color:(UIColor *)bgColor title:(NSString *)title;

/**
 添加UIAlertController
 cancelBlock:取消回调
 defaultBlock：确认回调
 */
+ (void)addAlertView:(NSString *)title
             message:(NSString *)message
         cancelTitle:(NSString *)cancelTitle
        confirmTitle:(NSString *)confirmTitle
         cancelBlock:(void(^)(void))cancelBlock
        defaultBlock:(void(^)(void))defaultBlock;

/**
 添加内容居左的UIAlertController
 cancelBlock:取消回调
 defaultBlock：确认回调
 */
+ (void)addLeftMessageAlertView:(NSString *)title
                        message:(NSString *)message
                    cancelTitle:(NSString *)cancelTitle
                   confirmTitle:(NSString *)confirmTitle
                    cancelBlock:(void(^)(void))cancelBlock
                   defaultBlock:(void(^)(void))defaultBlock;



@end
