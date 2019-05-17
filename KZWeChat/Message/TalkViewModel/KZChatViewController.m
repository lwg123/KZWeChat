//
//  ViewController.m
//  XMPPChat
//
//  Created by 123 on 2017/12/14.
//  Copyright © 2017年 123. All rights reserved.
//

#import "KZChatViewController.h"
#import "CSMessageCell.h"
#import "CSMessageModel.h"
#import "CSBigView.h"
#import "EmojiView.h"
#import "CSRecord.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHight [UIScreen mainScreen].bounds.size.height

@interface KZChatViewController ()<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,CSMessageCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) CGFloat nowHeight;
@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) CSBigView *bigImageView;
@property (nonatomic, strong) EmojiView *ev;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@end

@implementation KZChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _infoDict[@"nickname"];
    
    _dataArray = [NSMutableArray array];
    
    _tableView.backgroundColor = [[UIColor alloc] initWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    _tableView.separatorColor = [UIColor clearColor];
    _tableTopConstraint.constant = NavgationHeight;

    _bigImageView = [[CSBigView alloc] init];
    _bigImageView.frame = [UIScreen mainScreen].bounds;
    _bigImageView.backgroundColor = [UIColor redColor];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    // 首先从本地获取聊天记录，获取不到在请求数据
//    self.dataArray = [KZAppManager getMessage:_infoDict[@"to_user_id"]].mutableCopy;
//    if (self.dataArray.count == 0) {
//        // 获取所有聊天记录
//
//    }
    
    [self getMessage];
    // 创建一个定时器，每隔5s获取一次聊天记录
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(upDatePage) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

#pragma mark  - 滑到最底部
- (void)scrollTableToFoot:(BOOL)animated
{
    // 有多少行
    NSInteger r = [self.tableView numberOfRowsInSection:0];
    if (r == 0) {
        return;
    }
    //取最后一行数据
    NSIndexPath *ip = [NSIndexPath indexPathForRow:r-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:animated]; //滚动到最后一行
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.tableView.contentSize.height > self.tableView.height) {
        
        [self scrollTableToFoot:YES];

    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    // 把最新的聊天记录保存在本地
    [KZAppManager saveMessage:self.dataArray userid:_infoDict[@"to_user_id"]];
}

-(void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    _tableBottomConstraint.constant = 44 + height;
    UIView *vi = [self.view viewWithTag:100];
    CGRect rec = vi.frame ;
    rec.origin.y = _nowHeight - height;
    vi.frame = rec;
}
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    _tableBottomConstraint.constant = 44;
    UIView *vi = [self.view viewWithTag:100];
    vi.frame = CGRectMake(0, _nowHeight, [UIScreen mainScreen].bounds.size.width, 44);
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIView *vi = [self.view viewWithTag:100];
    if (!vi)
    {
        _nowHeight =  _tableView.frame.size.height+NavgationHeight;
        [self bottomView];
    }
    
}

#pragma mark -- 刷新数据 -----
- (void)upDatePage {
    
    NSDictionary *pram = @{
                           @"pair_id" : _infoDict[@"pair_id"],
                           @"user_id" : [KZAppManager getUserId],
                           @"type" : @"new"
                           };
    kWeakSelf(self);
    [KZNetworkManager POST:@"user/getMessage" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            // 字典转模型
            NSArray *tempArray = (NSArray *)responseObject;
            if (tempArray.count == 0) {
                return;
            }
            
            NSLog(@"getnewMessage:%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
        
                for (NSDictionary *dict in tempArray) {
                    CSMessageModel *model = [[CSMessageModel alloc] initWith:dict];
                    [self.dataArray addObject:model];
                }
                
                [weakself.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:weakself.dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [weakself.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:weakself.dataArray.count - 1 inSection:0]
                                            animated:YES
                                      scrollPosition:UITableViewScrollPositionMiddle];
            });
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
    
}


