//
//  AddLectureViewController.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 14..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddLectureViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSDictionary *lectureDictionary;



#warning 지워야할 주석
/*
 
 수업을 저장하기 위한 RealmObject
 
 NSInteger ulid : 고유 ID
 RLMArray<LectureDetailObject> *lectureDetails : 강의(parent) - 수업(child) <To Many>
 NSString *lectureName : 강의명
 NSString *theme : 시계 색깔 (테마)
 
 */

- (instancetype)init;
- (void)addLectureDetailAction;

@end
