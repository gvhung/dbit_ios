//
//  MZTimePickerView.h
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 29..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MZTimePickerView;

typedef NS_ENUM(NSInteger, MZTimePickerType) {
    MZTimePickerTypeStart,
    MZTimePickerTypeEnd
};

typedef void (^MZTimePickerAnimationHandler) (BOOL finished);

@protocol MZTimePickerDelegate <NSObject>

- (void)timePickerView:(MZTimePickerView *)timePickerView doneWithTime:(NSDate *)newDate;
- (void)timePickerViewDidCanceled:(MZTimePickerView *)timePickerView;
- (void)timePickerView:(MZTimePickerView *)timePickerView didChangedTime:(NSDate *)newDate;

@end

@interface MZTimePickerView : UIView

@property (nonatomic) MZTimePickerType type;
@property (nonatomic) BOOL isAnimating;

@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIToolbar *toolbar;

@property (strong, nonatomic) UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;

@property (weak, nonatomic) id<MZTimePickerDelegate> delegate;

- (void)animateToAppear;
- (void)animateToDisappearWithCompletion:(MZTimePickerAnimationHandler)completion;
- (void)setType:(MZTimePickerType)type startTime:(NSDate *)startDate endTime:(NSDate *)endDate;

@end
