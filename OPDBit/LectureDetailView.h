//
//  LectureDetailView.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LectureDetailView : UIView

@property (nonatomic) BOOL selectedLectureDetail;

@property (nonatomic) NSInteger theme;
@property (nonatomic, strong) NSString *lectureName;
@property (nonatomic, strong) NSString *lectureLocation;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame theme:(NSInteger)theme lectureName:(NSString *)lectureName lectureLocation:(NSString *)lectureLocation;

@end