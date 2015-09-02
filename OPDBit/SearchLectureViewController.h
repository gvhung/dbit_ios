//
//  SearchLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

@class SearchLectureViewController;
@class ServerSemesterObject;
@class LectureObject;

#import "ShowLectureViewController.h"

#import <UIKit/UIKit.h>
#import <Realm/Realm.h>

@interface SearchLectureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) id<ShowLectureViewControllerDelegate> delegate;

@property (nonatomic, strong) ServerSemesterObject *serverSemester;
@property (nonatomic, strong) LectureObject *currentLecture;
@property (nonatomic, strong) UITableView *tableView;

- (instancetype)initWithLecture:(LectureObject *)lecture;

@end
