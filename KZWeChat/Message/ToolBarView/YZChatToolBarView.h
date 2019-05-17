//
//  YZChatToolBarView.h
//  XMPPChat
//
//  Created by weiguang on 14-4-1.
//  Copyright (c) 2014年 weiguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  YZChatToolBarDeleagte <NSObject>

- (void)YZChatTextViewDidSend:(NSString*)text;

@end

@interface YZChatToolBarView : UIView
/*!
 *
 */
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) id<YZChatToolBarDeleagte> delegate;
@end
