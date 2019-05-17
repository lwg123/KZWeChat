//
//  DAAppManager.m
//  DuiaTest
//
//  Created by weiguang on 2018/7/23.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import "KZAppManager.h"
#import "KeychainItemWrapper.h"
#import <YYCache.h>

//用户信息缓存 名称
#define KUserCacheName @"KUserCacheName"

// 缓存用户聊天记录
#define KUserChatCache @"KUserChatCache"

//用户model缓存
#define KUserModelCache @"KUserModelCache"


static NSString * const DA_UUID_Key = @"DA_tyui8762157_key";
static NSString * const DA_LoginAccount_Key = @"DA_lo238dyhanjknckja_key";
static NSString * const DA_LoginPwd_Key = @"DA_pwsda78234816hbj_Key";
static NSString * const DA_UserId_Key = @"ZHY_uisdandkj387_key";
static NSString * const KZ_FirstLogin_Key = @"KZ_FirstLogin_Key";

@implementation KZAppManager


#pragma mark account & password
+ (void)setEmail:(NSString *)email
{
    [self p_setValue:email forKey:DA_LoginAccount_Key];
}

+ (NSString *)getEmail
{
    NSString *account = [self p_getValueKey:DA_LoginAccount_Key];
    return account == nil ? @"":account;
}

+ (void)setPassword:(NSString *)pwd
{
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithAccount:DA_LoginPwd_Key accessGroup:nil];
    [keyChain setObject:pwd forKey:(__bridge id)kSecValueData];
}

+ (NSString *)getPassword
{
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithAccount:DA_LoginPwd_Key accessGroup:nil];
    NSString *pwd = [keyChain objectForKey:(__bridge id)kSecValueData];;
    return pwd == nil ? @"":pwd;
}


+ (void)setuuid:(NSString *)uuid {
    
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithAccount:DA_UUID_Key accessGroup:nil];
    [keyChain setObject:uuid forKey:(__bridge id)kSecValueData];
}

+ (NSString *)getuuid {
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithAccount:DA_UUID_Key accessGroup:nil];
    NSString *uuid = [keyChain objectForKey:(__bridge id)kSecValueData];;
    return uuid == nil ? @"" : uuid;
}


+ (void)setIPAddress:(NSString *)iPAddress {
    [self p_setValue:iPAddress forKey:@"iPAddress"];
}

+ (NSString *)getIPAddress {
    return [self p_getValueKey:@"iPAddress"];
}

+ (void)setUserId:(NSString *)userId {
    [self p_setValue:userId forKey:@"userId"];
}

+ (NSString *)getUserId {
    return [self p_getValueKey:@"userId"];
}

+ (void)setChannel_id:(NSString *)channel_id {
    [self p_setValue:channel_id forKey:@"channel_id"];
}

+ (NSString *)getChannel_id
{
    return [self p_getValueKey:@"channel_id"];
}

+ (void)saveUserInfo:(KZUser *)userInfo{
    if (userInfo) {
        YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
        [cache setObject:(id)userInfo forKey:KUserModelCache];
        
    }
}

+ (KZUser *)loadUserInfo{
    YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
    KZUser *userInfo = (KZUser *)[cache objectForKey:KUserModelCache];
    if (userInfo) {
        return userInfo;
    }else {
        return nil;
    }
}

+ (void)clearUserInfo {
    YYCache *cache = [[YYCache alloc]initWithName:KUserCacheName];
    [cache removeAllObjects];
    [KZAppManager setUserId:@""];
}

// 保存第一次登录标记
+ (void)setFirstLogin:(NSString *)str
{
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithAccount:KZ_FirstLogin_Key accessGroup:nil];
    [keyChain setObject:str forKey:(__bridge id)kSecValueData];
}


+ (NSString *)getFirstLogin
{
    KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithAccount:KZ_FirstLogin_Key accessGroup:nil];
    NSString *uuid = [keyChain objectForKey:(__bridge id)kSecValueData];;
    return uuid;
}

+ (void)saveMessage:(NSArray *)array userid:(NSString *)userid
{
    YYCache *cache = [[YYCache alloc]initWithName:[NSString stringWithFormat:@"%@-%@",KUserChatCache,userid]];
    [cache setObject:array forKey:[NSString stringWithFormat:@"%@-%@",KUserChatCache,userid]];
}

+(NSArray *)getMessage:(NSString *)userid
{
    YYCache *cache = [[YYCache alloc]initWithName:[NSString stringWithFormat:@"%@-%@",KUserChatCache,userid]];
    NSArray *array = (NSArray *)[cache objectForKey:[NSString stringWithFormat:@"%@-%@",KUserChatCache,userid]];
    
    return array;
}

#pragma mark - 保存设备token字符串
+ (void)saveDeviceTokenStr:(NSString*)deviceTokenStr{
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:@"Push_DeviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)getDeviceTokenStr {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"Push_DeviceToken"];
}

#pragma mark - 保存对啊登录返回个人
+ (void)saveVideoArray:(NSMutableArray *)videoArray{
    
    NSString *path = [kPathDocument stringByAppendingPathComponent:@"videoArray"];
    [videoArray writeToFile:path atomically:YES];
}

+ (NSMutableArray *)getVideoArray{
    
    NSString *path = [kPathDocument stringByAppendingPathComponent:@"videoArray"];
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfURL:[NSURL fileURLWithPath:path]];
    
    return array;
}

+ (void)savePhoto:(UIImage *)image
{
    NSString *path = [kPathDocument stringByAppendingPathComponent:@"PhotoImage"];
    [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
}

+ (UIImage *)getPhoto
{
    NSString *path = [kPathDocument stringByAppendingPathComponent:@"PhotoImage"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+ (void)saveZiPaiVideo:(NSString *)ZiPaiVideoPath
{
    [[NSUserDefaults standardUserDefaults] setObject:ZiPaiVideoPath forKey:@"ZiPaiVideoPath"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getZiPaiVideo {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"ZiPaiVideoPath"];
}



/***********************  共用方法  ***********************************/
#pragma mark - private setter and getter method
+ (void)p_setValue:(id)value forKey:(NSString*)key {
    if (value == nil) {
        value = @"";
    }
    if ([value isKindOfClass:[NSNull class]]) {
        return;
    }
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:value forKey:key];
    [userdefaults synchronize];
}

+ (id)p_getValueKey:(NSString*)key {
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    return [userdefaults objectForKey:key];
}


@end
