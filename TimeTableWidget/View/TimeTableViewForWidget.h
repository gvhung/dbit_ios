//
//  TimeTableViewForWidget.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 8. 24..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeTableViewForWidget : UIView

@property (strong, nonatomic) NSDictionary *timetableForWidget;

- (instancetype)initForWidgetWithFrame:(CGRect)frame timetable:(NSDictionary *)timetable;

- (void)initializeProperty;
- (void)drawTimeTableLines;
- (void)drawLectureDetailView;

@end
