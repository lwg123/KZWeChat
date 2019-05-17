//
//  KZCardView.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/25.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZCardView.h"

@implementation KZCardView

- (instancetype)initWithFrame:(CGRect)frame user:(KZUser *)user
{
    self = [super initWithFrame:frame];
    if (self) {
        _user = user;
       
    }
    return self;
}



@end
