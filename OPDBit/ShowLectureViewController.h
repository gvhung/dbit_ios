//
//  ShowLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 6. 18..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShowLectureViewController;
@class ServerLectureObject;
@class TimeTableObject;

@protocol ShowLectureViewControllerDelegate <NSObject>

- (void)showLectureViewController:(ShowLectureViewController *)searchLectureViewController didDoneWithLectureObject:(LectureObject *)lectureObject;

@end

@interface ShowLectureViewController : UIViewController

@property (weak, nonatomic) id<ShowLectureViewControllerDelegate> delegate;

@property (strong, nonatomic) ServerLectureObject *serverLecture;
@property (strong, nonatomic) TimeTableObject *activedTimeTable;
@property (strong, nonatomic) LectureObject *currentLecture;

- (id)init;
- (instancetype)initWithServerLecture:(ServerLectureObject *)serverLecture currentLecture:(LectureObject *)currentLecture;

@end
