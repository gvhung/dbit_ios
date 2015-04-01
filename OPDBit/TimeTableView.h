//
//  TimeTableView.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeTableView : UIView

/**
 *  Section Titles
 */
@property (nonatomic, strong) NSArray *sectionTitles;

@property (nonatomic, strong) NSArray *lectureDetails;

@property (nonatomic) NSInteger timeStart;
@property (nonatomic) NSInteger timeEnd;

- (id)initWithFrame:(CGRect)frame lectureDetails:(NSArray *)lectureDetails sectionTitles:(NSArray *)sectionTitles timeStart:(NSInteger)timeStart timeEnd:(NSInteger)timeEnd;
- (id)initWithFrame:(CGRect)frame;

@end
