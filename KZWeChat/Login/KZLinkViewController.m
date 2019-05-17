//
//  KZLinkViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/21.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZLinkViewController.h"

@interface KZLinkViewController ()
@property (nonatomic,strong) UIWebView *webView;
@end

@implementation KZLinkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadWeb];
}

- (void)loadWeb {
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, NavgationHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NavgationHeight)];
    
    [self.view addSubview:_webView];
    NSURL *url = [NSURL URLWithString:_urlStr];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}




@end
