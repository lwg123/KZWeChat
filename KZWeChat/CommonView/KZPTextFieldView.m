//
//  DAPasswordView.m
//  DuiFuDao
//
//  Created by weiguang on 2018/8/9.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import "KZPTextFieldView.h"

@interface KZPTextFieldView()

@property (nonatomic,strong) NSString *placeholder;
@property (nonatomic,strong) NSString *imgName;
@end


@implementation KZPTextFieldView

- (instancetype)initWithFrame:(CGRect)frame
                  placeholder:(NSString *)placeholder
                    leftImage:(NSString *)imgName
{
    self = [super initWithFrame:frame];
    if (self) {
        _placeholder = placeholder;
        _imgName = imgName;
        [self setupUI];
    }
    return self;
}


- (void)setupUI {
    // 底线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-1.0, self.width, 1.0)];
    lineView.backgroundColor = RGB(204, 204, 204);
    [self addSubview:lineView];
    _lineView = lineView;
    
    // 添加image图片
    UIImageView *lockImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 20)];
    lockImg.centerY = self.height/2;
    lockImg.image = [UIImage imageNamed:_imgName];
   // lockImg.backgroundColor = [UIColor clearColor];
    lockImg.tintColor = [UIColor whiteColor];
    [self addSubview:lockImg];
    
    // 输入框
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(lockImg.maxX+10, 0, self.width - (lockImg.maxX+10), 30)];
    _textField.centerY = self.height/2;
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.font = PF_SC_Regular(16);
    _textField.textColor = [UIColor whiteColor];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.placeholder = _placeholder;
    [_textField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:_textField];
    
}


@end
