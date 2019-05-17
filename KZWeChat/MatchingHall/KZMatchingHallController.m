//
//  KZMatchingHallController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/8.
//  Copyright © 2019 duia. All rights reserved.
//

#define ImageWidth (ImageHeight * 9/16)         //225     // 16：9
#define ImageHeight 500
#define ImageScale 0.1  // 每张图片初始化缩小尺寸
#define ImageSpace 10   // 每张图片底部距离

#import "KZMatchingHallController.h"
#import "KZPersonInfoController.h"
#import "KZSettingViewController.h"
#import "KZMessageController.h"
#import <AVFoundation/AVFoundation.h>
#import "KZCardView.h"

static UIWindow *_alertWindow = nil;

//static NSString *urlStr = @"http://lbimg.ewm.wiki/video/201904/8a7449874dda5479450222b672a5a1ef.mp4";
static NSString *urlStr2 = @"http://ksy.fffffive.com/mda-hinp1ik37b0rt1mj/mda-hinp1ik37b0rt1mj.mp4";
static NSString *coverUrl = @"http://ksy.fffffive.com/mda-hinp1ik37b0rt1mj/mda-hinp1ik37b0rt1mj.jpg";

@interface KZMatchingHallController ()
{
    AVPlayerItem *_playerItem0;
    AVPlayerItem *_playerItem1;
    AVPlayerItem *_playerItem2;
    AVPlayerItem *_playerItem3;
    
//    UIImageView *_imageView0;
//    UIImageView *_imageView1;
//    UIImageView *_imageView2;
//    UIImageView *_imageView3;

    int grouping;   //  数据分组
    int currentCardIndex;   //  卡片计数

    int imageHeight;    //  Card大小
    int imageWidth;

}

@property (nonatomic,strong) AVPlayer *avPlayer0;
@property (nonatomic,strong) AVPlayer *avPlayer1;
@property (nonatomic,strong) AVPlayer *avPlayer2;
@property (nonatomic,strong) AVPlayer *avPlayer3;

// 存储数据源KZUser
@property (strong ,nonatomic) NSMutableArray<KZUser *> *dataArr;
// 存贮卡片view
@property (nonatomic, strong) NSMutableArray<KZCardView *> *cards;
// 存储avPlayer
@property (nonatomic,strong) NSMutableArray<AVPlayer *> *avPlayers;

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *redView;
@property (nonatomic, strong) KZCardView *topCard; //最上面
@property (nonatomic, strong) KZCardView *bottomCard; //最底部
@property (nonatomic, strong) NSMutableArray *randomArray;
@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *nextGroupBtn;

@end

@implementation KZMatchingHallController

#pragma mark - Lazy loading

- (NSMutableArray<KZUser *> *)dataArr{

    if (!_dataArr) {

        _dataArr = [@[] mutableCopy];
    }

    return _dataArr;
}

- (NSMutableArray<KZCardView *> *)cards {

    if (!_cards) {

        _cards = [@[] mutableCopy];
    }

    return _cards;
}

- (NSMutableArray<AVPlayer *> *)avPlayers {

    if (!_avPlayers) {

        _avPlayers = [@[] mutableCopy];
    }

    return _avPlayers;
}

-(NSMutableArray *)randomArray {

    if (!_randomArray) {

        _randomArray = [@[] mutableCopy];
    }

    return _randomArray;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupNavigation];
    
    [self setupFirstLogin];

    if (iPhoneXSMAX) {
        imageHeight = 600;
    } else if (iPhoneXR) {
        imageHeight = 600;
    } else if (iPhoneX) {
        imageHeight = 500;
    } else if (Plus) {
        imageHeight = 500;
    } else if (iPhone6) {
        imageHeight = 440;
    } else if (iPhone5) {
        imageHeight = 330;
    } else if (iPhone4S) {
        imageHeight = 300;
    } else {
        imageHeight = 300;
    }

    imageWidth = (imageHeight * 9/16);

    grouping = 0;
    currentCardIndex = 0;

    self.dataArr = [KZAppManager getVideoArray];

    if (self.dataArr.count == 0) {
        self.dataArr = [NSMutableArray array];
        // 获取视频数据
        [self requestData];
    }else {
        [self createCards];
    }

    NSMutableArray *arry = [KZAppManager getVideoArray];
    NSLog(@"array >>> %@",arry);
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 设置导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kzNavColor] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];

//    switch (currentCardIndex) {
//        case 0:
//            [self.avPlayer0 play];
//            self.avPlayer0.muted = NO;
//            break;
//        case 1:
//            [self.avPlayer1 play];
//            self.avPlayer1.muted = NO;
//            break;
//        case 2:
//            [self.avPlayer2 play];
//            self.avPlayer2.muted = NO;
//            break;
//        case 3:
//            [self.avPlayer3 play];
//            self.avPlayer3.muted = NO;
//            break;
//
//        default:
//            break;
//    }

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;

    for (AVPlayer *player in self.avPlayers) {
        [player pause];
        player.muted = YES;
    }

}

