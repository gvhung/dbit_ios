//
//  AddTimeTableViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class TimeTableObject;

#import <UIKit/UIKit.h>

@interface AddTimeTableViewController : UIViewController

@property (nonatomic, strong) TimeTableObject *timeTable;

- (instancetype)init;

@end
