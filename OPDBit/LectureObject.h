//
//  LectureObject.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Realm/Realm.h>
#import "LectureDetailObject.h"


/**
 * 수업을 저장하기 위한 RealmObject
 *
 * @param   ulid 강의 고유 ID (NSInteger)
 * @param   lectureDetails  강의(parent) - 수업(child) <To Many> (RLMArray<LectureDetailObject> *)
 * @param   lectureName 강의명 (NSString *)
 * @param   theme   시계 색깔 (테마) (NSString *)
 */

@interface LectureObject : RLMObject

@property NSInteger ulid;
@property RLMArray<LectureDetailObject> *lectureDetails;
@property NSString *lectureName;

@property NSString *theme;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<LectureObject>
RLM_ARRAY_TYPE(LectureObject)