#pragma mark --- 界面UI ------
- (void)setupNavigation {
    
    self.title = @"配对大厅";
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [leftBtn setBackgroundImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(jumpToPersonInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"消息"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(jumToMessage) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    // 设置导航栏字体
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    
    // 设置底部按钮
    UIButton *likeBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, SCREEN_HEIGHT - 90, 60, 60)];
    likeBtn.timeInterval = 1.0;
    [likeBtn setImage:[UIImage imageNamed:@"unlike"] forState:UIControlStateNormal];
    _likeBtn = likeBtn;
    [self.view addSubview:likeBtn];
    [likeBtn addTarget:self action:@selector(likeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-60-60, likeBtn.frame.origin.y, 60, 60)];
    cancelBtn.timeInterval = 1.0;
    [cancelBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
    _cancelBtn = cancelBtn;
    [self.view addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, likeBtn.frame.origin.y + 10, 50, 50)];
    btn.centerX = SCREEN_WIDTH/2;
//    [btn setImage:[UIImage imageNamed:@"qiehuan"] forState:UIControlStateNormal];
//    [btn addTarget:self action:@selector(nextGroupBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"Inform"] forState:UIControlStateNormal];
    [btn addTarget: self action: @selector(submitInform) forControlEvents: UIControlEventTouchUpInside];
    _nextGroupBtn = btn;
    btn.timeInterval = 1.0;
    [self.view addSubview:btn];
    
}

// 获取card数据
- (void)requestData {


    
    [KZNetworkManager POST:@"page/pair" parameters:@{@"user_id" : [KZAppManager getUserId]} completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
          
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSArray *tempArr = (NSArray *)responseObject;
                for (NSDictionary *dict in tempArr) {
                    KZUser *user = [[KZUser alloc] initWithDict:dict];
                    [self.dataArr addObject:user];
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self createCards];
            });
        }else {
            NSLog(@"%@",error.domain);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 暂无数据展示
                [self.view makeToast:error.domain];
            });
        }
        
    }];
    
}

// 点击like和左滑发送配对
- (void)sendPair {
    
    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           @"to_user_id" : self.topCard.user.user_id
                           };
    [KZNetworkManager POST:@"user/pair" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        if (error == nil) {
            
            NSLog(@"配对：%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"配对成功"];
            });
        }else {
            NSLog(@"%@",error.domain);
            dispatch_async(dispatch_get_main_queue(), ^{
              //  [self.view makeToast:error.domain];
            });
        }
    }];
}


#pragma mark --- 创建cards ------
- (void)createCards {
//    // 避免重复，随机从数组中取4个
//    NSMutableSet *randomSet = [[NSMutableSet alloc] init];
//    while ([randomSet count] < 4) {
//        int r = arc4random() % [_dataArr count];
//        [randomSet addObject:[_dataArr objectAtIndex:r]];
//    }
//    NSArray *randomArray = [randomSet allObjects];
//    self.randomArray = randomArray;

    //  生成展示数据，一次4个。取返回数据的第x分组的4个数据。
    for (int i = 0; i < 4; i++) {

        int indexNum = i + 4 * grouping;

        [self.randomArray addObject: self.dataArr[indexNum]];
    }

    for (KZUser *user in _randomArray) {

        DLog( @"v_id: %@", user.video_id);
    }

    for (int i = 0; i < 4; i++) {
        KZUser *user = self.randomArray[i];
        KZCardView *card = [[KZCardView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight) user:user];
        card.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:card.bounds];
        imageView.image = [UIImage imageNamed:@"Wechat11"];
        [card addSubview:imageView];

        card.tag = 100 + i;
        card.layer.masksToBounds = YES;
        card.layer.cornerRadius = 5.0;
        
        int index = i;
        if (index == 3) {
            index = 2;
        }
        // y坐标 = 屏幕中心点+中心点下移的距离+每个图片距离第一张图片的间距
        // 图片高度*缩放比例 = 图片减小的总大小。除以2是中心下移的距离，就可以和第一张图片底部对齐
        card.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT)/2 +(imageHeight*ImageScale*index/2)+ ImageSpace*index);
        card.transform = CGAffineTransformMakeScale(1-ImageScale*index, 1-ImageScale*index);

        [self.cards addObject:card];
        
        [self.view addSubview:card];
        [self.view sendSubviewToBack:card];
        
        //添加拖动手势
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandle:)];
        [card addGestureRecognizer:pan];
        
        card.userInteractionEnabled = NO;
        if (i == 0) {
            card.userInteractionEnabled = YES;
            self.topCard = card;
        }else if (i == 3){
            self.bottomCard = card;
        }
        
    }
    
    //配置视频相关
    [self setupPlayer];
    
}



