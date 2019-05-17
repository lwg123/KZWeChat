//
//  UIImage+Utils.m
//  DuiFuDao
//
//  Created by weiguang on 2018/7/25.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import "UIImage+Utils.h"

@implementation UIImage (Utils)

+ (UIImage *)imageWithColor:(UIColor *)color{
    return [self imageWithColor:color size:CGSizeMake(10, 10)];
}

+ (UIImage*)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)circleImageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width * 10.0, size.height * 10.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillEllipseInRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [UIImage imageWithData:UIImagePNGRepresentation(image) scale:10.0];
}

+ (UIImage *)imageWithColor:(UIColor *)color text:(NSString *)text size:(CGSize)size {
    //先创建放大一定倍数的画布，并在其上画圆、填色、写字，然后再缩放回原始比例，否则图片会模糊失真
    
    //放大倍数
    float ratio = 3.0;
    //得到ratio倍数的画布
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width * ratio, size.height * ratio);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //填充颜色（圆形）size.height=100时为个人信息页面头像，背景为白色
    if (size.height == 100) {
        UIColor * fillColor = [UIColor whiteColor];
        CGContextSetFillColorWithColor(context,fillColor.CGColor);
    } else {
        CGContextSetFillColorWithColor(context, [color CGColor]);
    }
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.width/2, 0, 2*M_PI, 0);
    CGContextDrawPath(context, kCGPathFill);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextSetShouldSmoothFonts(context, false);
    
    //得到当前画布的image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    [image drawAtPoint: CGPointZero];
    
    //设置文字属性
    CGFloat fontSize = 0;
    CGPoint onePint, twoPoint;
    if (size.height == 100) {
        fontSize = 30.0 * ratio;
        onePint = CGPointMake(rect.size.width/2-45, rect.size.height/2-50);
        twoPoint = CGPointMake(rect.size.width/2 - 90, rect.size.height/2-50);
    }
    else {
        fontSize = 10.0 * ratio;
        onePint = CGPointMake(rect.size.width/2-14, rect.size.height/2-16);
        twoPoint = CGPointMake(rect.size.width/2-29, rect.size.height/2-16);
    }
    //个人信息页面头像字体颜色
    UIColor *strokeColor = size.height == 100?color:[UIColor whiteColor];
    NSDictionary* dict = @{NSForegroundColorAttributeName: strokeColor,
                           NSFontAttributeName: [UIFont fontWithName:@"Arial" size:fontSize],
                           };
    //写文字
    if (text.length == 1) {
        [text drawAtPoint:onePint withAttributes:dict];
    }
    else if (text.length == 2) {
        [text drawAtPoint:twoPoint withAttributes:dict];
    }
    //得到写字后的image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //将newimage缩小至原始倍数返回
    return [UIImage imageWithData:UIImagePNGRepresentation(newImage) scale:ratio];
}

+ (UIImage *)image:(UIImage *)image Diameter:(CGFloat)diameter {
    //先创建image大小画布在其上裁减圆形，然后用image数据重新填充，最后将图片缩放到需要的比例
    //如不如此，则在uitableviewcell显示时会由于刷新问题无法将图片调整为圆形
    
    //创建image大小的画布
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    //裁减image（圆形）
    CGPathAddEllipseInRect(path, NULL, CGRectMake(0, 0, image.size.width, image.size.height));
    CGContextAddPath(context, path);
    CGContextClip(context);
    
    //绘制(如不加前两方法则绘制出的图片反向)
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage);
    
    //得到newimage
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    CFRelease(path);
    UIGraphicsEndImageContext();
    
    //缩放比例
    if (diameter == 0) {
        //0则为原始比例
        diameter = 1.0;
    }
    float ratio = newImage.size.height/diameter;
    return [UIImage imageWithData:UIImagePNGRepresentation(newImage) scale:ratio];
}

- (UIImage*)scaleToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage * result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  result;
}

- (UIImage *)circleImage{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0); // NO代表透明

    //获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //添加一个圆
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    
    //裁剪
    CGContextClip(ctx);
    
    //将图片画上去
    [self drawInRect:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

// 根据图片url获取图片尺寸
+(void)getImageSizeWithURL:(id)imageURL complete:(void(^)(CGSize imageSize))complete{
    NSURL* URL = nil;
    if([imageURL isKindOfClass:[NSURL class]]){
        URL = imageURL;
    }
    if([imageURL isKindOfClass:[NSString class]]){
        URL = [NSURL URLWithString:imageURL];
    }
    if(URL == nil)
        complete(CGSizeZero);                  // url不正确返回CGSizeZero
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
    [request setTimeoutInterval:1];
    NSString* pathExtendsion = [URL.pathExtension lowercaseString];
    
    CGSize size = CGSizeZero;
    if([pathExtendsion isEqualToString:@"png"]){
        size =  [self getPNGImageSizeWithRequest:request];
    }
    else if([pathExtendsion isEqual:@"gif"])
    {
        size =  [self getGIFImageSizeWithRequest:request];
    }
    else{
        size = [self getJPGImageSizeWithRequest:request];
    }
    if(CGSizeEqualToSize(CGSizeZero, size))                    // 如果获取文件头信息失败,发送异步请求请求原图
    {
        NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
        UIImage* image = [UIImage imageWithData:data];
        if(image)
        {
            size = image.size;
        }
    }
    
    complete(size);
}

//  获取PNG图片的大小
+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=16-23" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 8)
    {
        int w1 = 0, w2 = 0, w3 = 0, w4 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        [data getBytes:&w3 range:NSMakeRange(2, 1)];
        [data getBytes:&w4 range:NSMakeRange(3, 1)];
        int w = (w1 << 24) + (w2 << 16) + (w3 << 8) + w4;
        int h1 = 0, h2 = 0, h3 = 0, h4 = 0;
        [data getBytes:&h1 range:NSMakeRange(4, 1)];
        [data getBytes:&h2 range:NSMakeRange(5, 1)];
        [data getBytes:&h3 range:NSMakeRange(6, 1)];
        [data getBytes:&h4 range:NSMakeRange(7, 1)];
        int h = (h1 << 24) + (h2 << 16) + (h3 << 8) + h4;
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

//  获取gif图片的大小
+(CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=6-9" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(data.length == 4)
    {
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0, 1)];
        [data getBytes:&w2 range:NSMakeRange(1, 1)];
        short w = w1 + (w2 << 8);
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(2, 1)];
        [data getBytes:&h2 range:NSMakeRange(3, 1)];
        short h = h1 + (h2 << 8);
        return CGSizeMake(w, h);
    }
    return CGSizeZero;
}

