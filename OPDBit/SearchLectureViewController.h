//
//  SearchLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class SearchLectureViewController;
@class ServerSemesterObject;
@class ServerLectureObject;

#import <UIKit/UIKit.h>

@protocol SearchLectureViewControllerDelegate <NSObject>

- (void)searchLectureViewController:(SearchLectureViewController *)searchLectureViewController didDoneWithServerLectureObject:(ServerLectureObject *)serverLectureObject;

@end

@interface SearchLectureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<SearchLectureViewControllerDelegate> delegate;

@property (nonatomic, strong) ServerSemesterObject *serverSemester;
@property (nonatomic, strong) UITableView *tableView;

- (instancetype)init;

@end
