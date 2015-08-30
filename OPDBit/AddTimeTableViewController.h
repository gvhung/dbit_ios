//
//  AddTimeTableViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class TimeTableObject;
@class AddTimeTableViewController;

#import <UIKit/UIKit.h>

@protocol AddTimeTableViewControllerDelegate <NSObject>

- (void)addTimeTableViewController:(AddTimeTableViewController *)addTimeTableViewController didDoneWithIsModifying:(BOOL)isModifying;

@end

@interface AddTimeTableViewController : UIViewController

@property (nonatomic, weak) id<AddTimeTableViewControllerDelegate> delegate;
@property (nonatomic, strong) TimeTableObject *timeTable;

- (instancetype)init;

@end
