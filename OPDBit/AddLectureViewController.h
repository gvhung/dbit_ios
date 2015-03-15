//
//  AddLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RMDateSelectionViewController/RMDateSelectionViewController.h>

@interface AddLectureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, RMDateSelectionViewControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *serverLectureDictionary;
@property (nonatomic, strong) NSMutableDictionary *lectureDictionary;
@property (nonatomic, strong) NSArray *lectureDetails;

@property (nonatomic, strong) RMDateSelectionViewController *timePickerViewController;

- (instancetype)init;
- (void)addLectureDetailAction;

- (void)textFieldDidChanged:(UITextField *)textField;
- (void)timeButtonTapped:(UIButton *)button;

@end
