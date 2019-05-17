//
//  KZPersonInfoController.h
//  KZWeChat
//
//  Created by weiguang on 2019/4/9.
//  Copyright © 2019 duia. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^callBack)(NSString *);

@interface KZPersonInfoController : KZBaseViewController

@property (nonatomic,weak) callBack callback;

@end

NS_ASSUME_NONNULL_END
