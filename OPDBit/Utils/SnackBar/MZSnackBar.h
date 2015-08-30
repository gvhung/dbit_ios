//
//  MZSnackBar.h
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 30..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat MZSnackBarHeight = 60.0f;

typedef void (^MZSnackBarAnimationCompletion)(BOOL finished);

typedef NS_ENUM(NSInteger, MZSnackBarType){
    MZSnackBarTypeAlert = 0,    // default
    MZSnackBarTypeProgress
};

@interface MZSnackBar : UIView

@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

@property (strong, nonatomic) NSString *message;
@property (nonatomic) MZSnackBarType type;

@property (nonatomic) CGFloat waitingDurationForDisappear;
@property (nonatomic) CGFloat duration;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)animateToAppearInView:(UIView *)view;
- (void)animateToDisappearWithCompletion:(MZSnackBarAnimationCompletion)completion;

@end
