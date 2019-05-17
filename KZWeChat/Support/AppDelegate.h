//
//  AppDelegate.h
//  KZWeChat
//
//  Created by weiguang on 2019/4/8.
//  Copyright © 2019 duia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


+ (AppDelegate *)shareAppDelegate;
-(UIViewController *)getCurrentVC;
-(UIViewController *)getCurrentUIVC;

@end

