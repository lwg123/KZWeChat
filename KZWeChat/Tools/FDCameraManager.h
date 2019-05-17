//
//  FDCameraManager.h
//  DuiFuDao
//
//  Created by ztj000 on 2018/11/9.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    FDCameraAccessErrorStateNone,//没有错误
    FDCameraAccessErrorStateNoCamera,//没有摄像机
    FDCameraManagerErrorStateNoGrant,//没有授权
}FDCameraAccessErrorState;

typedef void(^CameraCheckAccess)(BOOL accessible, FDCameraAccessErrorState errorState);


@interface FDCameraManager : NSObject

// 相机是否可用
+ (BOOL)isCameraAvailable;

+ (void)checkCanAccessCameraComplete:(CameraCheckAccess)block;

//检测是否有授权，isStrict：Yes，没有的话请求授权。No,直接返回
+ (BOOL)isCameraAccessGranted:(BOOL)isStrict;

// 相机是否授权
+ (BOOL)isCameraAccessGranted;

@end

NS_ASSUME_NONNULL_END
