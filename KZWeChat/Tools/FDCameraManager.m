//
//  FDCameraManager.m
//  DuiFuDao
//
//  Created by ztj000 on 2018/11/9.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import "FDCameraManager.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

@implementation FDCameraManager

+ (BOOL)isCameraAvailable
{
    return  [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (void)checkCanAccessCameraComplete:(CameraCheckAccess)block
{
    if ([[self class] isCameraAvailable]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            //有可能在任意线程上调用
            FDCameraAccessErrorState errorState =granted? FDCameraAccessErrorStateNone:FDCameraManagerErrorStateNoGrant;
            dispatch_async(dispatch_get_main_queue(), ^{
                block(granted, errorState);
            });
        }];
    }
    else
    {
        block(NO,FDCameraAccessErrorStateNoCamera);
    }
}


+ (BOOL)isCameraAccessGranted:(BOOL)isStrict
{
    if (!isStrict) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType: AVMediaTypeVideo];
        if (status == AVAuthorizationStatusNotDetermined ||
            status == AVAuthorizationStatusAuthorized) {
            return YES;
        }
        return NO;
    }
    else {
        __block BOOL hasCalledBack = NO;
        __block BOOL isGranted = NO;
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            isGranted = granted;
            hasCalledBack = YES;
            
        }];
        
        
        
        NSTimeInterval checkEveryInterval = 0.1;
        while(!hasCalledBack) {
            @autoreleasepool {
                if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:checkEveryInterval]])
                    [NSThread sleepForTimeInterval:checkEveryInterval];
            }
        }
        
        return isGranted;
        
        
    }
    return YES;
}

+ (BOOL)isCameraAccessGranted
{
    return [self isCameraAccessGranted:NO];
}

@end
