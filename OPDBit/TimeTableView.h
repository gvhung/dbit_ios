//
//  TimeTableView.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeTableObject;

@interface TimeTableView : UIView

@property (strong, nonatomic) TimeTableObject *timetable;

- (instancetype)initWithFrame:(CGRect)frame timetable:(TimeTableObject *)timetable;
- (instancetype)initWithFrame:(CGRect)frame;

- (void)drawLines;

@end
