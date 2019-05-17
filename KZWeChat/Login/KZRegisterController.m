//
//  KZRegisterController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/8.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZRegisterController.h"
#import "AuthcodeView.h"
#import "KZMatchingHallController.h"
#import "KZAgreementController.h"


@interface KZRegisterController ()<UITextFieldDelegate>
{
    BOOL isCheck;
}
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) UILabel *titleLab;
@property (nonatomic,strong) KZPTextFieldView *emailFieldView;
@property (nonatomic,strong) KZPTextFieldView *passwordFieldView;
@property (nonatomic,strong) KZPTextFieldView *codeFieldView;
@property (nonatomic,strong) AuthcodeView *authCodeView;
@property (nonatomic,strong) UIButton *registerBtn;
@property (nonatomic,strong) UILabel *xieyiLab;
@property (nonatomic,strong) UIImageView *xieyiImgView;

@end

@implementation KZRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"注册";
    [self setupUI];
    isCheck = YES;
    
    [self registerNotification];
}

- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置导航栏为透明色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

#pragma mark keyBoardNotification

- (void)keyBoardWillShow:(NSNotification *)notify
{
    CGRect keyboardRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat transY = - keyboardRect.size.height;
    kWeakSelf(self);
    [UIView animateWithDuration:duration
                     animations:^{
 
                         weakself.view.transform = CGAffineTransformMakeTranslation(0, -60);
                         
                     }];
}


- (void)keyBoardWillHide:(NSNotification *)notify
{
    
    [UIView animateWithDuration:.35
                     animations:^{
                         
                         self.view.transform = CGAffineTransformMakeTranslation(0, 60);
                         
                         
                         
                         
                     }];
    
}

- (void)setupUI {
    [self.view addSubview:self.bgImageView];
    
    //app名字
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 95, 95)];
    iconView.center = CGPointMake(SCREEN_WIDTH/2, 160);
    iconView.image = [UIImage imageNamed:@"logo"];
    [self.bgImageView addSubview:iconView];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    nameLab.text = @"聊呗";
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.textColor = [UIColor whiteColor];
    nameLab.font = PF_SC_Regular(20.0);
    [nameLab sizeToFit];
    nameLab.center = CGPointMake(SCREEN_WIDTH/2, iconView.maxY+15);
    [self.bgImageView addSubview:nameLab];
    
    // 邮箱和密码输入框
    KZPTextFieldView *emailFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, nameLab.maxY+40, SCREEN_WIDTH - 80, 40) placeholder:@"请输入邮箱" leftImage:@"邮箱"];
    emailFieldView.textField.keyboardType = UIKeyboardTypeEmailAddress;
    emailFieldView.textField.delegate = self;
    [self.bgImageView addSubview:emailFieldView];
    _emailFieldView = emailFieldView;
    
    KZPTextFieldView *codeFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, emailFieldView.maxY+30, (SCREEN_WIDTH - 80)/2+20, 40) placeholder:@"图形验证码" leftImage:@"邀请码"];
    codeFieldView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    codeFieldView.textField.delegate = self;
    _codeFieldView = codeFieldView;
    [self.bgImageView addSubview:codeFieldView];
    
    // 验证码
    _authCodeView = [[AuthcodeView alloc] initWithFrame:CGRectMake(self.codeFieldView.maxX, _codeFieldView.y, (SCREEN_WIDTH - 80)/2-20, self.codeFieldView.height)];
    [self.bgImageView addSubview:_authCodeView];
    
    
    KZPTextFieldView *passwordFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, codeFieldView.maxY+30, SCREEN_WIDTH-80, 40) placeholder:@"请输入密码" leftImage:@"密码"];
    passwordFieldView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    passwordFieldView.textField.delegate = self;
    passwordFieldView.textField.secureTextEntry = YES;
    _passwordFieldView = passwordFieldView;
    [self.bgImageView addSubview:passwordFieldView];
    
    
    [self.bgImageView addSubview:self.registerBtn];
    [self setupXieyiLab];
}


#pragma mark -- UI --
- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerBtn.frame = CGRectMake(40, _passwordFieldView.maxY+50, SCREEN_WIDTH-40 * 2, 50);
        [self.bgImageView addSubview:_registerBtn];
        [_registerBtn addTarget:self action:@selector(registerBtnClick) forControlEvents:UIControlEventTouchUpInside];
        //添加渐变色
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, 0, _registerBtn.width, _registerBtn.height);
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        gradientLayer.locations = @[@(0.1),@(0.5),@(0.9)]; //渐变点
        [gradientLayer setColors:@[(id)[RGB(42, 150, 222) CGColor],(id)[RGB(58, 106, 231) CGColor],(id)[RGB(61, 102, 232) CGColor]]]; //渐变数组
        [_registerBtn.layer addSublayer:gradientLayer];
        
        [_registerBtn setTitle:@"注册并登录" forState:UIControlStateNormal];
        [_registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _registerBtn.titleLabel.font = PF_SC_Regular(20);
        _registerBtn.layer.cornerRadius = 25;
        _registerBtn.layer.masksToBounds = YES;
    }
    return _registerBtn;
}



- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.userInteractionEnabled = YES;
        _bgImageView.image = [UIImage imageNamed:@"background"];
    }
    return _bgImageView;
}

