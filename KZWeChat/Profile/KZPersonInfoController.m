//
//  KZPersonInfoController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/9.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZPersonInfoController.h"
#import "KZRecordVideoController.h"
#import <AVFoundation/AVFoundation.h>
#import "ActionSheetView.h"
#import "FDCameraManager.h"
#import "DApickerView.h"
#import "SexPickerTool.h"
#import "DatePickerTool.h"
#import "KZMatchingHallController.h"


static NSUInteger const kImageSizeRestrict = 10*1024*1024;
static UIWindow *_alertWindow = nil;

@interface KZPersonInfoController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate>

@property (nonatomic,strong) KZPTextFieldView *nameFieldView;
@property (nonatomic,strong) KZPTextFieldView *sexFieldView;
@property (nonatomic,strong) KZPTextFieldView *birthdayFieldView;
@property (nonatomic,strong) UIButton *zipaiButton;
@property (nonatomic,strong) UIButton *submitBtn;
@property (nonatomic,strong) AVPlayer *avPlayer;
@property (nonatomic,strong) UILabel *tipLab;
@property (nonatomic,strong) UIImageView *photoView;
@property (nonatomic,strong) UIImageView *tanchuangView;
@property (nonatomic,strong) KZUser *user;

@property (nonatomic, strong) NSString *videostatus;        //  视频情况字段，提交自拍、审核中等


@end

@implementation KZPersonInfoController

- (void)dealloc {
    [self.avPlayer pause];
    self.avPlayer.muted = YES;
    self.avPlayer = nil;
    [self.view removeAllSubviews];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"新用户资料设置";

    [self requestUserInfo];



//    KZUser *user = [KZAppManager loadUserInfo];
//    if (user != nil) {
//        _user = user;
//    }


    
//    if ([KZAppManager getZiPaiVideo] != nil) {
//        [self setupPlayer:[KZAppManager getZiPaiVideo]];
//    }


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveVideoSucess:) name:KNotificationSaveVideoSucess object:nil];
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:self.view.bounds];
    window.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    window.windowLevel = UIWindowLevelAlert;
    window.hidden = YES;
    _alertWindow = window;
    
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


- (void) requestUserInfo {

    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           @"uuid" : [KZAppManager getuuid],
                           };

    kWeakSelf(self)
    [KZNetworkManager POST:@"user/detail/" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        if (error == nil) {

            DLog( @"%@", responseObject);
            self.user = [[KZUser alloc] initWithDict: responseObject];

            weakself.videostatus = responseObject[@"status_name"];
            [weakself setupUI];

        }else {
            [self.view makeToast:error.domain];
        }
    }];
}

- (void)saveVideoSucess:(NSNotification *)noti {
    NSString *path = (NSString *)noti.object;
    
    [self uploadVideo:path];
//    [KZAppManager saveZiPaiVideo:path];   //  视频不再存储到本地
}

- (void)uploadVideo:(NSString *)path {
    
    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           @"upload_file" : @"headPic",
                           @"upload_type" : @"video"
                           };
    kWeakSelf(self);
    NSData *videoData = [NSData dataWithContentsOfFile:path];
    [KZNetworkManager uploadFileWithURL:@"user/upload" videoData:videoData parameters:pram progress:^(NSProgress *progress) {
        
    } completeHandler:^(id responseObject, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 上传成功
            if (error == nil) {
                [weakself setupPlayer2:path];
                weakself.tipLab.text = @"审核中...";
                DLog(@"%@",responseObject);
            }else {
                [weakself.view makeToast:@"视频上传失败"];
            }
            
        });
        
    }];
}


- (void)setupPlayer:(NSString *)path {
    // 本地视频播放
    //    NSURL *url = [NSURL fileURLWithPath:path];
    NSURL *url = [NSURL URLWithString: path];

    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    self.avPlayer.muted = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    // 设置播放页面
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    playLayer.frame = self.zipaiButton.frame;

    playLayer.backgroundColor = [UIColor cyanColor].CGColor;

    //设置播放窗口和当前视图之间的比例显示内容
    //1.保持纵横比；适合层范围内
    //2.保持纵横比；填充层边界
    //3.拉伸填充层边界
    /*
     第1种AVLayerVideoGravityResizeAspect是按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑；
     第2种AVLayerVideoGravityResizeAspectFill是以原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分就被切割了；
     第3种AVLayerVideoGravityResize是拉伸视频内容达到边框占满，但不按原比例拉伸，这里明显可以看出宽度被拉伸了。
     */
    playLayer.videoGravity = AVLayerVideoGravityResize;

    // 添加播放视图到view
    [self.view.layer addSublayer:playLayer];
    self.zipaiButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview: _zipaiButton];

    // 视频播放
    [self.avPlayer play];
}

