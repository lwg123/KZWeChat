//
//  KZRecordBtn.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/10.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZRecordBtn.h"

@implementation KZRecordBtn


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setupRoundButton];
        self.layer.cornerRadius = self.bounds.size.width/2;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setupRoundButton {
    self.backgroundColor = [UIColor clearColor];
    
    CGFloat width = self.frame.size.width;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:width/2];
    
    CAShapeLayer *trackLayer = [CAShapeLayer layer];
    trackLayer.frame = self.bounds;
    trackLayer.strokeColor = kzThemeTineColor.CGColor;
    trackLayer.fillColor = [UIColor clearColor].CGColor;
    trackLayer.opacity = 1.0;
    trackLayer.lineCap = kCALineCapRound;
    trackLayer.lineWidth = 2.0;
    trackLayer.path = path.CGPath;
    [self.layer addSublayer:trackLayer];
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = @"按住拍";
    textLayer.frame = CGRectMake(0, 0, 120, 30);
    textLayer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    UIFont *font = [UIFont boldSystemFontOfSize:22];
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    CGFontRelease(fontRef);
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    textLayer.foregroundColor = kzThemeTineColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.wrapped = YES;
    [trackLayer addSublayer:textLayer];
    
    CAGradientLayer *gradLayer = [CAGradientLayer layer];
    gradLayer.frame = self.bounds;
    gradLayer.colors = [KZUtils gradualColors];
    [self.layer addSublayer:gradLayer];
    
    gradLayer.mask = trackLayer;
    
    
}

@end
