//
//  KZUser.m
//  KZWeChat
//
//  Created by weiguang on 2019/4/21.
//  Copyright © 2019 duia. All rights reserved.
//

#import "KZUser.h"

@implementation KZUser

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.user_id = [dict objectForKey:@"user_id"];
        self.username = dict[@"username"];
        self.avatar = dict[@"avatar"];
        self.birthday = dict[@"birthday"];
        self.declaration = dict[@"declaration"];
        self.is_auth = dict[@"is_auth"];
        self.is_lock = dict[@"is_lock"];
        self.is_message = dict[@"is_message"];
        self.nickname = dict[@"nickname"];
        self.sex = dict[@"sex"];
        self.video = dict[@"video"];
        self.age = dict[@"age"];
        self.videoImage = dict[@"videoImage"];
        //  举报用
        self.video_id = dict[@"video_id"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.user_id forKey:@"user_id"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.birthday forKey:@"birthday"];
    [aCoder encodeObject:self.declaration forKey:@"declaration"];
    [aCoder encodeObject:self.is_auth forKey:@"is_auth"];
    [aCoder encodeObject:self.is_lock forKey:@"is_lock"];
    [aCoder encodeObject:self.is_message forKey:@"is_message"];
    [aCoder encodeObject:self.nickname forKey:@"nickname"];
    [aCoder encodeObject:self.sex forKey:@"sex"];
    [aCoder encodeObject:self.video forKey:@"video"];
    [aCoder encodeObject:self.age forKey:@"age"];
    [aCoder encodeObject:self.videoImage forKey:@"videoImage"];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.user_id = [aDecoder decodeObjectForKey:@"user_id"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.birthday = [aDecoder decodeObjectForKey:@"birthday"];
        
        self.declaration = [aDecoder decodeObjectForKey:@"declaration"];
        self.is_auth = [aDecoder decodeObjectForKey:@"is_auth"];
        self.is_lock = [aDecoder decodeObjectForKey:@"is_lock"];
        self.is_message = [aDecoder decodeObjectForKey:@"is_message"];
        self.nickname = [aDecoder decodeObjectForKey:@"nickname"];
        self.sex = [aDecoder decodeObjectForKey:@"sex"];
        self.video = [aDecoder decodeObjectForKey:@"video"];
        self.age = [aDecoder decodeObjectForKey:@"age"];
        self.videoImage = [aDecoder decodeObjectForKey:@"videoImage"];
    }
    return self;
}

@end
