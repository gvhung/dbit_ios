//
//  LectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HMSegmentedControl/HMSegmentedControl.h>


@interface LectureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) HMSegmentedControl *daySegmentedControl;

@property (nonatomic, strong) UITableView *lectureTableView;

@property (nonatomic, strong) NSArray *lectureDetails;

- (instancetype)init;

@end
