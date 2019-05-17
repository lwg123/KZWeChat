//
//  DAPasswordView.h
//  DuiFuDao
//
//  Created by weiguang on 2018/8/9.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <UIKit/UIKit.h>

// 密码登录
@interface KZPTextFieldView : UIView

@property (strong, nonatomic) UITextField *textField;
@property (nonatomic,strong) UIView *lineView;


- (instancetype)initWithFrame:(CGRect)frame
                  placeholder:(NSString *)placeholder
                    leftImage:(NSString *)imgName;

@end
