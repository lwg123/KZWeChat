//
//  KZMessageViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/10.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZMessageController.h"
#import "KZTalkViewController.h"
#import "KZMeaageCell.h"
#import "KZChatViewController.h"

#define koriginTapIndex -1

static NSString *cellID = @"cellID";

@interface KZMessageController ()<UITableViewDataSource,UITableViewDelegate,KZMeaageCellDelegate>
{
    bool isaSwipeLeft;
    NSIndexPath* indexPathLeft;
    int prepareTapIndex;
}

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) UILabel *tipLab;

@end

@implementation KZMessageController

- (void)viewDidLoad {
    [super viewDidLoad];
    isaSwipeLeft = false;
    self.title = @"消息";
    self.view.backgroundColor = [UIColor whiteColor];
    prepareTapIndex = koriginTapIndex;
    self.dataArray = @[].mutableCopy;
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavgationHeight, SCREEN_WIDTH, SCREEN_HEIGHT-NavgationHeight) style:UITableViewStylePlain];
    _myTableView.dataSource = self;
    _myTableView.delegate = self;

    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_myTableView];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)];
    [_myTableView addGestureRecognizer:tapGesture];
    
    [_myTableView registerClass:[KZMeaageCell class] forCellReuseIdentifier:cellID];
    
    UILabel *tipLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH-20, 20)];
    tipLab.centerY = 250;
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.text = @"您还没有相互配对的好友，快去配对大厅碰碰运气呗~";
    tipLab.textColor = [UIColor lightGrayColor];
    tipLab.font = [UIFont systemFontOfSize:14];
    tipLab.backgroundColor = [UIColor clearColor];
    tipLab.hidden = YES;
    _tipLab = tipLab;
    [self.myTableView addSubview:tipLab];
    
    // 获取数据源
    [self requestData];
    
    AdjustsScrollViewInsets_NO(self.myTableView,self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kzNavColor] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}


- (void)requestData {
    
    kWeakSelf(self);
    [KZNetworkManager POST:@"page/pairdialog" parameters:@{@"user_id" : [KZAppManager getUserId]} completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            NSLog(@"%@",responseObject);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    [self.dataArray addObjectsFromArray:responseObject];
                }
                
                if (self.dataArray.count == 0) {
                    // 显示无数据提示
                    weakself.tipLab.hidden = NO;
                }else {
                    weakself.tipLab.hidden = YES;
                }
                [self.myTableView reloadData];
                
            });
            
            
        }else {
            NSLog(@"%@",error.domain);
            dispatch_async(dispatch_get_main_queue(), ^{
                // 显示无数据提示
                weakself.tipLab.hidden = NO;
            });
        }
        
    }];
}

#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KZMeaageCell *cell = (KZMeaageCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.delegate = self;
    
    cell.tag = indexPath.row;
    cell.myContentView.tag = indexPath.row;
    cell.contentView.backgroundColor = [UIColor purpleColor];
    [cell.deleteBtn addTarget:self action:@selector(cellDeleteBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [cell.myContentView addGestureRecognizer:cell.singleTap];
    cell.infoDict = self.dataArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}



#pragma mark ----- KZMeaageCellDelegate -------
- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)tapGR {
    isaSwipeLeft = true;
    UIView *tapView = tapGR.view;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:tapView.tag inSection:0];
    indexPathLeft = indexPath;
    if (prepareTapIndex == koriginTapIndex) {
        prepareTapIndex = (int)indexPathLeft.row;
    }
    else {
        if (prepareTapIndex != indexPathLeft.row) {
            return;
        }
    }
    
    KZMeaageCell *cell = (KZMeaageCell *)[self.myTableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        CGRect rect = cell.myContentView.frame;
        [UIView animateWithDuration:0.5 animations:^
         {
             [cell.myContentView setFrame:CGRectMake(-CellBtnWidth, rect.origin.y, rect.size.width, rect.size.height)];
             
         }];
    }
}


// 右滑代理
- (void)handleSwipeRight:(UISwipeGestureRecognizer *)tapGR{
    
    UIView *view=tapGR.view;
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(long)view.tag inSection:0];
    KZMeaageCell* cell = (KZMeaageCell*)[self.myTableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        
        CGRect rect = cell.myContentView.frame;
        [UIView animateWithDuration:0.5 animations:^
         {
             [cell.myContentView setFrame:CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height)];
             
         }];
    }
    if (prepareTapIndex == indexPath.row) {
        prepareTapIndex = koriginTapIndex;
        isaSwipeLeft = false;
    }
}



//左滑取消配对
- (void)cellDeleteBtnClick:(UIButton *)btn {
   
    [KZUtils addAlertView:@"" message:@"确定取消配对吗？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
        [self tapGesture];
    } defaultBlock:^{

        [self cancelPeidui];
    }];
    
}

// 点击取消配对
- (void)cancelPeidui {
    // 调用接口
    NSDictionary *dict = self.dataArray[indexPathLeft.row];
    NSString *to_user_id = dict[@"to_user_id"];
    NSString *user_id = dict[@"user_id"];
    NSDictionary *pram = @{
                           @"user_id" : user_id,
                           @"to_user_id" : to_user_id
                           };
    [KZNetworkManager POST:@"user/unpair" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:@"解除配对成功!"];
                
                [self resetTableView];
            });
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
    
    
}

- (void)resetTableView {
    
    NSString *str = [self.dataArray objectAtIndex:indexPathLeft.row];
    [self.dataArray removeObject:str];
    [self.myTableView reloadData];
    
    //删除cell后剩下的cell复位
    for (int i=0; i<self.dataArray.count; i++) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        KZMeaageCell* cell = (KZMeaageCell*)[self.myTableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            CGRect rect = cell.myContentView.frame;
            [cell.myContentView setFrame:CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height)];
        }
    }
    prepareTapIndex = koriginTapIndex;
}

// 点击tab任何一个地方恢复左滑
- (void)tapGesture {
    if (isaSwipeLeft) {
        for (int i = 0; i < self.dataArray.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            KZMeaageCell* cell = (KZMeaageCell*)[self.myTableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                CGRect rect = cell.myContentView.frame;
                
                [UIView animateWithDuration:0.5 animations:^
                 {
                     [cell.myContentView setFrame:CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height)];
                 }];
            }
        }
        [self.myTableView reloadData];
        prepareTapIndex = koriginTapIndex;
        isaSwipeLeft = false;
    }
    
}

//点击cell跳转到详细信息
- (void)handleTap:(UITapGestureRecognizer *)tapGR{
    
    if (isaSwipeLeft) {
        for (int i=0; i<self.dataArray.count; i++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            KZMeaageCell* cell = (KZMeaageCell*)[self.myTableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                CGRect rect = cell.myContentView.frame;
                [UIView animateWithDuration:0.5 animations:^
                 {
                     [cell.myContentView setFrame:CGRectMake(0, rect.origin.y, rect.size.width, rect.size.height)];
                     
                 }];
            }
            
        }
        [_myTableView reloadData];
        prepareTapIndex = koriginTapIndex;
        isaSwipeLeft = false;
        
    }else
    {
        UIView *view=tapGR.view;
        NSDictionary* dict = [self.dataArray objectAtIndex:(long)view.tag];
        
        KZChatViewController *chatVC = [[KZChatViewController alloc] initWithNibName:NSStringFromClass([KZChatViewController class]) bundle:nil];
        chatVC.infoDict = dict;
        [self.navigationController pushViewController:chatVC animated:YES];
        
    }
}

@end
