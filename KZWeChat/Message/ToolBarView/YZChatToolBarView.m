//
//  YZChatToolBarView.m
//  XMPPChat
//
//  Created by weiguang on 14-4-1.
//  Copyright (c) 2014年 weiguang. All rights reserved.
//

#import "YZChatToolBarView.h"
#import <QuartzCore/QuartzCore.h>


@interface YZChatToolBarView() <UITextViewDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UITextView *msgTextView;
@property (nonatomic, strong) UIView *toolBarView;

@property (nonatomic, assign) BOOL isKeyboardShow;
@property (nonatomic, assign) BOOL isFaceBoardShow;
@property (nonatomic, assign) BOOL isToolBoxShow;

@end

@implementation YZChatToolBarView
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self initToolBarView];
        [self registerNotification];
    }
    return self;
}


- (void)registerNotification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)initToolBarView
{
    _toolBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    _toolBarView.autoresizesSubviews = YES;

    UIImageView *toolBarBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    toolBarBgImageView.image = [[UIImage imageWithColor:RGB(243, 247, 248)]stretchableImageWithLeftCapWidth:5 topCapHeight:25];
    toolBarBgImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_toolBarView addSubview:toolBarBgImageView];
    

    // 消息文本
    _msgTextView = [[UITextView alloc]initWithFrame:CGRectMake(10, 8, SCREEN_WIDTH - 100, 34)];
    _msgTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _msgTextView.layer.borderColor = [[UIColor colorWithWhite:.8 alpha:1.0] CGColor];
    _msgTextView.layer.borderWidth = 0.65f;
    _msgTextView.layer.cornerRadius = 6.0f;
    _msgTextView.scrollEnabled = YES;
    _msgTextView.scrollsToTop = NO;
    _msgTextView.userInteractionEnabled = YES;
    _msgTextView.textColor = [UIColor blackColor];
    _msgTextView.font = [UIFont systemFontOfSize:14.0f];
    _msgTextView.returnKeyType = UIReturnKeySend;
    _msgTextView.delegate = self;
    [_toolBarView addSubview:_msgTextView];
    
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 0, 55, 30)];
    sendBtn.centerY = _msgTextView.centerY;
    [sendBtn setBackgroundImage:[UIImage imageWithColor:kzNavColor] forState:UIControlStateNormal];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    sendBtn.layer.masksToBounds = YES;
    sendBtn.layer.cornerRadius = 5.0;
    [_toolBarView addSubview:sendBtn];
    
    [self addSubview:_toolBarView];
}


- (void)sendBtnClick {
    // 如果文本长度不为0，则发送文本
    if (_msgTextView.text.length > 0 && _delegate &&
        [_delegate respondsToSelector:@selector(YZChatTextViewDidSend:)])
    {
        [_delegate YZChatTextViewDidSend:_msgTextView.text];
    }
    _msgTextView.text = nil;
    [self resizeTextView];
}

- (CGFloat)offsetOfScrollView:(UIScrollView*)scrollView keyBoardHeight:(CGFloat)height
{
    CGFloat result = scrollView.frame.size.height - scrollView.contentSize.height;
    result = result > 0 ? result : 0;
    CGFloat offset = fabs(height) - result;
    offset = offset > 0 ? offset : 0;
    return offset;
}


#pragma mark keyBoardNotification

- (void)keyBoardWillShow:(NSNotification *)notify
{
    CGRect keyboardRect = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat transY = - keyboardRect.size.height;
    kWeakSelf(self);
    [UIView animateWithDuration:duration
                     animations:^{
                         
                         CGFloat offset = [self offsetOfScrollView:self->_scrollView keyBoardHeight:transY];
                         weakself.scrollView.transform = CGAffineTransformMakeTranslation(0, -offset);
                         self.transform = CGAffineTransformMakeTranslation(0, transY);
                     }];
}


- (void)keyBoardWillHide:(NSNotification *)notify
{
    
    [UIView animateWithDuration:.35
                     animations:^{
                         
                         CGFloat offset = [self offsetOfScrollView:self->_scrollView keyBoardHeight:216];
                         self->_scrollView.transform = CGAffineTransformMakeTranslation(0, -offset);
                         self.transform = CGAffineTransformMakeTranslation(0, -216);
                     }];
    return;
    
    if (!_isToolBoxShow && !_isFaceBoardShow)
    {
        double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration
                         animations:^{
                             
                             self->_scrollView.transform = CGAffineTransformIdentity;
                             self.transform = CGAffineTransformIdentity;
                         }];
    }
    else if (_isFaceBoardShow )
    {
        [UIView animateWithDuration:.35
                         animations:^{
                           
                             CGFloat offset = [self offsetOfScrollView:self->_scrollView keyBoardHeight:216];
                             self->_scrollView.transform = CGAffineTransformMakeTranslation(0, -offset);
                             self.transform = CGAffineTransformMakeTranslation(0, -216);
                         }];
    }
    else if (_isToolBoxShow)
    {
        [UIView animateWithDuration:.35
                         animations:^{
                           
                             CGFloat offset = [self offsetOfScrollView:self->_scrollView keyBoardHeight:216];
                             self->_scrollView.transform = CGAffineTransformMakeTranslation(0, -offset);
                             self.transform = CGAffineTransformMakeTranslation(0, -216);
                         }];
    }
    
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    _isKeyboardShow = YES;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.length != 1 && [text isEqualToString:@"\n"])
    {
        // 如果文本长度不为0，则发送文本
        if (textView.text.length > 0 && _delegate &&
            [_delegate respondsToSelector:@selector(YZChatTextViewDidSend:)])
        {
            [_delegate YZChatTextViewDidSend:textView.text];
        }
        textView.text = nil;
        [self resizeTextView];
        return NO;
    }
    return YES;
}

- (void)resizeTextView
{
    CGFloat span =  _toolBarView.frame.size.height - 50;
    if (span != 0)
    {
        CGRect toolBarViewFrame = _toolBarView.frame;
        toolBarViewFrame.size = CGSizeMake(SCREEN_WIDTH, 50);
        _toolBarView.frame = toolBarViewFrame;
        
        CGRect sRect = self.frame;
        sRect.size.height -= span;
        sRect.origin.y += span ;
        self.frame = sRect;
    }
}


- (void)textViewDidChange:(UITextView *)textView
{
    CGSize size = textView.contentSize;
    if (size.height < 34)
    {
        size.height = 34;
    }
    
    if (size.height >= 84)
    {
        size.height = 84;
    }
    
    if (size.height != textView.frame.size.height)
    {
        CGFloat span = size.height - textView.frame.size.height;
        
        CGRect toolBarViewFrame = _toolBarView.frame;
        toolBarViewFrame.size = CGSizeMake(SCREEN_WIDTH, size.height + 16);
        _toolBarView.frame = toolBarViewFrame;
        
        CGRect sRect = self.frame;
        sRect.size.height += span;
        sRect.origin.y -= span ;
        self.frame = sRect;
    }
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.bounds, point))
    {
        return YES;
    }
    else
    {
        [self endEditing:YES];
        [UIView animateWithDuration:.35
                         animations:^{
                             self->_scrollView.transform = CGAffineTransformIdentity;
                             self.transform = CGAffineTransformIdentity;
                         }completion:^(BOOL finished) {
                             
                             
                         }];
        
        _isKeyboardShow = NO;
        
        return NO;
    }

}

@end
