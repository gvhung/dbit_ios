//
//  LectureDetailObject.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Realm/Realm.h>

@class LectureObject;

/*
 
 강의를 저장하기 위한 RealmObject
 
 NSString *lectureLocation : 강의실
 NSInteger timeStart : 시작 시간을 저장하는 용도 (HHmm)
 NSInteger timeEnd : 끝나는 시간을 저장하는 용도 (HHmm)
 NSInteger day : 수업 요일을 저장하기 위한 용도 (0~6 : 월~일)
 
 */

static NSString * const LectureDetailObjectID = @"LectureDetailObject";

@interface LectureDetailObject : RLMObject

@property NSInteger ulid;

@property NSString *lectureLocation;
@property NSInteger timeStart;
@property NSInteger timeEnd;
@property NSInteger day;

- (void)setDefaultProperties;
- (LectureObject *)lecture;
- (BOOL)isContainedWithUtid:(NSInteger)utid;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<LectureDetailObject>
RLM_ARRAY_TYPE(LectureDetailObject)