#pragma mark -- 获取数据源 -----
- (void)getMessage {
    
    NSDictionary *pram = @{
                           @"pair_id" : _infoDict[@"pair_id"],
                           @"user_id" : [KZAppManager getUserId],
                           @"type" : @"all"
                           };
    [KZNetworkManager POST:@"user/getMessage" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            
          //  NSLog(@"getMessage:%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    NSArray *tempArray = (NSArray *)responseObject;
                    
                    // 字典转模型
                    for (NSDictionary *dict in tempArray) {
                        CSMessageModel *model = [[CSMessageModel alloc] initWith:dict];
                         [self.dataArray addObject:model];
                    }
                    
                    
                    if (tempArray.count == 0) {
                        // 如果未获取到加载本地的聊天记录
//                        self.dataArray = [KZAppManager getMessage:self->_infoDict[@"to_user_id"]].mutableCopy;
                        
                    }
                    
                    [self.tableView reloadData];
                }
                
            });
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
}



#pragma mark - tableViewDelegate --------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSMessageCell *cell=[CSMessageCell cellWithTableView:tableView messageModel:_dataArray[indexPath.row]];
    cell.delegate = self;
//    cell
    cell.backgroundColor = [[UIColor alloc] initWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSMessageModel *model = _dataArray[indexPath.row];
   // NSLog(@"cellHeight:%f",model.cellHeight);
    return [model cellHeight];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}
- (void)messageCellSingleClickedWith:(CSMessageCell *)cell
{
    
    [self.view endEditing:YES];
    
    
    if (_ev.hidden == NO)
    {
        _ev.hidden = YES;
        _tableBottomConstraint.constant = 44;
        UIView *vi = [self.view viewWithTag:100];
        vi.frame = CGRectMake(0, _nowHeight, [UIScreen mainScreen].bounds.size.width, 44);
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    CSMessageModel *model = _dataArray[indexPath.row];
    if (model.messageType == MessageTypeVoice)
    {
        [[CSRecord ShareCSRecord] playRecord];
        
        if ([_selectIndex isEqual: indexPath] == NO)
        {
            
            CSMessageCell *cell1 = [self.tableView cellForRowAtIndexPath:_selectIndex];
            [cell1 stopVoiceAnimation];
            
            _selectIndex = indexPath;
            [cell startVoiceAnimation];
        }
        else
        {
            if (cell.voiceAnimationImageView.isAnimating)
            {
                [cell stopVoiceAnimation];
            }
            else
            {
                [cell startVoiceAnimation];
            }
        }
    }
    else if (model.messageType == MessageTypeImage)
    {
        _bigImageView.bigImageView.image = model.imageSmall;
        _bigImageView.show = YES;

    }
    
}

-(void)bottomView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, _nowHeight, [UIScreen mainScreen].bounds.size.width, 44)];
    bgView.tag = 100;
    bgView.backgroundColor = [[UIColor alloc] initWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1];
   
    bgView.layer.masksToBounds = YES;
    bgView.layer.borderColor = [[UIColor alloc] initWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1].CGColor;
    bgView.layer.borderWidth = 1;
    [self.view addSubview:bgView];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 0, bgView.bounds.size.width - 110, 44)];
    textView.delegate = self;
    textView.tag = 101;
    textView.returnKeyType = UIReturnKeySend;
    textView.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    textView.text = @"";
    [bgView addSubview:textView];
    _textView = textView;

    // 添加发送按钮
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 0, 55, 30)];
    sendBtn.centerY = textView.centerY;
    [sendBtn setBackgroundImage:[UIImage imageWithColor:kzNavColor] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendLoaclMessage) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.layer.masksToBounds = YES;
    sendBtn.layer.cornerRadius = 5.0;
    [bgView addSubview:sendBtn];
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"])
    {
        if (textView.text.length == 0)
        {
            return NO;
        }
        CSMessageModel *model = [[CSMessageModel alloc] init];
        model.showMessageTime=NO;
        model.messageSenderType = MessageSenderTypeMe;
        model.messageType = MessageTypeText;
        model.messageText = textView.text;
      
        [_dataArray addObject:model];
        
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        
        [self sendMessage:textView.text]; //调用接口发送
        textView.text = @"";
        return NO;
    }
    
    return YES;
}

