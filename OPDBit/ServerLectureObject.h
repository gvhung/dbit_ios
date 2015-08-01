//
//  ServerLectureObject.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Realm/Realm.h>

/*
 
 서버 강의를 저장하기 위한 RealmObject
 
 NSInteger timeTableId : 시간표 id
 NSString *lectureProf : 교수님
 NSString *lectureCode : 학수번호
 NSString *lectureName : 강의명
 NSString *lectureLocation : 강의실
 NSString *lectureDaytime : 강의요일 / 강의시간
 
 */
static NSString * const ServerLectureObjectID  = @"ServerLectureObject";

@interface ServerLectureObject : RLMObject

@property NSInteger semesterID;
@property NSString *lectureName;
@property NSString *lectureKey;    // lectureCode 학수번호
@property NSString *lectureProf;
@property NSString *lectureLocation;
@property NSString *lectureDaytime;

// Addtional Meta Data
@property NSString *lectureCourse;
@property NSString *lectureType;
@property NSString *lectureEtc;
@property NSString *lectureLanguage;
@property NSInteger lecturePoint;
@property NSInteger serverLectureID;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ServerLectureObject>
RLM_ARRAY_TYPE(ServerLectureObject)
