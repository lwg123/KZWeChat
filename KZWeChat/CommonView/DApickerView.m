//
//  DApickerView.m
//  newDuiaApp
//
//  Created by quan on 2017/12/14.
//  Copyright © 2017年 李名泰. All rights reserved.
//

#import "DApickerView.h"
#import <NSDate+YYAdd.h>

@interface DApickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (nonatomic, strong) UIPickerView *pickerView;/**<*/
@property (nonatomic, strong) UILabel *titleLabel;/**<*/
@property (nonatomic, strong) UIView *contentView;/**<内容背景视图*/
@property (nonatomic, strong) NSArray *dataArray;/**<第一列数据源*/
@property (nonatomic, strong) NSArray *dataArray2;/**<第二列数据源*/
@property (nonatomic, strong) NSArray *dataArray3;/**<第二列数据源*/
@property (nonatomic, assign) NSInteger sections;/**<*/
@property (nonatomic, assign) NSInteger contentViewHeight;/**<*/
@property (nonatomic, strong) UICollectionView *collectionView;/**<*/
@property (nonatomic, assign) NSInteger selectRow1;/**<*/
@property (nonatomic, assign) NSInteger selectRow2;/**<*/
@property (nonatomic, assign) NSInteger selectRow3;/**<*/
@property (nonatomic, assign) BOOL special;/**<年份时包含至今*/
@property (nonatomic, assign) NSInteger row2Count;/**<第二列的个数*/

@property (nonatomic, strong) NSArray *currentYearMonth;/**<今年的已过月份*/
@property (nonatomic, strong) NSArray *monthArray;/**<*/
@end

@implementation DApickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.alpha = 0;
        self.needCompareDate = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title component:(NSInteger)component contentViewHeight:(NSInteger)height {
    
    self.sections = component;
    if (isIPhoneXSeries()) {
        height += 20;
    }
    self.contentViewHeight = height;
    [self setSubviews];
    self.titleLabel.text = title;
    self.special = [title isEqualToString:@"在职时间-止"];

}

- (void)setDataComponent1:(NSArray *)array1 component2:(NSArray *)array2 {
    self.dataArray = array1;
    self.dataArray2 = array2;
    if (self.isDate) {
        self.monthArray = array2;
        self.currentYearMonth = array2;
    }
    [self.pickerView reloadAllComponents];
}

- (void)setyearComponent:(NSArray *)array1 month:(NSArray *)array2 currentYear:(NSArray *)array3 {
    self.dataArray = array1;
    self.dataArray2 = array2;
    self.monthArray = array2;
    self.currentYearMonth = array3;
    self.needCurrentMonth = (array3 != nil);
    
    [self.pickerView reloadAllComponents];
    self.isDate = YES;
}


- (void)setSelectRowAtComponent1:(NSInteger)row1 component2:(NSInteger)row2 {
    self.selectRow1 = row1;
    self.selectRow2 = row2;
    [self.pickerView selectRow:row1 inComponent:0 animated:NO];
    if (self.sections > 1 ) {
        if (_isDate) {
            if (row1 == 0) {
                self.dataArray2 = @[@"月"];
            }else {
                self.dataArray2 = self.monthArray;
            }
            
            if (_special) {
                if (row1 == self.dataArray.count - 1) {
                    self.row2Count = 0;
                }else if (row1 == self.dataArray.count - 2) {
                    self.row2Count = self.currentYearMonth.count;
                    if (row2 > self.currentYearMonth.count) {
                        row2 = self.currentYearMonth.count - 1;
                    }
                    [self.pickerView reloadComponent:1];
                    [self.pickerView selectRow:row2 inComponent:1 animated:NO];
                }else {
                    self.row2Count = self.dataArray2.count;
                    [self.pickerView reloadComponent:1];
                    [self.pickerView selectRow:row2 inComponent:1 animated:NO];
                }
            }else if (_needCurrentMonth){
                if (row1 == self.dataArray.count - 1) {
                    self.row2Count = self.currentYearMonth.count;
                    if (row2 > self.currentYearMonth.count) {
                        row2 = self.currentYearMonth.count - 1;
                    }
                    [self.pickerView reloadComponent:1];
                    [self.pickerView selectRow:row2 inComponent:1 animated:NO];
                }else {
                    self.row2Count = self.dataArray2.count;
                    [self.pickerView reloadComponent:1];
                    [self.pickerView selectRow:row2 inComponent:1 animated:NO];
                }
            }else {
                self.row2Count = self.dataArray2.count;
                [self.pickerView reloadComponent:1];
                [self.pickerView selectRow:row2 inComponent:1 animated:NO];
            }
        }else {
            self.row2Count = self.dataArray2.count;
            [self.pickerView reloadComponent:1];
            [self.pickerView selectRow:row2 inComponent:1 animated:NO];
        }
    }
    [self.pickerView reloadAllComponents];
}

