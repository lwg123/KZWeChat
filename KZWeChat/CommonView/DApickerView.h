//
//  DApickerView.h
//  newDuiaApp
//
//  Created by quan on 2017/12/14.
//  Copyright © 2017年 李名泰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^pickerViewSelectBlock)(NSInteger row1,NSInteger row2);
typedef void(^pickerViewHideBlock)(void);

@interface DApickerView : UIView

@property (nonatomic, copy) pickerViewSelectBlock block;/**<*/
@property (nonatomic, copy) pickerViewHideBlock hideBlock;/**<*/

@property (nonatomic, assign) BOOL isDate;/**<是否是时间选择器*/
@property (nonatomic, assign) BOOL needCurrentMonth;/**<是否需要只包含今年已经过去的月*/
@property (nonatomic, assign) BOOL needCompareDate;/**<是否需要时间对比*/

/**
 设置pikerView 标题和列数

 @param title 标题
 @param component 列数
 @param height 高度
 */
- (void)setTitle:(NSString *)title component:(NSInteger)component contentViewHeight:(NSInteger)height;

/**
 设置pickerVIew 显示的数据源

 @param array1 第一列的数据源
 @param array2 第二列的数据源（如果有）
 */
- (void)setDataComponent1:(NSArray *)array1 component2:(NSArray *)array2;

/**
 设置pickerVIew 初始选中行数

 @param row1 第一列选中的行
 @param row2 第二列选中的行（如果有）
 */
- (void)setSelectRowAtComponent1:(NSInteger)row1 component2:(NSInteger)row2;

/**
 设置时间pickerView数据源

 @param array1 年数据源
 @param array2 月数据源
 @param array3 今年的月数据源
 */
- (void)setyearComponent:(NSArray *)array1 month:(NSArray *)array2 currentYear:(NSArray *)array3;



/**
 选中对应的数据

 @param row 对应的row
 @param component 选择的component
 @param animated 是否需要动画
 */
- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;

- (void)show;
- (void)hide;
@end

