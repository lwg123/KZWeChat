//
//  DACommonMacros.h
//  DuiFuDao
//
//  Created by weiguang on 2018/7/23.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#ifndef DACommonMacros_h
#define DACommonMacros_h

#pragma mark - ——————— 用户通知 ————————

//登录成功
#define KNotificationLoginSuccess @"KNotificationLoginSuccess"

//用户选择退出
#define KNotificationLogoutSuccess @"KNotificationLogoutSuccess"

// 注册成功
#define KNotificationRegisterSuccess @"KNotificationRegisterSuccess"

#define KNotificationSaveVideoSucess @"KNotificationSaveVideoSucess"

// 视频录制 时长
#define kzRecordTime        5.0

#define kzThemeBlackColor   [UIColor blackColor]
#define kzThemeTineColor    [UIColor greenColor]
#define kzNavColor RGB(49,130,224)


#pragma mark ---  常量值 -----
static const double kTextFieldHeight = 40.0;
static const double kTextFieldWidth = 300.0;

#define iPhone5AndEarlyDevice (([[UIScreen mainScreen] bounds].size.height*[[UIScreen mainScreen] bounds].size.width <= 320*568)?YES:NO)
#define Iphone6 (([[UIScreen mainScreen] bounds].size.height*[[UIScreen mainScreen] bounds].size.width <= 375*667)?YES:NO)

static inline float lengthFit(float iphone6PlusLength)
{
    if (iPhone5AndEarlyDevice) {
        return iphone6PlusLength *320.0f/414.0f;
    }
    if (Iphone6) {
        return iphone6PlusLength *375.0f/414.0f;
    }
    return iphone6PlusLength;
}

#define PAN_DISTANCE 120
#define CARD_WIDTH lengthFit(333)    // 301.63
#define CARD_HEIGHT lengthFit(400)  //362.319



#endif /* DACommonMacros_h */