- (void)show {
    [self.superview endEditing:YES];
    self.hidden = NO;
    [UIView animateWithDuration:.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:.2 animations:^{
            self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT - self.contentViewHeight*(SCREEN_WIDTH / 375.0), SCREEN_WIDTH, self.contentViewHeight*(SCREEN_WIDTH / 375.0));
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)hide {
    [UIView animateWithDuration:.2 animations:^{
        self.contentView.frame = CGRectMake(0, SCREEN_HEIGHT , SCREEN_WIDTH, self.contentViewHeight);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.hidden = YES;
            self.hideBlock? self.hideBlock() :NULL;
        }];
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.sections;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.dataArray.count;
    }else if (component == 1) {
        if ([self.dataArray2.firstObject isKindOfClass:[NSArray class]]) {
            return [[self.dataArray2 objectAtIndex:self.selectRow1] count];
        }else {
            
            if (self.isDate) {
                return self.row2Count;
            }
            return self.dataArray2.count;
        }
    }
    return 0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return (SCREEN_WIDTH - 30)/self.sections - 10;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 60 * (SCREEN_WIDTH / 375.0);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/self.sections - 20, 49 * (SCREEN_WIDTH / 375.0))];
        //        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        pickerLabel.textColor = [UIColor colorWithHexString:@"333333"];
        [pickerLabel setFont:[UIFont systemFontOfSize:15]];
    }
    if (component == 0) {
        pickerLabel.text = [self.dataArray objectAtIndex:row];
        
    }else {
        if ([self.dataArray2.firstObject isKindOfClass:[NSArray class]]) {
            pickerLabel.text = [[self.dataArray2 objectAtIndex:self.selectRow1] objectAtIndex:row];
        }else {
            if (self.isDate) {
                
                if ( (self.needCurrentMonth && self.selectRow1 == self.dataArray.count - 1) || (self.special && self.selectRow1 == self.dataArray.count - 2)) {
                    pickerLabel.text = [self.currentYearMonth objectAtIndex:row];
                }else {
                    
                    pickerLabel.text = [self.dataArray2 objectAtIndex:row];
                }
            }else {
                pickerLabel.text = [self.dataArray2 objectAtIndex:row];

            }
        }
    }
    [self clearSpearatorLine:pickerView];
    return pickerLabel;
}

