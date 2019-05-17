//
//  KZTalkViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/18.
//  Copyright © 2019 duia. All rights reserved.
//

static NSString *CellID = @"CellID";

#import "KZTalkViewController.h"
#import "KZTalkViewCell.h"
#import "YZChatToolBarView.h"

@interface KZTalkViewController ()<UITableViewDataSource,UITableViewDelegate,YZChatToolBarDeleagte>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *resultArray;

@property (nonatomic, strong) YZChatToolBarView *toolBarView;
@property (nonatomic,strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConst;


@end

@implementation KZTalkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    
    self.title = _infoDict[@"nickname"];
    self.dataArray = [NSMutableArray array];
    
    
    [self getMessage];

    [self.view addSubview:self.toolBarView];
    
    AdjustsScrollViewInsets_NO(self.myTableView,self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 创建一个定时器，每隔5s获取一次聊天记录
    _timer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(upDatePage) userInfo:nil repeats:YES];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)upDatePage {
    
    NSDictionary *pram = @{
                           @"pair_id" : _infoDict[@"pair_id"],
                           @"user_id" : [KZAppManager getUserId],
                           @"type" : @"new"
                           };
    [KZNetworkManager POST:@"user/getMessage" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            
            NSLog(@"getnewMessage:%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    
                    [self.dataArray addObjectsFromArray:responseObject];
                    [self.myTableView reloadData];
                }
                
            });
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
    
}

- (YZChatToolBarView*)toolBarView
{
    if (_toolBarView == nil)
    {
        CGFloat originY = self.navigationController.navigationBar.translucent ? (SCREEN_HEIGHT - 50) : (SCREEN_HEIGHT - 114);
        CGRect frame = CGRectMake(0, originY, SCREEN_WIDTH, 266);
        _toolBarView = [[YZChatToolBarView alloc]initWithFrame:frame];
        _toolBarView.scrollView = _myTableView;
        _toolBarView.delegate = self;
    }
    return _toolBarView;
}


- (void)getMessage {
    
    NSDictionary *pram = @{
                           @"pair_id" : _infoDict[@"pair_id"],
                           @"user_id" : [KZAppManager getUserId],
                           @"type" : @"all"
                           };
    [KZNetworkManager POST:@"user/getMessage" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            
            NSLog(@"getMessage:%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    [self.dataArray removeAllObjects];
                    
                    [self.dataArray addObjectsFromArray:responseObject];
                    [self.myTableView reloadData];
                }
                
            });
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
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
            // 发送成功刷新数据源
            dispatch_async(dispatch_get_main_queue(), ^{
               // [self getMessage];
                [self.dataArray addObject:responseObject];
                [self.myTableView reloadData];
                
            });
            
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
}


//泡泡文本
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf withPosition:(int)position{
    
    //计算大小
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
    // build single chat bubble cell with given text
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    returnView.backgroundColor = [UIColor clearColor];
    
    //背影图片
    UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"SenderAppNodeBkg_HL":@"ReceiverTextNodeBkg" ofType:@"png"]];
    
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:floorf(bubble.size.width/2) topCapHeight:floorf(bubble.size.height/2)]];
  //  NSLog(@"%f,%f",size.width,size.height);
    
    
    //添加文本信息
    UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(fromSelf?15.0f:22.0f, 20.0f, size.width+10, size.height+10)];
    bubbleText.backgroundColor = [UIColor clearColor];
    bubbleText.font = font;
    bubbleText.numberOfLines = 0;
    bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
    bubbleText.text = text;
    
    bubbleImageView.frame = CGRectMake(0.0f, 14.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+20.0f);
    
    if(fromSelf)
        returnView.frame = CGRectMake(SCREEN_WIDTH-position-(bubbleText.frame.size.width+30.0f), 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
    else
        returnView.frame = CGRectMake(position, 0.0f, bubbleText.frame.size.width+30.0f, bubbleText.frame.size.height+30.0f);
    
    [returnView addSubview:bubbleImageView];
    [returnView addSubview:bubbleText];
    
    return returnView;
}


#pragma mark - tableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        
    }else{
        for (UIView *cellView in cell.contentView.subviews){
            [cellView removeFromSuperview];
        }
    }
    
    NSDictionary *dict = [_dataArray objectAtIndex:indexPath.row];
    
    //创建头像
    UIImageView *photo;
    if ([[NSString stringWithFormat:@"%@",dict[@"user_id"]] isEqualToString:[KZAppManager getUserId]]) { // 本人
        photo = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, 10, 50, 50)];
        photo.layer.masksToBounds = YES;
        photo.layer.cornerRadius = photo.height/2;
        [cell.contentView addSubview:photo];

        

//        KZUser *user = [KZAppManager loadUserInfo];
//        [photo sd_setImageWithURL: [NSURL URLWithString: user.avatar]];
        [photo sd_setImageWithURL:dict[@"userAvatar"]];
        [cell.contentView addSubview:[self bubbleView:[dict objectForKey:@"message"] from:YES withPosition:65]];
        
    }else{
        photo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        photo.layer.masksToBounds = YES;
        photo.layer.cornerRadius = photo.height/2;
        [cell.contentView addSubview:photo];
       
        [photo sd_setImageWithURL:dict[@"toUserAvatar"]];
        
        [cell.contentView addSubview:[self bubbleView:[dict objectForKey:@"message"] from:NO withPosition:65]];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [_resultArray objectAtIndex:indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [[dict objectForKey:@"message"] sizeWithFont:font constrainedToSize:CGSizeMake(180.0f, 20000.0f) lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height+60;
}


#pragma mark ------- YZChatToolBarDeleagte -------
- (void)YZChatTextViewDidSend:(NSString *)text
{
    // 点击发送消息
    [self sendMessage:text];
}




@end
