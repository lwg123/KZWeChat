//
//  ViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/8.
//  Copyright © 2019 duia. All rights reserved.
//

#import "ViewController.h"
#import "KZLoginViewController.h"
#import "KZMatchingHallController.h"
#import "KZChatViewController.h"

@interface ViewController ()

@property (nonatomic,strong) UIButton *loginBtn;
@property (nonatomic,strong) UIImageView *bgImageView;
@property (nonatomic,strong) NSString *picUrl;
@property (nonatomic,strong) NSString *linkUrl;
@property (nonatomic,strong) UIWindow *alertWindow;
@property (nonatomic,strong) NSMutableArray *dataArr;
@property (nonatomic,strong) NSMutableArray *videoArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArr = [NSMutableArray array];
    self.videoArray = [NSMutableArray array];
    
    [self setupUI];
    [self getBanner];
    [self getActivation];
    
    [self getData];
   
}

- (void)getData {
    
    [KZNetworkManager POST:@"page/pair" parameters:@{@"user_id" : @"0"} completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSArray *tempArr = (NSArray *)responseObject;
                for (NSDictionary *dict in tempArr) {
                    KZUser *user = [[KZUser alloc] initWithDict:dict];
                    [self.dataArr addObject:user];
                }
            }
            
        }else {
            NSLog(@"%@",error.domain);
            
        }
        
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置导航栏为透明色
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    
}


- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _bgImageView.userInteractionEnabled = YES;
        _bgImageView.image = [UIImage imageNamed:@"background"];
    }
    return _bgImageView;
}

- (void)setupUI{
    [self.view addSubview:self.bgImageView];
    
    // icon
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 95, 95)];
    iconView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-150);
    iconView.image = [UIImage imageNamed:@"logo"];
    [self.bgImageView addSubview:iconView];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    nameLab.text = @"聊呗";
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.textColor = [UIColor whiteColor];
    nameLab.font = [UIFont systemFontOfSize:20];
    [nameLab sizeToFit];
    nameLab.center = CGPointMake(SCREEN_WIDTH/2, iconView.maxY+15);
    [self.bgImageView addSubview:nameLab];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(40, nameLab.maxY+130, SCREEN_WIDTH-40 * 2, 50);
    [self.bgImageView addSubview:loginBtn];
    _loginBtn = loginBtn;
    //添加渐变色
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, loginBtn.width, loginBtn.height);
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.locations = @[@(0.1),@(0.5),@(0.9)]; //渐变点
    [gradientLayer setColors:@[(id)[RGB(42, 150, 222) CGColor],(id)[RGB(58, 106, 231) CGColor],(id)[RGB(61, 102, 232) CGColor]]]; //渐变数组
    [loginBtn.layer addSublayer:gradientLayer];
    
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBtn.titleLabel.font = [UIFont systemFontOfSize:20.0];
    loginBtn.layer.cornerRadius = 25;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn addTarget:self action:@selector(loginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
   // [loginBtn setTitle:NSLocalizedString(@"Login", @"") forState:UIControlStateNormal];
    
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 70, SCREEN_WIDTH, 20)];
    tipLab.text = @"视频匹配，遇见真爱";
    tipLab.font = [UIFont systemFontOfSize:16];
    tipLab.textColor = UIColorHex(0xD3D3D3);
    tipLab.textAlignment = NSTextAlignmentCenter;
    [self.bgImageView addSubview:tipLab];

}

#pragma mark -- action --
- (void)loginBtnClick {
    DLog(@"点击登录");
    
    // 跳转到注册页面
    KZLoginViewController *registerVC = [[KZLoginViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)getBanner {
    
    [KZNetworkManager POST:@"page/index" parameters:@{} completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSDictionary *bannerDict = responseObject[@"banner"];
                if (bannerDict.count != 0) { // 有数据
                    
                    NSString *link = bannerDict[@"link"];
                    self.linkUrl = link;
                    NSString *picUrl = bannerDict[@"pic"];
                    self.picUrl = picUrl;
                    NSString *channel_id = bannerDict[@"channel_id"];
                    [KZAppManager setChannel_id:channel_id];
                    
                    // 弹出banner图片，点击跳转link地址
                    if (picUrl) {
                        [self popBanner];
                    }
                    
                }
    
            });
        }else {
            NSLog(@"%@",error.domain);
            
        }
        
    }];
}

- (void)popBanner {
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:self.view.bounds];
    window.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    window.windowLevel = UIWindowLevelAlert;
    window.hidden = NO;
    window.userInteractionEnabled = YES;
    _alertWindow = window;
    
    // 添加一个view 720 * 950   414 * 896
    UIImageView *bannerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 414*0.8, 896*0.8)];
    bannerView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    bannerView.backgroundColor = [UIColor clearColor];
    [bannerView sd_setImageWithURL:[NSURL URLWithString:self.picUrl]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bannerViewClick)];
    bannerView.userInteractionEnabled = YES;
    [bannerView addGestureRecognizer:tap];
    [_alertWindow addSubview:bannerView];
}


// 激活量
- (void)getActivation
{
    
    NSDictionary *pram = @{
                           @"device" : [KZUtils getCurrentDeviceModel],
                           @"mac" : [KZAppManager getuuid],
                           @"ip" : [KZUtils getIPAddress]
                           };
    [KZNetworkManager POST:@"api/activation" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        NSLog(@"%@",responseObject);
        
    }];
}

// 跳转
- (void)bannerViewClick {
    
    NSDictionary *pram = @{
                           @"channel_id" : [KZAppManager getChannel_id],
                           @"device" : [KZUtils getCurrentDeviceModel],
                           @"mac" : [KZAppManager getuuid],
                           @"ip" : [KZUtils getIPAddress]
                           };
    
    kWeakSelf(self)
    [KZNetworkManager POST:@"api/views" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSURL *url = [NSURL URLWithString:weakself.linkUrl];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
            
        });
    
    }];
}


@end
