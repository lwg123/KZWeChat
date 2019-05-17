//
//  KZRecordVideoController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/9.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZRecordVideoController.h"
#import "WCLRecordEngine.h"
#import "WCLRecordProgressView.h"
#import <AVKit/AVKit.h>
#import "KZRecordBtn.h"

typedef NS_ENUM(NSUInteger, UploadVieoStyle) {
    VideoRecord = 0,
    VideoLocation,
};

@interface KZRecordVideoController ()<WCLRecordEngineDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>
{
    UILongPressGestureRecognizer *_longPress;
    UIView *_progressLine;
    NSTimeInterval _surplusTime;
    NSTimer *_timer;
}

@property (weak, nonatomic) IBOutlet UIButton *changeCameraBT;
@property (weak, nonatomic) IBOutlet UIButton *recordBt;
@property (weak, nonatomic) IBOutlet WCLRecordProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *reRecordBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *closeBtnTopCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraBtnCon;


@property (strong, nonatomic) WCLRecordEngine *recordEngine;
@property (assign, nonatomic) BOOL  allowRecord;//允许录制
@property (assign, nonatomic) UploadVieoStyle videoStyle;//视频的类型

@property (nonatomic,strong) AVPlayer *avPlayer;

@property (nonatomic,strong) KZRecordBtn *recordBtn;
@property (nonatomic,strong) NSString *recordPath;
@property (nonatomic,strong) AVPlayerLayer *playLayer;

@end

@implementation KZRecordVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.allowRecord = YES;
    self.recordBt.hidden = YES;
    self.reRecordBtn.hidden = YES;
    self.saveBtn.hidden = YES;
    
    self.progressView.progressBgColor = [UIColor whiteColor];
    self.progressView.progressColor = RGB(46, 132, 207);
    
    self.closeBtnTopCon.constant = kStatusBarHeight;
    self.cameraBtnCon.constant = kStatusBarHeight;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recordEngine shutdown];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupRecordBtn];
    [self openVideo];
}

- (void)openVideo {
    
    [self.recordEngine previewLayer].frame = self.view.bounds;
    self.recordEngine.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:[self.recordEngine previewLayer] atIndex:0];
    
    [self.recordEngine startUp];
}


- (void)setupRecordBtn {
    
    _recordBtn = [[KZRecordBtn alloc] initWithFrame:self.recordBt.frame];
    [self.view addSubview:_recordBtn];
    
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressAction:)];
    _longPress.minimumPressDuration = 0.1;
    _longPress.delegate = self;
    [self.recordBtn addGestureRecognizer:_longPress];
    
}

- (void)longpressAction:(UILongPressGestureRecognizer *)gesture {
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (self.allowRecord) {
                self.videoStyle = VideoRecord;
                [self.recordEngine startCapture];
                
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            NSLog(@"StateChanged");
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"录制结束");
            [self finishRecordViedo];

        }
            break;
            
        default:
            break;
    }
    
}

- (void)finishRecordViedo {
    // 出现确认和取消按钮
    self.reRecordBtn.hidden = NO;
    self.saveBtn.hidden = NO;
    self.recordBtn.hidden = YES;
    
    [self.recordEngine stopCaptureHandler:^{
        // 同时开始播放视频
        [self setupPlayer:self.recordEngine.videoPath];
        
    }];
}


#pragma mark - set、get方法
- (WCLRecordEngine *)recordEngine {
    if (_recordEngine == nil) {
        _recordEngine = [[WCLRecordEngine alloc] init];
        _recordEngine.delegate = self;
    }
    return _recordEngine;
}


#pragma mark - WCLRecordEngineDelegate
- (void)recordProgress:(CGFloat)progress {
    if (progress >= 1) {
//        [self recordAction:self.recordBt];
//        self.allowRecord = NO;
        // 自动停止录制视频
        [self finishRecordViedo];
    }
    self.progressView.progress = progress;
}


#pragma mark - 各种点击事件
//返回点击事件
- (IBAction)dismissAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//切换前后摄像头
- (IBAction)changeCameraAction:(id)sender {
    self.changeCameraBT.selected = !self.changeCameraBT.selected;
    if (self.changeCameraBT.selected == YES) {
        
        [self.recordEngine changeCameraInputDeviceisFront:NO];
    }else {
        [self.recordEngine changeCameraInputDeviceisFront:YES];
    }
}


// 重新拍视频
- (IBAction)reRecordVideo:(id)sender {
    self.reRecordBtn.hidden = YES;
    self.saveBtn.hidden = YES;
    self.recordBtn.hidden = NO;
    // 删除原视频
    [self deleteVideoRecord];

}

- (void)deleteVideoRecord{
    [self.playLayer removeFromSuperlayer];
    self.avPlayer = nil;
    self.playLayer = nil;
    [self deleteVideoFile];
    
    [self openVideo];
}

/**
 删除当前的视频
 */
- (void)deleteVideoFile{
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtPath:self.recordPath error:&error];
    if (error) {
        NSLog(@"删除视频失败:%@",error);
    }else{
        NSLog(@"成功删除视频");
    }
}


// 保存视频
- (IBAction)saveVideo:(id)sender {
    [self.recordEngine saveVideo:^(NSString *fliePath) {
        self.recordPath = fliePath;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 保存成功发送通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationSaveVideoSucess object:self.recordPath];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    }];

}

// 播放视频
- (void)setupPlayer:(NSString *)path {
   
    // 本地视频播放
    NSURL *url = [NSURL fileURLWithPath:path];
    
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    self.avPlayer.muted = YES;
    
    // 设置播放页面
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    playLayer.frame = self.view.bounds;
    playLayer.videoGravity = AVLayerVideoGravityResize;
    self.playLayer = playLayer;
    // 添加播放视图到view
    [self.view.layer insertSublayer:self.playLayer above:self.recordEngine.previewLayer];
    [[self.recordEngine previewLayer] removeFromSuperlayer];
    //[self.recordEngine shutdown];
    // 视频播放
    [self.avPlayer play];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}


- (void)playEnd {
    
    __weak typeof(self) weakSelf = self;
    [_avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.avPlayer play];
    }];
    
}



- (void)dealloc {
    _recordEngine = nil;
}


@end