- (void)clearSpearatorLine:(UIPickerView *)pickerView
{
    for(UIView *subView2 in pickerView.subviews)
    {
        if (subView2.frame.size.height < 1)//取出分割线view
        {
            subView2.hidden = YES;//隐藏分割线
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectRow1 = row;
        if ([self.dataArray2.firstObject isKindOfClass:[NSArray class]]) {
            self.selectRow2 = 0;
            [self.pickerView selectRow:0 inComponent:1 animated:NO];
            [self.pickerView reloadComponent:1];
        }else {
            if (self.isDate) {
                if (row == 0) {
                    self.dataArray2 = @[@"月"];
                }else {
                    self.dataArray2 = self.monthArray;
                }
                
                if (self.special ) {
                    if (self.dataArray.count - 1 == row) {
                        self.selectRow2 = 0;
                        self.row2Count = 0;
                        
                    }else if (self.dataArray.count - 2 == row){
                        self.selectRow2 = 0;
                        self.row2Count = self.currentYearMonth.count;
                        [self.pickerView selectRow:0 inComponent:1 animated:NO];
                    }else {
                        self.selectRow2 = 0;
                        self.row2Count = self.dataArray2.count;
                    }
                    
                }else if (self.needCurrentMonth) {
                    if (self.dataArray.count - 1 == row) {
                        self.selectRow2 = 0;
                        self.row2Count = self.currentYearMonth.count;
                        [self.pickerView selectRow:0 inComponent:1 animated:NO];
                    }else {
                        self.selectRow2 = 0;
                        self.row2Count = self.dataArray2.count;
                    }
                }else {
                    self.selectRow2 = 0;
                    self.row2Count = self.dataArray2.count;
                }
                [self.pickerView reloadComponent:1];
            }
        }
    }else {
        self.selectRow2 = row;
    }
}

- (void)setSubviews {
    UIView *grayView = [[UIView alloc]initWithFrame:self.bounds];
    grayView.backgroundColor = [UIColor blackColor];
    grayView.alpha = .5;
    [self addSubview:grayView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeBtnClick:)];
    [grayView addGestureRecognizer:tap];
    
    
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.contentViewHeight * (SCREEN_WIDTH / 375.0))];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.contentView];
    
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 0, SCREEN_WIDTH - 140, 55 * (SCREEN_WIDTH / 375.0))];
    
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor colorWithHexString:@"111111"];
    self.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.titleLabel];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 55 * (SCREEN_WIDTH / 375.0), SCREEN_WIDTH, SCREEN_HEIGHT)];
    line.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:line];
    
    self.pickerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.pickerView];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, (self.contentViewHeight - 55)/2 - 24.5 + 55, SCREEN_WIDTH, SCREEN_HEIGHT)];
    line1.backgroundColor= [UIColor colorWithHexString:@"dcdcdc"];
    line1.tag = 20000;
    [self.contentView addSubview:line1];
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(.5);
        make.width.mas_equalTo(300 * (SCREEN_WIDTH / 375.0));
        make.centerY.mas_equalTo(self.pickerView.mas_centerY).offset(-22.5);
    }];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, (self.contentViewHeight - 55)/2 + 20.5 + 55, SCREEN_WIDTH, 0)];
    line2.backgroundColor= [UIColor colorWithHexString:@"dcdcdc"];
    line2.tag = 20001;
    [self.contentView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(.5);
        make.width.mas_equalTo(300 * (SCREEN_WIDTH / 375.0));
        make.centerY.mas_equalTo(self.pickerView.mas_centerY).offset(22.5);
    }];
    
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 55, self.contentView.width, 0.5)];
    topLine.backgroundColor = [UIColor colorWithHex:0xCCCCCC];
    [self.contentView addSubview:topLine];
    [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.contentView);
        make.height.mas_equalTo(.5);
        make.width.mas_equalTo(self.contentView.width);
        make.top.mas_equalTo(self.contentView).offset(line.y);
    }];
    
    UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectBtn.frame = CGRectMake(SCREEN_WIDTH - 50, 0, 50 , 55 * (SCREEN_WIDTH / 375.0));
    [selectBtn setImage:[UIImage imageNamed:@"pc_queren"] forState:UIControlStateNormal];
    [selectBtn addTarget:self action:@selector(selectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:selectBtn];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 0, 50, 55 * (SCREEN_WIDTH / 375.0));
    [closeBtn setImage:[UIImage imageNamed:@"pc_guanbi"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:closeBtn];
}
- (void)closeBtnClick:(UIButton *)btn {
    [self hide];
}

- (void)selectBtnClick:(UIButton *)btn {
    NSInteger row1 = NSNotFound;
    NSInteger row2 = NSNotFound;
    row1 = [self.pickerView selectedRowInComponent:0];
    if (self.sections == 2) {
        row2 = [self.pickerView selectedRowInComponent:1];
    }    
    if (self.isDate) {
        NSDate *date = [NSDate date];
        NSString *yearStr = self.dataArray[row1];
        NSString *monthStr = self.dataArray2[row2];
        if (_needCompareDate && date.year <= yearStr.integerValue && date.month < monthStr.integerValue) {
            return;
        }        
    }
    
    [self hide];
    
    if (self.block) {
        self.block(row1, row2);
    }
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        CGFloat height = self.contentViewHeight - (isIPhoneXSeries() ? 70 : 50);
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(15, 50 * (SCREEN_WIDTH / 375.0), SCREEN_WIDTH - 30, height * (SCREEN_WIDTH / 375.0) )];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated{
    row = row < 0?0:row;
    
    [self.pickerView selectRow:row inComponent:component animated:animated];
}

@end

