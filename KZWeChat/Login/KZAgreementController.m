//
//  KZAgreementController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/20.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZAgreementController.h"

@interface KZAgreementController ()<UIWebViewDelegate>

@property (nonatomic,strong) UIWebView *webView;

@end

@implementation KZAgreementController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"用户协议";
    [self loadWeb];
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


- (void)loadWeb {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NavgationHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NavgationHeight)];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    NSURL *url = [NSURL URLWithString:@"http://liaobei.ewm.wiki/page/agreement/"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

@end
