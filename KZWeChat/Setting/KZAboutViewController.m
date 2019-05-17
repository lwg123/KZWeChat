//
//  KZAboutViewController.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/10.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZAboutViewController.h"
#import "KZAgreementController.h"

@interface KZAboutViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *myTableView;
@property (nonatomic,strong) NSArray *dataArray;
@end

@implementation KZAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"关于我们";
    self.view.backgroundColor = RGB(241, 242, 243);
    self.dataArray = @[@"用户协议",@"当前版本"];    //,@"检查更新" 取消
    
    [self setupUI];
    
    AdjustsScrollViewInsets_NO(self.myTableView,self);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置导航栏
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:kzNavColor] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
}

- (void)setupUI {
    // icon
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, NavgationHeight+20, 95, 95)];
    iconView.centerX = SCREEN_WIDTH/2;
    iconView.image = [UIImage imageNamed:@"AppIcon"];
    [self.view addSubview:iconView];
    
    UILabel *nameLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    nameLab.text = @"聊呗";
    nameLab.textAlignment = NSTextAlignmentCenter;
    nameLab.textColor = [UIColor blackColor];
    nameLab.font = [UIFont systemFontOfSize:20];
    [nameLab sizeToFit];
    nameLab.center = CGPointMake(SCREEN_WIDTH/2, iconView.maxY+15);
    [self.view addSubview:nameLab];
    
    _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, nameLab.maxY+25, SCREEN_WIDTH, 45 * 2) style:UITableViewStylePlain];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.scrollEnabled = NO;
    
    [self.view addSubview:_myTableView];
}


#pragma mark - tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellID"];
    }
    if (indexPath.row == 0) {
        UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 0, 20, 20)];
        rightView.image = [UIImage imageNamed:@"rightArrow"];
        rightView.centerY = 45.0/2;
        [cell.contentView addSubview:rightView];
    }else if (indexPath.row == 1){
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, 0, 50, 20)];
        lab.centerY = 45.0/2;
        lab.text = @"V1.0.0";
        lab.font = [UIFont systemFontOfSize:14];
        lab.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:lab];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        KZAgreementController *agreeVC = [[KZAgreementController alloc] init];
        [self.navigationController pushViewController:agreeVC animated:YES];
    }else if (indexPath.row == 1) {
        
    }
//    else {
//        [self.view makeToast:@"已是最新版本"];
//    }
}






@end
