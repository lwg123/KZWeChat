//
//  KZUser.h
//  KZWeChat
//
//  Created by weiguang on 2019/4/21.
//  Copyright © 2019 duia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KZUser : NSObject<NSCoding>
@property (nonatomic,strong) NSString *user_id;
@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *avatar;
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *declaration;
@property (nonatomic,strong) NSString *nickname;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *video;
@property (nonatomic,strong) NSString *age;
@property (nonatomic,strong) NSString *videoImage;

@property (nonatomic,strong) NSString *is_auth;
@property (nonatomic,strong) NSString *is_lock;
@property (nonatomic,strong) NSString *is_message;

@property (nonatomic, strong) NSString *video_id;

- (instancetype)initWithDict:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END
