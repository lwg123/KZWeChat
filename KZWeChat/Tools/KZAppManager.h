//
//  DAAppManager.h
//  DuiaTest
//
//  Created by weiguang on 2018/7/23.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KZUser.h"
@interface KZAppManager : NSObject


+ (void)setuuid:(NSString *)uuid;
+ (NSString *)getuuid;

#pragma mark - account & password
+ (void)setEmail:(NSString *)email;   //登录帐号
+ (void)setPassword:(NSString *)pwd;  //登录密码


+ (NSString *)getEmail;
+ (NSString *)getPassword;

+ (void)setIPAddress:(NSString *)iPAddress;
+ (NSString *)getIPAddress;

+ (void)setUserId:(NSString *)userId;
+ (NSString *)getUserId;

+ (void)setChannel_id:(NSString *)channel_id;
+ (NSString *)getChannel_id;

#pragma mark - 保存设备token字符串
+ (void)saveDeviceTokenStr:(NSString*)deviceTokenStr;
+ (NSString*)getDeviceTokenStr;

// 保存第一次登录标记
+ (void)setFirstLogin:(NSString *)str;
+ (NSString *)getFirstLogin;


#pragma mark - 保存视频数组
+ (void)saveVideoArray:(NSMutableArray *)videoArray;
+ (NSMutableArray *)getVideoArray;

+ (void)saveUserInfo:(KZUser *)userInfo;

+ (KZUser *)loadUserInfo;

+ (void)clearUserInfo;

+ (void)savePhoto:(UIImage *)image;
+ (UIImage *)getPhoto;

+ (void)saveZiPaiVideo:(NSString *)str;
+ (NSString *)getZiPaiVideo;

+ (void)saveMessage:(NSArray *)array userid:(NSString *)userid;

+(NSArray *)getMessage:(NSString *)userid;

@end