#pragma mark --- 配置视频相关 ---
- (void)setupPlayer {
   
    // 本地视频播放
    for (int i = 0; i < self.cards.count; i++) {
        if (i == 0) {

            [self createPlayer0];
//            //  最上面的卡片开始播放
            [self.avPlayer0 play];
            self.avPlayer0.muted = NO;
        }else if (i == 1){
            [self createPlayer1];
            [self.avPlayer1 pause];
            self.avPlayer1.muted = YES;
        }else if (i == 2){
            [self createPlayer2];
            [self.avPlayer2 pause];
            self.avPlayer2.muted = YES;
        }else if (i == 3){
           [self createPlayer3];
            [self.avPlayer3 pause];
            self.avPlayer3.muted = YES;
        }
        
    }

}

- (void)setupAgeandSex:(int)i
{
    KZUser *user = self.randomArray[i];
    UIView *card = self.cards[i];
    // 添加用户昵称
    UILabel *nickName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
    nickName.text = user.nickname;
    nickName.textColor = [UIColor whiteColor];
    [nickName sizeToFit];
    [card addSubview:nickName];
    
    // 年龄
    UILabel *ageLab = [[UILabel alloc] initWithFrame:CGRectMake(10, nickName.maxY+10, 50, 16)];
    ageLab.text = [NSString stringWithFormat:@"%@岁",user.age];
    ageLab.backgroundColor = RGB(243, 86, 164);
    ageLab.textColor = [UIColor whiteColor];
    ageLab.font = [UIFont systemFontOfSize:14.0];
    ageLab.textAlignment = NSTextAlignmentCenter;
    //[ageLab sizeToFit];
    ageLab.layer.masksToBounds = YES;
    ageLab.layer.cornerRadius = ageLab.height/2;
    [card addSubview:ageLab];
    
    // 性别
    UILabel *sexLab = [[UILabel alloc] initWithFrame:CGRectMake(ageLab.maxX+10, ageLab.y, 30, 16)];
    sexLab.text = user.sex;
    sexLab.centerY = ageLab.centerY;
    sexLab.backgroundColor = RGB(47, 193, 237);
    sexLab.textColor = [UIColor whiteColor];
    sexLab.font = [UIFont systemFontOfSize:14.0];
    sexLab.textAlignment = NSTextAlignmentCenter;
    sexLab.layer.masksToBounds = YES;
    sexLab.layer.cornerRadius = sexLab.height/2;
    [card addSubview:sexLab];
}

- (void)createPlayer0 {
    
    KZUser *user = self.randomArray[0];
    KZCardView *card = self.cards[0];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:card.bounds];
//    imageView.backgroundColor = [UIColor clearColor]; // user.videoImage
//    [imageView sd_setImageWithURL:[NSURL URLWithString:user.videoImage]];
//    //imageView.image = [UIImage imageNamed:@"Wechat11"];
//    [card addSubview:imageView];
//    _imageView0 = imageView;

    NSURL *url = [NSURL URLWithString:user.video];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    _avPlayer0 = [[AVPlayer alloc] initWithPlayerItem:item];
    _avPlayer0.muted = NO;
    [_avPlayer0 play];
    _playerItem0 = item;
    
    // 监听状态
    [_playerItem0 addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲进度
//    [_playerItem0 addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    // 设置播放页面
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer0];
    playLayer.frame = card.bounds;
    playLayer.backgroundColor = [UIColor clearColor].CGColor;
    playLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加播放视图到card
    [card.layer addSublayer:playLayer];
    [_avPlayer0 addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.avPlayers addObject:_avPlayer0];
    //   增加下面这行可以解决iOS10兼容性问题了
    if (@available(iOS 10.0, *)) {
        _avPlayer0.automaticallyWaitsToMinimizeStalling = NO;
        [_avPlayer0 playImmediatelyAtRate:1.0];
    } else {
        // Fallback on earlier versions
    }
    
    [self setupAgeandSex:0];
    
}


- (void)playEnd0 {
    __weak typeof(self) weakSelf = self;
    [_avPlayer0 seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.avPlayer0 play];
    }];
}


- (void)createPlayer1 {
    
    KZUser *user = self.randomArray[1];
    UIView *card = self.cards[1];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:card.bounds];
//    imageView.backgroundColor = [UIColor clearColor];
//    [imageView sd_setImageWithURL:[NSURL URLWithString:user.videoImage]];
//    //imageView.image = [UIImage imageNamed:@"Wechat11"];
//    [card addSubview:imageView];
//    _imageView1 = imageView;

    NSURL *url = [NSURL URLWithString:user.video];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    _avPlayer1 = [[AVPlayer alloc] initWithPlayerItem:item];

    _playerItem1 = item;
    [_avPlayer1 pause];
    
    // 监听状态
    [_playerItem1 addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲进度
//    [_playerItem1 addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    
    // 设置播放页面
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer1];
    playLayer.frame = card.bounds;
    playLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playLayer.backgroundColor = [UIColor clearColor].CGColor;
    // 添加播放视图到card
    [card.layer addSublayer:playLayer];
    
    [_avPlayer1 addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    [self.avPlayers addObject:_avPlayer1];
    
    //   增加下面这行可以解决iOS10兼容性问题了
    if (@available(iOS 10.0, *)) {
        _avPlayer1.automaticallyWaitsToMinimizeStalling = NO;
        [_avPlayer1 playImmediatelyAtRate:1.0];
    } else {
        // Fallback on earlier versions
    }


    [self setupAgeandSex:1];
}