//  获取jpg图片的大小
+(CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request
{
    [request setValue:@"bytes=0-209" forHTTPHeaderField:@"Range"];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    if ([data length] <= 0x58) {
        return CGSizeZero;
    }
    
    if ([data length] < 210) {// 肯定只有一个DQT字段
        short w1 = 0, w2 = 0;
        [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
        [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
        short w = (w1 << 8) + w2;
        short h1 = 0, h2 = 0;
        [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
        [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
        short h = (h1 << 8) + h2;
        return CGSizeMake(w, h);
    } else {
        short word = 0x0;
        [data getBytes:&word range:NSMakeRange(0x15, 0x1)];
        if (word == 0xdb) {
            [data getBytes:&word range:NSMakeRange(0x5a, 0x1)];
            if (word == 0xdb) {// 两个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0xa5, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0xa6, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0xa3, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0xa4, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            } else {// 一个DQT字段
                short w1 = 0, w2 = 0;
                [data getBytes:&w1 range:NSMakeRange(0x60, 0x1)];
                [data getBytes:&w2 range:NSMakeRange(0x61, 0x1)];
                short w = (w1 << 8) + w2;
                short h1 = 0, h2 = 0;
                [data getBytes:&h1 range:NSMakeRange(0x5e, 0x1)];
                [data getBytes:&h2 range:NSMakeRange(0x5f, 0x1)];
                short h = (h1 << 8) + h2;
                return CGSizeMake(w, h);
            }
        } else {
            return CGSizeZero;
        }
    }
}

// 缩小图片到限制大小
- (NSData *)compressImageDataWithMaxBytes:(NSUInteger)bytes
{
    CGFloat curRatio = 1.0;
    NSData *compressImageData = UIImageJPEGRepresentation(self, curRatio);
    NSUInteger curBytes = [compressImageData length];
    
    curRatio = (CGFloat)bytes / curBytes;
    
    while (true) {
        if (curBytes <= bytes) {
            return compressImageData;
        }
        if (curRatio <= 0) {
            compressImageData = UIImageJPEGRepresentation(self, 0.0);
            curBytes = [compressImageData length];
            if (curBytes <= bytes) {
                return compressImageData;
            }
            else {
                return nil;
            }
        }
        else {
            compressImageData = UIImageJPEGRepresentation(self, curRatio);
            curBytes = [compressImageData length];
            
            curRatio -= 0.05;
        }
    }
    
    return nil;
}

-(UIImage *)removeBackground
{
    
    // 分配内存
    const int imageWidth = self.size.width;
    
    const int imageHeight = self.size.height;
    
    size_t bytesPerRow = imageWidth * 4;
    
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    
    
    
    // 创建context
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    
    // 遍历像素
    
    int pixelNum = imageWidth * imageHeight;
    
    uint32_t* pCurPtr = rgbImageBuf;
    
    for (int i = 0; i < pixelNum; i++, pCurPtr++)
        
    {
        
        //接近粉色
        
        //将像素点转成子节数组来表示---第一个表示透明度即ARGB这种表示方式。ptr[0]:透明度,ptr[1]:R,ptr[2]:G,ptr[3]:B
        
        //分别取出RGB值后。进行判断需不需要设成透明。
        
        uint8_t* ptr = (uint8_t*)pCurPtr;
        // NSLog(@"1是%d,2是%d,3是%d",ptr[1],ptr[2],ptr[3]);
        if(ptr[1] >= 200 || ptr[2] >= 200 || ptr[3] >= 200){
            ptr[0] = 0;
        }
    }
    
    // 将内存转成image
    
    CGDataProviderRef dataProvider =CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, nil);
    
    
    
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight,8, 32, bytesPerRow, colorSpace,
                                        
                                        kCGImageAlphaLast |kCGBitmapByteOrder32Little, dataProvider,
                                        
                                        NULL, true,kCGRenderingIntentDefault);
    
    
    CGDataProviderRelease(dataProvider);
    
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    
    // 释放
    
    CGImageRelease(imageRef);
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

- (UIImage *)changeImageColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
