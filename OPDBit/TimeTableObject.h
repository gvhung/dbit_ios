//
//  TimeTableObject.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Realm/Realm.h>
#import "LectureObject.h"
#import "ServerSemesterObject.h"

/*
 
 시간표를 저장하기 위한 RealmObject
 
 NSInteger utid : 시간표 고유 ID
 NSString *timeTableName : 시간표명
 NSInteger serverId : 연동된 서버 시간표 ID
 NSInteger timeStart : 시간표 시작 시간을 저장하는 용도 (HHmm)
 NSInteger timeEnd : 시간표 끝나는 시간을 저장하는 용도 (HHmm)
 
 RLMArray<LectureObject> *lectures : 시간표(parent) - 수업(child) <To Many>
 BOOL active : 시간표 활성화 여부
 
 # 시간표에 표시할 요일을 저장하기 위한 용도
 BOOL mon : 월요일
 BOOL tue : 화요일
 BOOL wed : 수요일
 BOOL thu : 목요일
 BOOL fri : 금요일
 BOOL sat : 토요일
 BOOL sun : 일요일
 
 */

/**
 *  Realm Array를 초기화할 때 사용할 키입니다.
 */
static NSString * const TimeTableObjectID = @"TimeTableObject";


/**
 *  TimeTable을 감싸는 모델입니다.
 *  properties : utid, timeTableName, timeStart, timeEnd, active, workAtWeekend, serverSemesterObject, lectures
 */
@interface TimeTableObject : RLMObject

/**
 *  TimeTable의 고유 ID입니다.
 */
@property NSInteger utid;
@property NSString *timeTableName;
@property NSInteger timeStart;
@property NSInteger timeEnd;
@property BOOL active;
@property BOOL workAtWeekend;

@property ServerSemesterObject *serverSemesterObject;
@property RLMArray<LectureObject> *lectures;

- (void)setDefaultProperties;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<TimeTableObject>
RLM_ARRAY_TYPE(TimeTableObject)