- (void)sendLoaclMessage {
    [self textView:_textView shouldChangeTextInRange:NSMakeRange(0, _textView.text.length) replacementText:@"\n"];
}


static int iiii = 0;
- (void)touchDown:(UIButton *)btn
{
    if (iiii == 0)
    {
        [[CSRecord ShareCSRecord] beginRecord];
        iiii = 1;
    }
    
}
- (void)leaveBtnClicked:(UIButton *)btn
{
    iiii = 0;
    NSLog(@"松开了");
    [[CSRecord ShareCSRecord] endRecord];
}
- (void)btnClicked:(UIButton *)btn
{
    [self.view endEditing:YES];
    _ev.hidden = YES;
    _tableBottomConstraint.constant = 44;
    UIView *vi = [self.view viewWithTag:100];
    vi.frame = CGRectMake(0, _nowHeight, [UIScreen mainScreen].bounds.size.width, 44);
    switch (btn.tag)
    {
        case 11:
            
            break;
        case 12:
            
        {
            
            _ev.hidden = NO;
            _tableBottomConstraint.constant = 44 + 180;
            UIView *vi = [self.view viewWithTag:100];
            CGRect rec = vi.frame ;
            rec.origin.y = _nowHeight - 180;
            vi.frame = rec;

        }
            
            break;
        case 13:
            {
                
                
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                [alertController addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                        
                        //图片选择是相册（图片来源自相册）
                        
                        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        
                        //设置代理
                        
                        picker.delegate=self;
                        
                        //模态显示界面
                        
                        [self presentViewController:picker animated:YES completion:nil];
                        
                    }
                    
                    else {
                        
                        NSLog(@"不支持相机");
                        
                    }
                    

                    NSLog(@"点击确认");
                    
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    UIImagePickerController * picker = [[UIImagePickerController alloc]init];
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        
                        //图片选择是相册（图片来源自相册）
                        
                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        
                        //设置代理
                        
                        picker.delegate=self;
                        
                        //模态显示界面
                        
                        [self presentViewController:picker animated:YES completion:nil];
                        
                        
                        
                    }
                    
                    NSLog(@"点击确认");
                    
                }]];
                [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                    NSLog(@"点击取消");
                    
                }]];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
            break;
        default:
            break;
    }
    NSLog(@"呀！我这个按钮别点击了！");
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
     if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary)
     {
        UIImage * image =info[UIImagePickerControllerOriginalImage];
        CSMessageModel * model = [[CSMessageModel alloc] init];
         model.showMessageTime=YES;
         model.messageSenderType = MessageSenderTypeOther;
         model.messageType = MessageTypeImage;
         model.imageSmall = image;
         model.messageTime = @"16:40";
         [_dataArray addObject:model];
         
         [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
         [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                     animated:YES
                               scrollPosition:UITableViewScrollPositionMiddle];
         
        [self dismissViewControllerAnimated:YES completion:nil];
     }
   else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        UIImage * image =info[UIImagePickerControllerOriginalImage];
        CSMessageModel * model = [[CSMessageModel alloc] init];
        model.showMessageTime=YES;
        model.messageSenderType = MessageSenderTypeOther;
        model.messageType = MessageTypeImage;
        model.imageSmall = image;
        model.messageTime = @"16:40";
        [_dataArray addObject:model];
        
        [_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_dataArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionMiddle];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// 发送消息
- (void)sendMessage:(NSString *)message {
    
    NSDictionary *pram = @{
                           @"pair_id" : _infoDict[@"pair_id"],
                           @"user_id" : [KZAppManager getUserId],
                           @"to_user_id" : _infoDict[@"to_user_id"],
                           @"message" : message
                           };
    
    [KZNetworkManager POST:@"user/sendMessage" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            
            NSLog(@"sendMessage:%@",responseObject);
            // 发送成功刷新数据源，不用再次刷新了
//            CSMessageModel *model = [[CSMessageModel alloc] initWith:responseObject];
//            [self.dataArray addObject:model];
            
    
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
}



@end