- (void)playEnd1 {
    __weak typeof(self) weakSelf = self;
    [_avPlayer1 seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.avPlayer1 play];
    }];
}

- (void)createPlayer2 {
    
    KZUser *user = self.randomArray[2];
    UIView *card = self.cards[2];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:card.bounds];
//    imageView.backgroundColor = [UIColor clearColor];
//    [imageView sd_setImageWithURL:[NSURL URLWithString:user.videoImage]];
//    //imageView.image = [UIImage imageNamed:@"Wechat11"];
//    [card addSubview:imageView];
//    _imageView2 = imageView;

    NSURL *url = [NSURL URLWithString:user.video];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    _avPlayer2 = [[AVPlayer alloc] initWithPlayerItem:item];

    _playerItem2 = item;
    [_avPlayer2 pause];
    
    // 监听状态
    [_playerItem2 addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲进度
//    [_playerItem2 addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    
    // 设置播放页面
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer2];
    playLayer.frame = card.bounds;
    playLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playLayer.backgroundColor = [UIColor clearColor].CGColor;
    // 添加播放视图到card
    [card.layer addSublayer:playLayer];
    [_avPlayer2 addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.avPlayers addObject:_avPlayer2];
    
    //   增加下面这行可以解决iOS10兼容性问题了
    if (@available(iOS 10.0, *)) {
        _avPlayer2.automaticallyWaitsToMinimizeStalling = NO;
        [_avPlayer2 playImmediatelyAtRate:1.0];
    } else {
        // Fallback on earlier versions
    }
    [self setupAgeandSex:2];
}


- (void)playEnd2 {
    __weak typeof(self) weakSelf = self;
    [_avPlayer2 seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.avPlayer2 play];
    }];
}

- (void)createPlayer3 {
    
    KZUser *user = self.randomArray[3];
    UIView *card = self.cards[3];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:card.bounds];
//    imageView.backgroundColor = [UIColor clearColor];
//    [imageView sd_setImageWithURL:[NSURL URLWithString:user.videoImage]];
//    //imageView.image = [UIImage imageNamed:@"Wechat11"];
//    [card addSubview:imageView];
//    _imageView3 = imageView;

    NSURL *url = [NSURL URLWithString:user.video];
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    _avPlayer3 = [[AVPlayer alloc] initWithPlayerItem:item];

    _playerItem3 = item;

    [_avPlayer3 pause];
    
    // 监听状态
    [_playerItem3 addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 监听缓冲进度
//    [_playerItem3 addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    // 设置播放页面
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer3];
    playLayer.frame = card.bounds;
    playLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    playLayer.backgroundColor = [UIColor clearColor].CGColor;
    // 添加播放视图到card
    [card.layer addSublayer:playLayer];
    [_avPlayer3 addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.avPlayers addObject:_avPlayer3];
    
    //   增加下面这行可以解决iOS10兼容性问题了
    if (@available(iOS 10.0, *)) {
        _avPlayer3.automaticallyWaitsToMinimizeStalling = NO;
        [_avPlayer3 playImmediatelyAtRate:1.0];
    } else {
        // Fallback on earlier versions
    }
    
    
    [self setupAgeandSex:3];
}


- (void)playEnd3 {
    __weak typeof(self) weakSelf = self;
    [_avPlayer3 seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.avPlayer3 play];
    }];
}



#pragma mark -- 是否是首次登陆 -----
- (void)setupFirstLogin {
    
    KZUser *user = [KZAppManager loadUserInfo];
    if ([user.is_auth integerValue] != 1) { //未设置资料 弹出提醒
    
        UIWindow *window = [[UIWindow alloc] initWithFrame:self.view.bounds];
        window.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        window.windowLevel = UIWindowLevelAlert;
        window.hidden = NO;
        _alertWindow = window;
    
        UIImageView *backView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 445)];
        backView.image = [UIImage imageNamed:@"弹窗"];
        backView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        backView.userInteractionEnabled = YES;
        backView.backgroundColor = [UIColor clearColor];
        [window addSubview:backView];
       
        UIButton *titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        titleBtn.frame = CGRectMake(23, backView.height - 70, backView.width - 46, 50);
        [titleBtn setTitle:@"完善资料" forState:UIControlStateNormal];
        [titleBtn setBackgroundImage:[UIImage imageWithColor:RGB(42, 155, 220)] forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(editPerson) forControlEvents:UIControlEventTouchUpInside];
        titleBtn.layer.masksToBounds = YES;
        titleBtn.layer.cornerRadius = 4.0;
        [backView addSubview:titleBtn];
        
        // 添加一个右上角button点击隐藏banner
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame = CGRectMake(backView.maxX-100, 0, 50, 50);
        cancelBtn.backgroundColor = [UIColor clearColor];
        [cancelBtn addTarget:self action:@selector(cancelBanner) forControlEvents:UIControlEventTouchUpInside];
        [backView addSubview:cancelBtn];
        
    }
}


