//
//  ShowTimeTableViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeTableObject;

@interface ShowTimeTableViewController : UIViewController

@property (nonatomic, strong) TimeTableObject *activedTimeTable;

- (id)init;

@end
