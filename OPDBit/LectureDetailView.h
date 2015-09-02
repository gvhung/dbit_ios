//
//  LectureDetailView.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 4. 2..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LectureDetailViewType) {
    LectureDetailViewTypeApp = 0,
    LectureDetailViewTypeWidget,
    LectureDetailViewTypeServerLecture // 뒤에 은은하게 퍼지는 애니메이션을 주기위해서
};

@interface LectureDetailView : UIView

@property (nonatomic) BOOL selectedLectureDetail;

@property (nonatomic) LectureDetailViewType type;
@property (nonatomic) NSInteger theme;
@property (nonatomic, strong) NSString *lectureName;
@property (nonatomic, strong) NSString *lectureLocation;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame theme:(NSInteger)theme lectureName:(NSString *)lectureName lectureLocation:(NSString *)lectureLocation type:(LectureDetailViewType)type;

@end