#pragma mark -- 跳转下一页 --------
- (void)jumpToPersonInfo {
    // 跳转设置页面
    KZSettingViewController *settingVC = [[KZSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)jumToMessage {
    KZMessageController *meaageVC = [[KZMessageController alloc] init];
    [self.navigationController pushViewController:meaageVC animated:YES];
}

- (void)editPerson {
    
    [self cancelBanner];
    KZPersonInfoController *personVC = [[KZPersonInfoController alloc] init];
    [self.navigationController pushViewController:personVC animated:YES];
}

- (void)cancelBanner {
    _alertWindow.hidden = YES;
}

#pragma mark ------ 配对大厅各种设置 -----------
//不喜欢，右侧滑出
- (void)cancelBtnClick:(UIButton *)sender {
    
    sender.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.1 animations:^{
        
        self.topCard.center = CGPointMake(SCREEN_WIDTH/2 + 5, SCREEN_HEIGHT/2);
        
    } completion:^(BOOL finished) {


        [UIView animateWithDuration:0.5 animations:^{
            
            self.topCard.center = CGPointMake(ImageWidth+SCREEN_WIDTH, SCREEN_HEIGHT/2);
            self.topCard.transform = CGAffineTransformMakeRotation(M_PI_4/2);
            
            for (UIView *card in self.cards) {
                
                if (card.tag != 100 && card.tag != 103) {
                    
                    NSInteger index = card.tag - 100;
                    
                    card.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2
                                              + imageHeight*index*ImageScale/2
                                              + ImageSpace*index //原始位置
                                              - ImageSpace
                                              - (imageHeight*ImageScale*index/2)/index);
                    
                    CGFloat scale = 1-index*ImageScale + ImageScale;
                    card.transform = CGAffineTransformMakeScale(scale, scale);
                }
            }
            
        }completion:^(BOOL finished) {
            
            sender.userInteractionEnabled = YES;
            [self cardRemove];
        }];
    }];
    
    [self sendPair];
}

//喜欢
- (void)likeBtnClick:(UIButton *)sender {
    
    sender.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.1 animations:^{
        
        self.topCard.center = CGPointMake(SCREEN_WIDTH/2 + 5, SCREEN_HEIGHT/2);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.topCard.center = CGPointMake(-ImageWidth, SCREEN_HEIGHT/2);
            self.topCard.transform = CGAffineTransformMakeRotation(-M_PI_4/2);
            
            for (UIView *card in self.cards) {
                
                if (card.tag != 100 && card.tag != 103) {
                    
                    NSInteger index = card.tag - 100;
                    
                    card.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2
                                              + imageHeight*index*ImageScale/2
                                              + ImageSpace*index //原始位置
                                              - ImageSpace
                                              - (imageHeight*ImageScale*index/2)/index);
                    
                    CGFloat scale = 1-index*ImageScale + ImageScale;
                    card.transform = CGAffineTransformMakeScale(scale, scale);
                }
            }
            
        }completion:^(BOOL finished) {
            
            sender.userInteractionEnabled = YES;
            [self cardRemove];
        }];
    }];
    
}


-(void)panHandle:(UIPanGestureRecognizer *)pan{
    
    UIView *cardView = pan.view;
    
    if (pan.state == UIGestureRecognizerStateBegan) { //开始拖动
        
    }else if (pan.state == UIGestureRecognizerStateChanged) { //正在拖动
        
        CGPoint transLcation = [pan translationInView:cardView];
        cardView.center = CGPointMake(cardView.center.x + transLcation.x, cardView.center.y + transLcation.y);
        CGFloat XOffPercent = (cardView.center.x-SCREEN_WIDTH/2.0)/(SCREEN_WIDTH/2.0);
        CGFloat rotation = M_PI_2/4*XOffPercent;
        cardView.transform = CGAffineTransformMakeRotation(rotation);
        [pan setTranslation:CGPointZero inView:cardView];
        
        [self animationBlowViewWithXOffPercent:fabs(XOffPercent)];
        
        
    }else if (pan.state == UIGestureRecognizerStateEnded) { //松手了，拖动结束
        
        //视图不移除，原路返回
        if (cardView.center.x > 60 && cardView.center.x < SCREEN_WIDTH - 60) {
            [UIView animateWithDuration:0.25 animations:^{
                cardView.center = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
                cardView.transform = CGAffineTransformMakeRotation(0);
                [self animationBlowViewWithXOffPercent:0];
            }];
        }else{
            
            //视图在屏幕左侧移除
            if (cardView.center.x < 60) {
                [UIView animateWithDuration:0.25 animations:^{
                    cardView.center = CGPointMake(-200, cardView.center.y);
                    
                }];
                
            } else{//视图在屏幕右侧移除
                [UIView animateWithDuration:0.25 animations:^{
                    cardView.center = CGPointMake(SCREEN_WIDTH+200, cardView.center.y);
                    // 左侧移除发送配对
                    [self sendPair];
                }];
            }
            
            [self animationBlowViewWithXOffPercent:1];
            [self performSelector:@selector(cardRemove) withObject:cardView afterDelay:0.25];
        }
    }
    
}

