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
 BOOL downloaded : 다운로드 여부 (갱신할때 downloaded:true는 건드리면 안됨)
 
 - (NSString *)getSemesterString : 학기 뷰에 표시할 때 사용 (ex 2015년 1학기)
 
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
@property BOOL downloaded;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ServerTimeTableObject>
RLM_ARRAY_TYPE(ServerTimeTableObject)
