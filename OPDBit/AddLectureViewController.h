//
//  AddLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class LectureObject;
@class AddLectureViewController;
@class MZTimePickerView;

#import <UIKit/UIKit.h>
#import <HMSegmentedControl/HMSegmentedControl.h>

@protocol AddLectureViewControllerDelegate <NSObject>

- (void)addLectureViewControllerDidDone:(AddLectureViewController *)addLectureViewController isModfiying:(BOOL)isModifying;

@end

@interface AddLectureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<AddLectureViewControllerDelegate> delegate;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) LectureObject *lecture;

@property (nonatomic, strong) MZTimePickerView *timePickerView;

- (instancetype)init;

@end