- (void)animationBlowViewWithXOffPercent:(CGFloat)XOffPercent {
    
    for (UIView *card in self.cards) {
        
        if (card != self.topCard && card.tag != 103) {
            
            NSInteger index = card.tag-100;
            
            card.center = CGPointMake(SCREEN_WIDTH/2,SCREEN_HEIGHT/2
                                      + (imageHeight*ImageScale*index/2)
                                      + ImageSpace*index  //上面3行是原始位置，下面2行是改变的大小
                                      - XOffPercent*ImageSpace
                                      - (imageHeight*ImageScale*index/2)*XOffPercent/index);
            
            CGFloat scale = 1-ImageScale*index + XOffPercent*ImageScale;
            card.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }
    
}


-(void)cardRemove{

    //  被划出的卡片停止播放
    AVPlayer *p = self.avPlayers[currentCardIndex];
    p.muted = YES;
    [p pause];

    // 滑动结束第一张和放到数组最后
    [self.cards removeObject:self.topCard];
    [self.cards addObject:self.topCard];

    //  第4张卡片，也就是需求中需要换组时，立即切换分组数据并重新生成卡片
    if (currentCardIndex == 3) {

        //  最后一张划走，需要加载加一组数据
        [self nextGroupBtnClick];
        return;
    }
    
    //    重新设置tag
    for (int i = 0 ; i < 4; i++) {
        UIView *card = self.cards[i];
        card.tag = 100+i;
    }
    
    
    // 重置第一张和最后一张（第4）
    self.topCard.userInteractionEnabled = NO;
    self.topCard.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2 + (imageHeight*ImageScale*2/2) + ImageSpace*2);
    self.topCard.transform = CGAffineTransformMakeScale(1-ImageScale*2, 1-ImageScale*2);
    [self.view sendSubviewToBack:self.topCard];
    
    self.bottomCard = self.topCard;
    
    KZCardView *currentCard = self.cards.firstObject;
    currentCard.userInteractionEnabled = YES;
    self.topCard = currentCard;

    currentCardIndex++;
    //  当前第一张卡片播放
    p = self.avPlayers[currentCardIndex];

    p.muted = NO;
    [p play];
}


// 切换下一组
- (void)nextGroupBtnClick {

    //  刷新，分组指示增加
    grouping++;

    [self refreshData];
}


// 获取新的card数据
- (void)refreshData {

    self.topCard = nil;
    self.bottomCard = nil;

    //  卡片数量计数清零
    currentCardIndex = 0;

    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[KZCardView class]]) {
            [subView removeFromSuperview];
        }
    }

    [self removeObserver];
    [self.avPlayers removeAllObjects];
    [self.cards removeAllObjects];
    [self.randomArray removeAllObjects];





//    //  清除card上所有子项
//    for (KZCardView *card in self.cards) {
//
//        [card removeAllSubviews];
//        [card removeFromSuperview];
//
//    }



    if (grouping > self.dataArr.count / 4 - 1) {
        //  数组分组已到最后一组，需要重新请求
        [self requestData];
        //  分组归零
        grouping = 0;

        return;
    }


    [self createCards];

    
}

