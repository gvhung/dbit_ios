//
//  SearchLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddLectureViewController.h"

@interface SearchLectureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) AddLectureViewController *delegate;

@property (nonatomic, strong) NSArray *serverLectures;

@property (nonatomic, strong) UITableView *tableView;

- (instancetype)init;

@end