- (void)setupPlayer2:(NSString *)path {
    // 本地视频播放
    NSURL *url = [NSURL fileURLWithPath:path];

    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
    self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
    self.avPlayer.muted = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    // 设置播放页面
    AVPlayerLayer *playLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    playLayer.frame = self.zipaiButton.frame;

    playLayer.backgroundColor = [UIColor cyanColor].CGColor;

    //设置播放窗口和当前视图之间的比例显示内容
    //1.保持纵横比；适合层范围内
    //2.保持纵横比；填充层边界
    //3.拉伸填充层边界
    /*
     第1种AVLayerVideoGravityResizeAspect是按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑；
     第2种AVLayerVideoGravityResizeAspectFill是以原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分就被切割了；
     第3种AVLayerVideoGravityResize是拉伸视频内容达到边框占满，但不按原比例拉伸，这里明显可以看出宽度被拉伸了。
     */
    playLayer.videoGravity = AVLayerVideoGravityResize;

    // 添加播放视图到view
    [self.view.layer addSublayer:playLayer];
    self.zipaiButton.backgroundColor = [UIColor clearColor];
    [self.view addSubview: _zipaiButton];

    // 视频播放
    [self.avPlayer play];
}


- (void)playEnd {
    
    __weak typeof(self) weakSelf = self;
    [_avPlayer seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [weakSelf.avPlayer play];
    }];
}

#pragma mark -- UI界面 ----
- (void)setupUI {
    
    _photoView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 300)/2, NavgationHeight, 300, 125)];
    _photoView.backgroundColor = [UIColor clearColor];
    _photoView.userInteractionEnabled = YES;
    _photoView.image = [UIImage imageNamed:@"上传头像"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadUserAvatar)];
    [_photoView addGestureRecognizer:tap];
    
    [self.view addSubview:_photoView];
    
    if (_user.avatar != nil) {
        UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        photoImageView.backgroundColor = [UIColor clearColor];
        photoImageView.center = CGPointMake(_photoView.width/2, _photoView.height/2-10);
        
        photoImageView.image = [[KZAppManager getPhoto] circleImage];
        [_photoView addSubview:photoImageView];

        photoImageView.layer.cornerRadius  = photoImageView.frame.size.width / 2;
        photoImageView.layer.masksToBounds = YES;

        [photoImageView sd_setImageWithURL: [NSURL URLWithString: _user.avatar]];

    }
    
    // 邮箱和密码输入框
    KZPTextFieldView *nameFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, _photoView.maxY+20, SCREEN_WIDTH - 80, 40) placeholder:@"请输入昵称" leftImage:@"昵称"];
    nameFieldView.textField.keyboardType = UIKeyboardTypeEmailAddress;
    nameFieldView.textField.delegate = self;
    _nameFieldView = nameFieldView;
    [nameFieldView.textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    nameFieldView.textField.textColor = [UIColor lightGrayColor];
    [self.view addSubview:nameFieldView];
    if (_user.nickname != nil) {
        _nameFieldView.textField.text = _user.nickname;
    }
    
    
    KZPTextFieldView *sexFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, nameFieldView.maxY+20, SCREEN_WIDTH-80, 40) placeholder:@"请选择性别" leftImage:@"男女"];
    sexFieldView.textField.keyboardType = UIKeyboardTypeASCIICapable;
    sexFieldView.textField.delegate = self;
    _sexFieldView = sexFieldView;
    [sexFieldView.textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    sexFieldView.textField.textColor = [UIColor lightGrayColor];
    [self.view addSubview:sexFieldView];
    if (_user.sex != nil) {
        sexFieldView.textField.text = _user.sex;
    }
    
    
    KZPTextFieldView *birthdayFieldView = [[KZPTextFieldView alloc] initWithFrame:CGRectMake(40, sexFieldView.maxY+20, SCREEN_WIDTH-80, 40) placeholder:@"请选择出生年月" leftImage:@"出生年月"];
    birthdayFieldView.textField.delegate = self;
    _birthdayFieldView = birthdayFieldView;
    [birthdayFieldView.textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    birthdayFieldView.textField.textColor = [UIColor lightGrayColor];
    [self.view addSubview:birthdayFieldView];
    if (_user.birthday != nil) {
        birthdayFieldView.textField.text = _user.birthday;
    }


    _zipaiButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.birthdayFieldView.maxY+20, 100, 4.0/3 * 100)];
    _zipaiButton.centerX = SCREEN_WIDTH/2;
    _zipaiButton.backgroundColor = RGB(208, 225, 254);
    [_zipaiButton setImage:[UIImage imageNamed:@"上传自拍"] forState:UIControlStateNormal];
    [_zipaiButton addTarget:self action:@selector(zipaiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    _zipaiButton.layer.masksToBounds = YES;
    _zipaiButton.layer.cornerRadius = 5.0;

    _tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, _zipaiButton.maxY+10, SCREEN_WIDTH, 16)];
    _tipLab.textAlignment = NSTextAlignmentCenter;
    _tipLab.text = self.videostatus; //@"提交自拍";
    _tipLab.font = [UIFont systemFontOfSize:14];
