//
//  MZTimePickerView.m
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 29..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#define CGRectSetY(rect, newY) CGRectMake(rect.origin.x, newY, rect.size.width, rect.size.height)

#import "MZTimePickerView.h"

#import "UIColor+OPTheme.h"

@interface MZTimePickerView ()

@property (nonatomic, strong) NSDate *selectedTime;

@end

@implementation MZTimePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,
                                                                     self.bounds.size.height - UIDatePickerDefaultHeight,
                                                                     self.bounds.size.width,
                                                                     UIDatePickerDefaultHeight)];
        [_datePicker addTarget:self
                        action:@selector(datePickerValueChanged:)
              forControlEvents:UIControlEventValueChanged];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        _datePicker.timeZone = [NSTimeZone systemTimeZone];
        _datePicker.minuteInterval = 5;
        
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                               self.datePicker.frame.origin.y - MZTimePickerToolbarHeight,
                                                               self.bounds.size.width,
                                                               MZTimePickerToolbarHeight)];
        [_toolbar setBarTintColor:[UIColor op_primary]];
        _cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"취소"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(cancelToTimePick:)];
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"완료"
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(doneToTimePick:)];
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _toolbar.items = @[_cancelButton, flexibleItem, _doneButton];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelToTimePick:)];
        UITapGestureRecognizer *minuteIntervalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeMinuteInterval:)];
        minuteIntervalTap.numberOfTapsRequired = 2;
        [_datePicker addGestureRecognizer:minuteIntervalTap];
        
        self.backgroundColor = [UIColor clearColor];
        [self addGestureRecognizer:tap];
        
        [self addSubview:_datePicker];
        [self addSubview:_toolbar];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    _datePicker.frame = CGRectMake(0,
                                   self.frame.size.height - UIDatePickerDefaultHeight,
                                   self.frame.size.width,
                                   UIDatePickerDefaultHeight);
    _toolbar.frame = CGRectMake(0,
                                self.datePicker.frame.origin.y - MZTimePickerToolbarHeight,
                                self.frame.size.width,
                                MZTimePickerToolbarHeight);
}

- (void)animateToAppear
{
    _isAnimating = YES;
    _toolbar.frame = CGRectSetY(_toolbar.frame, self.frame.size.height);
    _datePicker.frame = CGRectSetY(_datePicker.frame, self.frame.size.height + MZTimePickerToolbarHeight);
    [UIView animateWithDuration:0.3f animations:^{
        _datePicker.frame = CGRectSetY(_datePicker.frame, self.frame.size.height - _datePicker.frame.size.height);
        _toolbar.frame = CGRectSetY(_toolbar.frame, _datePicker.frame.origin.y - MZTimePickerToolbarHeight);
    } completion:^(BOOL finished) {
        _isAnimating = NO;
    }];
}

- (void)animateToDisappearWithCompletion:(MZTimePickerAnimationHandler)completion
{
    _isAnimating = YES;
    [UIView animateWithDuration:0.3f animations:^{
        _toolbar.frame = CGRectSetY(_toolbar.frame, self.frame.size.height);
        _datePicker.frame = CGRectSetY(_datePicker.frame, self.frame.size.height + MZTimePickerToolbarHeight);
    } completion:^(BOOL finished) {
        _isAnimating = NO;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)datePickerValueChanged:(UIDatePicker *)datePicker
{
    _selectedTime = datePicker.date;
    if ([_delegate respondsToSelector:@selector(timePickerView:didChangedTime:)]) {
        [_delegate timePickerView:self didChangedTime:datePicker.date];
    }
}

- (void)cancelToTimePick:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        UITapGestureRecognizer *gestureRecognizer = sender;
        UIView *view = gestureRecognizer.view;
        CGPoint location = [gestureRecognizer locationInView:view];
        UIView *subview = [view hitTest:location withEvent:nil];
        if (subview == self) {
            if ([_delegate respondsToSelector:@selector(timePickerViewDidCanceled:)]) {
                [_delegate timePickerViewDidCanceled:self];
            }
        }
    } else {
        if ([_delegate respondsToSelector:@selector(timePickerViewDidCanceled:)]) {
            [_delegate timePickerViewDidCanceled:self];
        }
    }
}

- (void)doneToTimePick:(UIBarButtonItem *)sender
{
    if ([_delegate respondsToSelector:@selector(timePickerView:doneWithTime:)]) {
        [_delegate timePickerView:self doneWithTime:_selectedTime];
    }
}

- (void)setType:(MZTimePickerType)type
{
    _type = type;
}

- (void)setType:(MZTimePickerType)type startTime:(NSDate *)startDate endTime:(NSDate *)endDate lectureDetailIndex:(NSInteger)lectureDetailIndex
{
    _type = type;
    _lectureDetailIndex = lectureDetailIndex;
    
    _datePicker.timeZone = [NSTimeZone systemTimeZone];
    
    if (type == MZTimePickerTypeStart) {
        if (!startDate) {
            [self datePickerValueChanged:_datePicker];
        } else {
            _selectedTime = startDate;
            _datePicker.date = _selectedTime;
        }
    }
    else {
        if (!endDate) {
            [self datePickerValueChanged:_datePicker];
        } else {
            _selectedTime = endDate;
            _datePicker.date = _selectedTime;
        }
    }
}

- (void)changeMinuteInterval:(UITapGestureRecognizer *)gestureRecognizer
{
    if (_datePicker.minuteInterval == 5) {
        _datePicker.minuteInterval = 1;
    } else {
        _datePicker.minuteInterval = 5;
    }
}

@end
