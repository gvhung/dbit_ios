//
//  TimeTableView.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeTableObject;
@class ServerLectureObject;

@interface TimeTableView : UIView

@property (strong, nonatomic) TimeTableObject *timetable;
@property (nonatomic, strong) ServerLectureObject *serverLecture;

- (instancetype)initWithFrame:(CGRect)frame timetable:(TimeTableObject *)timetable serverLecture:(ServerLectureObject *)serverLecture theme:(NSInteger)theme;
- (instancetype)initWithFrame:(CGRect)frame timetable:(TimeTableObject *)timetable;
- (instancetype)initWithFrame:(CGRect)frame;

- (void)drawLines;

@end