//    [_tipLab sizeToFit];
    _tipLab.centerX = SCREEN_WIDTH/2;

    [self.view addSubview:_tipLab];


    [self.view addSubview: self.zipaiButton];
    [self.view addSubview:self.submitBtn];

    UILabel *additionalInfoLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, _submitBtn.maxY+10, 100, 16)];
    additionalInfoLabel.textAlignment = NSTextAlignmentCenter;
    additionalInfoLabel.text = @"* 您提交的个人资料修改将在24小时内通过人工审核";
    additionalInfoLabel.font = [UIFont systemFontOfSize:12];
    [additionalInfoLabel sizeToFit];
    additionalInfoLabel.centerX = SCREEN_WIDTH/2;

    [self.view addSubview: additionalInfoLabel];

    NSString *user_id = self.user.user_id;

    if ([user_id isEqualToString:@""]) {
        KZUser *user = [KZAppManager loadUserInfo];
        user_id = user.user_id;
    }

    if (![_user.video isEqualToString: @""]) {
        [self setupPlayer: _user.video];
    }
    
}

// 提交自拍
//- (UIButton *)zipaiButton {
//    if (!_zipaiButton) {
//        _zipaiButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.birthdayFieldView.maxY+20, 100, 4.0/3 * 100)];
//        _zipaiButton.centerX = SCREEN_WIDTH/2;
//        _zipaiButton.backgroundColor = RGB(208, 225, 254);
//        [_zipaiButton setImage:[UIImage imageNamed:@"上传自拍"] forState:UIControlStateNormal];
//        [_zipaiButton addTarget:self action:@selector(zipaiButtonClick) forControlEvents:UIControlEventTouchUpInside];
//        _zipaiButton.layer.masksToBounds = YES;
//        _zipaiButton.layer.cornerRadius = 5.0;
//
//        UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, _zipaiButton.maxY+10, 50, 16)];
//        tip.textAlignment = NSTextAlignmentCenter;
//        tip.text = self.videostatus; //@"提交自拍";
//        tip.font = [UIFont systemFontOfSize:14];
//        [tip sizeToFit];
//        tip.centerX = SCREEN_WIDTH/2;
//        _tipLab = tip;
//        [self.view addSubview:tip];
//
//    }
//    return _zipaiButton;
//}


- (UIButton *)submitBtn {
    if (!_submitBtn) {
        _submitBtn = [KZUtils createButtonWithFrame:CGRectMake(35, self.zipaiButton.maxY+50, SCREEN_WIDTH-70, 44) color:[UIColor whiteColor] title:@"提交审核"];
        _submitBtn.layer.cornerRadius = 22;
        _submitBtn.layer.masksToBounds = YES;
        _submitBtn.layer.borderWidth = 1.0;
        _submitBtn.layer.borderColor = RGB(42, 155, 220).CGColor;
        [_submitBtn addTarget:self action:@selector(submitBtnClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _submitBtn;
}


- (void)showTanChuang {
    _alertWindow.hidden = NO;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 310, 250)];
    imageView.image = [UIImage imageNamed:@"提交资料-弹窗"];
    imageView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tanChuangClick)];
    [imageView addGestureRecognizer:tap];
    _tanchuangView = imageView;
    
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.height-50, imageView.width, 45)];
    tipLab.text = @"快去配对大厅滑动看看~";
    tipLab.textColor = [UIColor whiteColor];
    tipLab.backgroundColor = [UIColor clearColor];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.font = [UIFont systemFontOfSize:14];
    [imageView addSubview:tipLab];
    
    UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectMake(110, 130, 150, 50)];
    detailLab.text = @"您的资料已提交成功请等待人工审核";
    detailLab.textColor = [UIColor blackColor];
    detailLab.numberOfLines = 0;
    [imageView addSubview:detailLab];
    
    [_alertWindow addSubview:imageView];
}


