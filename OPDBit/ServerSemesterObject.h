//
//  ServerSemesterObject.h
//  OPDBit
//
//  Created by 1000732 on 2015. 7. 26..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

#import "RLMObject.h"

static NSString * const ServerSemesterObjectID = @"ServerSemesterObject";

@interface ServerSemesterObject : RLMObject

@property NSInteger semesterVersion;
@property NSInteger semesterID;
@property NSString *semesterKey;
@property NSString *semesterName;

@end

// This protocol enables typed collections. i.e.:
// RLMArray<ServerLectureObject>
RLM_ARRAY_TYPE(ServerLectureObject)