//
//  ActionSheetView.h
//  DuiFuDao
//
//  Created by weiguang on 2018/8/6.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionSheetView : UIView

//初始化方法:参数一：title，参数二：数据列表，参数三：取消的标题设置，参数四：选择单元格block，参数五：取消block
-(instancetype)initWithTitle:(NSString *)title cellArray:(NSArray *)cellArray cancelTitle:(NSString *)cancelTitle selectedBlock:(void(^)(NSInteger index))selectedBlock cancelBlock:(void(^)(void))cavoidncelBlock;

@end
