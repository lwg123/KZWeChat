//
//  KZMeaageCell.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/18.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZMeaageCell.h"

@implementation KZMeaageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //  首先添加一个view
        self.myContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
        self.myContentView.backgroundColor = [UIColor whiteColor];
        self.myContentView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.myContentView];
        
        self.deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteBtn setFrame:CGRectMake(SCREEN_WIDTH-CellBtnWidth, 0, CellBtnWidth, self.myContentView.height)];
        self.deleteBtn.backgroundColor = RGB(0xff, 0x61, 0x5d);
        [self.deleteBtn setTitle:@"取消配对" forState:UIControlStateNormal];
        self.deleteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        self.deleteBtn.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.deleteBtn];
        [self.contentView sendSubviewToBack:self.deleteBtn];
        
        UIView *separtor = [[UIView alloc]initWithFrame:CGRectMake(0, self.myContentView.height - 0.5, SCREEN_WIDTH, 0.5)];
        separtor.backgroundColor = RGB(238, 238, 244);
        [self.myContentView addSubview:separtor];
        
        self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
        [self.swipeLeft setNumberOfTouchesRequired:1];
        [self.swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self.myContentView addGestureRecognizer:self.swipeLeft];
        
        self.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
        [self.swipeRight setNumberOfTouchesRequired:1];
        [self.swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.myContentView addGestureRecognizer:self.swipeRight];
        
        
        _headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 0, 60, 60)];
        _headerImageView.centerY = self.myContentView.height/2.0;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.cornerRadius = _headerImageView.height/2;
        
        [self.myContentView addSubview:_headerImageView];
        
        
        _nameLab = [[UILabel alloc] initWithFrame:CGRectMake(_headerImageView.maxX+10, 15, 200, 20)];
        _nameLab.font = [UIFont systemFontOfSize:20.0];
        _nameLab.textColor = [UIColor blackColor];
        //_nameLab.backgroundColor = [UIColor orangeColor];
        [self.myContentView addSubview:_nameLab];
        
        _messageLab = [[UILabel alloc] initWithFrame:CGRectMake(_headerImageView.maxX+10, _nameLab.maxY+10, 180, 14)];
        _messageLab.font = [UIFont systemFontOfSize:14.0];
        _messageLab.textColor = [UIColor lightGrayColor];
       // _messageLab.backgroundColor = [UIColor orangeColor];
        [self.myContentView addSubview:_messageLab];
        
        _sendTimeLab = [[UILabel alloc] initWithFrame:CGRectMake(_myContentView.width - 100, _messageLab.y, 90, 14)];
        _sendTimeLab.font = [UIFont systemFontOfSize:14.0];
        _sendTimeLab.textColor = [UIColor lightGrayColor];
       // _sendTimeLab.backgroundColor = [UIColor orangeColor];
        _sendTimeLab.textAlignment = NSTextAlignmentRight;
        [self.myContentView addSubview:_sendTimeLab];
        
    }
    
    return self;
}

- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    [self.headerImageView sd_setImageWithURL:infoDict[@"avatar"]];

    self.nameLab.text = infoDict[@"nickname"];
    self.messageLab.text = infoDict[@"message"]? infoDict[@"message"] : @"很高兴认识你";
    self.sendTimeLab.text = infoDict[@"sendTime"];
}



- (void)swipeLeft:(UISwipeGestureRecognizer *)tapGR{
    
    if ([self.delegate respondsToSelector:@selector(handleSwipeLeft:)])
    {
        [self.delegate handleSwipeLeft:self.swipeLeft];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)tapGR{
    
    if ([self.delegate respondsToSelector:@selector(handleSwipeRight:)])
    {
        [self.delegate handleSwipeRight:self.swipeRight];
    }
}


@end
