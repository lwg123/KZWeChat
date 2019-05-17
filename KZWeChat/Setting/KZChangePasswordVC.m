//
//  KZChangePasswordVC.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/10.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZChangePasswordVC.h"

@interface KZChangePasswordVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *conformButton;
@property (nonatomic,strong) KZPTextFieldView *currentFieldView;
@property (nonatomic,strong) KZPTextFieldView *firstFieldView;
@property (nonatomic,strong) KZPTextFieldView *secondFieldView;

@end

@implementation KZChangePasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"修改密码";
    self.view.backgroundColor = RGB(241, 242, 243);
    
    self.conformButton.layer.masksToBounds = YES;
    self.conformButton.layer.cornerRadius = self.conformButton.height/2;
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kzNavColor] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)setupUI {
    
    KZPTextFieldView *currentFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(0, NavgationHeight, SCREEN_WIDTH, 50) placeholder:@"请输入当前密码" leftImage:@"密码(1)"];
    currentFieldView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    currentFieldView.textField.delegate = self;
    _currentFieldView = currentFieldView;
    [currentFieldView.textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    currentFieldView.textField.textColor = [UIColor lightGrayColor];
    currentFieldView.lineView.hidden = YES;
    [self.view addSubview:currentFieldView];
    currentFieldView.backgroundColor = [UIColor whiteColor];

    _currentFieldView.textField.secureTextEntry = YES;
    
    KZPTextFieldView *firstFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(0, currentFieldView.maxY+10, SCREEN_WIDTH, 50) placeholder:@"请输入新密码" leftImage:@"密码1"];
    firstFieldView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    firstFieldView.textField.delegate = self;
    _firstFieldView = firstFieldView;
    [firstFieldView.textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    firstFieldView.textField.textColor = [UIColor lightGrayColor];
    [self.view addSubview:firstFieldView];
    firstFieldView.backgroundColor = [UIColor whiteColor];

    _firstFieldView.textField.secureTextEntry = YES;
    
    KZPTextFieldView *secondFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(0, firstFieldView.maxY, SCREEN_WIDTH, 50) placeholder:@"请再次输入新密码" leftImage:@"密码(2)"];
    secondFieldView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    secondFieldView.textField.delegate = self;
    _secondFieldView = secondFieldView;
    [secondFieldView.textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    secondFieldView.textField.textColor = [UIColor lightGrayColor];
    secondFieldView.lineView.hidden = YES;
    [self.view addSubview:secondFieldView];
    secondFieldView.backgroundColor = [UIColor whiteColor];

    _secondFieldView.textField.secureTextEntry = YES;
    
}


- (IBAction)conformBtnClick:(id)sender {
    if (_currentFieldView.textField.text.length == 0) {
        [self.view makeToast:@"请输入原密码"];
        return;
    }
    
    if (_firstFieldView.textField.text.length == 0) {
        [self.view makeToast:@"请输入新密码"];
        return;
    }
    
    if (_secondFieldView.textField.text.length == 0) {
        [self.view makeToast:@"请再次输入新密码"];
        return;
    }
    
    if (_firstFieldView.textField.text != _secondFieldView.textField.text) {
        [self.view makeToast:@"两次输入密码不同"];
        return;
    }
    
    // 确认修改密码
    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           @"oldPassword" : _currentFieldView.textField.text,
                           @"newPassword" : _firstFieldView.textField.text
                           };
    [KZNetworkManager POST:@"user/editPassword" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"修改成功!"];
                [self.navigationController popViewControllerAnimated:YES];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"修改失败!"];
                
            });
        }
    }];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}



@end
