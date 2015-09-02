//
//  ShowLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 6. 18..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ServerLectureObject;
@class TimeTableObject;

@interface ShowLectureViewController : UIViewController

@property (nonatomic, strong) ServerLectureObject *serverLecture;
@property (nonatomic, strong) TimeTableObject *activedTimeTable;

- (id)init;
- (instancetype)initWithServerLecture:(ServerLectureObject *)serverLecture;

@end