- (void)setupXieyiLab {
    
    _xieyiLab = [[UILabel alloc] initWithFrame:CGRectMake(0, self.registerBtn.maxY+20, 215, 16)];
    _xieyiLab.backgroundColor = [UIColor clearColor];
    
    [self.bgImageView addSubview:_xieyiLab];
    NSString *text = @"注册表示您已满18岁，并接收《用户协议》";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:text];
    [attributedString addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:NSMakeRange(0, text.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:RGB(39, 142, 198) range:NSMakeRange(text.length-6, 6)];
    
    _xieyiLab.attributedText = attributedString;
    [_xieyiLab sizeToFit];
    _xieyiLab.centerX = SCREEN_WIDTH/2;
    // 添加左边选择框
    _xieyiImgView = [[UIImageView alloc] initWithFrame:CGRectMake(_xieyiLab.x-20, _xieyiLab.y, 13, 13)];
    _xieyiImgView.image = [UIImage imageNamed:@"xieyi-c"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(xieyiImgViewClick)];
    _xieyiImgView.userInteractionEnabled = YES;
    [_xieyiImgView addGestureRecognizer:tap];
    _xieyiImgView.centerY = _xieyiLab.centerY;
    [self.bgImageView addSubview:_xieyiImgView];
    
    
    UIButton *xieyiBtn = [[UIButton alloc] initWithFrame:CGRectMake(_xieyiLab.maxX-85, _xieyiLab.y, 85, 24)];
    xieyiBtn.backgroundColor = [UIColor clearColor];
    [xieyiBtn addTarget:self action:@selector(xieyiBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgImageView addSubview:xieyiBtn];
}


- (UITextField *)createTextFieldWithFrame:(CGRect)frame
                     placeholder:(NSString *)placeholder
                        leftView:(UIView *)leftView
{
    UITextField *field = [[UITextField alloc] initWithFrame:frame];
    field.placeholder = placeholder;
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.leftView = leftView;
    field.leftViewMode = UITextFieldViewModeAlways;
    field.returnKeyType = UIReturnKeyDone;
    return field;
}


#pragma mark -- action --

- (void)xieyiBtnClick {
   
    KZAgreementController *agreenmentVC = [[KZAgreementController alloc] init];
    [self.navigationController pushViewController:agreenmentVC animated:YES];
}

- (void)xieyiImgViewClick {
    
    if ([_xieyiImgView.image isEqual: [UIImage imageNamed:@"xieyi"] ]) {
        _xieyiImgView.image = [UIImage imageNamed:@"xieyi-c"];
        isCheck = YES;
        
    }else {
        _xieyiImgView.image = [UIImage imageNamed:@"xieyi"];
        isCheck = NO;
    }
}


- (void)registerBtnClick {
    if (!isCheck) {
        [KZUtils addAlertView:@"温馨提示" message:@"请同意协议" cancelTitle:nil confirmTitle:@"确定" cancelBlock:nil defaultBlock:^{
            
        }];
        return;
    }
    // 先验证邮箱是否正确
    BOOL validate = [self validateEmail:self.emailFieldView.textField.text];
    if (!validate) {
        [KZUtils addAlertView:@"温馨提示" message:@"邮箱错误，请重新输入" cancelTitle:nil confirmTitle:@"确定" cancelBlock:nil defaultBlock:^{
            
        }];
        return;
    }
    
    
    // 密码是否存在,密码限制6 - 16位
    if (_passwordFieldView.textField.text.length < 6 || _passwordFieldView.textField.text.length > 16) {
        [KZUtils addAlertView:@"提示" message:@"密码长度6-16位" cancelTitle:nil confirmTitle:@"确定" cancelBlock:nil defaultBlock:^{
            
        }];
        return;
    }
    
    if (_codeFieldView.textField.text.length == 0) {
        [KZUtils addAlertView:@"提示" message:@"请输入验证码" cancelTitle:nil confirmTitle:@"确定" cancelBlock:nil defaultBlock:^{
            
        }];
        return;
    }
    
    // 用户名和密码
    NSString *userName = [[EncryptionTools sharedEncryptionTools] encryptString:_emailFieldView.textField.text keyString:secretKey iv:[viKey dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *password = [[EncryptionTools sharedEncryptionTools] encryptString:_passwordFieldView.textField.text keyString:secretKey iv:[viKey dataUsingEncoding:NSUTF8StringEncoding]];

    // 注册
    NSDictionary *pram = @{
                           @"username" : userName,
                           @"password" : password,
                           @"ip" : [KZAppManager getIPAddress],
                           @"authCode" : _codeFieldView.textField.text
                           };
    [KZNetworkManager POST:@"api/register" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            NSLog(@"%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [KZAppManager setUserId:responseObject[@"user_id"]];
                KZMatchingHallController *matchingHallVC = [[KZMatchingHallController alloc] init];
                [self.navigationController pushViewController:matchingHallVC animated:YES];
                
            });
        }else {
            NSLog(@"%@",error.domain);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
    }];
    
}

/*
- (void)requestPersonInform {
    
    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           };
    [KZNetworkManager POST:@"user/detail" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            NSLog(@"%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 保存个人信息，跳转配对大厅
                KZUser *user = [[KZUser alloc] initWithDict:responseObject];
                [KZAppManager saveUserInfo:user];
                
                KZMatchingHallController *matchingHallVC = [[KZMatchingHallController alloc] init];
                [self.navigationController pushViewController:matchingHallVC animated:YES];
                
            });
        }else {
            NSLog(@"%@",error.domain);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
    
}
 */


//判断用户输入是否为邮箱
- (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:candidate];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
