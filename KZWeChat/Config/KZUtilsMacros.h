//
//  DAConfig.h
//  DuiaTest
//
//  Created by weiguang on 2018/7/23.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#ifndef DAConfig_h
#define DAConfig_h

/** 录制视频时的屏高宽   */
#define kVideoWidth 272
#define kVideoHeight 480


/* ------------------- 获取系统对象 ------------------------- */

#define kNotificationCenter [NSNotificationCenter defaultCenter]

#define kUserDefault [NSUserDefaults standardUserDefaults]

#define kApplication [UIApplication sharedApplication]

#define kAppWindow [UIApplication sharedApplication].delegate.window

#define kAppDelegate [DAAppDelegate shareAppDelegate]

#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#define kNavBarHeight 44.0

#define kNavigationBarHeight (IS_iPhoneX?88.0:64.0)

#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)

#define kTopHeight (kStatusBarHeight + kNavBarHeight)

/// 底部安全距离
#define kBottomSafeHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0)

//发送通知
#define KPostNotification(name,obj) [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];


/* ------------------- 获取屏幕宽高 ------------------------- */

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define SCREEN_FRAME [UIScreen mainScreen].bounds
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define Iphone6ScaleWidth SCREEN_WIDTH/375.0

#define Iphone6ScaleHeight SCREEN_HEIGHT/667.0

// 适配iPhoneX,若为iPhoneX导航的高度为88，否则为64
#define NavgationHeight (IS_iPhoneX ? 88 : 64)

#define StatusBarHeight (IS_iPhoneX ? 44 : 20)

//系统型号相关
#define IOS_SystemValue [[[UIDevice currentDevice] systemVersion] floatValue]
#define IS_IOS7_Later  IOS_SystemValue>=7
#define IS_IOS8_Later  IOS_SystemValue>=8
#define IS_IOS9_Later  IOS_SystemValue>=9
#define IS_IOS10_Later IOS_SystemValue>=10
#define IS_IOS11_Later IOS_SystemValue>=11
#define IS_IOS12_Later IOS_SystemValue>=12

#define IS_IOS7  (IOS_SystemValue>=7&&IOS_SystemValue<8)
#define IS_IOS8  (IOS_SystemValue>=8&&IOS_SystemValue<9)
#define IS_IOS9  (IOS_SystemValue>=9&&IOS_SystemValue<10)
#define IS_IOS10 (IOS_SystemValue>=10&&IOS_SystemValue<11)
#define IS_IOS11 (IOS_SystemValue>=11&&IOS_SystemValue<12)
#define IS_IOS12 (IOS_SystemValue>=12&&IOS_SystemValue<13)

//机型相关


// 判断是否iPhone 设备
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)
#define IS_IPHONE_4 (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_iPhoneX  isIPhoneXSeries()
#define IS_IPHONE_SMALL (IS_IPHONE && SCREEN_MAX_LENGTH <= 568.0)

#define iphone4x_3_5 ([UIScreen mainScreen].bounds.size.height==480.0f)

#define iphone5x_4_0 ([UIScreen mainScreen].bounds.size.height==568.0f)

#define iphone6_4_7 ([UIScreen mainScreen].bounds.size.height==667.0f)

#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

#define iPhone4S ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)    //是否是IPhone4S
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)    //是否是IPhone5
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)    //是否是IPhone6
#define Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)    //是否是IPhone6 Plus

#define iPhoneX  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneXSMAX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneXR ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)

/* ------------------- 获取颜色 ------------------------- */
#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define RGBHex(color) [UIColor colorWithRed:((color>>16)&0xFF)/255.0f green:((color>>8)&0xFF)/255.0f blue:(color&0xFF)/255.0f alpha:1.0f]

#define RGBAHex(color,alphaValue) [UIColor colorWithRed:((color>>16)&0xFF)/255.0f green:((color>>8)&0xFF)/255.0f blue:(color&0xFF)/255.0f alpha:alphaValue]

#define kRandomColorKRGBColor (arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0)

#define RGBRandomColor RGB(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256))

//GCD - 一次性执行
#define DISPATCH_ONCE_BLOCK(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock);

//GCD - 在Main线程上运行
#define GCDMain(mainQueueBlock) dispatch_async(dispatch_get_main_queue(), mainQueueBlock);

//GCD - 开启异步线程
#define GCDGlobal(globalQueueBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalQueueBlocl);


//强弱引用

#define WeakSelf __weak typeof(self) weakSelf = self;

#define kWeakSelf(type)__weak typeof(type)weak##type = type;

#define kStrongSelf(type)__strong typeof(type)type = weak##type;

//当前系统版本

#define CurrentSystemVersion [[UIDevice currentDevice].systemVersion doubleValue]

//当前语言
#define CurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])

//判断是真机还是模拟器
#if TARGET_OS_IPHONE
//iPhone Device
#endif

#if TARGET_IPHONE_SIMULATOR
//iPhone Simulator
#endif

/* -------------------打印日志------------------------- */

//DEBUG模式下打印日志,当前行

#ifdef DEBUG

#define DLog(fmt,...)NSLog((@"%s[Line %d]" fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);

#else

#define DLog(...)

#endif

//拼接字符串

#define NSStringFormat(format,...)[NSString stringWithFormat:format,##__VA_ARGS__]


//获取一段时间间隔

#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();

#define kEndTimeNSLog (@"Time: %f",CFAbsoluteTimeGetCurrent()- start)

//打印当前方法名

#define ITTDPRINTMETHODNAME()ITTDPRINT(@"%s",__PRETTY_FUNCTION__)

/* ------------------- 获取文件路径 ------------------------- */
//获取temp
#define kPathTemp NSTemporaryDirectory()

//获取沙盒 Document
#define kPathDocument [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]

//获取沙盒 Cache
#define kPathCache [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]


//单例化一个类
#define SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}

//去掉scrollView自动调整边距(@available运行时检查系统版本)
#define AdjustsScrollViewInsets_NO(scrollView,vc)\
\
if (@available(iOS 11.0, *)) {\
scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;\
} else {\
vc.automaticallyAdjustsScrollViewInsets = NO;\
}

// 判断是否是iPhone X/XS/XR/XS Max
static inline BOOL isIPhoneXSeries() {
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}



#define FONT(NAME,FONTSIZE) ([UIFont fontWithName:(NAME)size:(FONTSIZE)]?:[UIFont systemFontOfSize:FONTSIZE])
#define PF_SC_Regular(FONTSIZE) FONT(@"PingFang-SC-Regular",FONTSIZE)

#define Maincolor RGB(54,113,228)
#define secretKey @"2019041920190419"
#define viKey  @"1234567890123412"

#endif /* DAConfig_h */
