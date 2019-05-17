//
//  UIImage+Utils.h
//  DuiFuDao
//
//  Created by weiguang on 2018/7/25.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import <UIKit/UIKit.h>

// 生成不同类型的image
@interface UIImage (Utils)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)circleImageWithColor:(UIColor *)color
                             size:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color
                       text:(NSString*)text
                       size:(CGSize)size;


+ (UIImage *)image:(UIImage *)image
          Diameter:(CGFloat)diameter;


/**
 保存为特定size的图片

 @param newSize 图片的size
 @return 返回的图片
 */
- (UIImage*)scaleToSize:(CGSize)newSize;

/**
 * 圆形图片
 */
- (UIImage *)circleImage;

// 根据图片url获取图片尺寸
+(void)getImageSizeWithURL:(id)imageURL complete:(void(^)(CGSize imageSize))complete;

// 缩小图片到限制大小
- (NSData *)compressImageDataWithMaxBytes:(NSUInteger)bytes;

/**
 去除图片背景
 
 @return 修改之后的图片对象
 */
- (UIImage *)removeBackground;

/**
 修改图片颜色

 @param color 颜色
 @return 修改后的图片
 */
- (UIImage *)changeImageColor:(UIColor *)color;
@end
