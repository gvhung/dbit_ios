//
//  LocalDataObject.h
//  OPDBit
//
//  Created by Kweon Min Jun on 2015. 3. 8..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import <Realm/Realm.h>

/*
 
 Local Resource Data (ex. 색)를 저장하기 위한 RealmObject
 
 NSInteger order : 순서 (정렬할 순서)
 NSString type : 데이터 종류 (색, 기타 등등)
 NSString *key : Key
 NSString value : Value (색의 경우 #FFFFFF)
 
 */

@interface LocalDataObject : RLMObject


@end

// This protocol enables typed collections. i.e.:
// RLMArray<LocalDataObject>
RLM_ARRAY_TYPE(LocalDataObject)
