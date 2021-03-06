//
//  AuthcodeView.m
//  identifyingCodeDemo
//
//  Created by weiguang on 16/9/6.
//  Copyright © 2016年 weiguang. All rights reserved.
//

#define kRandomColor  [UIColor colorWithRed:arc4random() % 256 / 256.0 green:arc4random() % 256 / 256.0 blue:arc4random() % 256 / 256.0 alpha:1.0]
#define kLineCount 6
#define kLineWidth 1.0
#define kCharCount 4
#define kFontSize [UIFont systemFontOfSize:arc4random() % 10 + 12]


#import "AuthcodeView.h"

@interface AuthcodeView()

@property (nonatomic,strong) NSArray *dataArray;

@end


@implementation AuthcodeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self)     {
        self.layer.cornerRadius = 5.0f;
        self.layer.masksToBounds = YES;
        self.backgroundColor = kRandomColor;
       // [self getAuthcode]; // 本地获得随机验证码
        [self getCodeNetwork]; // 网络获取验证码
    }
    return self;
}

#pragma mark 获得随机验证码
- (void)getAuthcode {
    //字符串素材
    _dataArray = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",nil];
    _authCodeStr = [[NSMutableString alloc] initWithCapacity:kCharCount];    //随机从数组中选取需要个数的字符串，拼接为验证码字符串
    for (int i = 0; i < kCharCount; i++) {
        NSInteger index = arc4random() % (_dataArray.count-1);
        NSString *tempStr = [_dataArray objectAtIndex:index];
        _authCodeStr = (NSMutableString *)[_authCodeStr stringByAppendingString:tempStr];
    }
}

- (void)getCodeNetwork {
    
    NSDictionary *pram = @{@"type" : @"register"};
    [KZNetworkManager POST:@"api/getAuthCode" parameters:pram completeHandler:^(id responseObject, NSError *error) {
        
        NSLog(@"%@",responseObject);
        if (error == nil && [responseObject isKindOfClass:[NSDictionary class]]) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.authCodeStr = [[NSMutableString alloc] initWithCapacity:kCharCount];
                self.authCodeStr = (NSMutableString *)responseObject[@"authCode"];
                [self setNeedsDisplay];
            });
            
        }else {
            [self.superview makeToast:error.domain];
        }
    }];
}

#pragma mark 点击界面切换验证码
-(void)refreshCode {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self getCodeNetwork];
    //setNeedsDisplay调用drawRect方法来实现view的绘制
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self refreshCode];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    self.backgroundColor = kRandomColor;  //设置随机背景颜色
    NSString *text = [NSString stringWithFormat:@"%@",_authCodeStr];
    //根据要显示的验证码字符串，根据长度，计算每个字符串显示的位置
    CGSize cSize = [@"W" sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20]}];
    
    int width = rect.size.width/text.length - cSize.width;
    int height = rect.size.height - cSize.height;
    
    CGPoint point;
    float pX,pY;
    //依次绘制每一个字符,可以设置显示的每个字符的字体大小、颜色、样式等
    for ( int i = 0; i<text.length; i++) {
        pX = arc4random() % width + rect.size.width/text.length * i;
        pY = arc4random() % height;
        point = CGPointMake(pX, pY);
        unichar c = [text characterAtIndex:i];
        NSString *textC = [NSString stringWithFormat:@"%C", c];
        UILabel *tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(pX, pY, cSize.width, cSize.height)];
        tempLabel.backgroundColor = [UIColor clearColor];
        tempLabel.textColor = kRandomColor;
        tempLabel.text = textC;
        tempLabel.font = kFontSize;
        
        float random = [self getRandomNumber:-100 to:100]/100.0;
        tempLabel.transform = CGAffineTransformMakeRotation(random);
        [self addSubview:tempLabel];
        
        //直接把文字画出来的方法
        //NSDictionary * dic = @{NSFontAttributeName:kFontSize,
//                               NSForegroundColorAttributeName:kRandomColor};
        //[textC drawAtPoint:point withAttributes:dic];
    }
    
    //调用drawRect：之前，系统会向栈中压入一个CGContextRef，调用UIGraphicsGetCurrentContext()会取栈顶的CGContextRef
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, kLineWidth);  //设置线条宽度
    for (int i = 0; i < kLineCount; i++) {       //绘制干扰线
        UIColor *color = kRandomColor;
        CGContextSetStrokeColorWithColor(context, color.CGColor);//设置线条填充色
        //设置线的起点
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextMoveToPoint(context, pX, pY);        //设置线终点
        pX = arc4random() % (int)rect.size.width;
        pY = arc4random() % (int)rect.size.height;
        CGContextAddLineToPoint(context, pX, pY);     //画线
        CGContextStrokePath(context);
    }
}

-(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to - from + 1)));
}

@end
