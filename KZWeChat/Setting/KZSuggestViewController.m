//
//  KZSuggestViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/10.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZSuggestViewController.h"

@interface KZSuggestViewController ()
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UITextView *suggestTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConst;

@end

@implementation KZSuggestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"投诉建议";
    self.view.backgroundColor = RGB(241, 242, 243);
    self.topConst.constant = NavgationHeight+10;
    
    self.suggestTextView.layer.borderWidth = 0.5;
    self.suggestTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kzNavColor] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

- (IBAction)submitBtnClick:(id)sender {
    if (self.suggestTextView.text.length == 0) {
        [self.view makeToast:@"请输入内容"];
        return;
    }
    if (_suggestTextView.text.length > 200) {
        [self.view makeToast:@"请输入内容长度200字以内"];
        return;
    }
    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           @"complaint" : self.suggestTextView.text
                           };
    
    [KZNetworkManager POST:@"api/complaint" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        if (error == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"提交成功" duration:1.0 position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-50)] title:@"" image:nil style:nil completion:^(BOOL didTap) {
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                
            });
        }else {
            [self.view makeToast:error.domain];
        }
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
