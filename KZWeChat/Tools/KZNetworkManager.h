//
//  DANetworkManager.h
//  DuiFuDao
//
//  Created by weiguang on 2018/7/25.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, RequestMethod)
{
    POST = 0,
    GET,
};


/** 上传或者下载的进度 **/
typedef void (^ProgressCallBack)(NSProgress *progress);


/** responseObject:返回data中的数据， error不为空 出错*/
typedef void(^ResponseCallBack)(id responseObject, NSError *error);


@interface KZNetworkManager : NSObject

+ (instancetype)defaultManager;


#pragma mark - class method

// GET请求
+ (void)GET:(NSString *)URL
 parameters:(id)parameters
completeHandler:(ResponseCallBack)responseCallBack;



// POST请求
+ (void)POST:(NSString *)URL
  parameters:(id)parameters
completeHandler:(ResponseCallBack)responseCallBack;


// 上传文件
+ (void)uploadFileWithURL:(NSString *)URL
                imageData:(NSData *)imageData
               parameters:(NSDictionary *)parameters
                 progress:(ProgressCallBack)progress
          completeHandler:(ResponseCallBack)responseCallBack;

// 上传视频
+ (void)uploadFileWithURL:(NSString *)URL
                videoData:(NSData *)videoData
               parameters:(NSDictionary *)parameters
                 progress:(ProgressCallBack)progress
          completeHandler:(ResponseCallBack)responseCallBack;


// 下载文件
+ (void)downloadFileWithURL:(NSString *)URL
                 parameters:(id)parameters
                   progress:(ProgressCallBack)progress
            completeHandler:(ResponseCallBack)responseCallBack;


/// 根据url和parameters创建key
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters;

// 是否是手机网络
+ (BOOL)isWWANNetwork;

// 是否wifi
+ (BOOL)isWiFiNetwork;

/// 网络是否可用
+ (BOOL)isReachable;


// 取消特定的网络请求
+ (void )cancelRequest:(NSString *)url;

@end


