//
//  MZSnackBar.m
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 30..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#define CGRectSetY(rect, newY) CGRectMake(rect.origin.x, newY, rect.size.width, rect.size.height)

#import "MZSnackBar.h"

#import "UIColor+OPTheme.h"
#import "UIFont+OPTheme.h"

static const CGFloat MZSnackBarHorizontalMargin = 5.0f;

@interface MZSnackBar ()

@property (nonatomic) BOOL isWaiting;

@end

@implementation MZSnackBar

#pragma mark - Initialize

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.origin.y = frame.size.height - MZSnackBarHeight;
    frame.size.height = MZSnackBarHeight;
    
    self = [super initWithFrame:frame];
    if (self) {
        _messageLabel = [[UILabel alloc] init];
        _cancelButton = [[UIButton alloc] init];
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        
        _message = @"";
        _type = MZSnackBarTypeAlert;
        
        _waitingDurationForDisappear = 2.0f;
        _duration = .35f;
        
        _isWaiting = NO;
        
        [self initalize];
        
        [self addSubview:_messageLabel];
        [self addSubview:_cancelButton];
        [self addSubview:_indicatorView];
        
        self.backgroundColor = [UIColor op_snackBarColor];
    }
    return self;
}

- (void)initalize
{
    _messageLabel.frame = CGRectMake(MZSnackBarHorizontalMargin, 0, self.frame.size.width - MZSnackBarHorizontalMargin*2 - 40.0f, MZSnackBarHeight);
    _messageLabel.textAlignment = NSTextAlignmentLeft;
    _messageLabel.textColor = [UIColor op_textPrimary];
    _messageLabel.adjustsFontSizeToFitWidth = YES;
    _messageLabel.numberOfLines = 0;
    _messageLabel.font = [UIFont op_primary];
    
    _cancelButton.frame = CGRectMake(self.frame.size.width - MZSnackBarHorizontalMargin - 40.0f, 0, 40.0f, MZSnackBarHeight);
    _cancelButton.titleLabel.font = [UIFont op_primary];
    [_cancelButton setTitle:@"확인" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor op_textSecondary] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelSnackBar:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Properties

- (void)setMessage:(NSString *)message
{
    _messageLabel.text = message;
}

#pragma mark - Action

- (void)cancelSnackBar:(UIButton *)button
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(automaticallyDisappear) object:nil];
    [self animateToDisappearWithCompletion:nil];
}

- (void)automaticallyDisappear
{
    [self animateToDisappearWithCompletion:nil];
}

#pragma mark - Transition

- (void)animateToAppearInView:(UIView *)view
{
    MZSnackBarAnimationCompletion handler = ^(BOOL finished)
    {
        [view addSubview:self];
        
        _isWaiting = YES;
        [self performSelector:@selector(automaticallyDisappear) withObject:nil afterDelay:_waitingDurationForDisappear+_duration];
        
        self.frame = CGRectSetY(self.frame, view.frame.size.height + MZSnackBarHeight);
        [UIView animateWithDuration:_duration animations:^{
            self.frame = CGRectSetY(self.frame, view.frame.size.height - MZSnackBarHeight);
        }];
    };
    
    if (_isWaiting) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(automaticallyDisappear) object:nil];
        [self animateToDisappearWithCompletion:handler];
    } else {
        handler(NO);
    }
}

- (void)animateToDisappearWithCompletion:(MZSnackBarAnimationCompletion)completion
{
    if (_isWaiting) {
        _isWaiting = NO;
    } else {
        return;
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        self.frame = CGRectSetY(self.frame, self.frame.origin.y + MZSnackBarHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion(finished);
        }
    }];
}

@end
