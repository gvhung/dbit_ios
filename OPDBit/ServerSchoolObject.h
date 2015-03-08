//
//  ServerSchoolObject.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Realm/Realm.h>

/*
 
 서버 학교 정보를 저장하기 위한 RealmObject
 
 NSInteger schoolId : 학교 id
 NSString *schoolName : 학교 이름
 
 */

@interface ServerSchoolObject : RLMObject

@property NSInteger schoolId;
@property NSString *schoolName;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ServerSchoolObject>
RLM_ARRAY_TYPE(ServerSchoolObject)