#pragma mark ---- 视频监听方法 -------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {

    if ([object isKindOfClass: [AVPlayerItem class]]) {
        AVPlayerItem *playerItem = object;

        if (playerItem == _playerItem0) {

            DLog(@"\n\n>>>>>> %@ <<<<<<\n\n", keyPath);

            if ([keyPath isEqualToString:@"status"]) {
                AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
                if (status == AVPlayerStatusReadyToPlay) {
//                    NSLog(@"AVPlayer11111准备好了----");
//                    if (currentCardIndex == 0 && isShow) {
//                        [self.avPlayer0 play];
//                    }

                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd0) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

                }
            }

            if ([keyPath isEqualToString:@"timeControlStatus"]) {
//                if (_avPlayer0.rate == 1){
//                    _imageView0.hidden = YES;
//                }

                if (@available(iOS 10.0, *)) {
                    AVPlayerTimeControlStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
                    if (status == AVPlayerTimeControlStatusPlaying) {
                        // do something
//                        _imageView0.hidden = YES;
//                        NSLog(@"timeControlStatus0000");
                    }
                } else {
                    // ios10.0之后才能够监听到暂停后继续播放的状态，ios10.0之前监测不到这个状态
                    //但是可以监听到开始播放的状态 AVPlayerStatus  status监听这个属性。



                }

            }

            if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度

                NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
                CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
                float startSeconds = CMTimeGetSeconds(timeRange.start);
                float durationSeconds = CMTimeGetSeconds(timeRange.duration);
                NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
                CMTime duration = playerItem.duration;
                CGFloat totalDuration = CMTimeGetSeconds(duration);

                NSLog(@"player0:下载进度：%.2f", timeInterval / totalDuration);

            } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态

                NSLog(@"player0:缓冲不足暂停了");


            } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {

                NSLog(@"player0:缓冲达到可播放程度了");

            }

        }else if (playerItem == _playerItem1) {

            if ([keyPath isEqualToString:@"status"]) {
                AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
                if (status == AVPlayerStatusReadyToPlay) {
                    NSLog(@"AVPlayer22222准备好了----");

//                    if (currentCardIndex == 1) {
//                        [self.avPlayer1 play];
//                    }

                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd1) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

                }

            }

            if ([keyPath isEqualToString:@"timeControlStatus"]) {
//                if (_avPlayer1.rate == 1){
//                    _imageView1.hidden = YES;
//                }
                if (@available(iOS 10.0, *)) {
                    AVPlayerTimeControlStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
                    if (status == AVPlayerTimeControlStatusPlaying) {
                        // do something
                        // _imageView1.hidden = YES;
//                        NSLog(@"timeControlStatus1111");
                    }
                } else {

                    // ios10.0之后才能够监听到暂停后继续播放的状态，ios10.0之前监测不到这个状态
                    //但是可以监听到开始播放的状态 AVPlayerStatus  status监听这个属性。


                }

            }

            if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度

                NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
                CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
                float startSeconds = CMTimeGetSeconds(timeRange.start);
                float durationSeconds = CMTimeGetSeconds(timeRange.duration);
                NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
                CMTime duration = playerItem.duration;
                CGFloat totalDuration = CMTimeGetSeconds(duration);

                NSLog(@"player1:下载进度：%.2f", timeInterval / totalDuration);

            } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态

                NSLog(@"player1:缓冲不足暂停了");


            } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {

                NSLog(@"player1:缓冲达到可播放程度了");

            }


        }else if (playerItem == _playerItem2) {

            if ([keyPath isEqualToString:@"status"]) {
                AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
                if (status == AVPlayerStatusReadyToPlay) {
                    NSLog(@"AVPlayer33333准备好了----");

//                    if (currentCardIndex == 2) {
//                        [self.avPlayer2 play];
//                    }

                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd2) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

                }
            }

            if ([keyPath isEqualToString:@"timeControlStatus"]) {

//                if (_avPlayer2.rate == 1){
//                    _imageView2.hidden = YES;
//                }

                if (@available(iOS 10.0, *)) {
                    AVPlayerTimeControlStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
                    if (status == AVPlayerTimeControlStatusPlaying) {
                        // do something
                        // _imageView2.hidden = YES;
//                        NSLog(@"timeControlStatus2222");
                    }
                } else {

                    // ios10.0之后才能够监听到暂停后继续播放的状态，ios10.0之前监测不到这个状态
                    //但是可以监听到开始播放的状态 AVPlayerStatus  status监听这个属性。

                }

            }

            if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度

                NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
                CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
                float startSeconds = CMTimeGetSeconds(timeRange.start);
                float durationSeconds = CMTimeGetSeconds(timeRange.duration);
                NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
                CMTime duration = playerItem.duration;
                CGFloat totalDuration = CMTimeGetSeconds(duration);

                NSLog(@"player2:下载进度：%.2f", timeInterval / totalDuration);

            } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态

                NSLog(@"player2:缓冲不足暂停了");


            } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {

                NSLog(@"player2:缓冲达到可播放程度了");

            }

        }else {

            if ([keyPath isEqualToString:@"status"]) {
                AVPlayerStatus status = [[change objectForKey:@"new"] integerValue];
                if (status == AVPlayerStatusReadyToPlay) {
                    NSLog(@"AVPlayer44444准备好了----");

//                    if (currentCardIndex == 3) {
//                        [self.avPlayer3 play];
//                    }

                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd3) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

                }
            }

            if ([keyPath isEqualToString:@"timeControlStatus"]) {

//                if (_avPlayer3.rate == 1){
//                    _imageView3.hidden = YES;
//                }

                if (@available(iOS 10.0, *)) {
                    AVPlayerTimeControlStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
                    if (status == AVPlayerTimeControlStatusPlaying) {
                        // do something
                        // _imageView3.hidden = YES;
                        NSLog(@"timeControlStatus3333");
                    }
                } else {

                    // ios10.0之后才能够监听到暂停后继续播放的状态，ios10.0之前监测不到这个状态
                    //但是可以监听到开始播放的状态 AVPlayerStatus  status监听这个属性。

                }

            }

            if ([keyPath isEqualToString:@"loadedTimeRanges"]) {  //监听播放器的下载进度

                NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
                CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
                float startSeconds = CMTimeGetSeconds(timeRange.start);
                float durationSeconds = CMTimeGetSeconds(timeRange.duration);
                NSTimeInterval timeInterval = startSeconds + durationSeconds;// 计算缓冲总进度
                CMTime duration = playerItem.duration;
                CGFloat totalDuration = CMTimeGetSeconds(duration);

                NSLog(@"player3:下载进度：%.2f", timeInterval / totalDuration);

            } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) { //监听播放器在缓冲数据的状态

                NSLog(@"player3:缓冲不足暂停了");


            } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {

                NSLog(@"player3:缓冲达到可播放程度了");

            }


        }
    }

}

