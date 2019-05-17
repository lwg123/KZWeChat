//
//  KZRegisterViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/8.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZLoginViewController.h"
#import "KZRegisterController.h"
#import "KZMatchingHallController.h"
#import "KZUser.h"
#import "KZPersonInfoController.h"

@interface KZLoginViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) UIButton *loginBtn;
@property (nonatomic,strong) KZPTextFieldView *emailFieldView;
@property (nonatomic,strong) KZPTextFieldView *passwordFieldView;
@property (nonatomic,strong) UIButton *registerBtn;
@property (nonatomic,strong) UIImageView *backgroundImage;

@end

@implementation KZLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"登录";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self setupUI];
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
    
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.shadowImage = nil;
}



- (void)setupUI {
    [self.view addSubview:self.backgroundImage];
    //app名字
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 95, 95)];
    CGFloat height = 0.0;
    if (iPhone5AndEarlyDevice) {
        height = kNavigationBarHeight + 40;
    }else {
        height = kNavigationBarHeight + 80;
    }
    iconView.center = CGPointMake(SCREEN_WIDTH/2, height);
    iconView.image = [UIImage imageNamed:@"logo"];
    [self.backgroundImage addSubview:iconView];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    nameLab.text = @"聊呗";
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.textColor = [UIColor whiteColor];
    nameLab.font = PF_SC_Regular(20.0);
    [nameLab sizeToFit];
    nameLab.center = CGPointMake(SCREEN_WIDTH/2, iconView.maxY+15);
    [self.backgroundImage addSubview:nameLab];
    
    // 邮箱和密码输入框
    KZPTextFieldView *emailFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, nameLab.maxY+50, SCREEN_WIDTH - 80, 40) placeholder:@"请输入邮箱" leftImage:@"邮箱"];
    emailFieldView.textField.keyboardType = UIKeyboardTypeEmailAddress;

    emailFieldView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;//设置首字母小写
    emailFieldView.textField.returnKeyType = UIReturnKeyNext;
    emailFieldView.textField.delegate = self;

    [self.backgroundImage addSubview:emailFieldView];
    _emailFieldView = emailFieldView;
    
    
    KZPTextFieldView *passwordFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, emailFieldView.maxY+30, SCREEN_WIDTH-80, 40) placeholder:@"请输入密码" leftImage:@"密码"];
    passwordFieldView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    passwordFieldView.textField.secureTextEntry = YES;

    passwordFieldView.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;  //  首字母小写
    passwordFieldView.textField.delegate = self;

    _passwordFieldView = passwordFieldView;
    [self.backgroundImage addSubview:passwordFieldView];
    
    // 登录
    [self.view addSubview:self.loginBtn];
    // 注册新用户
    [self.view addSubview:self.registerBtn];
    
    // 监听输入
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (UIImageView *)backgroundImage {
    if (!_backgroundImage) {
        _backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _backgroundImage.image = [UIImage imageNamed:@"background"];
        _backgroundImage.userInteractionEnabled = YES;
    }
    return _backgroundImage;
}

- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [self createButtonWithFrame:CGRectMake(40, self.passwordFieldView.maxY+60, SCREEN_WIDTH-80, 45) color:RGBA(60, 108, 166, 1.0) title:@"登录" textColor:[UIColor whiteColor]];
        _loginBtn.alpha = 0.6;
        _loginBtn.enabled = YES;
        _loginBtn.tag = 1001;
    }
    return _loginBtn;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        
        _registerBtn = [self createButtonWithFrame:CGRectMake(40, self.loginBtn.maxY+40, SCREEN_WIDTH-80, 45) color:[UIColor grayColor] title:@"注册新用户" textColor:[UIColor whiteColor]];
        _registerBtn.alpha = 0.6;
        _registerBtn.tag = 1002;
        _registerBtn.timeInterval = 0.5; // 防止重复点击
        
    }
    return _registerBtn;
}


- (UIButton *)createButtonWithFrame:(CGRect)frame color:(UIColor *)bgColor title:(NSString *)title textColor:(UIColor *)textColor{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    btn.titleLabel.font = PF_SC_Regular(20);
    [btn setBackgroundColor:bgColor];
    btn.layer.cornerRadius = frame.size.height/2;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(loginBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}


#pragma mark -- action --
- (void)loginBtnClick:(UIButton *)button {
    
    if (button.tag == 1001) {
        DLog(@"点击登录");
       
//        KZMatchingHallController *vc = [[KZMatchingHallController alloc] init];
//        [self.navigationController pushViewController:vc animated:YES];
        
        [self login];
    }else if (button.tag == 1002){
        DLog(@"注册");
        KZRegisterController *regVC = [[KZRegisterController alloc] init];
        [self.navigationController pushViewController:regVC animated:YES];
    }
}

- (void)login {
    // 检验用户名和密码
    if (_emailFieldView.textField.text.length == 0) {
        [self.view makeToast:@"请输入用户名"];
        return;
    }
    if (_passwordFieldView.textField.text.length == 0) {
        [self.view makeToast:@"请输入密码"];
        return;
    }

    // 用户名和密码
    NSString *username = [[EncryptionTools sharedEncryptionTools] encryptString:_emailFieldView.textField.text keyString:secretKey iv:[viKey dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *password = [[EncryptionTools sharedEncryptionTools] encryptString:_passwordFieldView.textField.text keyString:secretKey iv:[viKey dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary *pram = @{
                           @"username" : username,
                           @"password" : password,
                           @"ip" : [KZAppManager getIPAddress]
                           };
    [KZNetworkManager POST:@"api/login" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            NSLog(@"loginSucess: %@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [KZAppManager setUserId:responseObject[@"user_id"]];
               
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


- (void)requestUserInfo:(NSString *)userid {
    
    NSDictionary *pram = @{
                           @"user_id" : userid,
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



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}


- (void)textFieldChange:(NSNotification *)noti {
    
    if (_emailFieldView.textField.text.length > 0 && _passwordFieldView.textField.text.length > 0) {
        _loginBtn.enabled = YES;
        _loginBtn.alpha = 1.0;
    }else {
        _loginBtn.enabled = YES;
        _loginBtn.alpha = 0.6;
    }
    
}

#pragma mark - UITextViewField Delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField == _emailFieldView.textField) {

        [_passwordFieldView.textField becomeFirstResponder];
    } else {
        [self loginBtnClick: _loginBtn];
    }

    return YES;
}

@end
