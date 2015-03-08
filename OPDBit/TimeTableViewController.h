//
//  TimeTableViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

- (instancetype)init;

@end
