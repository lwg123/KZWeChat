//
//  KZSettingViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/10.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZSettingViewController.h"
#import "KZPersonInfoController.h"
#import "KZChangePasswordVC.h"
#import "KZSuggestViewController.h"
#import "KZAboutViewController.h"
#import "ViewController.h"

static NSString *cellID = @"cellId";

@interface KZSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NSArray *section1Array;
@property (nonatomic,strong) NSArray *section2Array;
@end

@implementation KZSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人设置";
    self.view.backgroundColor = RGB(235, 233, 233);
    
    // 数据源
    _section1Array = @[@"修改个人资料",@"修改密码"];
    _section2Array = @[@"投诉建议",@"清理缓存",@"关于我们",@"退出账号"];
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NavgationHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NavgationHeight) style:UITableViewStylePlain];
    
    _myTableView.dataSource = self;
    _myTableView.delegate = self;
    _myTableView.rowHeight = 50;
    [_myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    _myTableView.backgroundColor = [UIColor clearColor];
    _myTableView.tableFooterView = [UIView new];
    [_myTableView setSeparatorInset:UIEdgeInsetsMake(50, 15, 0, 15)];
    [self.view addSubview:_myTableView];
    
    AdjustsScrollViewInsets_NO(self.myTableView,self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kzNavColor] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = nil;
}

#pragma mark - tableView datasource --
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _section1Array.count;
    }else {
        return _section2Array.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 25)];
    headerView.backgroundColor = RGB(235, 233, 233);
    
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.textLabel.text = self.section1Array[indexPath.row];
        switch (indexPath.row) {
            case 0:
            {
                cell.imageView.image = [UIImage imageNamed:@"修改个人资料"];
            }
                break;
            case 1:
            {
                cell.imageView.image = [UIImage imageNamed:@"修改密码"];
            }
                break;
                
            default:
                break;
        }
        
        
    }else {
        cell.textLabel.text = self.section2Array[indexPath.row];
        switch (indexPath.row) {
            case 0:
            {
                cell.imageView.image = [UIImage imageNamed:@"投诉"];
            }
                break;
            case 1:
            {
                cell.imageView.image = [UIImage imageNamed:@"清理缓存"];
            }
                break;
            case 2:
            {
                cell.imageView.image = [UIImage imageNamed:@"关于我们"];
            }
                break;
            case 3:
            {
                cell.imageView.image = [UIImage imageNamed:@"退出登录"];
            }
                break;
                
            default:
                break;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                KZPersonInfoController *personVC = [[KZPersonInfoController alloc] init];
                [self.navigationController pushViewController:personVC animated:YES];
            }
                break;
            case 1:
            {
                KZChangePasswordVC *pswVC = [[KZChangePasswordVC alloc] init];
                [self.navigationController pushViewController:pswVC animated:YES];
            }
                break;
                
            default:
                break;
        }
        
    }else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: // 投诉建议
            {
                KZSuggestViewController *suggestVC = [[KZSuggestViewController alloc] init];
                [self.navigationController pushViewController:suggestVC animated:YES];
            }
                break;
            case 1: //清理缓存
            {
                [[SDImageCache sharedImageCache] clearMemory];
                [self.view makeToast:@"清除缓存成功！"];
            }
                break;
            case 2: //关于我们
            {
                KZAboutViewController *aboutVC = [[KZAboutViewController alloc] init];
                [self.navigationController pushViewController:aboutVC animated:YES];
            }
                break;
            case 3: //退出当前账号,切换到登录页面
            {
                [self logout];
                
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)logout {
    
    [KZUtils addAlertView:@"" message:@"确定要退出登录吗？" cancelTitle:@"取消" confirmTitle:@"确定" cancelBlock:^{
        
    } defaultBlock:^{
        [self logoutSucess];
    }];
    
    
}


- (void)logoutSucess {
    [KZNetworkManager POST:@"api/logout" parameters:@{@"user_id" : [KZAppManager getUserId]} completeHandler:^(id responseObject, NSError *error) {
        
        if (error == nil) {
            NSLog(@"%@",responseObject);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // 退出成功，删除个人信息
                [self.view makeToast:@"退出成功"];
                [KZAppManager clearUserInfo];
                
                // 返回原来页面
                UIViewController *VC = nil;
                for (UIViewController *childVC in self.navigationController.childViewControllers) {
                    
                    if ([childVC isKindOfClass:[ViewController class]]) {
                        VC = childVC;
                    }
                }
                
                [self.navigationController popToViewController:VC animated:YES];
                
            });
            
        }else {
            NSLog(@"%@",error.domain);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:error.domain];
            });
        }
        
    }];
}

@end
