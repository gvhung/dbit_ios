//
//  ServerTimeTableObject.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Realm/Realm.h>

/*
 
 서버 시간표 정보를 저장하기 위한 RealmObject
 
 NSInteger timeTableId : 시간표 id
 NSInteger schoolId : 학교 id
 NSString *semester : 학기 (ex 2015-01)
 NSDate *updatedAt : 서버 최종 업데이트 시간
 NSDate *checkedAt : 유저 최종 확인 시간
 
 */

/**
 *  
 *
 */

@interface ServerTimeTableObject : RLMObject

@property NSInteger timeTableId;
@property NSInteger schoolId;
@property NSString *semester;
@property NSDate *updatedAt;
@property NSDate *checkedAt;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ServerTimeTableObject>
RLM_ARRAY_TYPE(ServerTimeTableObject)