#pragma mark -- action ----
- (void)tanChuangClick {
    _alertWindow.hidden = YES;
    
    UIViewController *VC = nil;
    for (UIViewController *childVC in self.navigationController.childViewControllers) {
        if ([childVC isKindOfClass:[KZMatchingHallController class]]) {
            VC = childVC;
        }
    }
    [self.navigationController popToViewController:VC animated:YES];
}

- (void)zipaiButtonClick {

    //相机权限

    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if (authStatus ==AVAuthorizationStatusRestricted ||//此应用程序没有被授权访问的照片数据。可能是家长控制权限

        authStatus ==AVAuthorizationStatusDenied)  //用户已经明确否认了这一照片数据的应用程序访问

    {

        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: @"聊呗未获得相机权限" message: @"聊呗未获得相机权限，请点击确定进行设置"  preferredStyle: UIAlertControllerStyleAlert];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler: nil];


        UIAlertAction *confirm = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            // 无权限 引导去开启

            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

            if ([[UIApplication sharedApplication]canOpenURL:url]) {

                [[UIApplication sharedApplication]openURL:url];

            }

        }];

        [alertVC addAction: cancel];
        [alertVC addAction: confirm];

        [self presentViewController: alertVC animated: YES completion: nil];

        return;

    }

    UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle: @"提示信息" message: @"录制并上传一段个人自拍，通过审核后将会被其他用户浏览并参与匹配。\n但请注意：\n1. 请勿发布骚扰性或违反当地法律法规视频。视频可能会被举报并移除。\n2. 视频中包含恃强凌弱、威胁、骚扰、侵犯隐私、泄露他人的个人信息及煽动他人进行暴力行为等内容的视频将受到严肃处理。\n3. 尊重版权。仅上传您制作的或您有权使用的视频。不要未经必要的授权就在您的视频中使用他人拥有版权的内容。" preferredStyle: UIAlertControllerStyleAlert];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        // 跳转到自拍页面
        KZRecordVideoController *recordVC = [[KZRecordVideoController alloc] initWithNibName:@"KZRecordVideoController" bundle:nil];
        [self.navigationController pushViewController:recordVC animated:YES];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"再想想" style: UIAlertActionStyleCancel handler: nil];

    [warningAlert addAction: confirm];
    [warningAlert addAction: cancel];

    [self presentViewController: warningAlert animated: YES completion: nil];


}

- (void)submitBtnClick {
    if (_nameFieldView.textField.text.length == 0 || _sexFieldView.textField.text.length == 0 || _birthdayFieldView.textField.text.length == 0) {
        [self.view makeToast:@"需要填写资料才可提交审核"];
        return;
    }
    
    //调用接口，提交审核
    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           @"nickname" : _nameFieldView.textField.text,
                           @"sex" : _sexFieldView.textField.text,
                           @"birth" : _birthdayFieldView.textField.text
                           };
    [KZNetworkManager POST:@"user/edit" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 弹窗
            [self showTanChuang];
        });
        
    }];
    
}