- (void)dealloc {
    [self removeObserver];
}

- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_playerItem0 removeObserver:self forKeyPath:@"status"];
    [_playerItem1 removeObserver:self forKeyPath:@"status"];
    [_playerItem2 removeObserver:self forKeyPath:@"status"];
    [_playerItem3 removeObserver:self forKeyPath:@"status"];
    
    [_avPlayer0 removeObserver:self forKeyPath:@"timeControlStatus"];
    [_avPlayer1 removeObserver:self forKeyPath:@"timeControlStatus"];
    [_avPlayer2 removeObserver:self forKeyPath:@"timeControlStatus"];
    [_avPlayer3 removeObserver:self forKeyPath:@"timeControlStatus"];

//    [_playerItem0 removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [_playerItem1 removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [_playerItem2 removeObserver:self forKeyPath:@"loadedTimeRanges"];
//    [_playerItem3 removeObserver:self forKeyPath:@"loadedTimeRanges"];


}


- (UIImage *)getblurryImage:(NSString *)imageUrl
{
    //加载图片 创建imageView
    
    UIImage *image = [UIImage imageNamed:@"bg.jpg"];
    
    //转换图片
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIImage *midImage = [CIImage imageWithData:UIImagePNGRepresentation(image)];
    //图片开始处理
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:midImage forKey:kCIInputImageKey];
    //value 改变模糊效果值
    [filter setValue:@7.0f forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    CGImageRef outimage = [context createCGImage:result fromRect:[result extent]];
    //转换成UIimage
    UIImage *resultImage = [UIImage imageWithCGImage:outimage];
    return resultImage;
}


- (BOOL)isPlaying:(AVPlayer *)player
{
    
    if (@available(iOS 10.0, *)) {
        return player.timeControlStatus == AVPlayerTimeControlStatusPlaying;
    } else {
        // Fallback on earlier versions
        return player.rate==1;
    }
    
}

/**
    举报视频
 */
- (void) submitInform {

    int index = currentCardIndex;

    kWeakSelf(self)


    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: @"举报视频" message: @"是否举报该视频？\n举报后，该视频将会从您的视频列表中删除。" preferredStyle: UIAlertControllerStyleAlert];

    UIAlertAction *comfrim = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [UIView animateWithDuration:0.1 animations:^{

            self.topCard.center = CGPointMake(SCREEN_WIDTH/2 + 5, SCREEN_HEIGHT/2);

        } completion:^(BOOL finished) {


            [UIView animateWithDuration:0.5 animations:^{

                self.topCard.center = CGPointMake(-ImageWidth, SCREEN_HEIGHT/2);
                self.topCard.transform = CGAffineTransformMakeRotation(-M_PI_4/2);

                for (UIView *card in self.cards) {

                    if (card.tag != 100 && card.tag != 103) {

                        NSInteger index = card.tag - 100;

                        card.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2
                                                  + imageHeight*index*ImageScale/2
                                                  + ImageSpace*index //原始位置
                                                  - ImageSpace
                                                  - (imageHeight*ImageScale*index/2)/index);

                        CGFloat scale = 1-index*ImageScale + ImageScale;
                        card.transform = CGAffineTransformMakeScale(scale, scale);
                    }
                }

            }completion:^(BOOL finished) {

                [self.view makeToast: @"举报成功" duration: 1.0 position: [NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-50)] title: @"" image: nil style: nil completion:^(BOOL didTap) {

                    [self cardRemove];
                }];

                KZUser *user= weakself.randomArray[index];

                NSDictionary *pram = @{
                                       @"user_id" : [KZAppManager getUserId],
                                       @"complaint" : @"举报视频",
                                       @"video_id": user.video_id,
                                       @"uuid": [KZAppManager getuuid],
                                       };

                [KZNetworkManager POST:@"api/complaint" parameters:pram completeHandler:^(id responseObject, NSError *error) {
                    if (error == nil) {

//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [self.view makeToast:@"举报成功！" duration:1.0 position:[NSValue valueWithCGPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-50)] title:@"" image:nil style:nil completion:^(BOOL didTap) {
//
//                                self.topCard = nil;
//                                self.bottomCard = nil;
//
//                                self->currentCardIndex = 0;
//                                self->grouping = 0;
//
//                                //  卡片数量计数清零
//                                for (UIView *subView in self.view.subviews) {
//                                    if ([subView isKindOfClass:[KZCardView class]]) {
//                                        [subView removeFromSuperview];
//                                    }
//                                }
//
//                                [self removeObserver];
//                                [self.avPlayers removeAllObjects];
//                                [self.cards removeAllObjects];
//                                [self.randomArray removeAllObjects];
//
//                                //  举报后重新加载视频列表
//                                [self requestData];
//                            }];
//
//                        });
                    }else {
                        [self.view makeToast:error.domain];
                    }
                }];

            }];
        }];



    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler: nil];

    [alertVC addAction: comfrim];
    [alertVC addAction: cancel];

    [self presentViewController: alertVC animated: YES completion: nil];

}


@end