// 上传头像
- (void)uploadUserAvatar {
    kWeakSelf(self);
    ActionSheetView *actionView = [[ActionSheetView alloc] initWithTitle:@"选取照片" cellArray:@[@"相册", @"拍照"] cancelTitle:@"取消" selectedBlock:^(NSInteger index) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
        ipc.delegate = self;
        ipc.allowsEditing = YES;
        switch (index) {
            case 1:{
                [ipc setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                [weakself presentViewController:ipc animated:YES completion:nil];
            }
                break;
            case 2:{
                [FDCameraManager checkCanAccessCameraComplete:^(BOOL accessible,FDCameraAccessErrorState state) {
                    if (accessible) {
                        [ipc setSourceType:UIImagePickerControllerSourceTypeCamera];
                        [weakself presentViewController:ipc animated:YES completion:nil];
                    } else if(!accessible && state == FDCameraManagerErrorStateNoGrant) {
//                        [[[UIAlertView alloc] initWithTitle:@"" message:@"聊呗未获得相机权限，请去往 设置>隐私>相机 中进行设置" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil] show];

                        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle: @"聊呗未获得相机权限" message: @"聊呗未获得相机权限，请点击确定进行设置"  preferredStyle: UIAlertControllerStyleAlert];

                        UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler: nil];


                        UIAlertAction *confirm = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                            // 无权限 引导去开启

                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

                            if ([[UIApplication sharedApplication]canOpenURL:url]) {

                                [[UIApplication sharedApplication]openURL:url];

                            }

                        }];

                        [alertVC addAction: cancel];
                        [alertVC addAction: confirm];

                        [self presentViewController: alertVC animated: YES completion: nil];

                        return;
                    } else if (!accessible && state == FDCameraAccessErrorStateNoCamera) {
                        [weakself.view makeToast:@"本机不支持拍照"];
                    } else {
                        NSAssert(NO, @"无法访问相机，且没有错误状态");
                    }
                }];
            }
                break;
        }
    } cancelBlock:nil];
    [self.view.window addSubview:actionView];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self dismissViewControllerAnimated:YES completion:Nil];
    UIImage *image = info[@"UIImagePickerControllerEditedImage"];
    
    NSData *data = UIImageJPEGRepresentation(image, 0.9);
    while (data.length > kImageSizeRestrict) {
        data = [image compressImageDataWithMaxBytes:kImageSizeRestrict*1024];
        image = [UIImage imageWithData:data];
    }
    kWeakSelf(self);
    NSDictionary *pram = @{
                           @"user_id" : [KZAppManager getUserId],
                           @"upload_file" : @"headPic",
                           @"upload_type" : @"image"
                           };
    [KZNetworkManager uploadFileWithURL:@"user/upload" imageData:data parameters:pram progress:^(NSProgress *progress) {
        
    } completeHandler:^(id responseObject, NSError *error) {
        
        NSLog(@"%@",responseObject);
        if (error == nil) {
            // 上传成功，设置头像
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakself setupPhoto:image];
            });
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.view makeToast:error.domain];
            });
        }
        
    }];
    
}

- (void)setupPhoto:(UIImage *)image {
   
    
    UIImageView *photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    photoImageView.backgroundColor = [UIColor clearColor];
    photoImageView.center = CGPointMake(_photoView.width/2, _photoView.height/2-10);
    photoImageView.image = [image circleImage];
    [self.photoView addSubview:photoImageView];
    [KZAppManager savePhoto:image];
    
}


- (void)chooseUserSex {
    
    SexPickerTool *sexPick = [[SexPickerTool alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-150, self.view.frame.size.width, 150)];
    kWeakSelf(self);
    sexPick.callBlock = ^(NSString *pickDate) {
        NSLog(@"%@",pickDate);
        
        if (pickDate) {
            weakself.sexFieldView.textField.text = pickDate;
        }
        [_alertWindow removeAllSubviews];
        _alertWindow.hidden = YES;
    };
    _alertWindow.hidden = NO;
    [_alertWindow addSubview:sexPick];
}

- (void)chooseUserBirthday {
    
    DatePickerTool *datePicker = [[DatePickerTool alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-280, self.view.frame.size.width, 280)];
    
    kWeakSelf(self);
    datePicker.callBlock = ^(NSString *pickDate) {
        
        NSLog(@"%@",pickDate);
        
        if (pickDate) {
            weakself.birthdayFieldView.textField.text = pickDate;
        }
        [_alertWindow removeAllSubviews];
        _alertWindow.hidden = YES;
    };
    _alertWindow.hidden = NO;
    [_alertWindow addSubview:datePicker];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _sexFieldView.textField) {
        [self.view endEditing:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self chooseUserSex];
        });
        
        return NO;
    }else if (textField == _birthdayFieldView.textField){
        [self.view endEditing:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self chooseUserBirthday];
        });
        
        return NO;
    }else {
        return YES;
    }
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}



@end
